#!/bin/bash
#SBATCH -p long
#SBATCH --job-name=ftc-rnaseq
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=michael.smallegan@colorado.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=6gb
#SBATCH --time=01:00:00
#SBATCH --output=nextflow.out
#SBATCH --error=nextflow.err

pwd; hostname; date
echo "You've requested $SLURM_CPUS_ON_NODE core."

Rscript -e 'rmarkdown::render("myh7b_matches.Rmd", "html_document")'


date


