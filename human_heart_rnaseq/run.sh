#!/bin/bash
#SBATCH -p long
#SBATCH --job-name=human-heart-rnaseq
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=michael.smallegan@colorado.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=6gb
#SBATCH --time=30:00:00
#SBATCH --output=nextflow.out
#SBATCH --error=nextflow.err
pwd; hostname; date
echo "You've requested $SLURM_CPUS_ON_NODE core."
module load singularity/3.1.1
nextflow run nf-core/rnaseq -r 1.4.1 \
-resume \
-profile singularity \
--singleEnd \
--reads 'fastq/*.fastq' \
--fasta ../../../genomes/Homo_sapiens/Gencode/v33/GRCh38.p13.genome.fa \
--gtf ../util/gencode.v33.annotation.gtf \
--pseudo_aligner salmon \
--gencode \
-c ../nextflow.config
date
