## ###########################################################

##  This script:
##  - Imports data extracted from the cohort extractor (wave1, wave2, wave3)
##  - Formats column types and levels of factors in data
##  - Saves processed data in ./output/processed/input_wave*.rds

## linda.nab@thedatalab.com - 2022024
## ###########################################################

# Load libraries & custom functions ---
library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)
utils_dir <- here("analysis", "utils")
source(paste0(utils_dir, "/extract_data.R")) # function extract_data()
source(paste0(utils_dir, "/add_kidney_vars_to_data.R")) # function add_kidney_vars_to_data()
source(paste0(utils_dir, "/process_data.R")) # function process_data()


# list of all input files
input_files <- c("input_control_uti_othvar.csv",
                 "input_control_urti_othvar.csv",
                 "input_control_lrti_othvar.csv")

# directory where input files are located
input_dir <- here::here("output")

# create output directory if it doesn't exist
output_dir <- here::here("output", "processed")
fs::dir_create(output_dir)

# loop over all input files
for(input_file in input_files) {
  # generate full path of input file
  input_file_path <- file.path(input_dir, input_file)
  
  # Extract data from the input file and formats columns to correct type (e.g., integer, logical etc)
  data_extracted <- extract_data(input_file_path)
  
  # Add Kidney columns to data (egfr and ckd_rrt)
  data_extracted_with_kidney_vars <- add_kidney_vars_to_data(data_extracted)
  
  # Process data_extracted by using correct levels for each column of type factor
  data_processed <- process_data(data_extracted_with_kidney_vars)
  
  # determine output file name
  output_file_name <- sub(".csv", ".rds", input_file)  # replace .csv with .rds
  
  # Save output
  saveRDS(object = data_processed,
          file = file.path(output_dir, output_file_name),
          compress = TRUE)
}