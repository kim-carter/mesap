load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/RNAseq.groovy"

INDEX=System.getenv("RAT_INDEX")
GENOME=System.getenv("RAT_GENOME")
GTF=System.getenv("RAT_GTF")
SPLICE=System.getenv("RAT_SPLICE")
EXON=System.getenv("RAT_EXON")



Bpipe.run {check_input + check_output + "%_R*.fastq.gz"  * [ hisat_align + stringtie]  + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj  + make_gene_counts_rat + make_transcript_expression}
