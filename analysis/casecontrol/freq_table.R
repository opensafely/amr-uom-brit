# Load necessary library
library(readr)
library(dplyr)
library(here)
library(tidyr)

# Define a function for generating the frequency table
generate_freq_table <- function(dataset_name) {
  # Read in the data
  df <- read_csv(here("output", paste0("input_case_", dataset_name, "_var_3.csv")))

  # Calculate the frequency and percentage
  type_columns <- c('ae_hematologic', 'ae_behavioral', 'ae_circulatory', 'ae_digestive', 'ae_endocrine', 'ae_eyeear', 'ae_genitourinary', 
                    'ae_liver', 'ae_nervous', 'ae_musculoskeletal', 'ae_poisoning', 'ae_renal', 'ae_respiratory', 'ae_skin', 'ae_unclassified')
                    
  full_names <- c('hematologic', 'behavioral syndromes', 'circulatory system', 'digestive system', 'endocrine', 'eye and ear', 
                  'genitourinary system (other than kidney)', 'liver', 'nervous system', 
                  'musculoskeletal system and connective tissue', 'poisoning', 'renal', 'respiratory system', 
                  'skin and subcutaneous tissue', 'others')

  type_freq_table <- df %>%
    select(all_of(type_columns)) %>%
    summarise_all(sum) %>%
    gather(key = "Type", value = "Frequency") %>%
    mutate(Type = recode(Type, !!!setNames(full_names, type_columns)), # Map the type to its full name
           Percentage = round(Frequency / sum(Frequency) * 100, 2))

  # Save the output
  write_csv(type_freq_table, here::here("output", paste0("freq_", dataset_name, ".csv")))
  
  return(type_freq_table)
}

# Define the dataset names
dataset_names <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Apply the function to all the datasets
lapply(dataset_names, generate_freq_table)

