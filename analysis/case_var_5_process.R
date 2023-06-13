# Load libraries & custom functions ---
library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)

# Define column specifications
col_spes <-cols_only(patient_index_date = col_date(format = ""),
                           infection_date = col_date(format = ""),
                           patient_id = col_number())

# list of all input files
input_files <- c("input_case_uti_var_5.csv",
                 "input_case_lrti_var_5.csv",
                 "input_case_urti_var_5.csv")

# directory where input files are located
input_dir <- here::here("output")

# create output directory if it doesn't exist
output_dir <- here::here("output", "processed")
fs::dir_create(output_dir)

# loop over all input files
for(input_file in input_files) {
  # generate full path of input file
  input_file_path <- file.path(input_dir, input_file)
  
  # Load data from the input file with specified column types
  data <- read_csv(input_file_path, col_types = col_spes)
  
  # determine output file name
  output_file_name <- sub(".csv", ".rds", input_file)  # replace .csv with .rds
  
  # Save output
  saveRDS(object = data,
          file = file.path(output_dir, output_file_name),
          compress = TRUE)
}