#!/usr/bin/env nextflow

params.name          = "lncMYH7b_KD_RNA-seq Novogene"
params.overhang      = '74'
params.multiqc       = "$baseDir/multiqc"
params.genome        = "Gencode_human/release_29/GRCh38.p12.genome.fa.gz"
params.annotation    = "Gencode_human/release_29/gencode.v29.annotation.gtf.gz"
params.reads         = "$baseDir/input/fastq/*{_1,_2}.fastq.gz"
params.outdir        = "results"




log.info "Rinn Lab RNA-seq Pipeline"
log.info "====================================="
log.info "name                   : ${params.name}"
log.info "genome                 : ${params.genome}"
log.info "reads                  : ${params.reads}"
log.info "annotation             : ${params.annotation}"
log.info "STAR overhang          : ${params.overhang}"
log.info "output                 : ${params.outdir}"
log.info "\n"



fastq_zipped      = Channel
                      .fromFilePairs(params.reads, size: -1)
                      .ifEmpty { error "Can't find any reads matching: ${params.reads}" }
multiqc_file      = file(params.multiqc)
genome_path       = Channel.value(params.genome)
annotation_path   = Channel.value(params.annotation)
transcriptome_path = Channel.value(params.transcriptome)
overhangs         = Channel.from(params.overhang)



process retrieve_annotation {

  publishDir 'input/annotation'

  input:
  val annotation_url from annotation_path

  output:
  file('*.gtf') into gene_annotation

  script:
  """
  wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/$annotation_url.value
  gunzip *.gz
  """
}



gene_annotation.into {
  annotation_for_index; annotation_for_count; annotation_for_transcriptome
}



process retrieve_genome {

  publishDir 'input/genome'

  input:
  val genome_url from genome_path

  output:
  file('*.fa') into genome

  script:
  """
  wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/$genome_path.value
  gunzip *.gz
  """
}



genome.into {
  genome_fasta_for_transcriptome; genome_fasta
}



process make_transcriptome {

  publishDir 'input/genome'

  input:
  file gene_annotations from annotation_for_transcriptome
  file genome_fasta from genome_fasta_for_transcriptome

  output:
  file "transcriptome.fa" into transcriptome_fasta

  script:
  """
  gffread -w transcriptome.fa -g ${genome_fasta} ${gene_annotations}
  """
}



fastq_zipped.into {
  reads_for_fastqc; reads_for_mapping
}



process fastqc {

  module 'fastqc/0.11.5'
  publishDir 'results/fastqc'

  input:
  set sample_id, file(fastqz) from reads_for_fastqc

  output:
  file("fastqc_${sample_id}_logs") into fastqc_files


  script:
  """
  mkdir fastqc_${sample_id}_logs
  fastqc --threads 4 -o fastqc_${sample_id}_logs -f fastq -q ${fastqz}
  """
}



process index {

  module 'STAR/2.6.0c'
  memory '60 GB'
  clusterOptions '--nodes=1 --ntasks=64'

  input:
  file genome_fasta
  file annotation_for_index
  val overhang from overhangs

  output:
  file "index_${overhang}" into star_index

  script:
  """
  mkdir index_${overhang}
  STAR  --runThreadN 64 \
        --runMode genomeGenerate \
        --genomeDir ./index_${overhang} \
        --genomeFastaFiles ${genome_fasta} \
        --sjdbGTFfile ${annotation_for_index} \
        --sjdbOverhang ${overhang}
  """
}



process map {


    module 'STAR/2.6.0c'
    clusterOptions '--nodes=1 --ntasks=4 --mem=40gb'
    publishDir 'results/bam'

    input:
    set sample_id, file(reads), file(index) from reads_for_mapping.combine(star_index)

    output:
    set sample_id, file("*Aligned.out.bam") into mapped_reads
    set sample_id, file("*Aligned.toTranscriptome.out.bam") into mapped_transcriptome
    file '*' into mapped_dir

    script:
    """
    STAR  --runThreadN 4 \
          --genomeDir ${index} \
          --readFilesIn ${reads.findAll{ it =~ /\_1\./ }.join(',')} \
                        ${reads.findAll{ it =~ /\_2\./ }.join(',')} \
          --readFilesCommand zcat \
          --outSAMtype BAM Unsorted \
          --outSAMmapqUnique 60 \
          --outSAMunmapped Within \
          --outSAMattributes NH HI NM MD AS \
          --outReadsUnmapped Fastx \
          --quantMode TranscriptomeSAM \
          --outFileNamePrefix ${sample_id}_ \
          --alignEndsType EndToEnd
    """
}



mapped_reads.into {
  mapped_for_count; mapped_for_igv
}



process count {

    module 'subread/1.6.2'
    publishDir 'results/feature_counts'

    input:
    file gene_annotations from annotation_for_count
    set sample_id, file(bam_file) from mapped_for_count

    output:
    file '*.fCounts' into feature_counts
    file '*.fCounts*' into fcounts

    script:
    """
    featureCounts  -C \
                   -p \
                   -T 4 \
                   -g gene_id \
                   -a ${gene_annotations} \
                   -o ${sample_id}.fCounts \
                   ${bam_file}
    """
}



process salmon {

  module 'salmon/0.13.1'
  publishDir 'results/salmon'
  clusterOptions '--ntasks=8'

  input:
  file transcript_fasta from transcriptome_fasta
  set sample_id, file(bam) from mapped_transcriptome

  output:
  file '*' into salmon_out
  file(sample_id) into salmon_for_multiqc

  script:
  """
  echo hello

  salmon quant -l A \
               -p 8 \
               -t ${transcript_fasta} \
               -o ${sample_id} \
               -a ${bam} \
               --numBootstraps 30
  """
}



process igv_index {

  module 'igvtools'
  publishDir 'results/igv'

  input:
  set sample_id, file(bam_file) from mapped_for_igv

  output:
  set file("*_sorted.bam"), file('*.bai') into igv_index


  script:
  """
  igvtools sort ${bam_file} ${sample_id}_sorted.bam
  igvtools index ${sample_id}_sorted.bam
  """
}



process multiqc {


  publishDir 'reports', mode:'copy'
  clusterOptions '--ntasks=1'

  input:
  file('*') from fastqc_files.mix(mapped_dir).mix(fcounts).mix(salmon_for_multiqc).collect()
  file(config) from multiqc_file

  output:
  file('multiqc_report.html')

  script:
  """
  module load python/3.6.3
  cp $config/* .
  echo "custom_logo: \$PWD/logo.png" >> multiqc_config.yaml
  multiqc .
  """
}



//process differential_expression {
//
  //publishDir 'reports', mode: 'copy'
//
  //input:
  //file sample_file from salmon_out.collect()
//
  //script:
  //"""
  //Rscript -e 'rmarkdown::render("${baseDir}/bin/02_differential_expression.Rmd")'
  //Rscript -e 'rmarkdown::render("${baseDir}/bin/03_functional_analysis.Rmd")'
  //"""
//}
