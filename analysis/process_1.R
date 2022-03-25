
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

# filter SGSS (exclude SGSS+admission, SGSS+death)
df1 =df1%>%filter( !is.na(patient_index_date)) # SGSS case

df1=df1%>%
  filter(is.na(primary_care_covid_date),
         is.na(covid_admission_date),
         is.na(died_date_cpns), 
         is.na(died_date_ons_covid))



df2<- read_csv(here::here("output", "input_covid_primarycare.csv"))
df2 =df2%>%filter( !is.na(patient_index_date)) # primary care case
df2=df2%>%
  filter(is.na(SGSS_positive_test_date),
         is.na(covid_admission_date),
         is.na(died_date_cpns), 
         is.na(died_date_ons_covid))



df=rbind(df1,df2)

# keep earlist covid infection date
df=df%>%
  group_by(patient_id)%>%
  arrange(patient_id,patient_index_date)%>%
  distinct(patient_id, .keep_all = TRUE)

# exclude case has severe outcome within 1 month
df=df%>%
  filter(
          is.na(covid_admission_date_after),
          is.na(died_date_cpns_after),
          is.na(died_date_ons_covid_after))

#write_csv(df, here::here("output", "case_covid_infection.csv"))

df$cal_YM=format(df$patient_index_date,"%Y-%m")
write_csv(df, here::here("output", "control_covid_infection.csv"))


