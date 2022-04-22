#!/bin/bash

SRR_exp=$1
echo $SRR_exp
#nThreads=$2
#[ ! -d $working_path/$SRR_exp/thor ] &&  mkdir $working_path/$SRR_exp/thor

source $CONDA_ACTIVATE thor
module load Utility/UCSC-utils/359;

echo "get blacklisted genes"
if [[ ! -e "${genome_location}/ce11-blacklist.v2.bed" ]]; then
  wget "https://github.com/Boyle-Lab/Blacklist/raw/master/lists/ce11-blacklist.v2.bed.gz"
  gunzip ce11-blacklist.v2.bed.gz
  mv ce11-blacklist.v2.bed ${genome_location}/ce11-blacklist.v2.bed
fi

blacklisted=${genome_location}/ce11-blacklist.v2.bed

mkdir -p ${working_path}/minusInput_Thor/

if [ ! -f "${working_path}/minusInput_Thor/${SRR_exp}_IP_norm_minusInput.bw" ]; then
  bamfile=`ls ${working_path}/${SRR_exp}/filt/IP_*_sorted.bam`
  echo "IP file is " $bamfile
  bamfile_input=`ls ${working_path}/${SRR_exp}/filt/input_*_sorted.bam`
  echo "input file is " $bamfile_input
  python ./normaliseWithThor.py -p $bamfile -n $bamfile_input -l $blacklisted -o $working_path -f $SRR_exp
fi



