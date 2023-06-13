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
  
  # Load data from the input file
  data <- read.csv(input_file_path)
  
  # Select the desired columns
  data_selected <- data[,c('patient_id', 'patient_index_date', 'infection_date')]
  
  # determine output file name
  output_file_name <- sub(".csv", ".rds", input_file)  # replace .csv with .rds
  
  # Save output
  saveRDS(object = data_selected,
          file = file.path(output_dir, output_file_name),
          compress = TRUE)
}