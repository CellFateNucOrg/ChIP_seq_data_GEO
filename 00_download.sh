#!/bin/bash
module add UHTS/Analysis/sratoolkit/2.10.7;

#$1 is the full filename (with directory location) of the csv file with the ChIP set SRR info
#$2 is the SRR numbers of the IP dataset to map
#$3 is the SRR numbers of the input datasets to map
taskID=$1
SRR_exp=$2
#SRR_IP=( "$3" )
#SRR_input=( "$4" )
nThreads=$3
slurmOutFile=$4

echo $taskID task
echo $SRR_exp experiment
SRR_exp1=(`grep -v "input;ip;name;group" $list_file_name | sed -n ${taskID}p | cut -f3 -d";"`)

if [ "${SRR_exp1}" == "${SRR_exp}" ]; then
  SRR_IP=(`grep -v "input;ip;name;group" $list_file_name | sed -n ${taskID}p | cut -f2 -d";"`)
  SRR_input=(`grep -v "input;ip;name;group" $list_file_name | sed -n ${taskID}p | cut -f1 -d";"`)
else 
  echo "Experiment names are different"
fi

echo ${SRR_IP[@]} IP
echo ${SRR_input[@]} input
echo $nThreads threads
#create folder for SRR download if it does not exists and delete content if it does
[ ! -d $working_path/SRR_download/${SRR_exp}_task${taskID} ] && mkdir -p $working_path/SRR_download/${SRR_exp}_task${taskID}
rm -rf $working_path/SRR_download/${SRR_exp}_task${taskID}/*
[ ! -d $working_path/SRR_download/${SRR_exp}_task${taskID}/IP ] && mkdir -p $working_path/SRR_download/${SRR_exp}_task${taskID}/IP
[ ! -d $working_path/SRR_download/${SRR_exp}_task${taskID}/input ] && mkdir -p $working_path/SRR_download/${SRR_exp}_task${taskID}/input
[ ! -d $working_path/qc/SRR_download/${SRR_exp}_task${taskID} ] && mkdir -p $working_path/qc/SRR_download/${SRR_exp}_task${taskID}

echo TMPDIR is $TMPDIR
touch $working_path/qc/SRR_download/${SRR_exp}_task${taskID}/spotCounts.csv
echo ""
echo "Downloading IP: ${SRR_IP[@]}"
for i in "${SRR_IP[@]}"
do
   echo $i
   prefetch -o $working_path/SRR_download/${SRR_exp}_task${taskID}/$i $i
   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   if [ $? -ne 0  ]
   then
	echo "trying fasterq on its own"
	fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/IP -t $TMPDIR -e $nThreads $i
   else
   	echo "running fasterq with prefetch"
   	fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/IP -t $TMPDIR  -e $nThreads $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   fi

   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/IP/${i}.fastq
   if [ $? -ne 0 ]
   then
   	echo "dowload failed. trying fastq-dump"
	fastq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/IP $i
	spots=$(tac $slurmOutFile | grep -m 1 "Read .* spots")
	echo $spots
   else
   	spots=$(tac $slurmOutFile | grep -m 1 "spots read")
	echo $spots
   fi
   echo "compressing fastq with gzip."
   gzip $working_path/SRR_download/${SRR_exp}_task${taskID}/IP/${i}.fastq
   echo "${SRR_exp};IP;${i};${spots}" >> $working_path/qc/SRR_download/${SRR_exp}_task${taskID}/spotCounts.csv
  
   #clean up
   rm $working_path/SRR_download/${SRR_exp}_task${taskID}/${i}*
done


echo ""
echo "Downloading input: ${SRR_input[@]}"
for i in "${SRR_input[@]}"
do
   prefetch -o $working_path/SRR_download/${SRR_exp}_task${taskID}/$i $i
   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   if [ $? -ne 0  ]
   then
       echo "trying fasterq on its own"
       fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/input -t $TMPDIR -e $nThreads $i
   else
       echo "running fasterq with prefetch"
       fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/input -t $TMPDIR -e $nThreads $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   fi
   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/input/${i}.fastq
   
   if [ $? -ne 0 ]
   then
   	echo "download failed. trying fastq-dump"
	fastq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/IP $i
   	spots=$(tac $slurmOutFile | grep -m 1 "Read .* spots")
	echo $spots
   else
   	spots=$(tac $slurmOutFile | grep -m 1 "spots read")
	echo $spots
   fi

   echo "compressing fastq with gzip."
   gzip $working_path/SRR_download/${SRR_exp}_task${taskID}/input/${i}.fastq
   echo "${SRR_exp};input;${i};${spots}" >> $working_path/qc/SRR_download/${SRR_exp}_task${taskID}/spotCounts.csv
   
   #clean up
   rm $working_path/SRR_download/${SRR_exp}_task${taskID}/${i}*
done

echo "This is over"



module rm UHTS/Analysis/sratoolkit/2.10.7;
