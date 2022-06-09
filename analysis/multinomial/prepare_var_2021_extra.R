### This script is for preparing the variables for repeat antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output"))

df <- read_csv("input_extra_2021.csv",
                     col_types = cols_only(
                       patient_id = col_integer(),
                       hospital_counts = col_integer(),
                       patient_index_date = col_date(format = ""),
                       smoking_status_date = col_date(format = ""),
                       most_recent_unclear_smoking_cat_date = col_date(format = ""),
                       smoking_status = col_character(),
                       bmi = col_integer(),
                       bmi_date_measured =  col_date(format = "")
                       ),
                     na = character())

## BMI category
# https://www.sciencedirect.com/science/article/pii/S0140673621006346
# https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/01_eth_cr_analysis_dataset.do

# remove strange values
df$bmi=ifelse(df$bmi<15 | df$bmi>50, NA, df$bmi)
# restrict measurement within 10 years
df$bmi.time=difftime(df$patient_index_date, df$bmi_date_measured,unit="days")
df$bmi=ifelse(df$bmi.time>365*10 | df$bmi.time<0,NA,df$bmi)

# bmi_cat
# BMI in kg/m2 was grouped into six categories using the WHO classification, with adjustments for South Asian ethnicity: 
#underweight (<18·5 kg/m2), normal weight (18·5–24·9 kg/m2), overweight (25·0–29·9 kg/m2 ); obese I (30·0–34·9 kg/m2 ); obese II (35·0–39·9 kg/m2); and obese III (≥40 kg/m2). 
# South Asian:normal weight (18·5–22.9 kg/m2), overweight (23–27·4 kg/m2); obese I (27·5–32·4 kg/m2); obese II (32·5–37·4 kg/m2); and obese III [≥37·5 kg/m2]. 

df=df%>% 
  mutate(bmi_cat = case_when(is.na(bmi) ~ "unknown",
                             bmi< 18.5 ~ "underweight",
                             bmi>=18.5 & bmi<=24.9 ~ "healthy weight",
                             bmi>24.9 & bmi<=29.9 ~ "overweight",
                             bmi>29.9 ~"obese"))

##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "current",
                                        smoking_status=="E" ~ "former",
                                        smoking_status=="N" ~ "never",
                                        smoking_status=="M" ~ "unknown", 
                                        is.na(smoking_status) ~ "unknown"))

## select variables for the baseline table
df <- select(df, patient_id, patient_index_date, bmi_cat, smoking_cat_3, hospital_counts) 
write_csv(df, here::here("output", "prepared_var_extra_2021.csv"))

# generate data table 
dttable <- select(df, bmi_cat, smoking_cat_3, hospital_counts) 

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "var_extra_blt_2021.csv"))
