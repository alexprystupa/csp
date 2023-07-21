# Overview

# Load Packages
library(tidyverse)
library(glue)
library(stringr)

# Functions

# 1. Return Stats Data Frame
## This function is performed on the cleaned output of CiberSort
return.stats.df <- function(df, comparison_col) {
  comp_df <- expand.grid(unique(df$cell_types), unique(df[[comparison_col]]), unique(df[[comparison_col]]))
  
  colnames(comp_df) <- c("cell_types", "ident.1", "ident.2")
  
  comp_df <- subset(comp_df, subset = ident.1 != ident.2)
  
  comp_df$combined <- apply(comp_df, 1, FUN = function(x) {
    sort_test <- sort(c(x[2], x[3]))
    return(paste(x[1], sort_test[1], sort_test[2], sep = "_"))
  })
  
  comp_df <- comp_df[!duplicated(comp_df$combined),] %>% dplyr::select(-combined)

  return(comp_df)
}



# 2. Get Subsetted Data Frame
## This function is performed on the original data frame. It is ended to be performed based on each row of the output of return.stat.df function.
get.subset.df <- function(df, comparison_col, cell_type, comparison_1, comparison_2) {
  
  return(subset(df, subset = cell_types == cell_type & eval(as.symbol(comparison_col)) %in% c(comparison_1, comparison_2)))
}



# 3. Get P Value
# This function will be on the subsetted data frame that contains cell fractions. The p values will then be added to the output of return.stats.df
get.p.value <- function(sub_df, comparison_col) {
  
  comparison_1 <- subset(sub_df, subset = eval(as.symbol(comparison_col)) == unique(sub_df[[comparison_col]])[1]) %>% pull(cell_fraction)
  comparison_2 <- subset(sub_df, subset = eval(as.symbol(comparison_col)) == unique(sub_df[[comparison_col]])[2]) %>% pull(cell_fraction)
  
  wilcox.out <- wilcox.test(comparison_1, comparison_2)
  return(wilcox.out$p.value)
}



# 4. Get Mean for Each Ident
get.comp.mean <- function(sub_df, comparison_col, ident_col) {
  
  #return(subset(sub_df, subset = eval(as.symbol(comparison_col)) == unique(sub_df[[comparison_col]])[comparison_num]) %>% 
  #         pull(cell_fraction) %>% mean())
  return(subset(sub_df, subset = eval(as.symbol(comparison_col)) == ident_col) %>% pull(cell_fraction) %>% mean())
}



# 5. Subset Data frame and Extract Means & P-Value based on each row stats data frame
get.bar.plot.stats <- function(df, comparison_col) {
  
  # Get Stats Data frame before statistics operations
  stats_df <- return.stats.df(df = df, comparison_col = comparison_col)
  
  # Add Column for Mean of Ident 1
  stats_df$ident.1.mean <- apply(stats_df, 1, FUN = function(x) {
    sub_df <- get.subset.df(df = df, comparison_col = comparison_col, cell_type = x[1], comparison_1 = x[2], comparison_2 = x[3])
    return(get.comp.mean(sub_df, comparison_col = comparison_col, ident_col = x[2]))
  })
  
  # Add Column for Mean of Ident 2
  stats_df$ident.2.mean <- apply(stats_df, 1, FUN = function(x) {
    sub_df <- get.subset.df(df = df, comparison_col = comparison_col, cell_type = x[1], comparison_1 = x[2], comparison_2 = x[3])
    return(get.comp.mean(sub_df, comparison_col = comparison_col, ident_col = x[3]))
  })
  
  # Use Wilcoxon Rank Sum Test to get p-values
  stats_df$p.values <- apply(stats_df, 1, FUN = function(x) {
    sub_df <- get.subset.df(df = df, comparison_col = comparison_col, cell_type = x[1], comparison_1 = x[2], comparison_2 = x[3])
    p.val <- get.p.value(sub_df, comparison_col = comparison_col)
    return(p.val)
  })
  
  # Add Significance Column
  stats_df <- stats_df %>%
    mutate(sig = case_when(
      p.values > 0.1 ~ "-",
      p.values <= 0.1 & p.values > 0.05 ~ "?",
      p.values <= 0.05 & p.values > 0.01 ~"*",
      p.values <= 0.01 ~ "**",
      p.values <= 0.001 ~ "***"
    ))
  
  return(stats_df %>% mutate(across(is.numeric, round, digits = 4)))
}



