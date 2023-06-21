# Define your library imports
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

columns <- c("sex","region","ab_frequency", "charlsonGrp","outcome_type")

# Create a vector with the names of the datasets
datasets <- c("uti", "lrti", "urti")

# Loop over the names
for (ds in datasets) {
  
  # Read the case and control datasets
  data <- readRDS(here::here("output", "processed", paste0("model_", ds, ".rds")))

  setiddt <- read_csv(here::here("output",paste0("mapping_input_case_",ds,"_type.csv")))%>%select(set_id,outcome_type)
  data <- merge(data,setiddt,by="set_id")

  data <- data %>% filter(outcome_type == "side effect")

  case <- data %>% filter(case==1)
  control <- data %>% filter(case==0)


  # Generate baseline table for case
  case_summary <- case %>% summary_factorlist(explanatory = columns)

  # Write case summary to csv
  write_csv(case_summary, here::here("output", paste0("table_1_", ds, "_case_sideeffect.csv")))

  # Generate baseline table for control
  control_summary <- control %>% summary_factorlist(explanatory = columns)

  # Write control summary to csv
  write_csv(control_summary, here::here("output", paste0("table_1_", ds, "_control_sideeffect.csv")))

}