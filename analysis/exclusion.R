
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


#### COVID INFECTION

# impoprt data
df1 <- read_csv(here::here("output", "input_covid_SGSS.csv"))
df2<- read_csv(here::here("output", "input_covid_primarycare.csv"))

# has covid infection record
df1 =df1%>%filter(patient_index_date>0) # SGSS case
df2 =df2%>%filter(patient_index_date>0) # primary care case

df=rbind(df1,df2)

# keep earlist covid infection date
df=df%>%
  group_by(patient_id)%>%
  arrange(patient_id,patient_index_date)%>%
  distinct(patient_id, .keep_all = TRUE)


# exclude case has previous covid related history (variables before patient_index_date)
df=df%>%
  filter(is.na(covid_admission_date),
         is.na(icu_date_admitted),
         is.na(died_date_cpns),
         is.na(died_date_ons_covid))

write_csv(df, here::here("output", "case_covid_infection.csv"))

rm(list=ls())




#### COVID admission

# impoprt data
df <- read_csv(here::here("output", "input_covid_admission.csv"))

# has covid admission record
df =df%>%filter(patient_index_date>0) # hosp admission case


# exclude case has previous covid related history (variables before patient_index_date)
df=df%>%
  filter(is.na(icu_date_admitted),
         is.na(died_date_cpns),
         is.na(died_date_ons_covid))

write_csv(df, here::here("output", "case_covid_admission.csv"))

rm(list=ls())






#### COVID severe outcome (icu or deaath)

# impoprt data
df1 <- read_csv(here::here("output", "input_covid_icu.csv"))
df2<- read_csv(here::here("output", "input_covid_death_cpns.csv"))
df3<- read_csv(here::here("output", "input_covid_death_ons.csv"))

# has covid infection record
df1 =df1%>%filter(patient_index_date>0) # icu
df2 =df2%>%filter(patient_index_date>0) # cpns
df3 =df3%>%filter(patient_index_date>0) # ons_covid

df=rbind(df1,df2,df3)

# keep earlist covid severe outcome date
df=df%>%
  group_by(patient_id)%>%
  arrange(patient_id,patient_index_date)%>%
  distinct(patient_id, .keep_all = TRUE)


write_csv(df, here::here("output", "case_covid_icu_death.csv"))
