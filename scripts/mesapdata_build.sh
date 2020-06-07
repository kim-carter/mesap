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
BASE_PATH="."
BASE_NAME="Rattus_norvegicus"
HISAT2_PATH="."
TMP_FASTA_File="Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa"
FASTA_File="$TMP_FASTA_File.ens100.fa"
GTF="Rattus_norvegicus.Rnor_6.0.100.gtf"
SPLICE="rat_splice_site"
EXON="rat_exon"

# Get the primary genome assembly (chroms and scaffolds only) for Rat6 Ensembl 100
wget http://ftp.ensembl.org/pub/release-100/fasta/rattus_norvegicus/dna/$TMP_FASTA_File.gz
gzip -d $TMP_FASTA_File.gz

# Fix the fasta header names to numerical chromosomes, so they match the GTF
cat  $TMP_FASTA_File | sed 's/ .*$//g' > $FASTA_File

# get the main annoation GTF file (ref chroms only) for Rat6 Ensembl 100
wget ftp://ftp.ensembl.org/pub/current_gtf/rattus_norvegicus/$GTF.gz
gzip -d $GTF.gz

# Run hisat2 to extract splice sites
$HISAT2_PATH/hisat2_extract_splice_sites.py ${GTF} > ${SPLICE}
# Run hisat2 to extract exons
$HISAT2_PATH/hisat2_extract_exons.py ${GTF} > ${EXON}

# Run hisat2 index builder
$HISAT2_PATH/hisat2-build -p 16 --exon ${EXON} --ss ${SPLICE} ${FASTA_File} ${BASE_NAME}


#########
# MOUSE #
#########
BASE_PATH="."
BASE_NAME="GRCm38"
HISAT2_PATH="."
FASTA_File="GRCm38.primary_assembly.genome.fa"
GTF="gencode.vM25.annotation.gtf"
SPLICE="mouse_splice_site"
EXON="mouse_exon"

# Get the primary genome assembly (chroms and scaffolds only) for M25
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/$FASTA_File.gz
gzip -d $FASTA_File.gz
# get the main annoation GTF file (ref chroms only) for M25
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/$GTF.gz
gzip -d $GTF.gz

# Run hisat2 to extract splice sites
$HISAT2_PATH/hisat2_extract_splice_sites.py ${GTF} > ${SPLICE}

# Run hisat2 to extract exons
$HISAT2_PATH/hisat2_extract_exons.py ${GTF} > ${EXON}

# Run hisat2 index builder
$HISAT2_PATH/hisat2-build -p 16 --exon ${EXON} --ss ${SPLICE} ${FASTA_File} ${BASE_NAME}


#########
# HUMAN #
#########
BASE_PATH="."
BASE_NAME="GRCh38"
HISAT2_PATH="."
FASTA_File="GRCh38.primary_assembly.genome.fa"
GTF="gencode.v34.annotation.gtf"
SPLICE="human_splice_site"
EXON="human_exon"

#Get the primary genome assembly (chroms and scaffolds only) for Human34
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/$FASTA_File.gz
gzip -d $FASTA_File.gz
# get the main annoation GTF file (ref chroms only) for Human34
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/gencode.v34.annotation.gtf.gz
gzip -d $GTF.gz

# Run hisat2 to extract splice sites
$HISAT2_PATH/hisat2_extract_splice_sites.py ${GTF} > ${SPLICE}
# Run hisat2 to extract exons
$HISAT2_PATH/hisat2_extract_exons.py ${GTF} > ${EXON}

# Run hisat2 index builder
$HISAT2_PATH/hisat2-build -p 16 --exon ${EXON} --ss ${SPLICE} ${FASTA_File} ${BASE_NAME}


