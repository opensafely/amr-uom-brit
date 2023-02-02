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
  Sys.glob(here::here("output", "input_control_var_*.csv"))


# Extract data from the input_files and formats columns to correct type 
## (e.g., integer, logical etc)
data_extracted <-
  map(.x = input_files,
      .f = ~ extract_data(file_name = .x))
## Add Kidney columns to data (egfr and ckd_rrt)
data_extracted_with_kidney_vars <- 
  map(.x = data_extracted,
      .f = ~ add_kidney_vars_to_data(data_extracted = .x))
## Process data_extracted by using correct levels for each column of type factor
data_processed <- 
  map(.x = data_extracted_with_kidney_vars,
       .f = ~ process_data(data_extracted = .x))


data_processed <- bind_rows(data_processed)

 
# Save output ---
output_dir <- here("output", "processed")
fs::dir_create(output_dir)
saveRDS(object = data_processed,
        file = paste0(output_dir, "/input_", "control_data", ".rds"),
        compress = TRUE)