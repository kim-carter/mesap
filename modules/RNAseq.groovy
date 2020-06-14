@intermediate
hisat_align =  {
        doc "Align reads to reference using Hisat2"
        output.dir = "alignments"

	if (input.input.size==2)
	{
        	//paired mode
		transform("bam")
        	{
	        exec """
        	        $HISAT2 --dta --known-splicesite-infile $SPLICE -p $threads -x $INDEX  -1 $input1 -2 $input2  | $SAMTOOLS sort -@ $threads -O bam -o ${output(output.prefix+".bam")}  -
	        """
        	}
	}
	else
	{
		//single-end mode
                transform("bam")
                {
	                exec """
			        $HISAT2 --dta --known-splicesite-infile $SPLICE -p $threads -x $INDEX  -U $input1   | $SAMTOOLS sort -@ $threads -O bam -o ${output(output.prefix+".bam")}  -		
			"""
		}
	}

}


@intermediate
stringtie = {
	output.dir = "assembly"
	transform("gtf") {
	exec """
		$STRINGTIE -p $threads $input.bam -o $output -G $GTF
	"""
	}
}


@intermediate
makeassemblylist = {
	output.dir="assembly"
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
	output.dir="merged_asm"
        produce ("stringtiemerged.gtf")
	{
	exec """
		$STRINGTIE --merge -G $GTF -p $threads assembly/merged.txt -o $MERGED_TRANSCRIPTS
	"""
	}
}


@intermediate
stringtiequant = {
        def target0 =output.prefix.prefix
	def target1 =output.prefix.prefix+".bam"
        def target2 =output.prefix.prefix.prefix + ".gtf"
        def target3 =output.prefix.prefix.prefix + "cov_refs.gtf"

	output.dir="alignments"
 
        def outputs = [
                ("alignments/$target0/" + "e2t.ctab")
        ]
        produce(outputs)
        {
        exec  """
                $STRINGTIE -p $threads  -G $MERGED_TRANSCRIPTS -e -b alignments/$target0 -o alignments/$target2 -C alignments/$target3 alignments/$target1 
        """
        }
}


make_ballgown_obj = {
	produce("bg.rda")
	{
	exec """
	$GLUE_4_BALLGOWN
	"""
	}
}

make_gene_counts_human = {
        produce("genecounts.txt")
        {
        exec """
        R --no-save < /mesap/scripts/gene_counts_human.R; perl /mesap/scripts/convert_gencode_genecounts.pl /OUTPUT/tmpcounts.csv $HUMAN_ENSMAP /OUTPUT/genecounts.txt; rm /OUTPUT/tmpcounts.csv
        """
        }
}

make_gene_counts_mouse = {
        produce("genecounts.txt")
        {
        exec """
        R --no-save < /mesap/scripts/gene_counts_mouse.R; perl /mesap/scripts/convert_gencode_genecounts.pl /OUTPUT/tmpcounts.csv $MOUSE_ENSMAP /OUTPUT/genecounts.txt; rm /OUTPUT/tmpcounts.csv

        """
        }
}

make_gene_counts_rat = {
        produce("genecounts.txt")
        {
        exec """
	R --no-save < /mesap/scripts/gene_counts_rat.R; perl /mesap/scripts/convert_gencode_genecounts.pl /OUTPUT/tmpcounts.csv $RAT_ENSMAP /OUTPUT/genecounts.txt; rm /OUTPUT/tmpcounts.csv
	"""
	}
}

make_transcript_expression = {
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
    output.dir = "qc"
	
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
    output.dir = "qc"

	def path = get_filepath("$input1")

        doc "Run samstat_parser to summarise ouput across all files"
        produce ("samstat_summary.txt")
        {
                exec "perl /mesap/scripts/samstat_parser.pl /OUTPUT/qc/ > /OUTPUT/qc/samstat_summary.txt"
        }
}

samstat_summarise = {
        output.dir = "qc"

        doc "Run samstat to summarise ouput across all files"
        produce ("samstat_results_summary.csv")
        {
                exec "python3 /mesap/scripts/samstat_parse_summaries.py"
        }
}

multiqc = {
    output.dir = "qc"
	
	doc "Run multiqc to summarise output across all files"

	produce ("multiqc_report.html")
	{
		exec "$MULTIQC qc/ alignments/ -o $output.dir" 
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
    output.dir = "qc"
	
	doc "Run fastqc to QC fastQ file"

	def filename = get_sample_filename_nopath_noextension("$input1")

	produce (filename+"_fastqc.zip",filename+"_fastqc.html")
	{
		exec "$FASTQC -o $output.dir $input1" 
	}
}

fastqc_parser = {
        output.dir = "qc"

        doc "Run fastqc_parser to summarise ouput across all files"
        produce ("fastqc_summary.txt")
        {
                exec "perl /mesap/scripts/fastqc_parser.pl qc/ > qc/fastqc_summary.txt"
        }
}


