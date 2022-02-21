library(dplyr)

md<-read.delim("./SMC_ChIPseq_metadata.txt",sep=",")
#mda<-read.delim("./SMC_ChIPseq_metadata_a.txt",sep=",")
# remove empty columns
md[,31:39]<-NULL
md$antibody<-gsub("^seq-","",unlist(lapply(strsplit(md$source_name,"_"),"[[",1)))
md$target<-unlist(lapply(strsplit(md$source_name,"_"),"[[",2))
md$stage<-unlist(lapply(strsplit(md$source_name,"_"),"[[",4))
md$replicate<-unlist(lapply(strsplit(md$source_name,"_"),"[[",6))
#write.table(md,"./SMC_ChIPseq_metadata1.txt",row.names=F)

ips<-md[ifelse(grepl("ChIP",md$source_name),T,F),]
inputs<-md[ifelse(grepl("Input",md$source_name),T,F),]

mmd<-left_join(ips,inputs[c("Run","target","stage","replicate","Assay.Type","source_name","antibody","strain")],by=c("target","stage","replicate", "Assay.Type","antibody","strain"),na_matches="never")
dim(mmd)
#mmd[,c("source_name.x","source_name.y","Run.x","Run.y")]


SRR<-data.frame(input=mmd$Run.y,ip=mmd$Run.x, name=gsub("^seq-","",mmd$source_name.x)
,
                group=as.numeric(factor(gsub("_ChIP_Rep.$","",
                                             gsub("^seq-","",mmd$source_name.x)))))

write.table(SRR,file="./SRR_SMCmodEncode_ChIPseq.csv",row.names=F,sep=";",quote=F)
