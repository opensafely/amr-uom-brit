# Load necessary library
library(readr)
library(dplyr)
library(here)
library(tidyr)
library(purrr)

# Define a function for generating the frequency table
generate_freq_table <- function(dataset_name) {
  # Read in the data
  df <- read_csv(here("output", paste0("input_case_", dataset_name, "_var_3.csv")))
  
  # Add a new column to identify the dataset
  df$dataset <- dataset_name

  return(df)
}

# Define the dataset names
dataset_names <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Apply the function to all the datasets
list_of_data <- lapply(dataset_names, generate_freq_table)

# Bind all the data into one data frame
combined_data <- bind_rows(list_of_data)

# Calculate the frequency for each type and each dataset
type_columns <- c('ae_hematologic', 'ae_behavioral', 'ae_circulatory', 'ae_digestive', 'ae_endocrine', 'ae_eyeear', 'ae_genitourinary', 
                  'ae_liver', 'ae_nervous', 'ae_musculoskeletal', 'ae_poisoning', 'ae_renal', 'ae_respiratory', 'ae_skin', 'ae_unclassified')

full_names <- c('hematologic', 'behavioral syndromes', 'circulatory system', 'digestive system', 'endocrine', 'eye and ear', 
                'genitourinary system (other than kidney)', 'liver', 'nervous system', 
                'musculoskeletal system and connective tissue', 'poisoning', 'renal', 'respiratory system', 
                'skin and subcutaneous tissue', 'others')

type_freq_table <- combined_data %>%
  select(c('dataset', all_of(type_columns))) %>%
  gather(key = 'Type', value = 'Frequency', -dataset) %>%
  mutate(Type = recode(Type, !!!setNames(full_names, type_columns))) %>%
  group_by(dataset, Type) %>%
  summarise(Frequency = sum(Frequency), .groups = 'drop')

# Spread the data to get a wide format table
wide_table <- type_freq_table %>%
  spread(key = dataset, value = Frequency)

# Save the output
write_csv(wide_table, here::here("output", "freq_combined.csv"))

wide_table

