

## Import libraries---
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")


df <- readRDS("output/processed/input_model_c_h.rds")
df$age_band = case_when(
  df$age < 18 ~ "<18",
  df$age >= 18 & df$age < 40 ~ "18-39",
  df$age >= 40 & df$age < 50 ~ "40-49",
  df$age >= 50 & df$age < 60 ~ "50-59",
  df$age >= 60 & df$age < 70 ~ "60-69",
  df$age >= 70 & df$age < 80 ~ "70-79",
  df$age >= 80 ~ "80+")
df1 <- df %>% filter(case == 1)
df2 <- df %>% filter(case == 0)
dttable <- select(df1,age_band,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
t$all <- plyr::round_any(t$all, 5)
write_csv(t, here::here("output", "table_1_case.csv"))

dttable2 <- select(df2,age_band,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab2 <- colnames(dttable2)
dttable2 %>% summary_factorlist(explanatory = colsfortab2) -> t2
#str(t)
t2$all <- plyr::round_any(t2$all, 5)
write_csv(t2, here::here("output", "table_1_control.csv"))