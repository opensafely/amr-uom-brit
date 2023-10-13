### This script is for sensitivity analysis -- complete case analysis ###

## Import libraries---

require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)


df <- readRDS("output/processed/input_model_c_h.rds")

df$smoking_status[df$smoking_status == "Missing"] <- NA
df$bmi_adult[df$bmi_adult == "Missing"] <- NA
df$ethnicity[df$ethnicity == "Unknown"] <- NA


# Function to generate the frequency of missing values by age and write to CSV
generate_missing_frequency_by_age_to_csv <- function(df, var_name) {
  # Get the name of the variable to be used in the formula
  variable <- as.name(var_name)
  
  # Create a new dataframe where the variable of interest is NA
  missing_df <- df[is.na(df[[variable]]), ]
  
  # Generate a table of frequencies of missing values by age
  freq_table <- table(missing_df$age)
  
  # Convert the table to a dataframe for easy CSV writing
  freq_df <- as.data.frame(freq_table)
  
  # Write to CSV
  output_path <- here::here("output", paste0("missing_freq_by_age_", var_name, ".csv"))
  write_csv(freq_df, output_path)
}

# Using the function to get the frequency tables for each variable
generate_missing_frequency_by_age_to_csv(df, "smoking_status")
generate_missing_frequency_by_age_to_csv(df, "bmi_adult")
generate_missing_frequency_by_age_to_csv(df, "ethnicity")
