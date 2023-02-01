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


## Extract data from the input_files and formats columns to correct type 
## (e.g., integer, logical etc)
input_files <-
  Sys.glob(here::here("output", "input_variables.csv"))

data_extracted <-
  extract_data(input_files)
## Add Kidney columns to data (egfr and ckd_rrt)
data_extracted_with_kidney_vars <-
  add_kidney_vars_to_data(data_extracted)
## Process data_extracted by using correct levels for each column of type factor
data_processed <-
  process_data(data_extracted_with_kidney_vars)
 
# Save output ---
output_dir <- here("output", "processed")
fs::dir_create(output_dir)
saveRDS(object = data_processed,
        file = paste0(output_dir, "/input_", "case_data", ".rds"),
        compress = TRUE)