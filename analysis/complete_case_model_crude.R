# Import libraries
library(tidyverse)
library(gtsummary)
library(survival)
library(car)
library(data.table)
library(gridExtra)
library(here)

# Function to fit and summarize the model
fit_model <- function(df, var) {
  model <- clogit(case ~ eval(parse(text=var)) + strata(set_id), df)
  return(data.frame(summary(model)$conf.int))
}

# Main function to process data
process_data <- function(file_path, output_name) {
  df <- readRDS(file_path) %>% 
    filter(
      !(smoking_status %in% c("Missing", NA) | 
          is.na(bmi_adult) | 
          ethnicity %in% c("Unknown", NA))
    )

  # Variables to iterate over
  variables <- c('imd', 'region', 'ethnicity', 'bmi_adult', 'smoking_status', 
                 'hypertension', 'chronic_respiratory_disease', 'asthma',
                 'chronic_cardiac_disease', 'diabetes_controlled', 'cancer',
                 'haem_cancer', 'chronic_liver_disease', 'stroke', 'dementia',
                 'other_neuro', 'organ_kidney_transplant', 'asplenia',
                 'ra_sle_psoriasis', 'immunosuppression', 'learning_disability',
                 'sev_mental_ill', 'alcohol_problems', 'care_home_type_ba',
                 'ckd_rrt', 'ab_frequency', 'ab_type_num')

  results_list <- lapply(variables, fit_model, df=df)
  result_df <- bind_rows(results_list) %>% 
    select(-Estimate) %>%
    setNames(c("OR", "CI_L", "CI_U")) %>%
    mutate(type = rownames(.)) %>%
    data.table()

  write_csv(result_df, here::here("output", output_name))
}

# Process the different datasets
process_data("output/processed/input_model_c_h.rds", "complete_case_model_result_c_h.csv")
process_data("output/processed/input_model_c.rds", "complete_case_model_result_c.csv")
process_data("output/processed/input_model_h.rds", "complete_case_model_result_h.csv")
