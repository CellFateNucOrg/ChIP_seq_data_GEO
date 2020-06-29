#!/bin/bash
#SBATCH --mail-user=peter.meister@izb.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=2-2%1
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=2-12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8G
#current_path=$PWD
echo $PWD
working_path="$(dirname "$(pwd)")"
export working_path=$working_path
echo $working_path
echo "Line $SLURM_ARRAY_TASK_ID"
sh wrapper.sh $working_path/SRR_names.csv $SLURM_ARRAY_TASK_ID


