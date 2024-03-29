library("tidyverse")

devStage="L3"

projDir<-getwd()
workDir<-paste0(projDir,"/modEncode_modHistone")

#########-
## Prepare table for chipseq pipeline -----
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
                          target=sapply(strsplit(sampleNames,"_"),"[",2),
                          replicate=l3$replicate_1)

sameTargetGroups<-factor(cleanMetadata$target)

SRRs<-data.frame(input=gsub(";"," ",l3$input),
                 ip=gsub(";"," ",l3$ip),
                 name=with(cleanMetadata,paste(target,strain,stage,sex,
                                               replicate,antibody,modEncodeID,
                                               sep="_")),
                 group=as.numeric(sameTargetGroups))


write.table(SRRs,paste0(projDir,"/SRR_modEncode_chromatinChipSeq_modHistone.csv"),
            sep=";",quote=F,row.names=F)


alreadyFetched<-cleanMetadata$modEncodeID
alreadyFetchedSrrs<-c(SRRs$input, SRRs$ip)
prjna63455<-read.csv2(paste0(projDir,"/SRR_namesPRJNA63455.csv"))
prjna<-c(unlist(lapply(prjna63455$input,strsplit," ")), unlist(lapply(prjna63455$ip,strsplit," ")))

alreadyFetchedSrrs %in% prjna # all included in previous download.


#########################-
# get ftp for other data------
#########################-
# load table of urls
ftpdata<-read.table(paste0(workDir,"/downloadurls_histoneMod.txt"),skip=1,
                    header=F)
colnames(ftpdata)<-c("modEncodeID","url")

# get rid of lines for wigs etc.
idx<-grepl("fastq.gz|fq.gz",ftpdata$url)
ftpdata<-ftpdata[idx,]

# reformat the modEncodeID
ftpdata$modEncodeID<-paste0("mE",ftpdata$modEncodeID)

# remove datasets already downloaded with GEO numbers
idx<-ftpdata$modEncodeID %in% alreadyFetched
ftpdata<-ftpdata[!idx,]

#load metadata
ftpmeta<-read.delim(paste0(workDir,"/metadata_histoneMod.tsv"))
mEids<-strsplit(ftpmeta$ID,", |and ")
mEcount<-data.frame(datasetGroup=1:length(mEids), datasetCount=sapply(mEids,length))

mEidTbl<-data.frame(modEncodeID=unlist(mEids),datasetGroup=rep(mEcount$datasetGroup,mEcount$datasetCount))
mEidTbl$modEncodeID<-gsub(" ","",mEidTbl$modEncodeID)
mEidTbl<-mEidTbl[!mEidTbl$modEncodeID=="",]
mEidTbl$modEncodeID<-paste0("mE",mEidTbl$modEncodeID)

match(ftpdata$modEncodeID, mEidTbl$modEncodeID)
ftpdata<-left_join(ftpdata,mEidTbl,by="modEncodeID")
ftpdata<-cbind(ftpdata,ftpmeta[ftpdata$datasetGroup,])

# restrict to l3
idx<-grep("L3",ftpdata$Conditions)
l3<-ftpdata[idx,]

l3ftpWithSrr<-l3$url[grep("SRR\\d*",l3$url)]
l3ftpWithSrr<-gsub("\\.fastq\\.gz","",substring(l3ftpWithSrr,regexpr("SRR\\d*",l3ftpWithSrr)))
l3ftpWithSrr %in% alreadyFetchedSrrs # none have been included

# part of PRJNA63461 project
prjna63461<-read.csv("/Users/semple/Documents/MeisterLab/Datasets/PRJNA63461_functGenomics/PRJNA63461_modencode_functionalGenomics.txt")
l3ftpWithSrr %in% prjna63461$Run # yes, for all but three
l3ftpWithSrr[!l3ftpWithSrr %in% prjna63461$Run] %in% prjna
# all are  members of PRJNA63455


# and the remaining ones?
# find mE ids of ones with srr in order to remove them
mEinPrjna<-unique(l3$modEncodeID[grep("SRR\\d*",l3$url)])

l3noSrr<-l3[! l3$modEncodeID %in% mEinPrjna,]
# only 4 datasets: 5051,5053,5054,5055
# all these samples have the same input with Fxx01175 and Fxx01517 in the name
# In the url file they have a .txt.gz extension for some reason
