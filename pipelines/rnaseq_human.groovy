load "localprograms.groovy"
load "localdatafiles.groovy"
load "/mesap/modules/RNAseq.groovy"

INDEX=HUMAN_INDEX
GENOME=HUMAN_GENOME
GTF=HUMAN_GTF
SPLICE=HUMAN_SPLICE
EXON=HUMAN_EXON



Bpipe.run {"%_R*.fastq.gz"  * [ hisat_align + stringtie] + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj + make_gene_counts_human + make_transcript_expression}
