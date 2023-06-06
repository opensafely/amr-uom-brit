# Define your library imports
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

# Define the case_when logic once to be used for both datasets
care_home_type_ba <- function(care_home_type) {
  case_when(
    care_home_type == "U" ~ "FALSE",
    care_home_type == "NA" ~ "FALSE",
    care_home_type == "PC" ~ "TRUE",
    care_home_type == "PN" ~ "TRUE",
    care_home_type == "PS" ~ "TRUE"
  )
}

# Define necessary columns
columns <- c("age", "agegroup", "sex", "region", "imd", "ethnicity", "bmi", "smoking_status",
             "hypertension", "chronic_respiratory_disease", "asthma", "chronic_cardiac_disease",
             "diabetes_controlled", "cancer", "haem_cancer", "chronic_liver_disease", "stroke",
             "dementia", "other_neuro", "organ_kidney_transplant", "asplenia", "ra_sle_psoriasis",
             "immunosuppression", "learning_disability", "sev_mental_ill", "alcohol_problems",
             "care_home_type_ba", "ckd_rrt", "ab_frequency", "ab_type_num", "charlsonGrp")

# Create a vector with the names of the datasets
datasets <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Loop over the names
for (ds in datasets) {
  
  # Read the case and control datasets
  case <- readRDS(here::here("output", "processed", paste0("case_", ds, ".rds")))
  control <- readRDS(here::here("output", "processed", paste0("control_", ds, ".rds")))

  # Apply the care_home_type_ba function
  case$care_home_type_ba <- care_home_type_ba(case$care_home_type)
  control$care_home_type_ba <- care_home_type_ba(control$care_home_type)

  # Select necessary columns
  case <- case %>% select(all_of(columns))
  control <- control %>% select(all_of(columns))

  # Generate baseline table for case
  case_summary <- case %>% summary_factorlist(explanatory = columns)

  # Write case summary to csv
  write_csv(case_summary, here::here("output", paste0("table_1_", ds, "_case.csv")))

  # Generate baseline table for control
  control_summary <- control %>% summary_factorlist(explanatory = columns)

  # Write control summary to csv
  write_csv(control_summary, here::here("output", paste0("table_1_", ds, "_control.csv")))


}