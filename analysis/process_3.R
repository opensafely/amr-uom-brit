
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
