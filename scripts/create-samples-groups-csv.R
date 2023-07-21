#!/usr/bin/env Rscript

# command line arguments
args = commandArgs(trailingOnly = TRUE)
counts_mat_file = args[1]

counts_mat <- read.table(counts_mat_file, sep = "\t", header = 1)

samples <- colnames(counts_mat)[-1]

samples_groups_df <- cbind.data.frame(samples, rep(NA, length(samples)), rep(NA, length(samples)))
colnames(samples_groups_df) <- c("samples", "groups_1", "groups_2")

write.csv(samples_groups_df, "samples.groups.csv", quote = F, row.names = F)
