
about title: "SAMStat pipeline."
def BASEROOTDIR="/mesap"

def SAMSTAT = "$BASEROOTDIR" + "/programs/samstat-1.5.2/src/samstat"

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
        output.dir = "qc"
	
	doc "Run Samstat over .bam alignments"

	transform (".bam") to (".bam.samstat.html")
	{
		exec """
		$SAMSTAT $input1 
		"""
	}
}

run_samstat_parser = {
        output.dir = "qc"

	def path = get_filepath("$input1")

        doc "Run samstat_parser to summarise ouput across all files"
        produce ("samstat_summary.txt")
        {
                exec "perl $BASEROOTDIR/scripts/samstat_parser.pl $path > qc/samstat_summary.txt"
        }
}

Bpipe.run { "%.[bs]am" * [run_samstat] + run_samstat_parser }
