load "localprograms.groovy"
load "localdatafiles.groovy"
load "/mesap/modules/RNAseq.groovy"

INDEX=System.getenv("HUMAN_INDEX")
GENOME=System.getenv("HUMAN_GENOME")
GTF=System.getenv("HUMAN_GTF")
SPLICE=System.getenv("HUMAN_SPLICE")
EXON=System.getenv("HUMAN_EXON")



Bpipe.run {check_input + check_output + "%_R*.fastq.gz"  * [ hisat_align + stringtie] + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj + make_gene_counts_human + make_transcript_expression}
