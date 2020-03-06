#!/bin/bash
#SBATCH -p short
#SBATCH --job-name=download-sra
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=michael.smallegan@colorado.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=10gb
#SBATCH --time=20:00:00
#SBATCH --output=dl.out
#SBATCH --error=dl.err

date
hostname

cd ../human_heart_rnaseq/fastq

module load sra
while read sra; do
  echo "downloading $sra"
  fasterq-dump $sra -t /dev/shm -e 8 -f -p
done < ../../util/sra_accession_list.txt
