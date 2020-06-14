# get list of merged GTF files (from stringtie), which contain the FPKM and TMP values we want
# note we want to exclude the cov gtf files)
files <- grep(list.files(path="/OUTPUT/alignments/",recursive=F,pattern="*.gtf$"), pattern='cov', inv=T, value=T)

# note we expect at least one file here
# due to the way R handles data frames, we need to make the first set of columns before we can append together

#file[1]
gtf <- read.delim(paste0("/OUTPUT/alignments/",files[1]), header=FALSE,comment.char = "#",stringsAsFactors=F)
colnames(gtf) <- c("seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attributes")
gtf <- subset(gtf,feature=="transcript") # only need transcripts

gene_ids <-  gsub(".*gene_id (.*?);.*", "\\1", gtf$attributes) #get gene_id from attributes column
transcript_ids<- gsub(".*transcript_id (.*?);.*", "\\1", gtf$attributes) #get transcript_id from attributes column
ref_gene_names<- gsub(".*ref_gene_name (.*?);.*", "\\1", gtf$attributes) #get transcript_id from attributes column

# create initial columns, ordered by the transcript_id of the first file - they should all be these same as 
# they are created from the merged stringtie output
tmp=data.frame(transcript_id=transcript_ids,gene_id=gene_ids,gene_names=ref_gene_names)
tmp <- tmp[order(tmp$transcript_id),]

# create out data frame
out <- tmp

# now process all of the files, appending just the tpm and fpkm columns
for (i in 1:length(files)) {
    gtf <- read.delim(paste0("/OUTPUT/alignments/",files[i]), header=FALSE,comment.char = "#",stringsAsFactors=F)
    colnames(gtf) <- c("seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attributes")
    gtf <- subset(gtf,feature=="transcript") # only need transcripts

    gene_ids <-  gsub(".*gene_id (.*?);.*", "\\1", gtf$attributes) #get gene_id from attributes column
    transcript_ids<- gsub(".*transcript_id (.*?);.*", "\\1", gtf$attributes) #get transcript_id from attributes column
    ref_gene_names<- gsub(".*ref_gene_name (.*?);.*", "\\1", gtf$attributes) #get transcript_id from attributes column
    tpm <-  gsub(".*TPM (.*?);.*", "\\1", gtf$attributes) #get TPM from attributes column
    fpkm <- gsub(".*FPKM (.*?);.*", "\\1", gtf$attributes) #get FPKM from attributes column

    # create output
    tmp <- data.frame(transcript_id=transcript_ids,gene_id=gene_ids,tpm=tpm,fpkm=fpkm)
    
    # order by transcript_id for consistency
    tmp <- tmp[order(tmp$transcript_id),]
    
    # filename_tmp and filename_fpkm  - note we are stripping the .gtf 
    out[paste0(gsub(".gtf","",files[i]), "_tpm")]<-tmp$tpm
    out[paste0(gsub(".gtf","",files[i]), "_fpkm")]<-tmp$fpkm
    
}

write.table(out,file="transcript_expression.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)

