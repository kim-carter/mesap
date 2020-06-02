
about title: "Multiqc pipeline."
def BASEROOTDIR="/mesap"

// software is install systemwide so no ned to path
def MULTIQC = "multiqc" 

// software will autodetect any useful files in qc dir
run_multiqc = {
        output.dir = "qc"
	
	doc "Run multiqc to summarise fastQC files"

	def indir = "qc"

	produce ("multiqc_report.html")
	{
		exec "$MULTIQC -o $output.dir" 
	}
}

Bpipe.run { run_fastqc }
