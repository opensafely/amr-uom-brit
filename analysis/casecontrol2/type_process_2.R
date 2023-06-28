# Load libraries
library("dplyr")
library("tidyverse")
library("lubridate")
library("here")

# Function to define column specifications and load the datasets
load_dataset <- function(file_path, is_case_file = TRUE) {
  col_spec_case <- cols_only(
    patient_index_date = col_date(format = "%Y-%m-%d"),
    age = col_number(),
    sex = col_character(),
    set_id = col_number(),
    cdi_binary = col_number(),
    abr_binary = col_number(),
    case = col_number(),
    ab_history_3yr = col_number(),
    patient_id = col_number()
  )

  col_spec_control <- cols_only(
    patient_index_date = col_date(format = "%Y-%m-%d"),
    age = col_number(),
    sex = col_character(),
    set_id = col_number(),
    case = col_number(),
    ab_history_3yr = col_number(),
    patient_id = col_number()
  )

  col_spec = ifelse(is_case_file, col_spec_case, col_spec_control)
  df <- read_csv(here(file_path), col_types = col_spec)
  return(df)
}

# Function to load and prepare the second and third dataset
load_prepared_df <- function(file_path, selected_vars) {
  df <- readRDS(here(file_path)) %>% select(one_of(selected_vars))
  return(df)
}

# Function to filter datasets based on binary flags
filter_data <- function(df, flag_column) {
  filtered_data <- df %>% filter(!!sym(flag_column) == 1)
  return(filtered_data)
}

# Function to filter control dataset based on set_id from case dataset
filter_control_data <- function(df_cases, df_control) {
  filtered_control <- df_control %>% filter(set_id %in% df_cases$set_id)
  return(filtered_control)
}

# Function to merge datasets
merge_data <- function(df.1, df.2) {
  merged_data <- df.1 %>%
    select(-cdi_binary, -abr_binary) %>%
    left_join(df.2, by = c("patient_id", "patient_index_date"))
  
  return(merged_data)
}

# Main function
main <- function(condition, flag_column, file_suffix) {
  df_cases <- load_dataset(paste0("output/matched_cases_", condition, ".csv"), is_case_file = TRUE)
  df_matches <- load_dataset(paste0("output/matched_matches_", condition, ".csv"), is_case_file = FALSE)
  
  df_cases <- filter_data(df_cases, flag_column)
  df_matches <- filter_control_data(df_cases, df_matches)

  df_ab_vars <- c("patient_index_date", "patient_id","charlson_score", "charlsonGrp")

  df_cases_ab <- load_prepared_df(paste0("output/processed/input_case_", condition, "_abvar.rds"), df_ab_vars)
  
  df_cases <- merge_data(df_cases, df_cases_ab)
  df_matches <- merge_data(df_matches, df_cases_ab)

  # Combine datasets using rbind
  merged_data <- rbind(df_cases, df_matches)

  # Save the merged data to a new RDS file using saveRDS
  saveRDS(merged_data, here("output", "processed", paste0("model2_", condition, "_", file_suffix, ".rds")))
}

# Call the main function for each condition
main("ae2", "cdi_binary", "cdi")
main("ae2", "abr_binary", "abr")
