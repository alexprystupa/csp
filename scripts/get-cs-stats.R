#!/bin/bash/env Rscript

source("csp/scripts/helper-scripts/Ciber-Sort-Barplot-Functions.R")
source("csp/scripts/helper-scripts/Ciber-Sort-Automate-Barplot-Stats.R")

# command line arguments
args = commandArgs(trailingOnly = TRUE)
samples_groups = args[1]

# Load Packages
library(tidyverse)
library(glue)
library(stringr)

# BarPlots

## 0. Read CS Clean Output
cs_out <- read.csv("cibersort-outs/cs_out_clean.csv", row.names = 1)
samples_groups <- read.csv("samples.groups.csv", row.names = 1) %>% tibble::rownames_to_column("samples")

cs_out <- cs_out[ ,samples_groups$samples]


## 1. Get Barplot Ready data frame
bp_df <- convert.to.bp.ready.df(cs_out, samples_groups)

## 2. Get Subsets
bp_df_list <- get.bp.subsets(bp_df)

## 3. Plot Barplots
outs_dir_plots = "cibersort-outs/bar-plots"
if (!dir.exists(outs_dir_plots)) dir.create(outs_dir_plots)

for (sample_type in names(bp_df_list)) {
  pdf(glue("{outs_dir_plots}/{sample_type}_bar_plot.pdf"), height = 10, width = 12)
  plot.bar.plot(bp_df_list[[sample_type]]) %>% print()
  dev.off()
}

# Bar Plot Stats
outs_dir_stats = "cibersort-outs/bar-plot-stats"
if (!dir.exists(outs_dir_stats)) dir.create(outs_dir_stats)

for (sample_type in names(bp_df_list)) {
  sample_stats <- get.bar.plot.stats(bp_df_list[[sample_type]], comparison_col = "groups")
  write.csv(sample_stats, glue("{outs_dir_stats}/{sample_type}_bar_plot_stats.csv"), row.names = F)
}




















