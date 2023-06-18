# Load libraries
library("dplyr")
library("tidyverse")
library("lubridate")
library("here")

# Function to define column specifications and load the datasets
load_dataset <- function(file_path) {
  col_spec <- cols_only(
    patient_index_date = col_date(format = ""),
    age = col_number(),
    sex = col_character(),
    set_id = col_number(),
    case = col_number(),
    patient_id = col_number()
  )

  df <- read_csv(here(file_path), col_types = col_spec)
  return(df)
}

# Function to load and prepare the second and third dataset
load_prepared_df <- function(file_path, selected_vars) {
  df <- readRDS(here(file_path)) %>% select(one_of(selected_vars))
  return(df)
}

# Function to merge datasets
merge_data <- function(df.1, df.2, df.3) {
  merged_data <- df.1 %>%
    left_join(df.2, by = c("patient_id", "patient_index_date")) %>%
    left_join(df.3, by = c("patient_id", "patient_index_date"))
  
  return(merged_data)
}

# Main function
main <- function(condition) {
  df_cases <- load_dataset(paste0("output/matched_cases_", condition, ".csv"))
  df_matches <- load_dataset(paste0("output/matched_matches_", condition, ".csv"))

  df_ab_vars <- c("patient_index_date", "patient_id", "ab_treatment", "ab_frequency", "ab_history", "charlson_score", "charlsonGrp")
  df_oth_vars <- c("patient_index_date", "patient_id", "region", "imd", "ethnicity", "bmi", "smoking_status_comb", "ckd_rrt")

  df_cases_ab <- load_prepared_df(paste0("output/processed/input_case_", condition, "_abvar.rds"), df_ab_vars)
  df_cases_oth <- load_prepared_df(paste0("output/processed/input_case_", condition, "_othvar.rds"), df_oth_vars)

  df_matches_ab <- load_prepared_df(paste0("output/processed/input_control_", condition, "_abvar.rds"), df_ab_vars)
  df_matches_oth <- load_prepared_df(paste0("output/processed/input_control_", condition, "_othvar.rds"), df_oth_vars)

  df_cases <- merge_data(df_cases, df_cases_ab, df_cases_oth)
  df_matches <- merge_data(df_matches, df_matches_ab, df_matches_oth)

  # Combine datasets using rbind
  merged_data <- rbind(df_cases, df_matches)

  # Save the merged data to a new RDS file using saveRDS
  saveRDS(merged_data, here("output", "processed", paste0("model_", condition, ".rds")))
}

# Call the main function for each condition
main("uti")
main("urti")
main("lrti")
