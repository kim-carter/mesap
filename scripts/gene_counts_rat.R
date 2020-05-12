library(GenomicFeatures)
library(GenomicAlignments)
library(stringr)


#generate TXDB from the GFF we used for the HISAT alignment
txdb <- makeTxDbFromGFF("/mesap/mesap_data/annotation/rn6/Rattus_norvegicus.Rnor_6.0.87.chr.gtf")


#specify path in quotes to directory with .bam files
fls = list.files(path="/OUTPUT/alignments/",recursive=TRUE, pattern="*.bam$", full=TRUE)
bfl <- BamFileList(fls)

#check bam file names are right
bfl

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
write.csv(file="/OUTPUT/tmpcounts.csv",data.frame(ensemblid = row.names(y_df), y_df),row.names=F,quote=F)

