
# # # # # # # # # # # # # # # # # # # # #
# This script:
# 1. define control group (SGSS+primary care) 
# 2. define case group (admittied to hospital) 
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library('dplyr')
library('lubridate')


#### COVID INFECTION

# impoprt data
df1 <- read_csv(here::here("output", "input_covid_SGSS.csv"),na="")
df1=df1%>%filter(patient_index_date <= as.Date("2021-12-31"))

# filter SGSS (exclude SGSS+admission, SGSS+death)
df1 =df1%>%filter( !is.na(patient_index_date)) # SGSS case

df1=df1%>%
  filter(is.na(primary_care_covid_date),
         is.na(covid_admission_date),
         is.na(died_date_cpns), 
         is.na(died_date_ons_covid))



df2<- read_csv(here::here("output", "input_covid_primarycare.csv"),na="")
df2=df2%>%filter(patient_index_date <= as.Date("2021-12-31"))

df2 =df2%>%filter( !is.na(patient_index_date)) # primary care case
df2=df2%>%
  filter(is.na(SGSS_positive_test_date),
         is.na(covid_admission_date),
         is.na(died_date_cpns), 
         is.na(died_date_ons_covid))


df=bind_rows(df1,df2)

# keep earlist covid infection date
df=df%>%
  group_by(patient_id)%>%
  arrange(patient_id,patient_index_date)%>%
  distinct(patient_id, .keep_all = TRUE)

# calendar month for matching
df$cal_YM=format(df$patient_index_date,"%Y-%m")

## Control - covid infection without any covid severe outcome within 1 month
df.0=df%>%
  filter(
          is.na(covid_admission_date_after),
          is.na(died_date_cpns_after),
          is.na(died_date_ons_covid_after))


## definition _1
# # # CASE - covid infection with hospital admission
# #  df.1=df%>%
# #    filter(! is.na(covid_admission_date_after))

## definition _2
## CASE - covid hospital admission (incident covid infeciton, so exclude recors outside 1 month)
df.1 <- read_csv(here::here("output", "input_covid_admission.csv"),na="")
df.1=df.1%>%filter(patient_index_date <= as.Date("2021-12-31"))

df.1 =df.1%>%filter( !is.na(patient_index_date)) # hospital patient


df.1=df.1%>%filter(
         is.na(SGSS_positive_test_date_before),
         is.na(primary_care_covid_date_before), 
         is.na(died_date_cpns_before),
         is.na(died_date_ons_covid_before))

# calendar month for matching
df.1$cal_YM=format(df.1$patient_index_date,"%Y-%m")

df.0$case=0
df.1$case=1
df=bind_rows(df.1,df.0)

# keep earlist covid positive date
df=df%>%
  group_by(patient_id)%>%
  arrange(patient_id,patient_index_date)%>%
  distinct(patient_id, .keep_all = TRUE)

df0=df%>%filter(case==0)
df1=df%>%filter(case==1)

write_csv(df0, here::here("output", "control_covid_infection.csv"))

write_csv(df1, here::here("output", "case_covid_hosp.csv"))
