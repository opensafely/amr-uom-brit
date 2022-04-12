
# # # # # # # # # # # # # # # # # # # # #
# This script:
# define covid infection (case) & potiential control group
# 
# 
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')





#### COVID admission

# impoprt data
df <- read_csv(here::here("output", "input_covid_admission.csv"))

# has covid admission record
df =df%>%filter( !is.na(patient_index_date)) # hosp admission case

# select ICU cases
df.icu= df%>% filter(icu_days>0)

df=df%>% filter(!icu_days>0|is.na(icu_days))
write_csv(df.icu, here::here("output", "case_covid_ICU.csv"))

# exclude case has previous covid related history (variables before patient_index_date)
# exclude case has severe outcome within 30 days
df=df%>%
  filter(
         is.na(SGSS_positive_test_date_before),
         is.na(primary_care_covid_date_before),
         is.na(died_date_cpns_before),
         is.na(died_date_ons_covid_before),
          is.na(died_date_cpns_after),
          is.na(died_date_ons_covid_after))

df$cal_YM=format(df$patient_index_date,"%Y-%m")

write_csv(df, here::here("output", "case_covid_admission.csv"))

rm(list=ls())






