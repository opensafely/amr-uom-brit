# Define your library imports
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

columns <- c("ab_treatment", "ab_frequency", "ab_history_binary", "charlson_score", "charlsonGrp")

# Create a vector with the names of the datasets
datasets <- c("uti", "lrti", "urti")

# Loop over the names
for (ds in datasets) {
  
  # Read the case and control datasets
  data <- readRDS(here::here("output", "processed", paste0("model_", ds, ".rds")))

  data <- data %>% mutate(ab_history_binary = case_when(ab_history == 0 ~ "FALSE",
                                                    ab_history > 0 ~ "TRUE"))
  case <- data %>% filter(case==1)
  control <- data %>% filter(case==0)


  # Generate baseline table for case
  case_summary <- case %>% summary_factorlist(explanatory = columns)

  # Write case summary to csv
  write_csv(case_summary, here::here("output", paste0("table_1_", ds, "_case.csv")))

  # Generate baseline table for control
  control_summary <- control %>% summary_factorlist(explanatory = columns)

  # Write control summary to csv
  write_csv(control_summary, here::here("output", paste0("table_1_", ds, "_control.csv")))

}