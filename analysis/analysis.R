######
# This script will run the full analysis using the singularity container 
#####

#### SETUP
library(rmarkdown)


# 02_tf_enrichment
rmarkdown::render("02_tf_enrichment/myh7_promoter_motifs.Rmd", md_document(variant = "markdown_github"))
