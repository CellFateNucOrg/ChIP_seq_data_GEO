#!/bin/bash
module add UHTS/Quality_control/cutadapt/2.5;
module add UHTS/Quality_control/fastqc/0.11.7;
taskID=$1
SRR_exp=$2
nThreads=$3
SRR_input=$(find $working_path/SRR_download/${SRR_exp}_task${taskID}/input/ -type f -name "*.fastq.gz")
SRR_IP=$(find $working_path/SRR_download/${SRR_exp}_task${taskID}/IP/ -type f -name "*.fastq.gz")
echo "Input files: $SRR_input" 
echo "IP files: $SRR_IP"
cat $SRR_input > $working_path/SRR_download/${SRR_exp}_input.fq.gz
cat $SRR_IP > $working_path/SRR_download/${SRR_exp}_IP.fq.gz

rm -rf $working_path/SRR_download/${SRR_exp}_task${taskID}

[ ! -d "$working_path/trim" ] && mkdir -p $working_path/trim
FILES=$(find $working_path/SRR_download/ -type f -name "*.fq.gz")
echo "trimming  "${FILE[@]}

for f in ${FILES[@]}
do
 target_name=${f##*/}
 target_name=${target_name%.fq.gz}
 #target_name=${target_name%_trimmed}
 if [ ! -f "$working_path/trim/${target_name}_trimmed.fq.gz" ]; then
   echo "Trimming $f..."
   $trim_galore_location/trim_galore -o $working_path/trim -q 2 --illumina --gzip -j $nThreads --fastqc $f 
 else
   echo "Trimmed $f already present"
 fi
done

# move qc data to the qc directory
[ ! -d "$working_path/qc" ] && mkdir -p $working_path/qc
mv $working_path/trim/${SRR_exp}_*_fastqc.html $working_path/qc/
mv $working_path/trim/${SRR_exp}_*_report.txt $working_path/qc/
mv $working_path/trim/${SRR_exp}_*_fastqc.zip $working_path/qc/

module rm UHTS/Quality_control/cutadapt/2.5;
module rm UHTS/Quality_control/fastqc/0.11.7;
