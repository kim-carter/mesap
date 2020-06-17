load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/RNAseq.groovy"

INDEX=RAT_INDEX
GENOME=RAT_GENOME
GTF=RAT_GTF
SPLICE=RAT_SPLICE
EXON=RAT_EXON


MERGED_TRANSCRIPTS = "merged_asm/stringtiemerged.gtf"

Bpipe.run {"%_R*.fastq.gz" * [ fastqc ] + fastqc_parser + "%_R*.fastq.gz" * [ hisat_align + stringtie + samstat] + samstat_parser + samstat_summarise + multiqc + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj  + make_gene_counts_rat + make_transcript_expression}


