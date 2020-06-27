#!/bin/bash

# KIM CARTER 2020

# This script runs through the commands necessary to generate reference indexes for the human, mouse and rat pipelines
#
# It's already configured for the latest reference files circa May-June 2020
#
# Use the BATH_PATH in each block to specify where the output hisat indexes are written
# Use the BASE_NAME to specify the generated index name
# Use the HISAT2_PATH to specify where the hisat2 install can be found (just the directory)
# Use the FASTA_File and GTF arguments for each block to specify versions of the fasta genome reference sequence and annotation gtf files 
# Note: for RAT an extra step is required to clean up the fasta sequence headers names, to ensure they are consistent with the GTF (as there's no gencode RAT)


#######
# RAT #
#######
RAT_BASE_PATH="."
RAT_BASE_NAME="Rattus_norvegicus"
RAT_HISAT2_PATH="."
RAT_TMP_FASTA_File="Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa"
RAT_FASTA_File="$TMP_FASTA_File.ens100.fa"
RAT_GTF="Rattus_norvegicus.Rnor_6.0.100.gtf"
RAT_SPLICE="rat_splice_site"
RAT_EXON="rat_exon"

# Get the primary genome assembly (chroms and scaffolds only) for Rat6 Ensembl 100
wget http://ftp.ensembl.org/pub/release-100/fasta/rattus_norvegicus/dna/$RAT_TMP_FASTA_File.gz
gzip -d $RAT_TMP_FASTA_File.gz

# Fix the fasta header names to numerical chromosomes, so they match the GTF
cat  $RAT_TMP_FASTA_File | sed 's/ .*$//g' > $RAT_FASTA_File

# get the main annoation GTF file (ref chroms only) for Rat6 Ensembl 100
wget ftp://ftp.ensembl.org/pub/current_gtf/rattus_norvegicus/$RAT_GTF.gz
gzip -d $RAT_GTF.gz

# Run hisat2 to extract splice sites
$RAT_HISAT2_PATH/hisat2_extract_splice_sites.py ${RAT_GTF} > ${RAT_SPLICE}
# Run hisat2 to extract exons
$RAT_HISAT2_PATH/hisat2_extract_exons.py ${RAT_GTF} > ${RAT_EXON}

# Run hisat2 index builder
$RAT_HISAT2_PATH/hisat2-build -p 16 --exon ${RAT_EXON} --ss ${RAT_SPLICE} ${RAT_FASTA_File} ${RAT_BASE_NAME}


#########
# MOUSE #
#########
MOUSE_BASE_PATH="."
MOUSE_BASE_NAME="GRCm38"
MOUSE_HISAT2_PATH="."
MOUSE_FASTA_File="GRCm38.primary_assembly.genome.fa"
MOUSE_GTF="gencode.vM25.annotation.gtf"
MOUSE_SPLICE="mouse_splice_site"
MOUSE_EXON="mouse_exon"

# Get the primary genome assembly (chroms and scaffolds only) for M25
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/$MOUSE_FASTA_File.gz
gzip -d $MOUSE_FASTA_File.gz
# get the main annoation GTF file (ref chroms only) for M25
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/$MOUSE_GTF.gz
gzip -d $MOUSE_GTF.gz

# rename original, and extract only the high quality level 1 and level 2 annotations
mv $MOUSE_GTF $MOUSE_GTF.orig
awk '{if($0~"level (1|2);"){print $0}}' $MOUSE_GTF.orig > $MOUSE_GTF

# Run hisat2 to extract splice sites
$MOUSE_HISAT2_PATH/hisat2_extract_splice_sites.py ${MOUSE_GTF} > ${MOUSE_SPLICE}

# Run hisat2 to extract exons
$MOUSE_HISAT2_PATH/hisat2_extract_exons.py ${MOUSE_GTF} > ${MOUSE_EXON}

# Run hisat2 index builder
$MOUSE_HISAT2_PATH/hisat2-build -p 16 --exon ${MOUSE_EXON} --ss ${MOUSE_SPLICE} ${MOUSE_FASTA_File} ${MOUSE_BASE_NAME}


#########
# HUMAN #
#########
HUMAN_BASE_PATH="."
HUMAN_BASE_NAME="GRCh38"
HUMAN_HISAT2_PATH="."
HUMAN_FASTA_File="GRCh38.primary_assembly.genome.fa"
HUMAN_GTF="gencode.v34.annotation.gtf"
HUMAN_SPLICE="human_splice_site"
HUMAN_EXON="human_exon"

#Get the primary genome assembly (chroms and scaffolds only) for Human34
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/$HUMAN_FASTA_File.gz
gzip -d $HUMAN_FASTA_File.gz
# get the main annoation GTF file (ref chroms only) for Human34
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/gencode.v34.annotation.gtf.gz
gzip -d $HUMAN_GTF.gz

# rename original, and extract only the high quality level 1 and level 2 annotations
mv $HUMAN_GTF $HUMAN_GTF.orig
awk '{if($0~"level (1|2);"){print $0}}' $HUMAN_GTF.orig > $HUMAN_GTF

# Run hisat2 to extract splice sites
$HUMAN_HISAT2_PATH/hisat2_extract_splice_sites.py ${HUMAN_GTF} > ${HUMAN_SPLICE}
# Run hisat2 to extract exons
$HUMAN_HISAT2_PATH/hisat2_extract_exons.py ${HUMAN_GTF} > ${HUMAN_EXON}

# Run hisat2 index builder
$HUMAN_HISAT2_PATH/hisat2-build -p 16 --exon ${HUMAN_EXON} --ss ${HUMAN_SPLICE} ${HUMAN_FASTA_File} ${HUMAN_BASE_NAME}

