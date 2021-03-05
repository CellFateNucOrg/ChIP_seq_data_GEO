devStage="L3"


#########-
## Prepare table for chipseq pipeline
#########-

# make SRR file for datasets that have geo
chipdata<-read.delim("modEncode_chromatinChipSeq_modHistone_fullTable.tsv")

l3<-chipdata[grepl(devStage,chipdata$stage_1) & !is.na(chipdata$name_1),]



# get ftp for other data
ftpdata<-read.table("downloadurls_histoneMod.txt",skip=1,header=F)
colnames(ftpdata)<-c("ID","url")
idx<-grepl("fastq.gz|fq.gz",ftpdata$url)
ftpdata<-ftpdata[idx,]

idx<-(gsub("modENCODE_","",chipdata$DCC.id) %in% ftpdata$ID) & is.na(chipdata$name_1)
chipdata[idx,]
