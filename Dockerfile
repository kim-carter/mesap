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

# Make dirs, and copy MESAP software
RUN mkdir /mesap
RUN mkdir /mesap/doc
RUN mkdir /mesap/modules
RUN mkdir /mesap/programs
RUN mkdir /mesap/pipelines
RUN mkdir /mesap/scripts
RUN mkdir /mesap/mesap_data
COPY doc/ /mesap/doc
COPY modules/ /mesap/modules
COPY pipelines/ /mesap/pipelines
COPY programs/ /mesap/programs
COPY scripts/ /mesap/scripts

# Setup Bioconductor and key packages
# - ballgown (for transcript expression), GenomicFeatures & GenomicAlignments (for count quantification)
RUN R -e 'install.packages("BiocManager", repos="https://cran.curtin.edu.au"); BiocManager::install(pkgs=c("ballgown","GenomicFeatures","GenomicAlignments","Rsubread")) '


# Now uncompress and install each of the MESAP components
# note: each tool is defined as an ARG variable first, which refers to the source programe version file
#       programs are then installed and setup using the variable rather than a hardcoded file name

# bpipe - and add it to the system path
ARG bpipe=bpipe-0.9.9.9.tar.gz
RUN cd /mesap/programs && tar -zxvf $bpipe
RUN ln -s /mesap/programs/$bpipe/bin/bpipe /usr/bin

# samtools 1.3 
RUN cd /mesap/programs; bunzip2 samtools-1.3.1.tar.bz2; tar xvf samtools-1.3.1.tar; cd samtools-1.3.1; make; make install
RUN ln -s /mesap/programs/samtools-1.2/samtools /usr/bin

# stringtie 1.0.4
RUN cd /mesap/programs && tar -zxvf stringtie-1.3.0.Linux_x86_64.tar.gz

# hisat2 2.0.4
RUN cd /mesap/programs && unzip hisat2-2.0.4-Linux_x86_64.zip

# samstat & html2text
RUN cd /mesap/programs && tar -zxvf html2text-1.3.2a.tar.gz && cd html2text-1.3.2a && ./configure && make
RUN cd /mesap/programs && tar -zxvf samstat-1.5.2.tar.gz && cd samstat-1.5.2 && ./configure && make

# fastqc 0.11.3 & fix its no-execute permissions
RUN cd /mesap/programs && unzip fastqc_v0.11.3.zip
RUN chmod +x /mesap/programs/FastQC/fastqc

# fastq_merger
RUN cd /mesap/programs && tar -xvf fastqmerger.tar && cd fastqmerger && gcc kslib.o -o fastq_merger  fastgmerger.c 

# HCQC 0.90.8
RUN cd /mesap/programs && tar -zxvf htqc-0.90.8-Source.tar.gz && cd htqc-0.90.8-Source && mkdir build && cd build && cmake .. && make && make install


# Setup INPUT and OUTPUT directories for pipelines
RUN mkdir /INPUT
RUN mkdir /OUTPUT
WORKDIR /OUTPUT

# Add the user to sudo to enable extra admin flexibility if needed
RUN echo '%mesap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# run entrypoint to map uid and gid from user environment variables
CMD ["/mesap/scripts/boot.sh"]
