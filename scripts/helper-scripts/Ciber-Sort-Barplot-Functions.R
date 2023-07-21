# 1. Convert Cibersort Cleaned Output to Bar Plottable Data Type
convert.to.bp.ready.df <- function(cs_df, samples_groups_df) {
  bp_df <- cs_df %>% 
    
    tibble::rownames_to_column("cell_types") %>% 
    
    tidyr::pivot_longer(colnames(cs_df), names_to = "samples", values_to = "cell_fraction")
  
  bp_df <- merge(bp_df, samples_groups_df, by = "samples")
  
  return(bp_df)
}

# 2. Get All 5 Possible Subsets
get.bp.subsets <- function(bp_df) {
  
  # Split Dataframes into list by groups, then merge into one list
  split_group_1 <- split(bp_df, bp_df$groups_1)
  split_group_1 <- lapply(split_group_1, FUN = function(x) {
    x <- dplyr::rename(x, groups = groups_2, sample_type = groups_1)
  })
  
  split_group_2 <- split(bp_df, bp_df$groups_2)
  split_group_2 <- lapply(split_group_2, FUN = function(x) {
    x <- dplyr::rename(x, groups = groups_1, sample_type = groups_2)
  }) 
  
  return(c(split_group_1, split_group_2))
}

# 3. Bar Plots Function
plot.bar.plot <- function(df) {
  
  sample_type <- df %>% pull(sample_type) %>% unique()
    
  ggplot(df, aes(x = cell_types, y = cell_fraction, fill = groups)) + 
    geom_boxplot() + 
    ggtitle(label = glue("{sample_type} Samples")) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          plot.title = element_text(hjust = 0.5))
}


