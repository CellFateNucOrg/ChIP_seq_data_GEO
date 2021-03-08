devStage="L3"

projDir<-getwd()
workDir<-paste0(projDir,"/modEncode_modHistone")

#########-
## Prepare table for chipseq pipeline
#########-

# make SRR file for datasets that have geo
chipdata<-read.delim(paste0(workDir, "/modEncode_chromatinChipSeq_modHistone_fullTable.tsv"))

l3<-chipdata[grepl(devStage,chipdata$stage_1) & !is.na(chipdata$name_1),]
sampleNames<-sapply(strsplit(l3$name_1,";"),"[",1)
sampleNames<-gsub(paste0("_N2_L3.*$"),"",gsub("^seq-","",sampleNames))
sampleNames<-gsub(":","_",sampleNames)

cleanMetadata<-data.frame(modEncodeID=gsub("modENCODE_","mE",l3$DCC.id),
                          strain=l3$strain_1, stage=gsub(" Larva","",l3$stage_1),
                          sex=gsub("mixed Male and Hermaphrodite population",
                                   "maleherm",l3$sex_1),
                          antibody=sapply(strsplit(sampleNames,"_"),"[",1),
                          target=sapply(strsplit(sampleNames,"_"),"[",2))

sameTargetGroups<-factor(cleanMetadata$target)

SRRs<-data.frame(input=gsub(";"," ",l3$input),
                 ip=gsub(";"," ",l3$ip),
                 name=with(cleanMetadata,paste(target,modEncodeID,strain,stage,sex,antibody,sep="_")),
                 group=as.numeric(sameTargetGroups))


write.table()



# get ftp for other data
ftpdata<-read.table("downloadurls_histoneMod.txt",skip=1,header=F)
colnames(ftpdata)<-c("ID","url")
idx<-grepl("fastq.gz|fq.gz",ftpdata$url)
ftpdata<-ftpdata[idx,]

idx<-(gsub("modENCODE_","",chipdata$DCC.id) %in% ftpdata$ID) & is.na(chipdata$name_1)
chipdata[idx,]
