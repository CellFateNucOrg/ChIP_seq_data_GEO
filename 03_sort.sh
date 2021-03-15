#!/bin/bash

module add UHTS/Analysis/samtools/1.8;
SRR_exp=$1
nThreads=$2
FILES=$(find $working_path/$SRR_exp/bam/ -type f -name "*.bam")
echo $FILES
for f in $FILES
do
  echo "Sorting $f..."
  target_name=${f##*/}
  target_name=${target_name%.bam}
  target_name=${target_name%_sorted}
#  echo $target_name
  if [ ! -f "$working_path/$SRR_exp/bam/${target_name}_sorted.bam" ]; then
    samtools sort -@ $nThreads $f > $working_path/$SRR_exp/bam/${target_name}_sorted.bam
    echo "Indexing $f..."
    samtools index -@ $nThreads $working_path/$SRR_exp/bam/${target_name}_sorted.bam
    rm $f
  fi
done
module rm UHTS/Analysis/samtools/1.8;
