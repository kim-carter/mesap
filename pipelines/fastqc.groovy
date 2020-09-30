
about title: "FastQC pipeline."
def BASEROOTDIR="/mesap"

def FASTQC = "$BASEROOTDIR" + "/programs/FastQC/fastqc"

def get_sample_filename_nopath_noextension(filename)
{

  def returned_value = ""

  // strip path
  def m = filename.split("/")[-1]

  // added fix for if filenames have other "." characters (other than .fastq.gz which is assumed)
  def lastIndex = m.lastIndexOf(".");
  def secondLastIndex = lastIndex > 0 ? m.lastIndexOf(".", lastIndex - 1) : -1;
  if (secondLastIndex >= 0)
  {
  	def m2 = m.substring(0,secondLastIndex);
	return m2
  }
  else
  {
	//return first part of file name irrespective of extensions (s)
  	return m.split("\\.")[0]
  }
}


run_fastqc = {
        output.dir = "/OUTPUT/qc"
	
	doc "Run fastqc to QC fastQ file"

	def filename = get_sample_filename_nopath_noextension("$input1")

	produce (filename+"_fastqc.zip",filename+"_fastqc.html")
	{
		exec "$FASTQC -o $output.dir $input1" 
	}
}

run_fastqc_parser = {
        output.dir = "/OUTPUT/qc"

        doc "Run fastqc_parser to summarise ouput across all files"
        produce ("fastqc_summary.txt")
        {
                exec "perl /mesap/scripts/fastqc_parser.pl /OUTPUT/qc/ > /OUTPUT/qc/fastqc_summary.txt"
        }
}

Bpipe.run { "%.fastq%" * [run_fastqc] + run_fastqc_parser }
