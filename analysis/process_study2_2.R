
# # # # # # # # # # # # # # # # # # # # #
# This script:
# 1. define covid admission cohort 
# 2. define case (covid death) and control (covid infection)
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library('dplyr')
library('lubridate')


# #### COVID hospital admission

# # import data
# df <- read_csv(here::here("output", "input_covid_admission.csv"))
# #df=read_csv("input_covid_admission.csv")
# df=df%>%filter(patient_index_date <= as.Date("2021-12-31"))


# # filter cohort
# df=df%>%filter( !is.na(patient_index_date)) # covid hospital case

# # df=df%>%
# #   filter(
# #          is.na(died_date_cpns), 
# #          is.na(died_date_ons_covid),
# #          is.na(ons_died_date_before)) 



# ## Control - covid hospital admission (incident covid infeciton, so exclude recors outside 1 month)
# df=df%>%filter(
#          is.na(SGSS_positive_test_date_before),
#          is.na(primary_care_covid_date_before), 
#          is.na(died_date_cpns_before),
#          is.na(died_date_ons_covid_before))



# # calendar month for matching
# df$cal_YM=format(df$patient_index_date,"%Y-%m")


# # control
# df0=df%>%
#   filter(
#     icu_days== 0 | is.na(icu_days),
#     is.na(died_date_cpns_after),
#     is.na(died_date_ons_covid_after))

# #write_csv(df0, here::here("output", "control_covid_hosp.csv"))







# ## CASE part1 - covid icu or covid death within 1 month after hospitalisation
# df1_1=df%>%
#   filter(icu_days>0|
#            !is.na(died_date_ons_covid_after)|
#            !is.na(died_date_cpns_after))#

# rm(df)



## CASE part2 - covid infection+death records within 1 month

# COVID INFECTION
# impoprt data
df1 <- read_csv(here::here("output", "input_covid_SGSS.csv"))
df1=df1%>%filter(patient_index_date <= as.Date("2021-12-31"))

# filter SGSS (exclude SGSS+admission, SGSS+death)
df1 =df1%>%filter( !is.na(patient_index_date)) # SGSS case

df1=df1%>%
  filter(is.na(primary_care_covid_date),
         is.na(covid_admission_date),
         is.na(died_date_cpns), 
         is.na(died_date_ons_covid))



df2<- read_csv(here::here("output", "input_covid_primarycare.csv"))
df2=df2%>%filter(patient_index_date <= as.Date("2021-12-31"))

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

# calendar month for matching
df$cal_YM=format(df$patient_index_date,"%Y-%m")

## CASE - covid infection+death records within 1 month
df1=df%>%
  filter(!is.na(died_date_ons_covid_after))

## CONTROL
df0=df%>%filter(is.na(died_date_ons_covid_after))

## CASE_2 - any death records within 1 month
df1.2=df%>%
  filter(!is.na(ons_died_date_after))
## CONTROL
df0.2=df%>%filter(is.na(ons_died_date_after))

write_csv(df1, here::here("output", "case_covid_death_study2_2.csv"))
write_csv(df0, here::here("output", "control_covid_infection_study2_2.csv"))

write_csv(df1.2, here::here("output", "case_covid_death_study2_2.2.csv"))
write_csv(df0.2, here::here("output", "control_covid_infection_study2_2.2.csv"))

