

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

df1.1 <- df1 %>% filter(imd == "1")
df1.2 <- df1 %>% filter(imd == "2")
df1.3 <- df1 %>% filter(imd == "3")
df1.4 <- df1 %>% filter(imd == "4")
df1.5 <- df1 %>% filter(imd == "5")

df2.1 <- df2 %>% filter(imd == "1")
df2.2 <- df2 %>% filter(imd == "2")
df2.3 <- df2 %>% filter(imd == "3")
df2.4 <- df2 %>% filter(imd == "4")
df2.5 <- df2 %>% filter(imd == "5")

dttable <- select(df1.1 ,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)

t$all <- plyr::round_any(t$all, 5)
write_csv(t, here::here("output", "table_1_imd1_case.csv"))

dttable <- select(df1.2 ,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
t$all <- plyr::round_any(t$all, 5)
write_csv(t, here::here("output", "table_1_imd2_case.csv"))

dttable <- select(df1.3 ,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
t$all <- plyr::round_any(t$all, 5)
write_csv(t, here::here("output", "table_1_imd3_case.csv"))

dttable <- select(df1.4 ,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
t$all <- plyr::round_any(t$all, 5)
write_csv(t, here::here("output", "table_1_imd4_case.csv"))

dttable <- select(df1.5 ,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
t$all <- plyr::round_any(t$all, 5)
write_csv(t, here::here("output", "table_1_imd5_case.csv"))

dttable2 <- select(df2.1,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab2 <- colnames(dttable2)
dttable2 %>% summary_factorlist(explanatory = colsfortab2) -> t2
#str(t)
t2$all <- plyr::round_any(t2$all, 5)
write_csv(t2, here::here("output", "table_1_imd1_control.csv"))

dttable2 <- select(df2.2,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab2 <- colnames(dttable2)
dttable2 %>% summary_factorlist(explanatory = colsfortab2) -> t2
#str(t)
t2$all <- plyr::round_any(t2$all, 5)
write_csv(t2, here::here("output", "table_1_imd2_control.csv"))

dttable2 <- select(df2.3,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab2 <- colnames(dttable2)
dttable2 %>% summary_factorlist(explanatory = colsfortab2) -> t2
#str(t)
t2$all <- plyr::round_any(t2$all, 5)
write_csv(t2, here::here("output", "table_1_imd3_control.csv"))

dttable2 <- select(df2.4,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab2 <- colnames(dttable2)
dttable2 %>% summary_factorlist(explanatory = colsfortab2) -> t2
#str(t)
t2$all <- plyr::round_any(t2$all, 5)
write_csv(t2, here::here("output", "table_1_imd4_control.csv"))

dttable2 <- select(df2.5,age_band,imd,
region,ethnicity,bmi_adult,smoking_status,hypertension,chronic_respiratory_disease,asthma,chronic_cardiac_disease,
diabetes_controlled,cancer,haem_cancer,chronic_liver_disease,stroke,dementia,other_neuro,organ_kidney_transplant,asplenia,ra_sle_psoriasis,immunosuppression,
             learning_disability,sev_mental_ill,alcohol_problems,care_home_type_ba,ckd_rrt,ab_frequency,ab_type_num,died_any_30d)

# columns for baseline table
colsfortab2 <- colnames(dttable2)
dttable2 %>% summary_factorlist(explanatory = colsfortab2) -> t2
#str(t)
t2$all <- plyr::round_any(t2$all, 5)
write_csv(t2, here::here("output", "table_1_imd5_control.csv"))