load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/RNAseq.groovy"

INDEX=HUMAN_INDEX
GENOME=HUMAN_GENOME
GTF=HUMAN_GTF
SPLICE=HUMAN_SPLICE
EXON=HUMAN_EXON



Bpipe.run {"%_R*.fastq.gz" * [ fastqc ] + fastqc_parser + "%_R*.fastq.gz" * [ hisat_align + stringtie + samstat] + samstat_parser + samstat_summarise + multiqc + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj  + make_gene_counts_human + make_transcript_expression}


