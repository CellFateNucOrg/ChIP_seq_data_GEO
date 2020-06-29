#!/bin/bash
module add UHTS/Analysis/picard-tools/2.21.8;
module add UHTS/Analysis/samtools/1.8;
SRR_exp=$1
[ ! -d $working_path/$SRR_exp/dedup ] &&  mkdir $working_path/$SRR_exp/dedup

FILES=$(find $working_path/$SRR_exp/bam/ -type f -name "*_sorted.bam")
for f in $FILES
  do
  target_name=${f##*/}
  target_name=${target_name%.bam}
  echo $target_name
  if [ ! -f $working_path/$SRR_exp/dedup/${target_name}_dedup.bam ]; then
  echo "Removing duplicates from $f..."
  picard-tools MarkDuplicates I=$f O=$working_path/$SRR_exp/dedup/${target_name}_dedup.bam M=$working_path/$SRR_exp/dedup/${target_name}_dedup.txt REMOVE_DUPLICATES=true REMOVE_SEQUENCING_DUPLICATES=true TMP_DIR=$working_path/ VALIDATION_STRINGENCY=LENIENT
  echo "Sorting deduplicated $f"
  samtools sort $working_path/$SRR_exp/dedup/${target_name}_dedup.bam > $working_path/$SRR_exp/dedup/${target_name}_dedup_sorted.bam
  echo "Indexing deduplicated $f"
  samtools index $working_path/$SRR_exp/dedup/${target_name}_dedup_sorted.bam
  rm $working_path/$SRR_exp/dedup/${target_name}_dedup.bam
  fi
done

module rm UHTS/Analysis/picard-tools/2.21.8;
module rm UHTS/Analysis/samtools/1.8;
