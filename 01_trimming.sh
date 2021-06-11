#!/bin/bash
module add UHTS/Quality_control/cutadapt/2.5;
module add UHTS/Quality_control/fastqc/0.11.7;
SRR_exp=$1
nThreads=$2
SRR_input=$(find $working_path/SRR_download/$SRR_exp/input/ -type f -name "*.fastq.gz")
SRR_IP=$(find $working_path/SRR_download/$SRR_exp/IP/ -type f -name "*.fastq.gz")
echo "Input files: $SRR_input" 
echo "IP files: $SRR_IP"
cat $SRR_input > $working_path/SRR_download/$SRR_exp/input/${SRR_exp}_input.fq.gz
cat $SRR_IP > $working_path/SRR_download/$SRR_exp/IP/${SRR_exp}_IP.fq.gz

rm $SRR_input
rm $SRR_IP

[ ! -d "$working_path/trim" ] && mkdir $working_path/trim
FILES=$(find $working_path/SRR_download/$SRR_exp/ -type f -name "*.fq.gz")
echo $FILES

for f in $FILES
do
 target_name=${f##*/}
 target_name=${target_name%.fq.gz}
 #target_name=${target_name%_trimmed}
 if [ ! -f "$working_path/trim/${target_name}_trimmed.fq.gz" ]; then
   echo "Trimming $f..."
   $trim_galore_location/trim_galore -o $working_path/trim/ -q 2 --illumina --gzip -j $nThreads --fastqc $f 
 else
   echo "Trimmed $f already present"
 fi
done

# move qc data to the qc directory
[ ! -d "$working_path/qc/$SRR_exp" ] && mkdir $working_path/qc/$SRR_exp
mv $working_path/trim/${SRR_exp}_*_fastqc.html $working_path/qc/$SRR_exp/
mv $working_path/trim/${SRR_exp}_*_report.txt $working_path/qc/$SRR_exp/
mv $working_path/trim/${SRR_exp}_*_fastqc.zip $working_path/qc/$SRR_exp/

module rm UHTS/Quality_control/cutadapt/2.5;
module rm UHTS/Quality_control/fastqc/0.11.7;
