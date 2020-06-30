
about title: "Multiqc pipeline."
def BASEROOTDIR="/mesap"

// software is install systemwide so no ned to path
def MULTIQC = "multiqc" 

// software will autodetect any useful files in qc dir
run_multiqc = {
    output.dir = "/OUTPUT/qc"
	
	doc "Run multiqc to summarise fastQC files"

	// Note this function is forced to run every time the pipeline is run, to ensure it finds any new files
	//produce ("multiqc_report.html")
	//{
		exec "$MULTIQC -f /OUTPUT/qc/ /OUTPUT/alignments/ -o $output.dir" 
	//}
}

Bpipe.run { run_fastqc }
