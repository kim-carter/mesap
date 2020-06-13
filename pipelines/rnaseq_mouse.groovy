load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/RNAseq.groovy"

HISATINDEX=HISAT2MM11
GENOME=GENOMEMM11

KNOWNTRANSCRIPTS=GENCODEVM5_MM11
KNOWNSPLICESITES=GENCODEVM5_MM11_SPLICESITES

MERGED_TRANSCRIPTS = "merged_asm/stringtiemerged.gtf"

Bpipe.run {"%_R*.fastq.gz"  * [ hisat_align + stringtie]  + makeassemblylist + stringtiemerge + "%_R*.fastq.gz"  * [stringtiequant] + make_ballgown_obj  + make_gene_counts_mouse}

