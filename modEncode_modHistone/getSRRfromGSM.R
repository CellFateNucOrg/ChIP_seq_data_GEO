library(reutils)
library(xml2)
library(stringr)


#esearch -db sra -query "GSM123456" | efetch -format docsum | xtract -pattern DocumentSummary -element Runs | perl -ne '@mt = ($_ =~ /SRR\d+/g); print "@mt\n"'`
#
geoNum="GSM1217461"

geoToSra<-function(geoNum){
  df<-tryCatch(
  {
   es<-reutils::esearch(geoNum,"sra")
   ef<-reutils::efetch(es)
   ex<-reutils::content(ef,as="xml")
   XML::getNodeSet(ex,"//SAMPLE_ATTRIBUTE")
   #getNodeSet(ex,"//RUN_SET/RUN/SRAFiles/SRAFile")
   ns<-XML::getNodeSet(ex,"//@url")
   srrNum<-unique(sapply(ns,stringr::str_extract,pattern="SRR\\d*"))
   if(length(srrNum)>1){
     srrNum<-paste(srrNum,collapse=",")
   }

   #XML::getNodeSet(ex,"//SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE")
   name<-XML::xmlValue(XML::getNodeSet(ex,"//SAMPLE /SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG='source_name']/VALUE"))
   strain<-XML::xmlValue(XML::getNodeSet(ex,"//SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG='strain']/VALUE"))
   stage<-XML::xmlValue(XML::getNodeSet(ex,"//SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG='developmental stage']/VALUE"))
   genotype<-XML::xmlValue(XML::getNodeSet(ex,"//SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG='genotype']/VALUE"))
   sex<-XML::xmlValue(XML::getNodeSet(ex,"//SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG='sex type']/VALUE | //SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG='Sex']/VALUE"))

   df<-data.frame(GEO=geoNum, SRR=srrNum, name=name, strain=strain,
                 stage=stage, genotype=genotype,sex=sex)
  },
  error=function(e){
    message(paste("could not get data for",geoNum))
    df<-data.frame(GEO=geoNum, SRR=NA, name=NA, strain=NA,
                 stage=NA, genotype=NA,sex=NA)
    return(df)
  }
  )
  return(df)
}


processGeoNumList<-function(geoNums){
  df<-lapply(geoNums,geoToSra)
  df<-do.call(rbind,df)
  df$input<-grepl("Input",df$name)
  df$ip<-grepl("ChIP",df$name)
  df$rep1<-grepl("rep1",df$name,ignore.case=T)
  df$rep2<-grepl("rep2",df$name,ignore.case=T)
  return(df)
}




geoTable<-read.csv(file="modEncode_chromatinChipSeq_modHistone.csv",header=T, stringsAsFactors=F)
#geoTable<-data.frame(readxl::read_excel("modEncode_chromatinChipSeq_modHistone.xlsx", 3))

geoNums<-unlist(sapply(geoTable$GEO,strsplit,split=";"),use.names=F)
geoNums<-na.omit(geoNums)
srrTable<-processGeoNumList(geoNums)

# the failed fetches:
srrTable[rowSums(is.na(srrTable))>1,]
srrTable[(srrTable$input + srrTable$ip)!=1,]
srrTable[(srrTable$rep1 + srrTable$rep2)!=1,]

mergeGeoSrrTables<-function(geoTable,srrTable){
  geoTable$input<-NA
  geoTable$ip<-NA
  geoTable$name_1<-NA
  geoTable$genotype_1<-NA
  geoTable$strain_1<-NA
  geoTable$stage_1<-NA
  geoTable$sex_1<-NA
  input1<-srrTable$input & srrTable$rep1
  input2<-srrTable$input & srrTable$rep2
  ip1<-srrTable$ip & srrTable$rep1
  ip2<-srrTable$ip & srrTable$rep2
  for(i in 1:nrow(geoTable)){
    geoNums<-geoTable$GEO[i]
    geoNums<-unlist(stringr::str_split(geoNums,";"))
    idx<-match(geoNums,srrTable$GEO)
    geoTable$input[i]<-paste0(
      c(srrTable$SRR[idx][input1[idx]],
        srrTable$SRR[idx][input2[idx]]), collapse=";")
    geoTable$ip[i]<-paste0(
      c(srrTable$SRR[idx][ip1[idx]],
        srrTable$SRR[idx][ip2[idx]]), collapse=";")
    geoTable$name_1[i]<-srrTable$name[idx][1]
    geoTable$genotype_1[i]<-srrTable$genotype[idx][1]
    geoTable$strain_1[i]<-srrTable$strain[idx][1]
    geoTable$stage_1[i]<-srrTable$stage[idx][1]
    geoTable$sex_1[i]<-srrTable$sex[idx][1]
    geoNums<-NULL
  }
  return(geoTable)
}

fullTable<-mergeGeoSrrTables(geoTable,srrTable)

write.table(fullTable, file="modEncode_chromatinChipSeq_modHistone_fullTable.tsv", sep="\t", row.names=F)


