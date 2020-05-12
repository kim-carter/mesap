load "localprograms.groovy"
load "localdatafiles.groovy"
load "/mesap/modules/RNAseq.groovy"

HISATINDEX=HISAT2HG19

GENOME=GENOMEHG19

KNOWNTRANSCRIPTS=GENCODEV19_HS
KNOWNSPLICESITES=GENCODEV19_HS_SPLICESITES

MERGED_TRANSCRIPTS = "merged_asm/stringtiemerged.gtf"

Bpipe.run {"%_R*.fastq.gz"  * [ hisat_align + stringtie] + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj + make_gene_counts_human}
