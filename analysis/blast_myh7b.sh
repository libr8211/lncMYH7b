module load ncbi-blast/2.7.1
cd /scratch/Shares/rinn/Michael/genomes/references/Homo_sapiens/Gencode/v32/sequence/

makeblastdb -in GRCh38.p13.genome.fa -dbtype nucl -parse_seqids


cd /scratch/Shares/rinn/Michael/myh7b_heart/analysis/genomic_complementarity

blastn -task blastn \
-word_size 7 \
-evalue 1000 \
-gapopen 5 \
-gapextend 2 \
-reward 1 \
-penalty -3 \
-dust 'no' \
-outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore sstrand' \
-db /scratch/Shares/rinn/Michael/genomes/references/Homo_sapiens/Gencode/v32/sequence/GRCh38.p13.genome.fa \
-query myh7b.fa \
-out genomic_myh7b_matches_permissive.out


# Default value of outfmt
# 'qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore sstrand'



