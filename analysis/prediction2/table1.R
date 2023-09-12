# Define your library imports
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")
library("readr")
library("here")
columns_of_interest <- c("EVENT", "age", "age_band", "sex", "region", "imd", "ethnicity", "bmi", "smoking_status_comb", "charlsonGrp", "ab_3yr", "ab_30d")

# Load data
input_data <- readRDS(here::here("output", "data_for_cox_model_all.rds"))

# Define a function to calculate the age band
get_age_band <- function(age) {
  case_when(
    age >= 18 & age < 40 ~ "18-39",
    age >= 40 & age < 50 ~ "40-49",
    age >= 50 & age < 60 ~ "50-59",
    age >= 60 & age < 70 ~ "60-69",
    age >= 70 & age < 80 ~ "70-79",
    age >= 80 ~ "80+"
  )
}

input_data <- input_data %>%
  mutate(age_band = get_age_band(age))

conditions <- c("has_uti", "has_urti", "has_lrti", "has_sinusitis", "has_ot_externa", "has_otmedia")

for (condition in conditions) {
  data_filtered <- input_data %>% filter(!!sym(condition))
  
  # Generate baseline table for each condition
  condition_summary <- data_filtered %>% summary_factorlist(explanatory = columns_of_interest)
  
  # Write condition summary to csv using here::here
  filename <- here::here("output", sprintf("%s_table1.csv", condition))
  write_csv(condition_summary, filename)
}
