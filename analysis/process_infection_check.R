
# # # # # # # # # # # # # # # # # # # # #
#              This script:             #
#            check case cohort          #
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

# import data
col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        historic_sepsis_gp = col_number(),
                        historic_sepsis_hosp = col_number(),
                        had_sepsis_within_2day = col_number(),
                        SGSS_positive_6weeks = col_number(),
                        GP_positive_6weeks = col_number(),
                        covid_admission_6weeks = col_number(),
                        has_uti = col_number(),
                        has_urti = col_number(),
                        has_lrti = col_number(),
                        has_sinusitis = col_number(),
                        has_ot_externa = col_number(),
                        has_otmedia = col_number(),
                        has_pneumonia = col_number(), 
                        has_infection = col_number(),                 
                        patient_id = col_number()
)

df <- read_csv(here::here("output", "input_case_infection.csv"),
                col_types = col_spec)

# Identify incident sepsis only, Check any historic record of sepsis in their GP & Hosp record (14 days)#
df <- df %>% mutate(incident_sepsis = case_when(historic_sepsis_gp == 0 & historic_sepsis_hosp == 0 ~ "1",
                                                historic_sepsis_gp == 0 & historic_sepsis_hosp == 1 ~ "0",
                                                historic_sepsis_gp == 1 & historic_sepsis_hosp == 0 ~ "0",
                                                historic_sepsis_gp == 1 & historic_sepsis_hosp == 1 ~ "0"))

df <- df %>% filter (incident_sepsis == 1)

# Filter the covid cases

df <- df %>% filter (SGSS_positive_6weeks == 0)
df <- df %>% filter (GP_positive_6weeks == 0)
filtered_df <- df %>% filter (covid_admission_6weeks == 0)


# Look at community sepsis only
filtered_df <- df %>% filter (had_sepsis_within_2day == 1)

# Calculate counts and percentages
total_rows <- nrow(filtered_df)
counts <- colSums(filtered_df[, c("has_infection", "has_uti", "has_urti", "has_lrti", "has_sinusitis", "has_ot_externa", "has_otmedia","has_pneumonia")])
percentages <- counts / total_rows * 100

# Combine counts and percentages
results <- data.frame(
  Condition = c("has_infection", "has_uti", "has_urti", "has_lrti", "has_sinusitis", "has_ot_externa", "has_otmedia", "has_pneumonia"),
  Count = counts,
  Percentage = percentages
)


# Save the results
write_csv(results, here::here("output", "infection_check_table.csv"))

