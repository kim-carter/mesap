# MEdical Sequence Analysis Pipeline (MESAP) 
This is the homepage for the MEdical Sequence Analysis Pipeline (MESAP) bioinformatics package for conducting automated, reproducible RNA-seq analysis.  The MESAP package was initially developed by Kim Carter while at [Telethon Kids Institute](https://www.telethonkids.org.au) and later refined, and builds on a number of open source technologies and packages form an integrated analysis suite.  The two core RNA-seq approaches in MESAP are 1) transcript-level alignment and quanitification methods developed by the Salzberg team over many years, published in Nature Protocols in 2016 (http://www.nature.com/nprot/journal/v11/n9/full/nprot.2016.095.html) and 2) gene-level quantification (count) approaches developed by many, published in Nature Protocols in 2013 (http://www.nature.com/nprot/journal/v8/n9/full/nprot.2013.099.html). MESAP_T provides the tools to complete the first 'stage' of any RNA-seq analysis that would typically involve basic QC of the raw data files, alignment to a refernence sequence, quantification at both the transcript and gene level, and post-alignment QC.   Once you have your quantified genes or transcripts, it's then up to you to take forward the next stage of analyses where you would typically preform differential gene expression (or transcript expression) between the experimental groups in your study (as per the study design), followed up by pathway and ontology enrichment analyses and/or gene network analyses. Most of the downstream analyses are conducted in R, and we provide you with R objects and R-compatiable files to readily work with at the end of the MESAP pipeline.

# BUILD
# docker build -t mesap_dev_2.2 .

# testing
# docker run -it -v /MESAP/DATA/rat/:/INPUT -v /MESAP/mesap_data/:/mesap_data -v /MESAP/OUTPUT/rat/:/OUTPUT mesap_dev_2.2:latest

# Singularity
# singularity build mesap_2.2.sif docker-daemon://mesap_dev_2.2:latest

# singularity exec --bind /MESAP/mesap_data:/mesap_data,/MESAP/DATA/rat/:/INPUT,/MESAP/OUTPUT/rat_sing:/OUTPUT ./mesap_2.2.sif bash -c 'bpipe -n 4 -r /mesap/pipelines/rnaseq_human_fullqc.groovy /INPUT/test*.gz'


## singularity shit
# need to do --nohome as singularity maps your installs from the computer into the image ... whhich breaks everything R for example (libc errors etc)
# completely counter intuitive
# also need to do cd /OUTPUT
#  *** maybe set user homedir to /OUTPUT for the session
# maybe leave boot.sh with just a warning message about perms, maybe auto detect docker, and leave as is

### need to declear ENSMAP just in case 


#### Current version: 2.0

The MESAP_T package is for NGS transcriptome sequencing (RNA-seq) projects, with the idea of providing an easy to use, reproducible and robust set of standardised methods (and reference files) for analysing this type of data. The two core approaches in MESAP_T are 1) transcript-level alignment and quanitification methods developed by the Salzberg team over many years, published in Nature Protocols in 2016 (http://www.nature.com/nprot/journal/v11/n9/full/nprot.2016.095.html) and 2) gene-level quantification (count) approaches developed by many, published in Nature Protocols in 2013 (http://www.nature.com/nprot/journal/v8/n9/full/nprot.2013.099.html). MESAP_T provides the tools to complete the first 'stage' of any RNA-seq analysis that would typically involve basic QC of the raw data files, alignment to a refernence sequence, quantification at both the transcript and gene level, and post-alignment QC.   Once you have your quantified genes or transcripts, it's then up to you to take forward the next stage of analyses where you would typically preform differential gene expression (or transcript expression) between the experimental groups in your study (as per the study design), followed up by pathway and ontology enrichment analyses and/or gene network analyses. Most of the downstream analyses are conducted in R, and we provide you with R objects and R-compatiable files to readily work with at the end of the MESAP pipeline.

## What pipelines and software are contained in this docker image?
There are specific versions of each software tool tied to each mesap_t version (eg MESAP_T 1.0 vs 1.1 vs 2.0 ). The version details can be found the Dockerfile.versionX located in the git repository - eg [Dockerfile](http://biocentral.ichr.uwa.edu.au:8888/carter/mesap_t/blob/master/Dockerfile.mesap_t.v2.0). For the current version 2.0 release of MESAP_T, the software versions of the HiSAT2 aligner, Stringtie assembler/quantifier and Ballgown R suite are the same as with the 2016 Nature Protocols article described above.

Pipelines and software included in **version 2.0** are:
- pre-alignment QC using [FastQC 0.11.3] (http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- alignment against human (hg19/grch37 genome build), mouse (mm11), and rat (rn6) genomes, both at the transcript and gene level using [HISAT2 2.0.4] (http://www.ccb.jhu.edu/software/hisat/index.shtml)
- transcript discovery and quantification (FPKM) of HISAT2 alignments using [Stringtie 1.3.0] (https://ccb.jhu.edu/software/stringtie/) and [Ballgown] (https://github.com/alyssafrazee/ballgown).
- gene-level quantification (counts) of HISAT2 alignments using SummarizeOverlaps (http://www.rdocumentation.org/packages/GenomicRanges/functions/summarizeOverlaps) (equivalent of HT-seq).
- post-alignment QC using [Samstat 1.5.2] (http://samstat.sourceforge.net/)
- plus some sundry scripts/programs to help with merging fastq lanes, and for helping with gencode gene names

MESAP is built around the BPIPE workflow / pipeline technology - currently using version 0.9.9.2 (https://github.com/ssadedin/bpipe/).  For more information in BPIPE itself, you can check out the tutorials and information here: [http://bpipe-test-documentation.readthedocs.org/en/latest/Tutorials/RealPipelineTutorial/] (http://bpipe-test-documentation.readthedocs.org/en/latest/Tutorials/RealPipelineTutorial/).


## What reference / annotation files that the pipelines use?
We've bundled up all of the necessary genome sequence and annotation files for each of the Human, Mouse and Rat pipelines to ensure that the pipelines and reference data files themselves are repeatable and reproducible.  The descriptions of how the data files were created are detailed elsewhere in the mesap_data git repository, and are summarised below.

Reference files included in **version 2.0** are:
- for the Human pipeline we are using the HG19/GRCH37 genome build from UCSC, along with the Gencode GTF annotation (https://www.gencodegenes.org/releases/) version 19 (to most recent vuild for HG19 available) using level 1 & 2 trancripts only, supplemented with genome annotation from Ensembl 75 (the last HG19 release for Ensembl)
- for the Mouse pipeline we are using the MM11/GRCm38.p5 genome build from Sanger/Gencode, along with the Gencode GTF annotation (https://www.gencodegenes.org/releases/) version M12 using level 1 & 2 trancripts only, supplemented with genome annotation from Ensembl 87 (the latest release for MM11).
- for the Rat pipeline we are using the RN6 genome build from Ensembl, along with the Ensembl GTF annotation details from Ensembl 87 (the latest release for RN6).


## Before you use the pipelines
Any input files (we're talking Illumina FASTQ files) need to be in the standard naming format, which AGRF and other providers normally produce for you. Illumina FASTQ files use the following naming scheme:
~~~{.bash}
<sample name>_<barcode sequence>_L<lane (0-padded to 3 digits)>_R<read number>.fastq.gz
~~~
For example, the following is a valid FASTQ file name:
NA10831_ATCACG_L002_R1.fastq.gz

If you have paired-end data, each _R1.fastq.gz file will have a corresponding _R2.fastq.gz file
If you have single-end data, you just have _R1

Multiple lanes of sequence for a sample will be presented by different Lane numbers (not necessarily consequtive). You can merge multiple lanes (of the same sample) together using the Fastqmerger tool we provide in the MESAP package (described below).

All of your input files should be compressed (gzip'd) before you start - if you have plain .fastq files, you should use the gzip command to compress each one before starting. Eg
~~~{.bash}
gzip *.fastq
~~~


## How do I use the pipelines?

#### 1. Login to the bioinformatics environment
Login to the SGI server (tki-lc1.ichr.uwa.edu.au) or the NGS server (hobiongs.ichr.uwa.edu.au) either via command line, or via GUI (X2GO) and open a terminal window, as per the instructions you were sent when getting access to the platform.

#### 2. Start a new "screen" session or restart an existing one (optional)
Screen starts a new terminal (inside your existing one) that is robust to network interruptions.  ie If your internet drops, or you lose your connection to the server for any reason, you can connect back and continue your work as is (or you can just leave long running tasks, and come back and check on them).
~~~{.bash}
screen
~~~
If've you lost connection to the server you can use the -r option with screen to resume your session.  If you have a look at any online tutorials regarding how to use screen, this will give you an idea of the normal practices for working with it

#### 3. Start the mesap_t docker container, selecting a specific mesap_t version or use the default latest.

The following command runs the MESAP transcriptome docker container (mesap_t), specifying an INPUT directory (the directory where your fastq.gz files are stored) and OUTPUT directory (where you want stuff saved to).  You will need to substitute these in for yourself depending on where your files are located on the servers.   The following is a long command, and this needs to be run all in a single line.
~~~{.bash}
nice -n 20 docker run -it  --volumes-from mesapdata  -v /RAW/yourinputdirectory/:/INPUT   -v /SCRATCH/youroutputdirectory/:/OUTPUT   -e MYUID=`id -u` -e MYGID=`id -g`  biocentral.ichr.uwa.edu.au:4444/mesap_t:2.0
~~~
* Replace the /RAW/yourinput directory and /SCRATCH/youroutputdirectory with the full path to your input directory and to your output directory.
* The version number of mesap_t to use is the last argument at the end of the long command. i.e. **mesap_t:2.0** You can replace 2.0 with 1.1 or 1.0 to use earlier versions of the mesap software (and associated earlier versions of the reference files), or use the word latest to always use the latest version i.e. **mesap_t:latest**
* <b>One gotcha / safety check before running any BPIPE command is to make sure you are in the /OUTPUT when you run any commands, and that the correct directories are mapped to /OUTPUT and /INPUT</b>. The path is displayed to you in the command prompt each time. When running the MESAP docker container, the only way to save data and output files is via the /OUTPUT (and /INPUT) directory mappings.  If you write any files to a different directory, or make a change to something else - eg saving a file to /tmp, <b>when you exit all changes will be lost and not recoverable</b>.  You are free to explore the /mesap directories and programs, pipellines and scripts, but when you are ready to run a command, always return to /OUTPUT or a subdirectory off of this directory (use the cd command).

#### 4. Run the desired pipeline(s) inside the MESAP container
The command in (3) puts you into the terminal (shell) of the MESAP container where you can run BPIPE commands to run the various pipelines we've made available in the mesap_t release. In the commands following the <b>-n X</b> option that specifies how many CPU cores to make available for each analysis. In the examples following we use `-n 10` to run 10 simulaneous jobs (as job each uses a single CPU core) at a time until all of your files are processed.  Please use this option judiciously to ensure that you don't consume all of the CPU core (96 total for the SGI; 32 for the NGS server) on the server. Preferably using up to 10 or 20 cores for a large tasks is sufficient for most tasks.  Some tasks require only a few cores to gain a speed up. The other options in the command line (`-v` and `-r`) are recommended for BPIPE and are detailed in the documentation elsewhere.

As noted above, there are multiple pipelines included in the package. Following are descriptions of how to use each of them. MESAP itself is installed in the /mesap directory, with the pipelines and all other files located under this directory.


Inside the container you will be placed at a prompt like the following initially:
~~~{.bash}
mesap@47f0f914639c:/OUTPUT$
~~~

###### Pre-alignment QC
To run the pre-aligment QC software, FastQC (/mesap/pipelines/fastqc.groovy), you would do something like the following:
~~~{.bash}
mesap@server:/OUTPUT$     bpipe run -r -v -n 10 /mesap/pipelines/fastqc.groovy /INPUT/*.fastq.gz
~~~
This will run the fastqc pipeline with any fastq files in your /INPUT directory, with the output written into the /OUTPUT directory (in this case into a `qc` subdirectory). In the qc subdirectory you will find a .html file for each input .fastq.gz file containing the summary of QC information, which you can open in a browser. The full FastQC output for each input file is also containined in a .zip file, named similarly to the input file. MESAP_T also produces a quick summary file of across all of the input files, summarising how many files passed each QC measure - `fastqc_summary.txt`.

###### Alignment, denovo transcriptome assembly and gene & transcript-level quantification
To run the Human (/mesap/pipelines/StringTieDeNovoHUMAN.groovy), Mouse (/mesap/pipelines/StringTieDeNovoMOUSE).groovy), or RAT (/mesap/pipelines/StringTieDeNovoRAT.groovy), you would typically do something like the following (usually after doing QC above) (human example):

~~~{.bash}
mesap@server:/OUTPUT$     bpipe run -r -v -n 10 /mesap/pipelines/StringTieDeNovoHUMAN.groovy /INPUT/*.fastq.gz
~~~~
This will run through the full HISAT->STRINGTIE->BALLGOWN doing novel transcript assembly and known transcript annotation, and will produce a Ballgown R object (`bg.rda`) ready to use for downstream analysis - just run R, load the ballgown library (`library(ballgown)`), and load the R data object (`load(bg.rda)`). The output will be written to a various subdirectories (eg assembly alignments etc).

This pipeline will also automatically produce a `genecounts.txt` file, using the HISAT alignments and SummarizeOverlaps, with some extra Ensembl annotation (gene name, symbol) added.  We strongly recommend you have a look at the /mesap/scripts/gene_counts.R file to check the strandedness of your sequencing to ensure the counts are calculated correctly (example code is provided here to check). Please see the notes below about extra considerations around Gencode annotations, PAR regions, ID mapping (eg to Entrez IDs) and so on.

###### Post-alignment QC
Once the alignments and quantification are run, you could check the alignment quality by running Samstat on the output .bam files. For example:
~~~{.bash}
mesap@server:/OUTPUT$   bpipe run -r -v -n 10 /mesap/pipelines/samstat.groovy alignments/*.bam
~~~
This will run the samstat pipeline with any bam files in your /OUTPUT/alignments directory (the default location), with the output written into the `qc` subdirectory (as with fastqc). In the qc subdirectory you will find a .samstat.html file for each .bam file file containing the summary of alignment QC information, which you can open in a browser. MESAP_T also produces a quick summary file of across all of the input files, summarising average percentages of mapping quality - `samstat_summary.txt`.

#### 5. Throughout the process BPIPE logs every command you've run (saved into the /OUTPUT directory, or wherever you launch bpipe from), and provides the ability to resume a pipeline if there was an error at any stage.
You can examine logs using something like the following:
~~~{.bash}
mesap@server:/OUTPUT$   bpipe log
~~~

#### 6. Exit MESAP
When you're finished running things inside the MESAP docker container, simply type "exit" to return to your normal shell on the server.   Just remember that anything that's not saved to the /OUTPUT directory will not be there when you run the MESAP next time (ie for another project or set of input files).    The idea is that you should run the MESAP pipelines on each project separately, as you can only map one input and output directory to a session - this also helps to keep output files, bpipe logs etc separate per project.



## Other important and useful information
MESAP_T is really the first stage or phase of RNA-seq analysis, it's certainly not the endpoint.  Once you have your quantified transcripts or gene counts, you need to perform differential expression analysis fitting the design of your study (typically done in R via Limma and possibly EdgeR/Voom or directly in Ballgown in R), then follow it up with pathway enrichment, ontology enrichment and/or network analysis and so on. All of these steps may likely require biostatistical and bioinformatics expertise, and we strongly recommend you consult/involve an expert in this type of analysis right from the design stage.

#### Gencode IDs and pseudoautosomal regions (PAR)  (Human and Mouse pipelines)
For both the Human and Mouse pipelines, we use [Gencode] (https://www.gencodegenes.org/) project annotations, as the most quality reference standard annotation available for both species (there is no Gencode RAT project currently).

In the `genecounts.txt` gene counts file for the Human and Mouse pipelines, you may well find that there are duplicate gene names or symbols in some of the annotation columns. This is not an issue relating to the MESAP, this is in relation to the genome annotation differences and conventions between datasources. The first column in your genecounts file is `gencodeid` - this is a unique Gencode identifier, which is mostly unique Ensembl gene IDs.

Ensembl ids, by convention, are made of a species index ("ENS" for human and "ENSMUS" for mouse etc) followed by a feature type indicator ("G" for gene, "T" for transcript, "E" for exon, "P" for translation) and an 11-number figure.

The Gencode GTF/GFF3 files make an exception to this rule in the case of the so called **pseudoautosomal regions (PAR)** of chromosome Y. The gene annotation in these regions is identical between chromosomes X and Y. Ensembl do not provide different feature ids for both chromosomes. The Ensembl GTF file only includes this annotation once, for chromosome X. However, Gencode decided that the GENCODE GTF/GFF3 files would include the annotation in the PAR regions of both chromosomes. Since the GTF convention dictates that feature ids have to be unique for different genome regions, Gencode slightly modify the Ensembl feature id by replacing the first zero with an "R". Thus, "ENSG00000182378.10" in chromosome X becomes "ENSGR0000182378.10" in chromosome Y.

Here's an example:
~~~{.bash}
tki-lc1:> grep ENSG00000002586 genecounts.txt
gencodeid            sample1  sample2  EnsemblID        Symbol  Description
ENSG00000002586.13   1011     989      ENSG00000002586  CD99    CD99 molecule [Source:HGNC Symbol;Acc:7082]
ENSGR0000002586.13   1011     1002     ENSG00000002586  CD999   CD99 molecule [Source:HGNC Symbol;Acc:7082]
~~~
The first one represents the X chromosome counts, and second "R" one represents the Y chromosome counts.

The extra columns (EnsemblID, Symbol & Description) added to the genecounts file as part of mesap are directly from Ensembl annotation, which don't use the X&Y notation that Gencode use (as described above).  They similarly don't use the transcript number notation ie geneID.transcriptnumber such as ENSG00000002586.13.   The ID column created is just the Gene ID and description and name - therefore there will/may be a few duplicates for these specific X & Y regions.

If you were just interested in autosomes, then the duplication isn't an issue either way.  Otherwise, you can use the first ID column instead to get a unique ID.

You will also see that MESAP also produces a `genecounts.txt.missing` file for you - this flags any Ensembl identifiers that could not be located in the additional annotation informatics for the given reference files (basically this is an extra sanity check to make sure that consisent reference annotations are used throughout the pipeline) - this file should be empty.

#### Entrez IDs and mapping other identifiers
When using taking gene level outputs from MESAP and converting to other platforms, please be aware that there isn't always a 1-to-1 mapping of identifiers. Throughout MESAP we've standardised around Ensembl (plus Gencode) for annotations and nomenclature (please also see above note regarding the missing identifier checks that MESAP does for you).

If you want to take the genecounts.txt output and map to Entrez IDs for example, please remember that Entrez Ids are build from the NCBI/Genbank based genome builds and annotation projects, which are not 100% identical to the Ensembl based efforts. There are no quickfixes, and there are multi-mapping of gene identifiers whether you are starting from the NCBI or Ensembl builds - there are no 100% complete reproducible, version controlled mappings of indentifiers. The best we can do is recommend an approach something like the following (example is for human data):

~~~{r}
# load annotation libraries
library(AnnotationDbi)
library(org.Hs.eg.db)

# read gene counts file
data <- read.csv("genecounts.txt",sep="\t",stringsAsFactors=F)

# map org.HS to our data using gene symbol (for example)
Annotation <- select(org.Hs.eg.db, keys = as.character(data$Symbol), columns = c("ENTREZID", "GENENAME"), keytype = "SYMBOL")

# the Annotation data frame can now by merged in with our original data
~~~

#### How do I build the docker image from scratch (eg onto my own computer)? Note: this step isn't normally required

1. Sync the mesap_t docker repository using git (or download the .zip file)  (note this will only work inside the TKI network)
~~~{.bash}
git pull http://biocentral.ichr.uwa.edu.au:8888/carter/mesap_t.git
~~~

2. Run the docker build command (assuming you've already installed docker from [http://docker.com/] (http://docker.com/) inside the downloaded repository
Note: the -t tag command, gives a repository name for your image.  This is an example:
~~~{.bash}
docker build -t mesap_t_yourname .
~~~
Note: the -t tag command, gives a repository name for your image.  You can replace your name with whatever you wish to use to reference and version your own version of the mesap_t. We use our own internal docker repository, and versioning system to refer to mesap_t.
