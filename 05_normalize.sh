#!/bin/bash
module add R/3.6.1;

SRR_exp=$1
#[ ! -d $working_path/norm ] && mkdir -p $working_path/norm
#[ ! -d $working_path/enrich ] && mkdir -p $working_path/enrich

Rscript normalize.R "$working_path" "$SRR_exp"
