#!/bin/bash
#SBATCH --mail-user=jennifer.semple@izb.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=35,36,42,43#4%10
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --partition=pshort
#SBATCH --time=0-03:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
#SBATCH --output=slurm-%x-%A-%a.out
#SBATCH --error=slurm-%x-%A-%a.out

module add UHTS/Analysis/MultiQC/1.8;

SRR_exp=$1
[ ! -d $working_path/$SRR_exp/norm ] && mkdir $working_path/$SRR_exp/norm
[ ! -d $working_path/$SRR_exp/enrichment ] && mkdir $working_path/$SRR_exp/enrichment

echo $PWD
source ./file_locations.sh

mkdir -p $working_path
echo $working_path
echo "Line $SLURM_ARRAY_TASK_ID"

slurmOutFile=${PWD}/slurm-${SLURM_JOB_NAME}-${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}.out

sh wrapper.sh $SLURM_ARRAY_TASK_ID $SLURM_CPUS_PER_TASK $slurmOutFile

#source $CONDA_ACTIVATE
#if [ -d $working_path/qc/allRuns_multiqc_report_data ]
#then
#   rm -r $working_path/qc/allRuns_multiqc_report_data
#   rm $working_path/qc/allRuns_multiqc_report.html
#fi
#multiqc -i allRuns -o $working_path/qc $working_path

