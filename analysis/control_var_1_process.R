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


# Initialize variables for different types of data
types <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Directory where input files are located
input_dir <- here::here("output")

# Create output directory if it doesn't exist
output_dir <- here::here("output", "processed")
fs::dir_create(output_dir)

# Loop over all types
for (type in types) {
    # Initialize a list to hold data from each file of the same type
    data_list <- list()
    
    # Loop over files from 1 to 9
    for (i in 1:9) {
        # Generate input file name
        input_file <- paste0("input_control_", i, "_", type, "_var_1.csv")
        
        # Generate full path of input file
        input_file_path <- file.path(input_dir, input_file)
        
        # Extract data from the input file and formats columns to correct type (e.g., integer, logical etc)
        data_extracted <- extract_data(input_file_path)
        
        # Add Kidney columns to data (egfr and ckd_rrt)
        data_extracted_with_kidney_vars <- add_kidney_vars_to_data(data_extracted)
        
        # Process data_extracted by using correct levels for each column of type factor
        data_processed <- process_data(data_extracted_with_kidney_vars)
        
        # Append data_processed to data_list
        data_list[[i]] <- data_processed
    }
    
    # Combine all data from the same type
    data_combined <- do.call(rbind, data_list)
    
    # Determine output file name
    output_file_name <- paste0("input_control_", type, "_var_1.rds")
    
    # Save output
    saveRDS(object = data_combined,
            file = file.path(output_dir, output_file_name),
            compress = TRUE)
}
