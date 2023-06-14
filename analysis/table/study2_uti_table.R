# Load necessary library
library(dplyr)
library(readr)
library(here)

# Directory where input files are located
input_dir <- here("output")

# Load data from csv
file_path <- file.path(input_dir, "input_case_uti_study2.csv")
df <- read_csv(file_path)

# Create a table of outcome_type counts
outcome_table <- df %>%
  group_by(outcome_type) %>%
  summarise(count = n(), .groups = "keep")

# Save the table as csv
output_file_path <- file.path(here("output"), "study2_uti_table.csv")
write_csv(outcome_table, output_file_path)
