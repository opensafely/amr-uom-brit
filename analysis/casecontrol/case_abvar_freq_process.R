# Load libraries & custom functions ---
library(here)
library(dplyr)
library(readr)
library(purrr)
library(tidyverse)
library(stringr)

# Set input and output directories
input_dir <- here::here("output")
output_dir <- here::here("output", "processed")
# Ensure output directory exists
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# List all input files
input_files <- c("input_case_uti_abvar.csv",
                 "input_case_urti_abvar.csv",
                 "input_case_lrti_abvar.csv")

# Function to process data
process_data <- function(input_file) {
  # Read the data
  df <- read.csv(file.path(input_dir, input_file))
  
  # Filter columns
  cols_to_keep <- c("patient_id", "patient_index_date", grep("^Rx_", colnames(df), value = TRUE))
  df <- df[, cols_to_keep]

  # Remove "Rx_" from column names
  names(df) <- str_replace(names(df), "Rx_", "")

  # Convert antibiotic columns to logical
  ab_cols <- names(df)[!names(df) %in% c("patient_id", "patient_index_date")]
  df <- df %>% mutate_at(vars(ab_cols), ~ . > 0)

  # Generate frequency table of antibiotics
  freq_table <- df %>%
    select(-c(patient_id, patient_index_date)) %>%
    summarise_all(sum) %>%
    gather(key = "antibiotic", value = "frequency") %>%
    arrange(desc(frequency)) %>%
    head(10)

  # Write frequency table to CSV
  freq_table_file <- file.path(output_dir, str_replace(basename(input_file), "\\.csv", "_freq_ab.csv"))
  write.csv(freq_table, freq_table_file)

  # Save final dataset
  rds_file <- file.path(output_dir, str_replace(basename(input_file), "\\_abvar\\.csv", "_ab.rds"))
  saveRDS(df, rds_file)
}

# Apply function to each file
lapply(input_files, process_data)

