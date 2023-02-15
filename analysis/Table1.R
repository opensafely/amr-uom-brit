

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

dttable <- select(df,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "table_1.csv"))