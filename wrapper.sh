#!/bin/bash
#$1 is the line of the csv file with the dataset to map
#$2 is the number of threads per cpu
source ./file_locations.sh
echo $list_file_name

echo $working_path
line_number=$1
echo $SRR_line_number
nThreads=$2
echo $nThreads threads used per task
slurmOutFile=$3
echo $slurmOutFile is slurm output file

#create folder for SRR download if it does not exists
#$(awk -F ',' 'NR=="'SRR_line_number'"' '{printf"%s",$1$3}' $file_name | tr -d '"')
#SRR_exp=$(awk -F ";" 'NR=="'$SRR_line_number'" {print $3}' $list_file_name | tr ';' ' ' | tr '"' ' ' | tr -s ' ')
#SRR_IP=$(awk -F ";" 'NR=="'$SRR_line_number'" {print $2}' $list_file_name |  tr ';' ' ' | tr '"' ' ' | tr -s ' ')
#SRR_input=$(awk -F ";" 'NR=="'$SRR_line_number'" {print $1}' $list_file_name  | tr ';' ' ' | tr '"' ' ' | tr -s ' ')
SRR_exps=(`cut -f3 -d";" $list_file_name`)
SRR_IPs=(`cut -f2 -d";" $list_file_name`)
SRR_inputs=(`cut -f1 -d";" $list_file_name`)

SRR_exp=${SRR_exps[$line_number]}
SRR_IP=${SRR_IPs[$line_number]}
SRR_input=${SRR_inputs[$line_number]}
echo "Experiment name $SRR_exp"
echo "input SRR: $SRR_input"
echo "IP SRR: $SRR_IP"
echo "-------------------------------"
#create folder for SRR download
[ ! -d $working_path/$SRR_exp ] && mkdir $working_path/$SRR_exp

#echo "Now downloading data from GEO..."
#bash 00_download.sh $SRR_exp $SRR_IP $SRR_input $nThreads $slurmOutFile

echo "Now trimming fastq files..."
#bash 01_trimming.sh $SRR_exp $nThreads

echo "Now mapping fastq files using bowtie2..."
#bash 02_map.sh $SRR_exp $nThreads

echo "Now sorting mapped files..."
#bash 03_sort.sh $SRR_exp $nThreads

echo "Now deduplicating files using picard..."
#bash 04_dedup.sh $SRR_exp $nThreads

echo "Now calculating enrichment..."
bash 05_normaliseThor.sh $SRR_exp

#echo "Cleaning up..."
#cd $working_path/$SRR_exp
#rm -r SRR_download
#rm -r trimmed_fq
#rm -r bam
#rm -r dedup
#rm -r filt
#rm -r norm
#rm -r enrichment
#cd $working_path/
echo "This is over"
