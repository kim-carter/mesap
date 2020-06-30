FROM ubuntu:18.04
LABEL Version="2.1" Description="MESAP transcriptome pipeline" MAINTAINER="kimwarwickcarter@gmail.com"

# Update apt repositories to a fast AU mirror and add AU R mirror
RUN echo "deb http://au.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://au.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://au.archive.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list

# Install necessary system packages
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Perth
RUN apt-get update && apt-get -y --force-yes install tzdata ca-certificates gnupg && rm -rf /var/lib/apt/lists/*

# Add the apt key for CRAN
RUN echo "deb https://cran.curtin.edu.au/bin/linux/ubuntu bionic-cran35/ " >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

# Install base R and Java
RUN apt-get update && apt-get install -y --force-yes r-base default-jre-headless && rm -rf /var/lib/apt/lists/*

# Install core dependecies for R packages and other tools
RUN apt-get update && apt-get install -y --force-yes openssl libssl-dev libncurses5-dev bzip2 wget ncurses-base flex bison zlib1g-dev git unzip libcurl4-gnutls-dev libxml2-dev vim cmake libboost-all-dev && rm -rf /var/lib/apt/lists/*

# force a useful bash prompt printing full path
RUN echo 'PS1="[\u@docker \$PWD ] $ "' >> /etc/bash.bashrc

# Setup Bioconductor and key packages
# - ballgown (for transcript expression), GenomicFeatures & GenomicAlignments (for count quantification)
RUN R -e 'install.packages("BiocManager", repos="https://cran.curtin.edu.au"); BiocManager::install(pkgs=c("ballgown","GenomicFeatures","GenomicAlignments","Rsubread")) '

# Make dirs for copying local data into
RUN mkdir /mesap
RUN mkdir /mesap/doc
RUN mkdir /mesap/modules
RUN mkdir /mesap/programs
RUN mkdir /mesap/pipelines
RUN mkdir /mesap/scripts
RUN mkdir /mesap/mesap_data



# Copy and setup necessary programs
COPY programs/ /mesap/programs

# Now uncompress and install each of the MESAP components
# note: each tool is defined as an ARG variable first, which refers to the source programe version file
#       programs are then installed and setup using the variable rather than a hardcoded file name

# bpipe - file version is set in the ARG.  Change to upgrade 
ARG bpipe=bpipe-0.9.9.9.tar.gz
RUN cd /mesap/programs && tar -zxvf $bpipe
# get the filename without extension and link it into the system bin path
RUN temp=`basename -s .tar.gz $bpipe` && ln -s /mesap/programs/$temp/bin/bpipe /usr/bin

# stringtie - file version is set in the ARG.  Change to upgrade 
ARG stringtie=stringtie-2.1.3b.Linux_x86_64.tar.gz
RUN cd /mesap/programs && tar -zxvf $stringtie
# get the filename without extension and link it into the system bin path
RUN temp=`basename -s .tar.gz $stringtie` && ln -s /mesap/programs/$temp/stringtie /usr/bin

# hisat2 - file version is set in the ARG.  Change to upgrade 
ARG hisat=hisat2-2.2.0-Linux_x86_64.zip
RUN cd /mesap/programs && unzip $hisat
# get the filename without extension and link it into the system bin path
RUN temp=`basename -s -Linux_x86_64.zip $hisat` && ln -s /mesap/programs/$temp/hisat2 /usr/bin && ln -s /mesap/programs/$temp/hisat2-build /usr/bin

# samtools 1.10 - file version is set in the ARG.  Change to upgrade
ARG samtools=samtools-1.10.tar.bz2
RUN cd /mesap/programs; tar jxvf $samtools;
RUN temp=`basename -s .tar.bz2 $samtools` && cd /mesap/programs/$temp; make; make install

# samstat & html2text - note: this is the final version of samstat (from Timo Lassmann)
RUN apt-get update && apt-get install -y --force-yes html2text && rm -rf /var/lib/apt/lists/*
RUN cd /mesap/programs && tar -zxvf samstat-1.5.2.tar.gz && cd samstat-1.5.2 && ./configure && make
RUN ln -s /mesap/programs/samstat-1.5.2/src/samstat /usr/bin/

# fastqc 0.11.9 & fix its no-execute permissions - file version is set in the ARG.  Change to upgrade
ARG fastqc=fastqc_v0.11.9.zip
RUN cd /mesap/programs && unzip $fastqc
RUN chmod +x /mesap/programs/FastQC/fastqc

# multiqc - installed through python3 pip - requires locales to be set
# note: not specifically version controlled atm - should be added though, as by 
# default pip will grab the latest
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8
RUN apt-get update && apt-get install -y --force-yes locales python3-pip && rm -rf /var/lib/apt/lists/ && pip3 install multiqc bs4



# Copy and setup necessary docs, scripts, modules and pipelines
COPY doc/ /mesap/doc
COPY modules/ /mesap/modules
COPY pipelines/ /mesap/pipelines
COPY scripts/ /mesap/scripts



# Setup INPUT and OUTPUT directories for pipelines
RUN mkdir /INPUT
RUN mkdir /OUTPUT
WORKDIR /OUTPUT



ENV ENV="/etc/environment"

# Ensembl mappings for Ensembl Stable ID, Gene Name, Gene Description and NCBI/Ensembl ID obtained from Biomart
ENV HUMAN_ENSMAP=/mesap_data/human/Biomart_E100_human.txt 
ENV MOUSE_ENSMAP=/mesap_data/mouse/Biomart_E100_mouse.txt 
ENV RAT_ENSMAP=/mesap_data/rat/Biomart_E100_rat.txt 

# Reference files
ENV HUMAN_INDEX=/mesap_data/human/GRCh38
ENV HUMAN_GENOME=/mesap_data/human/GRCh38.primary_assembly.genome.fa
ENV HUMAN_GTF=/mesap_data/human/gencode.v34.annotation.gtf
ENV HUMAN_SPLICE=/mesap_data/human/human_splice
ENV HUMAN_EXON=/mesap_data/human/human_exon

ENV MOUSE_INDEX=/mesap_data/mouse/GRCm38
ENV MOUSE_GENOME=/mesap_data/mouse/GRCm38.primary_assembly.genome.fa
ENV MOUSE_GTF=/mesap_data/mouse/gencode.vM25.annotation.gtf
ENV MOUSE_SPLICE=/mesap_data/mouse/mouse_splice
ENV MOUSE_EXON=/mesap_data/mouse/mouse_exon

ENV RAT_INDEX=/mesap_data/rat/Rattus_norvegicus
ENV RAT_GENOME=/mesap_data/rat/Rattus_norvegicus.Rnor_6.0.dna.toplevel.ens100.fixed.fa
ENV RAT_GTF=/mesap_data/rat/Rattus_norvegicus.Rnor_6.0.100.gtf
ENV RAT_SPLICE=/mesap_data/rat/rat_splice
ENV RAT_EXON=/mesap_data/rat/rat_exon


# run entrypoint to map uid and gid from user environment variables
CMD ["/mesap/scripts/boot.sh"]

#
## SINGULARITY has no simple workdir to inherit from docker (it's a separate option)
#
# TODO
# add new summary option to hisat
# add option to stop non-aligned being written
# register(ncpus) to R when running - pass as command line parameter
# ie ie too many cpu cores, memory will overload    