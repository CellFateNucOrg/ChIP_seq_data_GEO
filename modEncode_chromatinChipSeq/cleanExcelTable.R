library("readxl")

projDir<-getwd()
workDir<-paste0(projDir,"/modEncode_chromatinChipSeq")

xl<-read_excel(paste0(workDir,"/modEncode_chromatinChipSeq_mix.xlsx"),
               sheet="Sheet2")
options(tibble.width = Inf)

dataStart<-grep("modENCODE",xl$`DCC id`)
dataEnd<-c(dataStart[2:length(dataStart)]-1,nrow(xl))

cleanTbl<-NULL
for(i in 1:length(dataStart)){
  data1<-xl[dataStart[i]:dataEnd[i],]
  data1$`Embargoed until`<-NULL
  colnames(data1)<-c("DCC.id","Name","developmental.stage","antibody",
                     "strain","temperature","GEO")
  newLine<-data1[1,]
  newLine$target<-gsub("\\s*$","",gsub("^target:\\s","",data1$antibody[2]))
  if(is.na(newLine$target)){
    antibody_target<-unlist(strsplit(newLine$antibody,"\\/\\s"))
    newLine$target<-antibody_target[2]
    newLine$antibody<-antibody_target[1]
  }
  geos<-data1$GEO[grep("GEO",data1$GEO)]
  geos<-gsub("\\s*$","",substring(geos,regexpr("GSM\\d*", geos)))
  newLine$GEO<-paste0(geos,collapse=";")
  newLine$antibody<-gsub("\\s*\\d*$","",gsub("\\[ALL\\]\\s\\/","",newLine$antibody))
  newLine[1,]<-t(as.tibble(gsub("\\s*$","",gsub("\\[ALL\\]\\s*$","",newLine))))
  if(is.null(cleanTbl)){
    cleanTbl<-newLine
  } else {
    cleanTbl<-rbind(cleanTbl,newLine)
  }
}

cleanTbl$order<-as.character(1:nrow(cleanTbl))

cleanTbl<-cleanTbl[,c("order","DCC.id","Name","developmental.stage","antibody",
                     "target","strain","temperature","GEO")]

# some manual cleaning:
cleanTbl$antibody<-gsub("^C. elegans ","",cleanTbl$antibody)
cleanTbl$antibody<-gsub(" rabbit polyclonal antibody$","",cleanTbl$antibody)
cleanTbl$target[c(1,2)]<-sapply(strsplit(cleanTbl$antibody[c(1,2)], "_"),"[",2)
cleanTbl$developmental.stage<-gsub("DevStageWorm:","",cleanTbl$developmental.stage)

write.csv(cleanTbl,file=paste0(workDir,"/modEncode_chromatinChipSeq_mix.csv"),
          row.names=F)
