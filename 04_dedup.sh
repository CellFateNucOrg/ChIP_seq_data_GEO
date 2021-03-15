#!/bin/bash
module add UHTS/Analysis/picard-tools/2.21.8;
module add UHTS/Analysis/samtools/1.8;
module add UHTS/Analysis/MultiQC/1.8;
SRR_exp=$1
nThreads=$2
[ ! -d $working_path/$SRR_exp/dedup ] &&  mkdir $working_path/$SRR_exp/dedup
[ ! -d "$working_path/$SRR_exp/filt" ] &&  mkdir $working_path/$SRR_exp/filt
[ ! -d $working_path/qc ] && mkdir $working_path/qc

FILES=$(find $working_path/$SRR_exp/bam/ -type f -name "*_sorted.bam")
for f in $FILES
  do
  target_name=${f##*/}
  target_name=${target_name%.bam}
  echo $target_name
  if [ ! -f "$working_path/$SRR_exp/filt/${target_name}_dedup_filt_sorted.bam" ]; then


  #if [ ! -f $working_path/$SRR_exp/dedup/${target_name}_dedup.bam ]; then
    echo "Removing duplicates from $f..."
    picard-tools MarkDuplicates I=$f O=$working_path/$SRR_exp/dedup/${target_name}_dedup.bam M=$working_path/$SRR_exp/dedup/${target_name}_dedup.txt REMOVE_DUPLICATES=true REMOVE_SEQUENCING_DUPLICATES=true TMP_DIR=$working_path/ VALIDATION_STRINGENCY=LENIENT
  
    echo "Removing blacklisted genes from ${target_name}_dedup.bam..."
    if [[ ! -e "${genome_location}/ce11-blacklist.v2.bed" ]]; then
      wget "https://github.com/Boyle-Lab/Blacklist/raw/master/lists/ce11-blacklist.v2.bed.gz"
      gunzip ce11-blacklist.v2.bed.gz
      mv ce11-blacklist.v2.bed ${genome_location}/ce11-blacklist.v2.bed
    fi
    #-q 1 option removes multimappers assigned 0 by bwa aln
    samtools view -u -q 1 -@ $nThreads $working_path/$SRR_exp/dedup/${target_name}_dedup.bam | samtools view  -b -@ $nThreads -L ${genome_location}/ce11-blacklist.v2.bed -U $working_path/$SRR_exp/filt/${target_name}_dedup_filt.bam  -o $working_path/$SRR_exp/filt/${target_name}_dedup_blacklisted.bam  -

    echo "Sorting deduplicated $f"
    samtools sort -@ $nThreads -o $working_path/$SRR_exp/filt/${target_name}_dedup_filt_sorted.bam  $working_path/$SRR_exp/filt/${target_name}_dedup_filt.bam 

    echo "Indexing deduplicated $f"
    samtools index -@ $nThreads $working_path/$SRR_exp/filt/${target_name}_dedup_filt_sorted.bam

    multiqc -i $SRR_exp -o $working_path/qc  $working_path/$SRR_exp
    #cleanup
    rm $working_path/$SRR_exp/filt/${target_name}_dedup_blacklisted.bam
    rm $working_path/$SRR_exp/dedup/${target_name}_dedup.bam
    rm $working_path/$SRR_exp/filt/${target_name}_dedup_filt.bam
  fi
done



module rm UHTS/Analysis/picard-tools/2.21.8;
module rm UHTS/Analysis/samtools/1.8;
module rm UHTS/Analysis/MultiQC/1.8;
