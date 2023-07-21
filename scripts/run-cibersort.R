#!/bin/bash/env Rscript

source("csp/scripts/helper-scripts/CIBERSORT.R")

# command line arguments
args = commandArgs(trailingOnly = TRUE)
sig_mat_file = args[1]
mixture_file = args[2]

# load packages
library(dplyr)
library(tidyr)
library(tibble)

# Run Cibersort Function
run.cibersort <- function(sig_mat_file, mixture_file) {

  # 1. Run Cibersort
  cs_out_raw <- CIBERSORT(sig_matrix = sig_mat_file, mixture_file = mixture_file, perm = 1000, QN = FALSE)
  
  # 2. Clean Cibersort Output
  cs_out_clean <- cs_out_raw %>% t() %>% as.data.frame() %>% round(5)
  cs_out_clean <- cs_out_clean[nrow(cs_out_clean) - 3: nrow(cs_out_clean), ] %>% as.data.frame()
  
  # 3. Return Raw/Clean as list
  cs_outs <- list(cs_out_raw, cs_out_clean)
  names(cs_outs) <- c("raw", "clean")

  return(cs_outs)
}

# Run Cibersort
sig_mat_file = "csp/raw-data/sig_mat_file.txt"
mixture_file = "csp/raw-data/mixture_file.txt"
cs_outs <- run.cibersort(sig_mat_file, mixture_file)

# Save Results
outs_dir = "cibersort-outs"
if (!dir.exists(outs_dir)) dir.create(outs_dir)

write.csv(cs_outs$raw, "cibersort-outs/cs_out_raw.csv", quote = F)
write.csv(cs_outs$clean, "cibersort-outs/cs_out_clean.csv", quote = F)
