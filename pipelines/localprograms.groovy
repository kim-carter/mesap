BASEROOTDIR="/mesap"
// these are in system-wide path
HISAT2 = "hisat2"
STRINGTIE = "stringtie"
SAMTOOLS = "samtools"
SAMSTAT = "samstat"
MULTIQC = "multiqc"

// these are in mesap dir only
CHECKBAM = "$BASEROOTDIR"+ "/scripts/check_bam_files.sh"
GLUE_4_BALLGOWN = "$BASEROOTDIR"+ "/pipelines/make_ballgown_obj.sh"
FASTQC = "$BASEROOTDIR"+"/programs/FastQC/fastqc"

