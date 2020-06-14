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


