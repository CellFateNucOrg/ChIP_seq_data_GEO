#!/bin/bash
module add R/3.6.1;
module add UHTS/Analysis/MultiQC/1.8;

SRR_exp=$1
[ ! -d $working_path/$SRR_exp/norm ] && mkdir $working_path/$SRR_exp/norm
[ ! -d $working_path/$SRR_exp/enrichment ] && mkdir $working_path/$SRR_exp/enrichment

multiqc -i allRuns -o $working_path/qc $working_path

Rscript 05_normalize.R "$working_path/$SRR_exp"
