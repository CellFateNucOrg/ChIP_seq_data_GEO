#!/bin/bash
module add UHTS/Analysis/sratoolkit/2.10.7;

#$1 is the full filename (with directory location) of the csv file with the ChIP set SRR info
#$2 is the SRR numbers of the IP dataset to map
#$3 is the SRR numbers of the input datasets to map
SRR_exp=$1
SRR_IP=($2)
SRR_input=($3)
nThreads=$4
slurmOutFile=$5

echo $SRR_exp experiment
echo $SRR_IP IP
echo $SRR_input input
echo $nThreads threads
#create folder for SRR download if it does not exists and delete content if it does
[ ! -d $working_path/$SRR_exp/SRR_download ] && mkdir $working_path/$SRR_exp/SRR_download
rm -rf $working_path/$SRR_exp/SRR_download/*
[ ! -d $working_path/$SRR_exp/SRR_download/IP ] && mkdir $working_path/$SRR_exp/SRR_download/IP
[ ! -d $working_path/$SRR_exp/SRR_download/input ] && mkdir $working_path/$SRR_exp/SRR_download/input
[ ! -d $working_path/qc ] && mkdir -p $working_path/qc

mkdir -p /scratch/meisterLab
touch $working_path/qc/spotCounts.csv
echo ""
echo "Downloading IP: $SRR_IP"
for i in "${SRR_IP[@]}"
do
   echo $i
   prefetch -o $working_path/$SRR_exp/SRR_download/$i $i
   vdb-validate $working_path/$SRR_exp/SRR_download/$i
   if [ $? -ne 0  ]
   then
	echo "trying fasterq on its own"
	fasterq-dump -O $working_path/$SRR_exp/SRR_download/IP -t /scratch/meisterLab/$SRR_exp -e $nThreads $i
   else
   	echo "running fasterq with prefetch"
   	fasterq-dump -O $working_path/$SRR_exp/SRR_download/IP -t /scratch/meisterLab/$SRR_exp -e $nThreads $working_path/$SRR_exp/SRR_download/$i
   fi

   vdb-validate $working_path/$SRR_exp/SRR_download/IP/${i}.fastq
   if [ $? -ne 0 ]
   then
   	echo "dowload failed. trying fastq-dump"
	fastq-dump -O $working_path/$SRR_exp/SRR_download/IP $i
	spots=$(tac $slurmOutFile | grep -m 1 "Read .* spots")
	echo $spots
   else
   	spots=$(tac $slurmOutFile | grep -m 1 "spots read")
	echo $spots
   fi
   echo "compressing fastq with gzip."
   gzip $working_path/$SRR_exp/SRR_download/IP/${i}.fastq
   echo "${SRR_exp};IP;${i};${spots}" >> $working_path/qc/spotCounts.csv
   
   #clean up
   rm $working_path/$SRR_exp/SRR_download/${i}*
done


echo ""
echo "Downloading input: $SRR_input"
for i in "${SRR_input[@]}"
do
   prefetch -o $working_path/$SRR_exp/SRR_download/$i $i
   vdb-validate $working_path/$SRR_exp/SRR_download/$i
   if [ $? -ne 0  ]
   then
       echo "trying fasterq on its own"
       fasterq-dump -O $working_path/$SRR_exp/SRR_download/input -t /scratch/meisterLab/$SRR_exp -e $nThreads $i
   else
       echo "running fasterq with prefetch"
       fasterq-dump -O $working_path/$SRR_exp/SRR_download/input -t /scratch/meisterLab/$SRR_exp -e $nThreads $working_path/$SRR_exp/SRR_download/$i
   fi
   vdb-validate $working_path/$SRR_exp/SRR_download/input/${i}.fastq
   
   if [ $? -ne 0 ]
   then
   	echo "download failed. trying fastq-dump"
	fastq-dump -O $working_path/$SRR_exp/SRR_download/IP $i
   	spots=$(tac $slurmOutFile | grep -m 1 "Read .* spots")
	echo $spots
   else
   	spots=$(tac $slurmOutFile | grep -m 1 "spots read")
	echo $spots
   fi

   echo "compressing fastq with gzip."
   gzip $working_path/$SRR_exp/SRR_download/input/${i}.fastq
   echo "${SRR_exp};input;${i};${spots}" >> $working_path/qc/spotCounts.csv
   
   #clean up
   rm $working_path/$SRR_exp/SRR_download/${i}*
done

echo "This is over"

module rm UHTS/Analysis/sratoolkit/2.10.7;
