require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")

# Filter out the rows with the conditions you mentioned
df_clean <- df %>%
  filter(
    !(smoking_status == "Missing" | 
      bmi_adult == "Missing" | 
      ethnicity == "Unknown")
  )

df <- df_clean

mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfch <- DF

df <- readRDS("output/processed/input_model_c.rds")

# Filter out the rows with the conditions you mentioned
df_clean <- df %>%
  filter(
    !(smoking_status == "Missing" | 
      bmi_adult == "Missing" | 
      ethnicity == "Unknown")
  )


df <- df_clean

mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + 
             strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfc <- DF

df <- readRDS("output/processed/input_model_h.rds")

# Filter out the rows with the conditions you mentioned
df_clean <- df %>%
  filter(
    !(smoking_status == "Missing" | 
      bmi_adult == "Missing" | 
      ethnicity == "Unknown")
  )

df <- df_clean

mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + 
             strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfh <- DF

write_csv(dfh, here::here("output", "cc_adjusted_h.csv"))
write_csv(dfc, here::here("output", "cc_adjusted_c.csv"))
write_csv(dfch, here::here("output", "cc_adjusted_ch.csv"))
