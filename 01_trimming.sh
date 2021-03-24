#!/bin/bash
module add UHTS/Quality_control/cutadapt/2.5;
module add UHTS/Quality_control/fastqc/0.11.7;
SRR_exp=$1
nThreads=$2
SRR_input=$(find $working_path/$SRR_exp/SRR_download/input/ -type f -name "*.fastq.gz")
SRR_IP=$(find $working_path/$SRR_exp/SRR_download/IP/ -type f -name "*.fastq.gz")
echo "Input files: $SRR_input" 
echo "IP files: $SRR_IP"
cat $SRR_input > $working_path/$SRR_exp/SRR_download/input/input.fq.gz
cat $SRR_IP > $working_path/$SRR_exp/SRR_download/IP/IP.fq.gz

rm $SRR_input
rm $SRR_IP

[ ! -d "$working_path/$SRR_exp/trimmed_fq" ] && mkdir $working_path/$SRR_exp/trimmed_fq
FILES=$(find $working_path/$SRR_exp/SRR_download/ -type f -name "*.fq.gz")
echo $FILES

for f in $FILES
do
 target_name=${f##*/}
 target_name=${target_name%.fq.gz}
 #target_name=${target_name%_trimmed}
 if [ ! -f "$working_path/$SRR_exp/trimmed_fq/${target_name}_trimmed.fq.gz" ]; then
   echo "Trimming $f..."
   $trim_galore_location/trim_galore -o $working_path/$SRR_exp/trimmed_fq -q 2 --illumina --gzip -j $nThreads --fastqc $f 
 else
   echo "Trimmed $f already present"
 fi
done

# move qc data to the qc directory
[ ! -d "$working_path/qc/$SRR_exp" ] && mkdir $working_path/qc/$SRR_exp
mv $working_path/$SRR_exp/trimmed_fq/*_trimmed_fastqc.html $working_path/qc/$SRR_exp/
mv $working_path/$SRR_exp/trimmed_fq/*_trimming_report.txt $working_path/qc/$SRR_exp/
mv $working_path/$SRR_exp/trimmed_fq/*_trimmed_fastqc.zip $working_path/qc/$SRR_exp/

module rm UHTS/Quality_control/cutadapt/2.5;
module rm UHTS/Quality_control/fastqc/0.11.7;
