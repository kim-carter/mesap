load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/RNAseq.groovy"

HISATINDEX=HISAT2RN6
GENOME=GENOMERN6

KNOWNTRANSCRIPTS=ENSEMBL87_RN6
KNOWNSPLICESITES=ENSEMBL87_RN6_SPLICESITES

MERGED_TRANSCRIPTS = "merged_asm/stringtiemerged.gtf"

Bpipe.run {"%_R*.fastq.gz"  * [ hisat_align + stringtie]  + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj  + make_gene_counts_rat}
