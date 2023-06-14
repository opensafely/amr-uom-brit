# Load necessary library
library(dplyr)
library(readr)
library(here)

# Directory where input files are located
input_dir <- here("output")

# Load data from csv
file_path <- file.path(input_dir, "input_case_uti_study2.csv")
df <- read_csv(file_path)

# Count the number of TRUE entries for ae_diarrhea and ae_candidiasis
diarrhea_count <- sum(df$ae_diarrhea == 1)
candidiasis_count <- sum(df$ae_candidiasis == 1)

# Create a data frame to hold the counts
outcome_table <- data.frame(ae_diarrhea = diarrhea_count, ae_candidiasis = candidiasis_count)

# Save the table as csv
output_file_path <- file.path(here("output"), "study2_uti_table.csv")
write_csv(outcome_table, output_file_path)
