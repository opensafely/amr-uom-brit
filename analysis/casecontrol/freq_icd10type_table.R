# Load necessary library
library(readr)
library(dplyr)
library(here)
library(tidyr)

# Define a function for generating the frequency table
generate_freq_table <- function(dataset_name) {
  # Read in the data
  df <- read_csv(here("output", paste0("input_case_", dataset_name, "_var_4.csv")))

  # Calculate the frequency and percentage
  type_columns <- c("ae_I15_codelist", "ae_I26_codelist", "ae_I31_codelist", "ae_I42_codelist", "ae_I44_codelist", 
                    "ae_I45_codelist", "ae_I46_codelist", "ae_I47_codelist", "ae_I49_codelist", "ae_I60_codelist", 
                    "ae_I61_codelist", "ae_I62_codelist", "ae_I80_codelist", "ae_I85_codelist", "ae_I95_codelist", 
                    "ae_J38_codelist", "ae_J45_codelist", "ae_J46_codelist", "ae_J70_codelist", "ae_J80_codelist", 
                    "ae_J81_codelist", "ae_N14_codelist", "ae_N17_codelist", "ae_N19_codelist", "ae_R00_codelist", 
                    "ae_R04_codelist", "ae_R06_codelist", "ae_R41_codelist", "ae_R42_codelist", "ae_R44_codelist", 
                    "ae_R50_codelist", "ae_R51_codelist", "ae_R55_codelist", "ae_R58_codelist", "ae_S06_codelist", 
                    "ae_X44_codelist", "ae_Y40_codelist", "ae_Y41_codelist", "ae_Y57_codelist", "ae_Y88_codelist", 
                    "ae_Z88_codelist")
                    
  type_freq_table <- df %>%
    select(all_of(type_columns)) %>%
    summarise_all(sum) %>%
    gather(key = "Type", value = "Frequency") %>%
    mutate(Percentage = round(Frequency / sum(Frequency) * 100, 2)) %>%
    arrange(desc(Frequency))  # Sort the table in descending order

  # Save the output
  write_csv(type_freq_table, here::here("output", paste0("freq_icd10type_", dataset_name, ".csv")))
  
  return(type_freq_table)
}

# Define the dataset names
dataset_names <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Apply the function to all the datasets
lapply(dataset_names, generate_freq_table)
