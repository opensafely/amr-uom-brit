
# Load necessary libraries
library(readr)
library(dplyr)
library(here)
library(lubridate)  # for date manipulation
library(tidyverse)

# Define dataset names
dataset_names <- c("uti", "lrti", "urti")

# Define date_gap labels
date_gap_labels <- c("0-7 days", "8-14 days", "15-21 days", "22-30 days")

# Loop through each dataset name
for(dataset_name in dataset_names){
  
  # Import data
  df <- read_csv(here::here("output",paste0("input_case_", dataset_name, "_var_5.csv")))
  
  # Convert date columns to Date type
  df$patient_index_date <- as.Date(df$patient_index_date)
  df$infection_date <- as.Date(df$infection_date)
  
  # Calculate date_gap in days
  df$date_gap <- df$patient_index_date - df$infection_date
  
  # Classify date_gap
  df$date_gap <- cut(as.numeric(df$date_gap), breaks=c(-Inf, 7, 14, 21, Inf), labels=date_gap_labels, include.lowest = TRUE)
  
  # Replace NA in date_gap with "22-30 days"
  df$date_gap <- replace_na(df$date_gap, "22-30 days")
  
  # Loop through each type of date_gap
  for(label in date_gap_labels){
    
    # Filter the dataframe by date_gap
    df_filtered <- df[df$date_gap == label,]
    
    # Select only numeric columns and exclude the last column
    df_filtered <- df_filtered %>% select(where(is.numeric))
    df_filtered <- df_filtered[, -ncol(df_filtered)] # removes the last column
    
    # Calculate the sum for each column 
    column_sums <- colSums(df_filtered[,4:ncol(df_filtered)])
    
    # Create a data frame with columns and their sums
    sum_df <- data.frame(column_name = names(column_sums), sum = column_sums)
    
    # Calculate the percentage for each column and round to two decimal places
    sum_df$percentage <- round((sum_df$sum / nrow(df_filtered)) * 100, 2)
    
    # Rank the columns based on the sum
    sum_df$rank <- rank(-sum_df$sum)
    
    # Order by rank
    sum_df <- sum_df[order(sum_df$rank),]
    
    # Write the dataframe to csv
    write_csv(sum_df,here::here("output",paste0("freq_icd10type_", dataset_name, "_", label, ".csv")))
  }
}
