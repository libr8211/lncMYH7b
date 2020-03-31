options(stringsAsFactors = FALSE)
library(tidyverse)

samples <- read.csv("../../samplesheet.csv")

samples$condition <- sapply(samples$sample_title, function(x) {
  gsub('[[:digit:]]+', '', x)
})
# For some reason these samples doesn't exist
# SRR7426830
# SRR7426847
samples <- samples %>% filter(run_accession != "SRR7426830")
samples <- samples %>% filter(run_accession != "SRR7426847")


 
samples$bam_files <- paste0("../../results/markDuplicates/", samples$run_accession,
                            "Aligned.sortedByCoord.out.markDups.bam")

write.table(samples %>% select(run_accession, bam_files, condition),
            "bamfiles.tsv",
            col.names = FALSE, row.names = FALSE, sep = "\t", quote = FALSE)


gtf_exons <- gtf[which(gtf$type == "exon")]
rtracklayer::export(gtf_exons, "gencode.v32.exons.gtf")
