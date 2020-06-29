#!/bin/bash
#$1 is the full filename (with directory location) of the csv file with the ChIP set SRR info
#$2 is the line of the csv file with the ChIP dataset to map
file_name=$1
#echo $file_name
echo $working_path
SRR_line_number=$2
#echo $SRR_line_number
#echo "This is the line"
#create folder for SRR download if it does not exists
#$(awk -F ',' 'NR=="'SRR_line_number'"' '{printf"%s",$1$3}' $file_name | tr -d '"')
SRR_exp=$(awk -F ";" 'NR=="'$SRR_line_number'" {print $3}' $file_name | tr ';' ' ' | tr '"' ' ' | tr -s ' ')
SRR_IP=$(awk -F ";" 'NR=="'$SRR_line_number'" {print $2}' $file_name |  tr ';' ' ' | tr '"' ' ' | tr -s ' ')
SRR_input=$(awk -F ";" 'NR=="'$SRR_line_number'" {print $1}' $file_name  | tr ';' ' ' | tr '"' ' ' | tr -s ' ')
echo "Experiment name $SRR_exp"
echo "input SRR: $SRR_input"
echo "IP SRR: $SRR_IP"
echo "-------------------------------"
#create folder for SRR download
[ ! -d $working_path/$SRR_exp ] && mkdir $working_path/$SRR_exp
echo "Now downloading data from GEO..."
bash 00_download.sh $SRR_exp "$SRR_IP" "$SRR_input"
echo "Now trimming fastq files..."
bash 01_trimming.sh $SRR_exp

echo "Now mapping fastq files using bowtie2..."
bash 02_map.sh $SRR_exp

echo "Now sorting mapped files..."
bash 03_sort.sh $SRR_exp

echo "Now deduplicating files using picard..."
bash 04_dedup.sh $SRR_exp

echo "Now calculating enrichment..."
bash 05_normalize.sh $SRR_exp 

echo "Cleaning up..."
cd $working_path/$SRR_exp
rm -r SRR_download
rm trimmed_fq/*.fq.gz
rm -r bam
cd $working_path/
echo "This is over"
