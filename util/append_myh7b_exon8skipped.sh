#!/bin/bash

cp ../../genomes/Homo_sapiens/Gencode/v33/gencode.v33.annotation.gtf .
cat myh7b_exon7skipped.gtf >> gencode.v33.annotation.gtf
