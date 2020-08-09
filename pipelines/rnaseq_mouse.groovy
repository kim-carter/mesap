load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/RNAseq.groovy"

INDEX=System.getenv("MOUSE_INDEX")
GENOME=System.getenv("MOUSE_GENOME")
GTF=System.getenv("MOUSE_GTF")
SPLICE=System.getenv("MOUSE_SPLICE")
EXON=System.getenv("MOUSE_EXON")




Bpipe.run {check_input + check_output + "%_R*.fastq.gz"  * [ hisat_align + stringtie]  + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj  + make_gene_counts_mouse + make_transcript_expression}

