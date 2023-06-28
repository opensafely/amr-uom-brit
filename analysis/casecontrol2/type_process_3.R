# Load libraries
library("dplyr")
library("tidyverse")
library("lubridate")
library("here")

# Function to define column specifications and load the datasets
  col_spec_case <- cols_only(
    patient_index_date = col_date(format = ""),
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
    patient_index_date = col_date(format = ""),
    age = col_number(),
    sex = col_character(),
    set_id = col_number(),
    case = col_number(),
    ab_history_3yr = col_number(),
    patient_id = col_number()
  )

  df_cases <- read_csv(paste0("output/matched_cases_", "ae2", ".csv"), col_types = col_spec_case)
  df_matches <- read_csv(paste0("output/matched_matches_", "ae2", ".csv"), col_types = col_spec_control)

  df_case_cdi <- df_cases %>% filter(cdi_binary==0) %>% select(-c("cdi_binary","abr_binary"))
  filtered_control <- df_matches %>% filter(set_id %in% df_case_cdi$set_id)


  df_ab_vars <- c("patient_index_date", "patient_id","charlson_score", "charlsonGrp")


  df_cases_ab <- readRDS(paste0("output/processed/input_case_", "ae2", "_abvar.rds"))
  df_matches_ab <- readRDS(paste0("output/processed/input_control_", "ae2", "_abvar.rds"))

  df_cases <- df_case_cdi %>% left_join(df_cases_ab, by = c("patient_id", "patient_index_date"))
  df_matches <- filtered_control %>% left_join(df_matches_ab, by = c("patient_id", "patient_index_date"))


  # Combine datasets using rbind
  merged_data <- rbind(df_cases, df_matches)

  # Save the merged data to a new RDS file using saveRDS
  saveRDS(merged_data, here("output", "processed", paste0("model2_", "ae2", "_", "abr", ".rds")))



