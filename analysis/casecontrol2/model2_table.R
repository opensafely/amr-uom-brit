# Define your library imports
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

columns <- c("age","age_band","sex","imd","ethnicity","region","smoking_status_comb","bmi", "exposure_ab", "charlsonGrp","ckd_rrt")
# Create a vector with the names of the datasets
datasets <- c("ae2")

# Loop over the names
for (ds in datasets) {
  
  # Read the case and control datasets
  data <- readRDS(here::here("output", "processed", paste0("model_", ds, ".rds")))


  data <- data %>% mutate(ab_history_count = case_when(ab_history_3yr == 0 ~ "0",
                                                    ab_history_3yr == 1 ~ "1",
                                                    ab_history_3yr > 1 & ab_history_3yr <3 ~ "2-3",
                                                    ab_history_3yr >= 3 ~ "3+"))

  data$age_band = case_when(
    data$age >= 18 & data$age < 40 ~ "18-39",
    data$age >= 40 & data$age < 50 ~ "40-49",
    data$age >= 50 & data$age < 60 ~ "50-59",
    data$age >= 60 & data$age < 70 ~ "60-69",
    data$age >= 70 & data$age < 80 ~ "70-79",
    data$age >= 80 ~ "80+")

  data <- data %>% mutate(exposure_ab = case_when(
  ab_history_count == "0" & ab_type_num == "0" ~ "count_0_type_0",
  ab_history_count == "1" & ab_type_num == "1" ~ "count_1_type_1",
  ab_history_count == "2-3" & ab_type_num == "1" ~ "count_23_type_1",
  ab_history_count == "2-3" & ab_type_num == "2-3" ~ "count_23_type_23",
  ab_history_count == "3+" & ab_type_num == "1" ~ "count_4_type_1",
  ab_history_count == "3+" & ab_type_num == "2-3" ~ "count_4_type_23",
  ab_history_count == "3+" & ab_type_num == "3+" ~ "count_4_type_4",
  TRUE ~ "count_0_type_0"
))

  data$exposure_ab = relevel(as.factor(data$exposure_ab), ref="count_0_type_0")

  case <- data %>% filter(case==1)
  control <- data %>% filter(case==0)


  # Generate baseline table for case
  case_summary <- case %>% summary_factorlist(explanatory = columns)

  # Write case summary to csv
  write_csv(case_summary, here::here("output", paste0("table_2_", ds, "_case.csv")))

  # Generate baseline table for control
  control_summary <- control %>% summary_factorlist(explanatory = columns)

  # Write control summary to csv
  write_csv(control_summary, here::here("output", paste0("table_2_", ds, "_control.csv")))

}
