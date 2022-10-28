#!/bin/bash
module add R/3.6.1;

SRR_exp=$1

Rscript normalize.R "$working_path" "$SRR_exp"
