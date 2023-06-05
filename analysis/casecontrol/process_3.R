# Load necessary libraries
library(readr)
library(dplyr)

# Define list of infection types
infection_types <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Define column specifications
col_spec_cases <-cols_only(patient_index_date = col_date(format = ""),
                           set_id = col_number(),
                           case = col_number(),
                           patient_id = col_number())

# Loop through each infection type and process data
for (infection in infection_types) {
  # Read CSV file
  table <- read_csv(paste0("output/cases_", infection, ".csv"), col_types = col_spec_cases)
  
  # Read first RDS file
  rds1 <- readRDS(paste0("output/processed/input_case_", infection, "_var_1.rds"))
  
  # Read second RDS file, excluding "age" column
  rds2 <- readRDS(paste0("output/processed/input_case_", infection, "_var_2.rds")) %>% 
    select(-age)
  
  # Merge three datasets
  merged_data <- table %>%
    left_join(rds1, by = c("patient_id", "patient_index_date")) %>%
    left_join(rds2, by = c("patient_id", "patient_index_date"))
  
  # Write the merged data to a new RDS file
  writeRDS(merged_data, paste0("output/processed/case_", infection, ".rds"))
}
