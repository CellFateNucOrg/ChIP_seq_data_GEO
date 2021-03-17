#!/bin/bash
#SBATCH --mail-user=jennifer.semple@izb.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=1    ##-34%10
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --partition=pshort
#SBATCH --time=0-03:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8G
#SBATCH --output=slurm-%x-%A-%a.out
#SBATCH --error=slurm-%x-%A-%a.out

echo $PWD
source ./file_locations.sh

mkdir -p $working_path
echo $working_path
echo "Line $SLURM_ARRAY_TASK_ID"

slurmOutFile=${PWD}/slurm-${SLURM_JOB_NAME}-${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}.out

sh wrapper.sh $SLURM_ARRAY_TASK_ID $SLURM_CPUS_PER_TASK $slurmOutFile


