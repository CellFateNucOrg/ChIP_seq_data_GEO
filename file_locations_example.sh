#!bin/bash

# file with list of fastq files to process (input;IP;exp_name;group)
script_path="$(pwd)"
export list_file_name=${script_path}/SRR_namesGSE45678kranz.csv

# directry in which to put all intermediate steps of analysis
export working_path="$(dirname "$(pwd)")"/tmpRun

export trim_galore_location=/data/projects/p025/Peter/software/TrimGalore-0.6.5/
export genome_location=/data/projects/p025/Peter/ChIP_seq/genome/
