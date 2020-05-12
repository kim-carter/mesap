% Local config file
% Timo Lassmann
% Today

# Introduction

The file is used to define the paths to the programs bpipe should use. These are all included in the package. 

##File: localprograms.groovy

~~~~{.java}

BASEROOTDIR="BASEDIRNAME"


PICARD="$BASEROOTDIR" + "/programs/picard/dist/picard.jar"

BWA ="$BASEROOTDIR" + "/programs/bwa-0.7.12/bwa"

HISAT = "$BASEROOTDIR" + "/programs/hisat-master/hisat"

STRINGTIE = "$BASEROOTDIR" + "/programs/stringtie-master/stringtie"

SAMTOOLS = "$BASEROOTDIR"+ "/programs/samtools-1.2/samtools"
MARKDUPLICATES = "$BASEROOTDIR"+ "/programs/MarkDuplicates.jar"
GATK = "$BASEROOTDIR"+ "/programs/GenomeAnalysisTK.jar --interval_padding 100 -et NO_ET -K " + "$BASEROOTDIR"+ "/programs/key/timo.lassmann_telethonkids.org.au.key"

CHECKBAM = "$BASEROOTDIR"+ "/scripts/check_bam_files.sh"

TABLEMAKER = "$BASEROOTDIR"+ "/programs/tablemaker-2.1.1/tablemaker"
CUFFMERGE =   "$BASEROOTDIR"+ "/programs/cufflinks-2.2.1/cuffmerge"
CUFFCOMPARE =  "$BASEROOTDIR"+ "/programs/cufflinks-2.2.1/cuffcompare"
STRINGTIE =   "$BASEROOTDIR"+ "/programs/stringtie-master/stringtie"

GLUE_4_BALLGOWN = "$BASEROOTDIR"+ "/pipelines/make_ballgown_obj.sh"



~~~~

##File: localdatafiles.groovy


~~~~{.java}

BASEROOTDIR="BASEDIRNAME"

GENOMEHG19="$BASEROOTDIR" + "/mesap_data/genomes/hg19/ucsc.hg19.fasta"
GENOMEMM10="$BASEROOTDIR" + "/mesap_data/genomes/mm10/GRCm38.primary_assembly.genome.fa"

HISATHG19="$BASEROOTDIR" + "/mesap_data/genomes/hg19/ucsc.hg19.hisat"
HISATMM10="$BASEROOTDIR" + "/mesap_data/genomes/mm10/GRCm38.hisat"


GENOME="$BASEROOTDIR" + "/bundle/2.8/hg19/ucsc.hg19.fasta"
MILLS1000GINDEL="$BASEROOTDIR" +"/bundle/2.8/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf"
DBDNP138="$BASEROOTDIR" +"/bundle/2.8/hg19/dbsnp_138.hg19.vcf"
HAPMAP="$BASEROOTDIR" +"/bundle/2.8/hg19/hapmap_3.3.hg19.sites.vcf"
OMNI="$BASEROOTDIR" +"/bundle/2.8/hg19/1000G_omni2.5.hg19.sites.vcf"

HISATEXAMPLEINDEX = "$BASEROOTDIR" + "/bundle/2.8/hg19/ucsc.hg19.hisat"

GENCODEV19 = "$BASEROOTDIR" + "/misc/gencode.v19.annotation_level_1_2.gtf"

GENCODEV19_HS="$BASEROOTDIR" + "/mesap_data/annotation/hg19/gencode.v19.annotation_level_1_2.gtf"
GENCODEV19_HS_SPLICESITES="$BASEROOTDIR" + "/mesap_data/annotation/hg19/gencode.v19.annotation_level_1_2_splicesites.txt"

GENCODEVM5_MM="$BASEROOTDIR" + "/mesap_data/annotation/mm10/gencode.vM5.annotation_level_1_2.gtf"
GENCODEVM5_MM_SPLICESITES="$BASEROOTDIR" + "/mesap_data/annotation/mm10/gencode.vM5.annotation_level_1_2_splicesites.txt"

~~~~
