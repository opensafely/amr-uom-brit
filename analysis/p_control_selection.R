# Required libraries
library(readr)
library(here)
library(dplyr)

# Read in dataset
df <- read_csv(here::here("output", "input_p_control_2_var.csv"), 
      col_types = cols(
        patient_id = col_integer(),
        patient_index_date = col_date(format = ""),
        age = col_integer(),
        agegroup = col_character(),
        sex = col_character(),
        region = col_character(),
        SGSS_positive_6weeks = col_logical(),
        GP_positive_6weeks = col_logical(),
        covid_admission_6weeks = col_logical(),
        ab_history_3yr = col_integer()))

# Exclude rows
df <- df %>% 
  filter(!SGSS_positive_6weeks,
         !GP_positive_6weeks,
         !covid_admission_6weeks)

# Write to csv
write_csv(df, here::here("output", "p_control_cohort.csv"))
