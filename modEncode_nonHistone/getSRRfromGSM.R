library(reutils)
library(xml2)
library(stringr)

projDir<-getwd()
workDir<-paste0(projDir,"/modEncode_nonHistone")


#esearch -db sra -query "GSM123456" | efetch -format docsum | xtract -pattern DocumentSummary -element Runs | perl -ne '@mt = ($_ =~ /SRR\d+/g); print "@mt\n"'`
#
#geoNum="GSM1217461"

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




geoTable<-read.csv(file=paste0(workDir,"/modEncode_chromatinChipSeq_nonHistone.csv"),
                   header=T, stringsAsFactors=F)
#geoTable<-data.frame(readxl::read_excel("modEncode_chromatinChipSeq_modHistone.xlsx", 3))
geoTable$GEO<-sapply(geoTable$GEO,function (x) gsub("^\\s+|\\s+$", "", x))
geoNums<-unlist(sapply(geoTable$GEO,strsplit,split=";"),use.names=F)
geoNums<-na.omit(geoNums)
srrTable<-processGeoNumList(geoNums)

# the failed fetches:
srrTable[rowSums(is.na(srrTable))>1,]
srrTable[(srrTable$input + srrTable$ip)!=1,]
srrTable[(srrTable$rep1 + srrTable$rep2)!=1,]

# mergeGeoSrrTables<-function(geoTable,srrTable){
#   geoTable$input<-NA
#   geoTable$ip<-NA
#   geoTable$name_1<-NA
#   geoTable$genotype_1<-NA
#   geoTable$strain_1<-NA
#   geoTable$stage_1<-NA
#   geoTable$sex_1<-NA
#   input1<-srrTable$input & srrTable$rep1
#   input2<-srrTable$input & srrTable$rep2
#   ip1<-srrTable$ip & srrTable$rep1
#   ip2<-srrTable$ip & srrTable$rep2
#   for(i in 1:nrow(geoTable)){
#     geoNums<-geoTable$GEO[i]
#     geoNums<-unlist(stringr::str_split(geoNums,";"))
#     idx<-match(geoNums,srrTable$GEO)
#     geoTable$input[i]<-paste0(
#       c(srrTable$SRR[idx][input1[idx]],
#         srrTable$SRR[idx][input2[idx]]), collapse=";")
#     geoTable$ip[i]<-paste0(
#       c(srrTable$SRR[idx][ip1[idx]],
#         srrTable$SRR[idx][ip2[idx]]), collapse=";")
#     geoTable$name_1[i]<-paste0(c(srrTable$name[idx], collapes=";"))
#     geoTable$genotype_1[i]<-srrTable$genotype[idx][1]
#     geoTable$strain_1[i]<-srrTable$strain[idx][1]
#     geoTable$stage_1[i]<-srrTable$stage[idx][1]
#     geoTable$sex_1[i]<-srrTable$sex[idx][1]
#     geoNums<-NULL
#   }
#   return(geoTable)
# }


mergeGeoSrrTables1<-function(geoTable,srrTable){
  newTable<-NULL
  failed<-c()
  for(i in 1:nrow(geoTable)){
    print(i)
    geoNums<-geoTable$GEO[i]
    geoNums<-unlist(stringr::str_split(geoNums,";"))

    dfline<-cbind(geoTable[i,], data.frame(input_1=NA, ip_1=NA, name_1=NA,
                                           genotype_1=NA, strain_1=NA,
                                           stage_1=NA, sex_1=NA, replicate_1=NA,
                                           group_1=i))
    dflines<-as.data.frame(do.call("rbind",replicate(ceiling(length(geoNums)/2),
                                                     dfline,simplify=F)))

    idx<-match(geoNums,srrTable$GEO)
    if(length(geoNums)==1){
      print(paste("no geo IDs: line",i))
      failed<-c(failed,i)
      next;
    } else if(length(geoNums)>4){
      print(paste("More than two replicates! did not process:",
                   paste0(geoNums, collapse=";")))
      failed<-c(failed,i)
      next;
    } else if(length(geoNums)>2){
      #print(paste("processing 2 replicates",i,paste0(geoNums,collapse=";")))
      tryCatch({ dflines$input_1<-srrTable$SRR[idx][srrTable$input[idx]]},
              error=function(e){
                message(paste("No input SRRs",paste(geoNums,collapse=","),"line",i))
                dflines$input_1<-NA
                })
      tryCatch({dflines$ip_1<-srrTable$SRR[idx][srrTable$ip[idx]]},
              error=function(e){
                message(paste("No ip SRRs",paste(geoNums,collapse=","),"line",i))
                dflines$ip_1<-NA})
      dflines$name_1<-rbind(paste0(srrTable$name[idx][srrTable$rep1[idx]],
                                     collapse=";"),
                            ifelse(any(srrTable$rep2[idx]==TRUE),
                               paste0(srrTable$name[idx][srrTable$rep2[idx]],
                                     collapse=";"),
                               NA))
    } else if(length(geoNums)<=2) {
      print(paste("processing 1 replicate",i,paste0(geoNums,collapse=";")))
      dflines$input_1<-srrTable$SRR[idx][srrTable$input[idx]]
      dflines$ip_1<-srrTable$SRR[idx][srrTable$ip[idx]]
      dflines$name_1<-paste0(srrTable$name[idx][srrTable$rep1[idx]],
                               collapse=";")
    } else {
      print("failed for unknown reason: ",i)
      failed<-c(failed,i)
      next;
    }
    dflines$replicate_1<-paste0("rep",1:(length(geoNums)/2))
    dflines$genotype_1<-srrTable$genotype[idx][1]
    dflines$strain_1<-srrTable$strain[idx][1]
    dflines$stage_1<-srrTable$stage[idx][1]
    dflines$sex_1<-srrTable$sex[idx][1]
    if(is.null(newTable)){
      newTable<-dflines
    } else {
      newTable<-rbind(newTable,dflines)
    }
    geoNums<-NULL
  }
  print(paste0("failed rows: ",paste(failed,collapse=",")))
  return(newTable)
}





#fullTable<-mergeGeoSrrTables(geoTable,srrTable)


fullTable1<-mergeGeoSrrTables1(geoTable,srrTable)
write.table(fullTable1, file=paste0(workDir,"/modEncode_chromatinChipSeq_nonHistone_fullTable.tsv"), sep="\t", row.names=F)


