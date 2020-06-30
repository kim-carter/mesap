@intermediate
hisat_align =  {
	doc "Align reads to reference using Hisat2"
	output.dir = "/OUTPUT/alignments"

	def outbam = output.prefix+".bam"
	def outreport = output.prefix+".summary.txt"

	if (input.input.size==2)
	{
        	//paired mode
		produce($outbam,$outreport)
        {
	        exec """
        	        $HISAT2 --dta --known-splicesite-infile $SPLICE -p $threads -x $INDEX  --no-unal --new-summary --summary-file $outreport  -1 $input1 -2 $input2  | $SAMTOOLS sort -@ $threads -O bam -o $outbam  -
	        """
        }
	}
	else
	{
		//single-end mode
        produce($outbam,$outreport)
        {
	        exec """
			    $HISAT2 --dta --known-splicesite-infile $SPLICE -p $threads -x $INDEX  --no-unal  --new-summary --summary-file $outreport  -U $input1   | $SAMTOOLS sort -@ $threads -O bam -o $outbam  -		
			"""
		}
	}

}


@intermediate
stringtie = {
	output.dir = "/OUTPUT/assembly"
	transform("gtf") {
	exec """
		$STRINGTIE -p $threads $input.bam -o $output -G $GTF
	"""
	}
}


@intermediate
makeassemblylist = {
	output.dir="/OUTPUT/assembly"
	doc "Makes a list of all assemblies for merging"

	produce ("merged.txt")
	{
	exec """
	find assembly -name '*.gtf'  > $output
	"""
	}
}


@intermediate
stringtiemerge = {
	output.dir="/OUTPUT/merged_asm"
	produce ("stringtiemerged.gtf")
	{
	exec """
		$STRINGTIE --merge -G $GTF -p $threads /OUTPUT/assembly/merged.txt -o $MERGED_TRANSCRIPTS
	"""
	}
}


@intermediate
stringtiequant = {
    def target0 =output.prefix.prefix
	def target1 =output.prefix.prefix+".bam"
    def target2 =output.prefix.prefix.prefix + ".gtf"
    def target3 =output.prefix.prefix.prefix + "cov_refs.gtf"

	output.dir="/OUTPUT/alignments"
 
        def outputs = [
                ("/OUTPUT/alignments/$target0/" + "e2t.ctab")
        ]
        produce(outputs)
        {
        exec  """
                $STRINGTIE -p $threads  -G $MERGED_TRANSCRIPTS -e -b /OUTPUT/alignments/$target0 -o /OUTPUT/alignments/$target2 -C /OUTPUT/alignments/$target3 /OUTPUT/alignments/$target1 
        """
        }
}


make_ballgown_obj = {
	output.dir = "/OUTPUT/"
	produce("bg.rda")
	{
		exec """
		$GLUE_4_BALLGOWN
		"""
	}
}

make_gene_counts_human = {
	output.dir = "/OUTPUT/"
	produce("genecounts.txt")
	{
	exec """
	export THREAD=$threads; R --no-save < /mesap/scripts/gene_counts_human.R; perl /mesap/scripts/convert_gencode_genecounts.pl /OUTPUT/tmpcounts.csv $HUMAN_ENSMAP /OUTPUT/genecounts.txt; rm /OUTPUT/tmpcounts.csv
	"""
	}
}

make_gene_counts_mouse = {
	output.dir = "/OUTPUT/"
	produce("genecounts.txt")
	{
	exec """
	export THREAD=$threads; R --no-save < /mesap/scripts/gene_counts_mouse.R; perl /mesap/scripts/convert_gencode_genecounts.pl /OUTPUT/tmpcounts.csv $MOUSE_ENSMAP /OUTPUT/genecounts.txt; rm /OUTPUT/tmpcounts.csv

	"""
	}
}

make_gene_counts_rat = {
	output.dir = "/OUTPUT/"
	produce("genecounts.txt")
	{
	exec """
	export THREAD=$threads; R --no-save < /mesap/scripts/gene_counts_rat.R; perl /mesap/scripts/convert_gencode_genecounts.pl /OUTPUT/tmpcounts.csv $RAT_ENSMAP /OUTPUT/genecounts.txt; rm /OUTPUT/tmpcounts.csv
	"""
	}
}

make_transcript_expression = {
	output.dir = "/OUTPUT/"
	produce("transcript_expression.txt")
	{
	exec """
       	R --no-save < /mesap/scripts/get_transcript_expression.R
	"""
	}
}

def get_sample_filename_nopath_withextension(filename)
{

  def returned_value = ""

  // strip path
  def m = filename.split("/")[-1]

  return m
}

def get_filepath(filename)
{

  def returned_value = ""

  def i = filename.lastIndexOf("/")
  def m = filename.substring(0,i)

  //return filepath
  return m
}

samstat = {
    output.dir = "/OUTPUT/qc"
	
	doc "Run Samstat over .bam alignments"
	transform (".bam") to (".bam.samstat.html")
	{
			// from here forces bpipe to look back and find .bam inputs
			from("bam") {
			exec """
			$SAMSTAT $input1 
			"""
			}
	}
}

samstat_parser = {
    output.dir = "/OUTPUT/qc"

	def path = get_filepath("$input1")

        doc "Run samstat_parser to summarise ouput across all files"
        produce ("samstat_summary.txt")
        {
                exec "perl /mesap/scripts/samstat_parser.pl /OUTPUT/qc/ > /OUTPUT/qc/samstat_summary.txt"
        }
}

samstat_summarise = {
        output.dir = "/OUTPUT/qc"

        doc "Run samstat to summarise ouput across all files"
        produce ("samstat_results_summary.csv")
        {
                exec "python3 /mesap/scripts/samstat_parse_summaries.py"
        }
}

multiqc = {
    output.dir = "/OUTPUT/qc"
	
	doc "Run multiqc to summarise output across all files"

	produce ("multiqc_report.html")
	{
		exec "$MULTIQC /OUTPUT/qc/ /OUTPUT/alignments/ -o $output.dir" 
	}
}

def get_sample_filename_nopath_noextension(filename)
{

  def returned_value = ""

  // strip path
  def m = filename.split("/")[-1]

  //return first part of file name irrespective of extensions (s)
  return m.split("\\.")[0]
}

@intermediate
fastqc = {
    output.dir = "/OUTPUT/qc"
	
	doc "Run fastqc to QC fastQ file"

	def filename = get_sample_filename_nopath_noextension("$input1")

	produce (filename+"_fastqc.zip",filename+"_fastqc.html")
	{
		exec "$FASTQC -o $output.dir $input1" 
	}
}

fastqc_parser = {
	output.dir = "/OUTPUT/qc"

	doc "Run fastqc_parser to summarise ouput across all files"
	produce ("fastqc_summary.txt")
	{
			exec "perl /mesap/scripts/fastqc_parser.pl /OUTPUT/qc/ > /OUTPUT/qc/fastqc_summary.txt"
	}
}


check_output = {
    doc "Checking output dir exists "	
	outdir = new File("/OUTPUT");
    if (outdir.exists())
	{
		// check if we have write access
		if(outdir.canWrite())
		{
  			// write access, so move forward
		}
		else
		{
  			// no write access
			fail "Can't write to /OUTPUT directory. Please check permissions and try again"
		}
		// exists, so move forward	
    }
    else
	{
     	fail "Can't find /OUTPUT directory.  Please check it is mapped correctly and try again"
	}

}

check_input = {
	doc "Check input"
	indir = new File("/INPUT");
	if (indir.exists())
	{
		if (input.input.size==0)
		{
			// no input files specified, so look for anything matching our default pattern
			input = glob("/INPUT/%_R*.fastq.gz")
		}
			// exists, so move forward      
	}
	else
	{
		fail "Can't find /INPUT directory.  Please check it is mapped correctly and try again"
	}

	forward(input)
}
