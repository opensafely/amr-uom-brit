#### This script is for calculating mortality rate and draw the table ####

require('tidyverse')
require("gtsummary")
library(car)
library(data.table)
library(gridExtra)
library(purrr)
library(dplyr)
library(survival)
library(rms)

df <- readRDS("output/processed/input_model_c.rds")
df <- df %>% filter(case==1)
df$agegroup = case_when(
  df$age < 18 ~ "<18",
  df$age >= 18 & df$age < 40 ~ "18-39",
  df$age >= 40 & df$age < 50 ~ "40-49",
  df$age >= 50 & df$age < 60 ~ "50-59",
  df$age >= 60 & df$age < 70 ~ "60-69",
  df$age >= 70 & df$age < 80 ~ "70-79",
  df$age >= 80 ~ "80+")

###Age###

df$agegroup= relevel(as.factor(df$agegroup), ref="50-59")

df1 <- df %>% filter (covid == 1)
df2 <- df %>% filter (covid == 2)
df3 <- df %>% filter (covid == 3)

df <-df1
###Age###

mod <- glm(died_any_30d~ hypertension + chronic_respiratory_disease + asthma + chronic_cardiac_disease + diabetes_controlled + cancer +
 haem_cancer + chronic_liver_disease + stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
 learning_disability + sev_mental_ill + alcohol_problems +  care_home_type_ba + ckd_rrt + ab_frequency +  rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))

write_csv(result, here::here("output", "sen_mortality_full_model_community.csv"))