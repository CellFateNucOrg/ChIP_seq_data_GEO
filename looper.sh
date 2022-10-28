#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=14#-14%10
#SBATCH --job-name="ChIP_seq"
##SBATCH --partition=pall
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=16G
#SBATCH --output=slurm-%x-%A-%a.out
#SBATCH --error=slurm-%x-%A-%a.out

module add UHTS/Analysis/MultiQC/1.8;
export TMPDIR=$SCRATCH

echo $PWD
source ./file_locations.sh

echo $working_path

echo "Line $SLURM_ARRAY_TASK_ID"

slurmOutFile=${PWD}/slurm-${SLURM_JOB_NAME}-${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}.out

sh wrapper.sh $SLURM_ARRAY_TASK_ID $SLURM_CPUS_PER_TASK $slurmOutFile

#source $CONDA_ACTIVATE
#multiqc -f -i allRuns -o $working_path/qc $working_path

