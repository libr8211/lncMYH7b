#!/bin/bash
#SBATCH -p short
#SBATCH --job-name=lncMYH7b_KD_NG_manager
#SBATCH --mail-type=ALL            # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=lindsey.broadwell@colorado.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=6gb                 # Memory limit
#SBATCH --time=12:00:00            # Time limit hrs:min:sec
#SBATCH --output=/scratch/Shares/rinn/LindseyJoe/lncMYH7b_KD_NG/.slurmlog/nf_manager_%j.out
#SBATCH --error=/scratch/Shares/rinn/LindseyJoe/lncMYH7b_KD_NG/.slurmlog/nf_manager_%j.err



pwd; hostname; date

echo "You've requested $SLURM_CPUS_ON_NODE core."

nextflow main.nf \
  -resume \
  -with-report ./reports/lncMYH7b_KDNG_rnaseq.html \
  -with-dag ./reports/lncMYH7b_KDNG_dag.html
#delete dag line if issue arises
echo "Your Nextflow run is done." | mailx -s "lncMYH7b KD RNA-seq Novogene" \
  -a ./reports/lncMYH7b_KD_rnaseq.html lindsey.broadwell@colorado.edu

date
