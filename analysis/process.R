
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
  filter(is.na(primary_care_covid_date),
         is.na(covid_admission_date),
         is.na(died_date_cpns), 
         is.na(died_date_ons_covid))



df=rbind(df1,df2)

# keep earlist covid infection date
df=df%>%
  group_by(patient_id)%>%
  arrange(patient_id,patient_index_date)%>%
  distinct(patient_id, .keep_all = TRUE)

# exclude case has previous covid related history (variables before patient_index_date)
# exclude case has severe outcome within 1 month
df=df%>%
  filter(
         ! is.na(covid_admission_date_after),
         ! is.na(died_date_cpns_after),
         ! is.na(died_date_ons_covid_after))

write_csv(df, here::here("output", "case_covid_infection.csv"))

df$cal_YM=format(df$patient_index_date,"%Y-%m")
write_csv(df, here::here("output", "control_covid_infection.csv"))


# # # split data by month (for matching general population)

# # list=sort(unique(df$cal_YM))

# # for (i in 1:length(list)){
# #   DF=subset(df,cal_YM==list[i])
  
# #   write_csv(DF, here::here("output", paste0("case_covid_infection_",list[i],".csv")))
# # }

rm(list=ls())




#### COVID admission

# impoprt data
df <- read_csv(here::here("output", "input_covid_admission.csv"))

# has covid admission record
df =df%>%filter( !is.na(patient_index_date)) # hosp admission case

# exclude case has previous covid related history (variables before patient_index_date)
# exclude case has severe outcome within 14 days
df=df%>%
  filter(
         is.na(SGSS_positive_test_date_before),
         is.na(primary_care_covid_date_before),
         is.na(died_date_cpns_before),
         is.na(died_date_ons_covid_before),
         ! is.na(died_date_cpns_after),
         ! is.na(died_date_ons_covid_after))

df$cal_YM=format(df$patient_index_date,"%Y-%m")

write_csv(df, here::here("output", "case_covid_admission.csv"))

rm(list=ls())






#### COVID severe outcome ( death)

# impoprt data
#df1 <- read_csv(here::here("output", "input_covid_icu.csv"))
df2<- read_csv(here::here("output", "input_covid_death_cpns.csv"))
df3<- read_csv(here::here("output", "input_covid_death_ons.csv"))

# has covid  record
#df1 =df1%>%filter(patient_index_date>0) # icu
df2 =df2%>%filter( !is.na(patient_index_date)) # cpns
df3 =df3%>%filter( !is.na(patient_index_date)) # ons_covid

df2=df2%>%
  filter(
         is.na(SGSS_positive_test_date_before),
         is.na(primary_care_covid_date_before),
         is.na(died_date_cpns_before),
         is.na(died_date_ons_covid_before))

df3=df3%>%
  filter(
         is.na(SGSS_positive_test_date_before),
         is.na(primary_care_covid_date_before),
         is.na(died_date_cpns_before),
         is.na(died_date_ons_covid_before))


df=rbind(df2,df3)

# keep earlist covid severe outcome date
df=df%>%
  group_by(patient_id)%>%
  arrange(patient_id,patient_index_date)%>%
  distinct(patient_id, .keep_all = TRUE)

# exclude case has previous covid related history (variables before patient_index_date)


df$cal_YM=format(df$patient_index_date,"%Y-%m")

write_csv(df, here::here("output", "case_covid_icu_death.csv"))



# #### general population

# rm(list=ls())
# list=seq(as.Date("2020-02-01"), as.Date("2021-12-01"), "month")

# for (i in 1:length(list)){
# df=read_csv(here::here("output","measures", paste0("input_covid_general_population_",list[i],".csv.gz")))

# df$patient_index_date=as.Date(list[i])

# df=df%>%
#   filter(is.na(covid_admission_date),
#          is.na(icu_date_admitted),
#          is.na(died_date_cpns),
#          is.na(died_date_ons_covid))

# df$cal_YM=format(df$patient_index_date,"%Y-%m")

# write_csv(df, here::here("output", paste0("control_general_population_",list[i],".csv")))
# }
