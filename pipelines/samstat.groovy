
about title: "SAMStat pipeline."
def BASEROOTDIR="/mesap"

def SAMSTAT = "samstat"

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


run_samstat = {
        output.dir = "/OUTPUT/qc"
	
	doc "Run Samstat over .bam alignments"

	transform (".bam") to (".bam.samstat.html")
	{
		exec """
		$SAMSTAT $input1 
		"""
	}
}

run_samstat_parser = {
        output.dir = "/OUTPUT/qc"

	def path = get_filepath("$input1")

        doc "Run samstat_parser to summarise ouput across all files"
        produce ("samstat_summary.txt")
        {
                exec "perl $BASEROOTDIR/scripts/samstat_parser.pl $path > /OUTPUT/qc/samstat_summary.txt"
        }
}


run_samstat_summarise = {
        output.dir = "/OUTPUT/qc"

	doc "Run samstat to summarise ouput across all files"
        produce ("samstat_results_summary.csv")
        {
                exec "python3 /mesap/scripts/samstat_parse_summaries.py"
        }
}


Bpipe.run { "%.[bs]am" * [run_samstat] + run_samstat_parser }
