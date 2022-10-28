#!/bin/bash
#$1 is the line of the csv file with the dataset to map
#$2 is the number of threads per cpu
source ./file_locations.sh
echo $list_file_name

echo $working_path
taskID=$1
echo $taskID
nThreads=$2
echo $nThreads threads used per task
slurmOutFile=$3
echo $slurmOutFile is slurm output file

#extract experiment name
SRR_exp=(`grep -v "input;ip;name;group" $list_file_name | sed -n ${taskID}p | cut -f3 -d";"`)
echo "Experiment name $SRR_exp"
#echo "IP SRR: ${SRR_IP[@]}"
echo "-------------------------------"
#create folder for SRR download
[ ! -d $working_path ] && mkdir $working_path

#echo "Now downloading data from GEO..."
bash 00_download.sh $taskID $SRR_exp $nThreads $slurmOutFile

echo "Now trimming fastq files..."
bash 01_trimming.sh $taskID $SRR_exp $nThreads

echo "Now mapping fastq files using bowtie2..."
bash 02_map.sh $SRR_exp $nThreads

echo "Now sorting mapped files..."
bash 03_sort.sh $SRR_exp $nThreads

echo "Now deduplicating files using picard and filtering blacklisted..."
bash 04_dedup.sh $SRR_exp $nThreads

echo "Now calculating enrichment..."
bash 05_normalize.sh $SRR_exp

echo "This is over"
