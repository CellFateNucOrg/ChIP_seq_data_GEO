#!/bin/bash
#SBATCH --mail-user=bolaji.isiaka@izb.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=2-15%10
#SBATCH --job-name="ChIP_seq_kramer"
##SBATCH --partition=pall
#SBATCH --time=0-12:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
#SBATCH --output=slurm-%x-%A-%a.out
#SBATCH --error=slurm-%x-%A-%a.out

module add UHTS/Analysis/MultiQC/1.8;
export TMPDIR=$SCRATCH

SRR_exp=$1

echo $PWD
source ./file_locations.sh

mkdir -p $working_path
echo $working_path
[ ! -d $working_path/norm ] && mkdir -p $working_path/norm
[ ! -d $working_path/enrich ] && mkdir -p $working_path/enrich

echo "Line $SLURM_ARRAY_TASK_ID"

slurmOutFile=${PWD}/slurm-${SLURM_JOB_NAME}-${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}.out

sh wrapper.sh $SLURM_ARRAY_TASK_ID $SLURM_CPUS_PER_TASK $slurmOutFile

#source $CONDA_ACTIVATE
#multiqc -f -i allRuns -o $working_path/qc $working_path

