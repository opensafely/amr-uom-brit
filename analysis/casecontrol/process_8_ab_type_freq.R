# Load the necessary libraries
library(readr)
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)

# Load necessary packages
library(tidyverse)

# Define the list of input files
input_files <- c("input_case_uti_var_2.csv",
                 "input_case_lrti_var_2.csv",
                 "input_case_urti_var_2.csv",
                 "input_case_sinusitis_var_2.csv",
                 "input_case_ot_externa_var_2.csv",
                 "input_case_ot_media_var_2.csv",
                 "input_case_pneumonia_var_2.csv")

# Define the list of infections (matches order of input_files)
infections <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Iterate over each file in the list
for (i in 1:length(input_files)) {

  # Load data for the current infection
  case_infection <- read_csv(here::here("output", input_files[i]))

  # Columns related to the antibiotics
  antibiotic_cols <- grep("^Rx_", names(case_infection), value = TRUE)

  # Transform the dataframe
  case_infection <- case_infection %>%
    mutate_at(.vars = antibiotic_cols, .funs = ~ifelse(. != 0, 1, 0))

  # Generate frequency table
  frequency_table <- colSums(case_infection[antibiotic_cols])

  # Convert to a dataframe for better view
  frequency_table <- as.data.frame(frequency_table)
  frequency_table <- rownames_to_column(frequency_table, "Antibiotic_Type")
  colnames(frequency_table)[2] <- "Frequency"

  # Write the frequency table to a CSV file
  write_csv(frequency_table, here::here("output", paste0(infections[i], "_abtype_freq.csv")))
}
