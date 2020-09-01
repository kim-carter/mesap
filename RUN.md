# RUN instructions for the MEdical Sequence Analysis Pipeline (MESAP) for RNA-Seq analysis
The MESAP package has been developed for NGS transcriptome sequencing (RNA-seq) projects with the purpose providing an easy to use, reproducible and robust set of standardised methods (and reference files) for analysing this type of data. More background details are available in [README.md](README.md).

Following are instructions for using MESAP through the [Singularity](https://github.com/hpcng/singularity/releases) and [Docker](https://www.docker.com) conrainer platforms. Container platform technoologies allow you to create and run operating system-like containers (think of it as a light-weight virtual machine) that package up pieces of software in a way that is portable and reproducible at the OS level. You can build a container on your laptop, and then run it on the largest HPC clusters in the world, local university or company clusters, a single server, in the cloud, or on a workstation down the hall without any changes. This is incredibly powerful, and the perfect choice for building robust and reproducible bioinformatics pipelines.   

#### Reference MESAP version 3.0

## Quick Shortcuts to key parts of the documentation
- [Items to check before you run](https://github.com/kim-carter/mesap/blob/master/RUN.md#before-you-use-the-pipelines-please-check-the-following-items)
- [Run MESAP via Singularity at TKI](https://github.com/kim-carter/mesap/blob/master/RUN.md#singularity--tki)
- [What output files are created?](https://github.com/kim-carter/mesap/blob/master/RUN.md#what-output-files-are-created)

## What pipelines and software are contained in this pipeline?
There are specific versions of each software tool tied to each MESAP version (eg MESAP 3.0 vs 2.0 vs 1.0). Details of the specific software tool versions can be found in the [README.md](README.md) and the git history of the [Dockerfile](Dockerfile) in the [MESAP git repository](https://github.com/kim-carter/mesap).  

In the current version of MESAP there are 3 simple RNA-seq pipelines (human, mouse and rat), which contain no QC steps in the pipeline to get you a quick answer; and there are 3 piplines that run the full pre- and post-alignment QC process, in addition to the standard alignment->gene and transcript quantification.

When running MESAP, you need to select the appropriate pipeline, either **rnaseq_human.groovy / rnaseq_mouse.groovy / rnaseq_rat.groovy** OR **rnaseq_human_fullqc.groovy / rnaseq_mouse_fullqc.groovy / rnaseq_rat_fullqc.groovy**.   Note: if you run the simple pipelines first of all, you can always run the _fullqc version of the pipeline quickly afterwards, as MESAP will detect any already produced files (eg the alignment bam files) and will skill these,

MESAP also contains separate QC pipelines for each of the major tools, namely pre-alignment QC with Fastqc (run fastqc,groovy); post-alignment QC with Samstat (run samstat,groovy); and QC results (and alignment results if available) aggregation with Multiqc (run multiqc.groovy).  You can run any of these separately from the main pipelines if you wish to obtain specific QC results separately for any reason.

## What reference / annotation files do the pipelines use?
MESAP comes with the the necessary genome sequence and annotation files for each of the Human, Mouse and Rat pipelines to ensure that the pipelines and reference data files themselves are repeatable and reproducible.  The descriptions of how the data files were created are detailed elsewhere in the mesap_data git repository, in the [mesapdata_build.sh](scripts/mesapdata_build.sh).  **Briefly, the current 3.0 build uses Gencode 34 human (GRCh38), Gencode 25 mouse (GRCm38), and Rat 6.0 from Ensembl version 100, with other identifier mappings also from Ensembl 100**.

## Before you use the pipelines, please check the following items
a) Any input files (standard gzipped FASTQ files) need to be in the standard naming format, which AGRF and other providers normally produce for you. Illumina (and other) FASTQ files use the following naming scheme:
~~~{.bash}
<sample name>_<barcode sequence>_L<lane (0-padded to 3 digits)>_R<read number>.fastq.gz
~~~
For example, the following is a valid FASTQ file name:
NA10831_ATCACG_L002_R1.fastq.gz

If you have paired-end data, each _R1.fastq.gz file will have a corresponding _R2.fastq.gz file
If you have single-end data, you just have _R1

Multiple lanes of sequence for a sample will be represented by different Lane numbers (not necessarily consequtive). You can merge multiple lanes (of the same sample) together using simply Unix/Linux commands:
~~~{.bash}
eg. cat file*.fastq > bigfile.fastq  OR cat file*.fastq.gz > bigfile.fastq.gz 
~~~

b) All of your input files should be compressed (gzip'd) before you start - if you have plain .fastq files, you should use the gzip command to compress each one before starting. Eg
~~~{.bash}
gzip *.fastq
~~~

c) Before you run anything, you need 5 pieces of information:
* the "INPUT" directory containing your fastq.gz files. **Note: files should all be in the same directory (not in subdirs)**
* the "OUTPUT" directory, where all of the results (qc, alignment, quantifications) will be written. **Note: ideally this should be empty.  If you use a directory with existing files, MESAP will check to see if any of the output files from the pipeline have already been created, and will only update/create the missing ones**
* the location of the "mesap_data" directory, containing all the reference files
* the name of the pipeline to run - human/mouse/rat and either fullqc or no qc (as noted above)
* the maxiumum number of CPU cores to use simultaneously. **Note: while it may be tempting to just put the number of available cores in your laptop, workstation or server, please check that you have sufficient memory (RAM) to support this many core.  The rule of thumb is 6 Gb (6 gigabytes) of RAM per CPU core - ie to use 2 cores on your laptop you need about 12Gb of free memory; to use 20 cores on a server, you need about 120 Gb of free memory.   For disk space, a good rule of thumb is about twice the size of your input directory.**

## Running the pipelines using SINGULARITY
The first set of run instructions for use with the [Singularity](https://github.com/hpcng/singularity/releases). Singularity and Docker are similarly in many ways, but one of the critical differences is permissions, where Singularity runs as a normal user account, while Docker required root (superuser/admin) privileges. As a result, Singularity is appealing for HPC and shared network environments, such as at TKI.

### SINGULARITY @ TKI
The IT team at TKI are happy to support the use of Singularity for bioinformatics pipelines, and will provide a virtual machine to any user (researcher) with this pre-installed for easy use.  The mesap_data will be available in /REFERENCE/mesap_3.0 and the singularity binary for mesap (.sif file) will be in /SOFTWARE/mesap_3.0/ - note, wih new versions these paths may change or be updated.

#### 1. Login to your VM server environment
Login to the server IT has created for you (eg could be tki-hohpc-t2002.ichr.uwa.edu.au) either via command line (SSH), or via GUI (eg RDP/X2GO) as instructed by IT, and open a terminal window.

#### 2. Start a new "screen" session or restart an existing one (optional)
Screen starts a new terminal (inside your existing one) that is robust to network interruptions.  ie If your internet drops, or you lose your connection to the server for any reason, you can connect back and continue your work as is (or you can just leave long running tasks, and come back and check on them) - very useful of your pipeline takes more than a day to run and you want to take your laptop home.
~~~{.bash}
screen
~~~
If've you lost connection to the server you can use the -r option with screen to resume your session.  If you have a look at any online tutorials regarding how to use screen, this will give you an idea of the normal practices for working with it

#### 3. Run the pipeline
The following command should be modified use the 5 bits of information highlighted earlier, specifying the input (MY_INPUT_DIR), output (MY_OUTPUT_DIR) and mesap_data (this one will be in /SOFTWARE for your already) directories that are bind mounted into the container, plus the particular pipeline (PIPELINE.groovy), and finally the maximum number of cores (CPUCORES) to use.  The command line is pretty long and needs to be input as a single command (ie line) - this is unfortunately necessary as there's lots of options that have to be right to enable you to run the entire pipeline in a single command.

Here's what the command line looks like, and where these bits of information go 
~~~{.bash}
singularity run --bind /REFERENCE/mesap_3.0:/mesap_data,MY_INPUT_DIR:/INPUT,MY_OUTPUT_DIR:/OUTPUT -H /run/user/`id -u`:/home/`id -un`  /SOFTWARE/mesap_3.0/mesap_3.0.sif bash -c 'cd /OUTPUT/ && bpipe run -n CPUCORES -r /mesap/pipelines/PIPELINE.groovy /INPUT/*.gz'
~~~

Here's what the an actual command line looks like, running the rnaseq_human_fullqc pipeline using 20 cores on an input and output directory located in /SCRATCH.
~~~{.bash}
singularity run --bind /REFERENCE/mesap_3.0:/mesap_data,/SCRATCH/AGRF_CAGRF20031852_HLLMYDRXX:/INPUT,/SCRATCH/AGRF_CAGRF20031852_HLLMYDRXX_OUTPUT:/OUTPUT -H /run/user/`id -u`:/home/`id -un`  /SOFTWARE/mesap_3.0/mesap_3.0.sif bash -c 'cd /OUTPUT/ && bpipe run -n 20 -r /mesap/pipelines/rnaseq_human_fullqc.groovy /INPUT/*.gz'
~~~

There will be lots printed to the screen as the pipeline software works through each step of the relevant pipeline.  
* If there are errors, such as no input files being found, or missing reference / annotation files, then it's likely there's a typo in your run command with the paths that are being mapped to /mesap_data, /INPUT and /OUTPUT - please check are re-run the run command to fix.
* If you see an out of memory or disk space error, then you may have to check the specs of your machine and confirm with IT.
* If everything is successful, you will see something like the following:

~~~{.bash}
======================================== Pipeline Succeeded ========================================
13:34:37 MSG:  Finished at Fri Aug 14 13:34:37 AWST 2020
13:34:40 MSG:  Outputs are:
                /OUTPUT/qc/fastqc_summary.txt
                /OUTPUT/assembly/MD29_C6GRMANXX_ACAGTGAT_L003_R1.fastq.gtf
                /OUTPUT/qc/MD29_C6GRMANXX_ACAGTGAT_L003_R1.fastq.bam.samstat.html
                /OUTPUT//transcript_expression.txt
                /OUTPUT/assembly/MD28_C6GRMANXX_TGACCAAT_L003_R1.fastq.gtf
                ... 93 more ...
~~~

### SINGULARITY @ Home / elsewhere    
As long as you have singularity installed, you can run the MESAP pipeline on pretty much any computer, provided you have the MESAP binary file and corresponding mesap_data data directory. You can copy these from the /SOFTWARE/mesap_3.0 and /REFERENCE/mesap_3.0 directories at TKI.

As with the previous set of instructions, you still need the same 5 bits of information highlighted earlier, specifying the input (MY_INPUT_DIR), output (MY_OUTPUT_DIR) and mesap_data directories that are bind mounted into the container, plus the particular pipeline (PIPELINE.groovy), and finally the maximum number of cores (CPUCORES) to use. In this case however, the two changes from the previous instructions are the locations of the mesap_data directory and the mesap_3.0 sif binary. The following example assumes the files are accessible in the users home directory (eg /home/user):

~~~{.bash}
singularity run --bind /home/user/mesap_data:/mesap_data,MY_INPUT_DIR:/INPUT,MY_OUTPUT_DIR:/OUTPUT -H /run/user/`id -u`:/home/`id -un`  /home/user/mesap_3.0.sif bash -c 'cd /OUTPUT/ && bpipe run -n CPUCORES -r /mesap/pipelines/PIPELINE.groovy /INPUT/*.gz'
~~~

## What output files are created?

### key output files
In your OUTPUT folder will be the following:
* *genecounts.txt*, a tab delimited text file of the (raw) read counts for each input file, with gencode, ensembl, gene symbol and entrezid identifiers and gene description  
* *transcript_expression.txt*, a tab delimited text file of the normalised expression values (tpm and fpkm) for each input file, with ensembl transcript identifiers
* *bg.rda*, a rdata object from the ballgown biocondunctor package, which can be further used to perform isoform-level differential expression analysis of the input files

### pre-alignment and post-alignment QC
If you have opted to run the *fullqc* versions of the human, mouse and rat pipelines (or the separate QC pipelines), in the **qc/** folder off of your OUTPUT directory will be the following:
* for each input fastq file (or pair of files) there will be a corresponding _fastqc.html file and _fastqc.zip from FastQC (pre-alignment)
* for each aligned bam file there will be a corresponding _samstat.html file from SamStat (post-alignment)
* *fastqc_summary.txt*, a brief text file summary of all of the fastqc results in this folder
* *samstat_summary.txt*, a brief text file summary of all of the fastqc results in this folder
* *samstat_results_summary.csv*, a detailed delimited text file summary of the fastqc results
* *multiqc_report.html* (and multiqc_data folder), a detailed graphical html summary report covering both the fastqc and hisat alignment results

### alignments 
In the **alignments/** folder off of your OUTPUT directory will be the following:
* for each input fastq file (or pair of files) there will be a corresponding bam file (post-alignment summary and qc for each is in the qc/ outputs)
* for each input fastq file (or pair of files) there will be a (merged) .gtf and coverage cov_refs.gtf (these are temporary files, which are summarised elsewhere)

### assembly 
In the **assembly/** folder off of your OUTPUT directory will be the following:
* for each input fastq file (or pair of files) there will be a first pass .gtf with coverage and expression (these are temporary files, which are summarised elsewhere)
In the **merged_asm/** folder off of your OUTPUT directory will be the following:
* a merged assembly gtf file containing alignments to both the known species reference GTF and any potential novel transcripts

### debugging, logging and other outputs for reproducibility
In the **.bpipe/** folder off of your OUTPUT directory - check *bpipe.log* for debugging.  *commandlog.txt* in your OUTPUT folder contains all of the commands (and options) that have been run


## Running the pipelines using DOCKER
Following are instructions for using MESAP with [Docker](https://docker.com).  While Docker normally requires root (superuser/admin) privileges, the mesap container has been built to restrict this as much as possible, such that you are required to map your own user & group privileges as part of how the pipelines run (details following). 

### Check you have built the MESAP DOCKER image
For whatever laptop/deskop/workstation or server you are running on, you need to have Docker installed and runnning, and have grabbed the MESAP git repository and built the image - see [BUILD.md](BUILD.md) for detailed instructions.

### Run the pipeline in DOCKER
The following command should be modified use the 5 bits of information highlighted earlier, specifying the input (MY_INPUT_DIR), output (MY_OUTPUT_DIR) and mesap_data directories, the number of cores (-n 4), and the pipeline (rnaseq_human_fullqc.groovy). 

~~~{.bash}
# docker run -it -e MYUID=`id -u` -e MYGID=`id -g` -v /home/user/MY_INPUT_DIR:/INPUT -v /home/user/mesap_data/:/mesap_data -v /home/user/MY_OUTPUT_DIR/:/OUTPUT mesap:3.0 bash -c 'bpipe -n 4 -r /mesap/pipelines/rnaseq_human_fullqc.groovy /INPUT/test*.gz'
~~~

The same output files will be created as described above.
