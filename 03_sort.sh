#!/bin/bash

module add UHTS/Analysis/samtools/1.10;
SRR_exp=$1
nThreads=$2
FILES=$(find $working_path/aln/ -type f -name "${SRR_exp}_*.bam")
echo "sorting and indexing " ${FILES[@]}
for f in ${FILES[@]}
do
  echo "Sorting $f..."
  target_name=${f##*/}
  target_name=${target_name%.bam}
  target_name=${target_name%_sort}
#  echo $target_name
  if [ ! -f "$working_path/aln/${target_name}_sort.bam" ]; then
    samtools sort -@ $nThreads $f > $working_path/aln/${target_name}_sort.bam
    echo "Indexing $f..."
    samtools index -@ $nThreads $working_path/aln/${target_name}_sort.bam
    rm $f
  fi
done
module rm UHTS/Analysis/samtools/1.10;
