FROM ubuntu:14.04
LABEL Version="2.0" Description="MESAP transcriptome pipeline"
MAINTAINER Bioinformatics <bioinformatics@telethonkids.org.au>

#Update apt repository to a fast WA mirror
RUN echo "deb http://mirror.internode.on.net/pub/ubuntu/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://mirror.internode.on.net/pub/ubuntu/ubuntu trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://cran.ms.unimelb.edu.au/bin/linux/ubuntu/ trusty/" >> /etc/apt/sources.list

# Install necessary system packages
RUN apt-get update && apt-get install -y --force-yes build-essential libncurses5-dev bzip2 wget ncurses-base flex bison zlib1g-dev git unzip r-base libcurl4-gnutls-dev libxml2-dev vim cmake libboost-all-dev

# make informatics bash prompt printing full path
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

# Setup R
RUN R --no-save < /mesap/scripts/setupBioconductor.R



# Setup oracle java (not openjdk)
RUN mkdir /usr/local/java
RUN cd /usr/local/java/ && tar -zxvf /mesap/programs/jdk-7u79-linux-x64.tar.gz
ENV JAVA_HOME="/usr/local/java/jdk1.7.0_79/"
RUN ln -s /usr/local/java/jdk1.7.0_79/bin/java /usr/bin/java
RUN ln -s /usr/local/java/jdk1.7.0_79/bin/javac /usr/bin/javac


# Now uncompress and install each of the MESAP components

# bpipe - and add it to the system path
RUN cd /mesap/programs && tar -zxvf bpipe-0.9.9.2.tar.gz
RUN ln -s /mesap/programs/bpipe-0.9.9.2/bin/bpipe /usr/bin

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
