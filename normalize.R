#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
library(GenomicRanges)
library(BSgenome.Celegans.UCSC.ce11)
library(GenomicAlignments)
library(rtracklayer)
genome = Celegans

print(args)
#Set parent directory holding the scripts and a folder called ./dedup/ with the reads after 
#0. copied fastq files (in ./SRR_download folder)
#1. trimming with trim_galore (in ./trimmed_fq folder)
#2. mapping with bwa (in ./bam folder)
#3. sorting with samtools (in ./bam folder)
#4. deduplicated with picard and filtering out blacklisted and multimappers (in ./dedup and ./filt folders)
#5. sorted and indexed with samtools (in ./filt folder)

working_dir<-args[1]
exp_name<-args[2]
print(working_dir)
print(exp_name)
if( !  dir.exists(paste0(working_dir,"/norm/"))){
	dir.create(paste0(working_dir,"/norm/"))
}
if( !  dir.exists(paste0(working_dir,"/enrich_subtract/"))){
        dir.create(paste0(working_dir,"/enrich_subtract/"))
}
if( !  dir.exists(paste0(working_dir,"/enrich_ratio/"))){
        dir.create(paste0(working_dir,"/enrich_ratio/"))
}


read_depth <- matrix(nrow=2, ncol=1)
filenames <- list.files(path=paste0(working_dir,"/filt/"), pattern=paste0(exp_name,".*_trim_sort_dedup_filt_sort.bam$"))
print("normalising")
print(filenames)
#RPM calculations, calculate for each position the coverage, with no pseudocount
for (i in (1:length(filenames)))
{
  f <- filenames[i]
  #read in bam file
  bamFile<-readGAlignments(paste0(working_dir,"/filt/",f))
  bamFile<-GRanges(bamFile)
  #extend reads to 200 bp from the start, taking into account the directionality 
  #(identical to MACS pileup)
  bamFile<- resize(granges(bamFile),200,fix="start",ignore.strand=FALSE)
  #Calculate coverage
  sampleCoverage<-coverage(bamFile)[1:7]
  #print(sampleCoverage)
  #Store mapped read number somewhere
  read_depth[i,1] <- length(bamFile)
  #Normalize to the number of million reads (RPM)
  rpm_norm <- (sampleCoverage)/length(bamFile)*10^6
  rpm_norm <- bindAsGRanges(rpm_norm)
  names(mcols(rpm_norm))<-"score"
  #Save bigwig file in ./norm/ folder
  export.bw(rpm_norm, paste0(working_dir,"/norm/",gsub(".bam","_no_pseudo_ext200_norm.bw",filenames[i])))
}

#Save the mapped read number for each library with correct row names and column name
rownames(read_depth)<- filenames
colnames(read_depth)<-"mapped_reads"
if(! dir.exists(paste0(working_dir,"/qc/"))){
 dir.create(paste0(working_dir,"/qc/"))
}
write.table(read_depth,paste0(working_dir,"/qc/",exp_name,"_Sequencing_depth.txt"))

#Command to re-load mapped read numbers from the txt file saved just above.
#read_depth <- as.matrix(read.table("./norm/Sequencing_depth.txt"))

#Substract normalized mapped read counts at each position
#Load paired input/IP RPM bigwig tracks
input <-import(paste0(working_dir,"/norm/",exp_name,"_input_trim_sort_dedup_filt_sort_no_pseudo_ext200_norm.bw"))
print("Input loaded")
seqlevels(input)<-seqlevels(genome) # make sure levels are in same order
seqinfo(input)<-seqinfo(genome) #add circular and genome version data
print(paste0(sum(is.na(input$score))," NAs in input"))
print(sapply(mcolAsRleList(input,"score"),length)==seqlengths(genome))

ChIP <- import(paste0(working_dir,"/norm/",exp_name,"_IP_trim_sort_dedup_filt_sort_no_pseudo_ext200_norm.bw"))
print("IP loaded")  
seqlevels(ChIP)<-seqlevels(genome)
seqinfo(ChIP)<-seqinfo(genome)
print(paste0(sum(is.na(ChIP$score))," NAs in ChIP"))
print(sapply(mcolAsRleList(ChIP,"score"),length)==seqlengths(genome))

#Calculate enrichment by substracting input from IP 
enrichment <- (mcolAsRleList(ChIP,"score"))-(mcolAsRleList(input,"score"))
#Transform RleList into GRange
enrichment <- bindAsGRanges(enrichment)
#Change mcol name for saving as bigwig
names(mcols(enrichment))<-"score"
print(paste0(sum(is.na(enrichment$score))," NAs in input"))

#Save track as bigwig in ./enrichment
#export.bw(enrichment, paste0(working_dir,"/enrichment/ChIP_enrichment_substract_norm_",rev(unlist(strsplit(working_dir,"/")))[1],".bw"))
export.bw(enrichment, paste0(working_dir,"/enrich_subtract/",exp_name,"_ChIP_norm_minusInput.bw"))


#Calculate enrichment by ratio of IP over input (add psuedo count of 1 to get rid of 0s)
enrichment_ratio <- (mcolAsRleList(ChIP,"score")+1)/(mcolAsRleList(input,"score")+1)
#Transform RleList into GRange
enrichment_ratio <- bindAsGRanges(enrichment_ratio)
#Change mcol name for saving as bigwig
names(mcols(enrichment_ratio))<-"score"
print(paste0(sum(is.na(enrichment$score))," NAs in input"))

#Save track as bigwig in ./enrichment
#export.bw(enrichment, paste0(working_dir,"/enrichment/ChIP_enrichment_substract_norm_",rev(unlist(strsplit(working_dir,"/")))[1],".bw"))
export.bw(enrichment_ratio, paste0(working_dir,"/enrich_ratio/",exp_name,"_ChIP_norm_ratioIPinput.bw"))
