#!/bin/bash
module add UHTS/Analysis/samtools/1.10;
module add UHTS/Aligner/bwa/0.7.17;

SRR_exp=$1
nThreads=$2
FILES=$(find $working_path/trim/ -type f -name "${SRR_exp}_*.fq.gz")
[ ! -d $working_path/aln/ ] && mkdir -p $working_path/aln/
echo "aligning  " ${FILES[@]}

for f in ${FILES[@]}
do
  target_name=${f##*/}
  target_name=${target_name%med.fq.gz}
#  echo $target_name
  if [ ! -f "$working_path/aln/${target_name}_sort.bam" ]; then 
     echo "Mapping $f to ce11 using bwa aln..."
#     bowtie2 -p 2 --no-unal -q -x $genome_location/ce11 -U $f -S ./$SRR_exp/bam/${target_name}.sam > ./$SRR_exp/bam/${target_name}_alignment_report_bw2.txt
     bwa aln -t $nThreads $genome_location/ce11bwaidx $f > $working_path/aln/${target_name}.sai
     bwa samse $genome_location/ce11.fa $working_path/aln/${target_name}.sai $f > $working_path/aln/${target_name}.sam
     echo "Converting $f SAM to BAM..."
     samtools view -S -b -@ $nThreads -q 20 $working_path/aln/${target_name}.sam > $working_path/aln/${target_name}.bam
     rm $working_path/aln/${target_name}.sam
     rm $working_path/aln/${target_name}.sai
    else
    echo "$f already mapped to ce11..."
##  rm ${f%.fq.gz}.sai
  fi
done

module rm UHTS/Analysis/samtools/1.10;
module rm UHTS/Aligner/bwa/0.7.17;
