#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=Aleksandr.Prystupa@nyulangone.org
#SBATCH --partition=a100_short
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=20G
#SBATCH --gres=gpu:1
#SBATCH --job-name=run-stats
#SBATCH --output=run-stats_%A_%a.out
#SBATCH --error=run-stats_%A_%a.err

proj_dir=$(pwd)

cs_out=${proj_dir}/cibersort-outs/cs_out_clean.csv

# bash commands
bash_cmd="Rscript --vanilla ${proj_dir}/csp/scripts/get-cs-stats.R $cs_out"

# Run Stats
echo $bash_cmd
($bash_cmd)
