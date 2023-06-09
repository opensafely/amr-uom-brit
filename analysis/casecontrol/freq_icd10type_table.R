# Load necessary library
library(readr)
library(dplyr)
library(here)
library(tidyr)

# Required library
library(readr)
library(here)

# Define dataset names
dataset_names <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Loop through each dataset name
for(dataset_name in dataset_names){

  # Import data
  df <- read_csv(here::here("output",paste0("input_case_", dataset_name, "_var_4.csv")))
  
  # Calculate the sum for each column 
  column_sums <- colSums(df[,4:ncol(df)])

  # Create a data frame with columns and their sums
  sum_df <- data.frame(column_name = names(column_sums), sum = column_sums)

  # Calculate the percentage for each column and round to two decimal places
  sum_df$percentage <- round((sum_df$sum / nrow(df)) * 100, 2)

  # Rank the columns based on the sum
  sum_df$rank <- rank(-sum_df$sum)

  # Order by rank
  sum_df <- sum_df[order(sum_df$rank),]
  
  # Write the dataframe to csv
  write_csv(sum_df, here::here("output", paste0("freq_icd10type_", dataset_name, ".csv")))
}

