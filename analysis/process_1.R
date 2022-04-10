
# # # # # # # # # # # # # # # # # # # # #
# This script:
# 1. define covid admission cohort 
# 2. define case (icu or death) and control (without any severe outcome)
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library('dplyr')
library('lubridate')


#### COVID hospital admission

# import data
df <- read_csv(here::here("output", "input_covid_admission.csv"))
df=read_csv("input_covid_admission.csv")

# filter cohort
df =df%>%filter( !is.na(patient_index_date)) # covid hospital case

df=df%>%
  filter(
         is.na(died_date_cpns), 
         is.na(died_date_ons_covid),
         is.na(died_date_ons_covid_after))


df=df%>%filter(patient_index_date <= as.Date("2021-12-31"))


# calendar month for matching
df$cal_YM=format(df$patient_index_date,"%Y-%m")

## CASE - covid icu or covid death within 1 month
df1=df%>%
  filter(icu_days>0|
           !is.na(died_date_ons_covid_after)|
           !is.na(died_date_cpns_after))

## CASE - covid icu or any death death within 1 month
df2=df%>%
  filter(icu_days>0|
           !is.na(ons_died_date)|
           !is.na(died_date_cpns_after)|
           !is.na(died_date_ons_covid_after))

write_csv(df1, here::here("output", "case_covid_icu_death.csv"))
write_csv(df2, here::here("output", "case_covid_icu_death_2.csv"))


## Control - covid hospital without any covid severe outcome within 1 month
df0=df%>%
  filter(
          icu_days== 0 | is.na(icu_days),
          is.na(died_date_cpns_after),
          is.na(died_date_ons_covid_after))

#write_csv(df, here::here("output", "case_covid_infection.csv"))

write_csv(df.1, here::here("output", "case_covid_hosp.csv"))
write_csv(df.0, here::here("output", "control_covid_infection.csv"))


