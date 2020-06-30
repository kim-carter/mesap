library(GenomicFeatures)
library(GenomicAlignments)
library(stringr)

# get number of available cores/threads for parallel processing
maxthread <- as.numeric(Sys.getenv("THREAD"))
if (is.na(maxthread))
{
    # default if not set
    maxthread<-1  
}

# set max number of workers
register(MulticoreParam(workers = maxthread), default = TRUE)

#generate TXDB from the GFF we used for the HISAT alignment
txdb <- makeTxDbFromGFF(Sys.getenv("HUMAN_GTF"))

#specify path in quotes to directory with .bam files
fls = list.files(path="/OUTPUT/alignments/",recursive=TRUE, pattern="*.bam$", full=TRUE)
bfl <- BamFileList(fls)

#check bam file names are right
#bfl

# run the counts
exbygene <- exonsBy(txdb, "gene")
olap_nostrand = summarizeOverlaps(exbygene, bfl,"IntersectionNotEmpty", ignore.strand=TRUE)

### note check stranded vs not stranded
# olap_nostrand = summarizeOverlaps(exbygene, bfl,"IntersectionNotEmpty", ignore.strand=TRUE)
# olap_strand = summarizeOverlaps(exbygene, bfl,"IntersectionNotEmpty", ignore.strand=FALSE)
# y_strand = assays(olap_strand)$counts
# y_nostrand = assays(olap_nostrand)$counts
#
# For example
# sum(y_strand)
# [1] 629119
# sum(y_nostrand)
# [1] 17098462
#

#get the counts
y = assays(olap_nostrand)$counts
y_df <- as.data.frame(y)

#write file out to CSV.  Note requires further tidying up for gencode ensembl IDs (which are the rownames) - they have a different naming system
write.csv(file="/OUTPUT/tmpcounts.csv",data.frame(gencodeid = row.names(y_df), y_df),row.names=F,quote=F)
