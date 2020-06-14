load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/RNAseq.groovy"

INDEX=MOUSE_INDEX
GENOME=MOUSE_GENOME
GTF=MOUSE_GTF
SPLICE=MOUSE_SPLICE
EXON=MOUSE_EXON


MERGED_TRANSCRIPTS = "merged_asm/stringtiemerged.gtf"

Bpipe.run {"%_R*.fastq.gz"  * [ hisat_align + stringtie]  + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj  + make_gene_counts_mouse + make_transcript_expression}

