#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=Aleksandr.Prystupa@nyulangone.org
#SBATCH --partition=a100_short
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=50G
#SBATCH --gres=gpu:1
#SBATCH --job-name=run-cs
#SBATCH --output=run-cs_%A_%a.out
#SBATCH --error=run-cs_%A_%a.err

proj_dir=$(pwd)

sig_mat_file=${proj_dir}/csp/raw-data/sig_mat_file.txt
mixture_file=${proj_dir}/csp/raw-data/mixture_file.txt

# bash commands
bash_cmd_1="Rscript --vanilla ${proj_dir}/csp/scripts/run-cibersort.R $sig_mat_file $mixture_file"
bash_cmd_2="Rscript --vanilla ${proj_dir}/csp/scripts/create-samples-groups-csv.R $mixture_file"

# Run Cibersort
echo $bash_cmd_1
($bash_cmd_1)

# Generate samples.groups.csv
echo $bash_cmd_2
($bash_cmd_2)
