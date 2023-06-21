# Load libraries & custom functions ---
library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)

# Set input and output directories
input_dir <- here::here("output")


# List all input files
input_files_1 <- c("input_case_uti_type.csv",
                   "input_case_urti_type.csv",
                   "input_case_lrti_type.csv")

input_files_2 <- c("matched_cases_uti.csv",
                   "matched_cases_urti.csv",
                   "matched_cases_lrti.csv")

# Function to process data
process_data <- function(file1, file2) {
  
  # Read datasets
  df1 <- read_csv(file.path(input_dir, file1)) %>%
    select(patient_id, outcome_type)  # select necessary columns in df1
  
  df2 <- read_csv(file.path(input_dir, file2)) %>%
    select(patient_id, set_id)  # select necessary columns in df2
  
  # Merge datasets
  df <- inner_join(df1, df2, by = "patient_id")
  
  # Save final dataset
  write_csv(df, file.path(input_dir, paste0('mapping_', basename(file1))))
}

# Apply function to each file
mapply(process_data, input_files_1, input_files_2)
