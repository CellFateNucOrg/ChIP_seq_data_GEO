#!/bin/bash
module add R/3.6.1;

SRR_exp=$1
[ ! -d $working_path/$SRR_exp/norm ] && mkdir $working_path/$SRR_exp/norm
[ ! -d $working_path/$SRR_exp/enrichment ] && mkdir $working_path/$SRR_exp/enrichment


Rscript normalize.R "$working_path/$SRR_exp"
