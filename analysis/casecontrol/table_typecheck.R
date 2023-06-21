library(dplyr)
library(readr)
library(here)
library("stringr")

# Define the directory
input_dir <- here::here("output")

# List all input files
input_files <- c("input_case_uti_type.csv",
                 "input_case_urti_type.csv",
                 "input_case_lrti_type.csv")

# Loop through each file
for (file in input_files) {
  
  # Read the data from the file
  df <- read_csv(file.path(input_dir, file))
  
  # Calculate the number of side_effect == 1 and disease == 1
  table <- df %>%
    summarise(side_effect_count = sum(side_effect == 1),
              disease_count = sum(disease == 1))
  
  # Generate the output file name
  output_file <- str_replace(file, "input", "table")
  
  # Write the table to a CSV file
  write_csv(table, file.path(input_dir, output_file))
}
