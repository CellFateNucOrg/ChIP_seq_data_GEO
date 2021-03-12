#!/bin/bash
module add UHTS/Quality_control/cutadapt/2.5;
module add UHTS/Quality_control/fastqc/0.11.7;
SRR_exp=$1
nThreads=$2
SRR_input=$(find $working_path/$SRR_exp/SRR_download/input/ -type f -name "*.fastq")
SRR_IP=$(find $working_path/$SRR_exp/SRR_download/IP/ -type f -name "*.fastq")
echo "Input files: $SRR_input" 
echo "IP files: $SRR_IP"
cat $SRR_input > $working_path/$SRR_exp/SRR_download/input/input.fq
cat $SRR_IP > $working_path/$SRR_exp/SRR_download/IP/IP.fq

[ ! -d "$working_path/$SRR_exp/trimmed_fq" ] && mkdir $working_path/$SRR_exp/trimmed_fq
FILES=$(find $working_path/$SRR_exp/SRR_download/ -type f -name "*.fq")
echo $FILES

for f in $FILES
do
 target_name=${f##*/}
 target_name=${target_name%.fq}
 #target_name=${target_name%_trimmed}
 if [ ! -f "$working_path/$SRR_exp/trimmed_fq/${target_name}_trimmed.fq" ]; then
   echo "Trimming $f..."
   $trim_galore_location/trim_galore -o $working_path/$SRR_exp/trimmed_fq -q 2 --three_prime_clip_R1 50 --illumina --gzip -j 2 --fastqc $f 
 else
   echo "Trimmed $f already present"
 fi
done
module rm UHTS/Quality_control/cutadapt/2.5;
module rm UHTS/Quality_control/fastqc/0.11.7;
