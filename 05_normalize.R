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
#2. mapping with bowtie2 (in ./bam folder)
#3. sorting with samtools (in ./bam folder)
#4. deduplicated with picard (in ./dedup folder)
#5. sorted with samtools (in ./dedup folder)

setwd(paste0("./",args[1],"/"))
current_dir <- getwd()
print(current_dir)
read_depth <- matrix(nrow=2, ncol=1)
filenames <- list.files(path="./dedup/", pattern="*_sorted_dedup_sorted.bam$")
print(filenames)
#RPM calculations, calculate for each position the coverage, with no pseudocount
for (i in (1:length(filenames)))
{
  f <- filenames[i]
  #read in bam file
  bamFile<-readGAlignments(paste0("./dedup/",f))
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
  export.bw(rpm_norm, paste0("./norm/",gsub(".bam","_no_pseudo_ext200_norm.bw",filenames[i])))
}

#Save the mapped read number for each library with correct row names and column name
rownames(read_depth)<- filenames
colnames(read_depth)<-"mapped_reads"
write.table(read_depth,("./norm/Sequencing_depth.txt"))

#Command to re-load mapped read numbers from the txt file saved just above.
#read_depth <- as.matrix(read.table("./norm/Sequencing_depth.txt"))

#Substract normalized mapped read counts at each position
#Load paired input/IP RPM bigwig tracks
  input <-import("./norm/input_trimmed_sorted_dedup_sorted_no_pseudo_ext200_norm.bw")
print("Input loaded")
  ChIP <- import("./norm/IP_trimmed_sorted_dedup_sorted_no_pseudo_ext200_norm.bw")
 print("IP loaded")  
#Calculate enrichment by substracting input to IP 
  enrichment <- (mcolAsRleList(ChIP,"score"))-(mcolAsRleList(input,"score"))
  #Transform RleList into GRange
  enrichment <- bindAsGRanges(enrichment)
  #Change mcol name for saving as bigwig
  names(mcols(enrichment))<-"score"
  #Save track as bigwig in ./enrichment
  export.bw(enrichment, paste0("./enrichment/ChIP_enrichment_substract_norm_",args[1],".bw"))

