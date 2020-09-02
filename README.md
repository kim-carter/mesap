# MEdical Sequence Analysis Pipeline (MESAP) 
This is the homepage for the MEdical Sequence Analysis Pipeline (MESAP) bioinformatics package for conducting automated, reproducible RNA-seq analysis.  The MESAP package was initially developed by Kim Carter while at [Telethon Kids Institute](https://www.telethonkids.org.au) and later refined, and builds on a number of open source technologies and packages form an integrated analysis suite.  The two core RNA-seq approaches in MESAP are 1) transcript-level alignment and quanitification methods developed by the Salzberg team over many years, published in Nature Protocols in 2016 (http://www.nature.com/nprot/journal/v11/n9/full/nprot.2016.095.html) and 2) gene-level quantification (count) approaches developed by many, published in Nature Protocols in 2013 (http://www.nature.com/nprot/journal/v8/n9/full/nprot.2013.099.html). 

MESAP provides the tools to complete the first 'stage' of any RNA-seq analysis that would typically involve basic pre-alignment QC of the raw data files, alignment to a reference sequence, quantification at both the transcript and gene level, and post-alignment QC.   Once you have your quantified genes or transcripts, it's then up to you to take forward the next stage of analyses where you would typically preform differential gene expression (or transcript expression) between the experimental groups in your study (as per the study design), followed up by pathway and ontology enrichment analyses and/or gene network analyses. Most of the downstream analyses are conducted in R, and we provide you with R objects and R-compatiable files to readily work with at the end of the MESAP pipeline.

## INSTRUCTIONS
* Run instructions are contained in [RUN.md](run.md)
* Build instructions are contained in [BUILD.md](BUILD.md)

## Other important and useful information
MESAP is really the first stage or phase of RNA-seq analysis, it's certainly not the endpoint.  Once you have your quantified transcripts or gene counts, you need to perform differential expression analysis fitting the design of your study (typically done in R via Limma and possibly EdgeR/Voom or directly in Ballgown in R), then follow it up with pathway enrichment, ontology enrichment and/or network analysis and so on. All of these steps may likely require biostatistical and bioinformatics expertise, and we strongly recommend you consult/involve an expert in this type of analysis right from the design stage.

### Gencode IDs and pseudoautosomal regions (PAR)  (Human and Mouse pipelines)
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

If you want to take the genecounts.txt output and map to Entrez IDs for example, please remember that Entrez Ids are build from the NCBI/Genbank based genome builds and annotation projects, which are not 100% identical to the Ensembl based efforts. There are no quickfixes, and there are multi-mapping of gene identifiers whether you are starting from the NCBI or Ensembl builds - there are no 100% complete reproducible, version controlled mappings of indentifiers. 
