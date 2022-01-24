
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


#### COVID INFECTION--------- codes are merged with process.R

# # impoprt data
# df1 <- read_csv(here::here("output", "input_covid_SGSS.csv"))
# df2<- read_csv(here::here("output", "input_covid_primarycare.csv"))

# # has covid infection record
# df1 =df1%>%filter(patient_index_date>0) # SGSS case
# df2 =df2%>%filter(patient_index_date>0) # primary care case

# df=rbind(df1,df2)

# # keep earlist covid infection date
# df=df%>%
#   group_by(patient_id)%>%
#   arrange(patient_id,patient_index_date)%>%
#   distinct(patient_id, .keep_all = TRUE)

# # exclude case has previous covid related history (variables before patient_index_date)
# df=df%>%
#   filter(is.na(covid_admission_date),
#   #       is.na(icu_date_admitted),
#          is.na(died_date_cpns),
#          is.na(died_date_ons_covid))

# df$cal_YM=format(df$patient_index_date,"%Y-%m")

# write_csv(df, here::here("output", "case_covid_infection.csv"))


# # split data by month (for matching general population)

# list=sort(unique(df$cal_YM))

# for (i in 1:length(list)){
#   DF=subset(df,cal_YM==list[i])
  
#   write_csv(DF, here::here("output", paste0("case_covid_infection_",list[i],".csv")))
# }


# rm(list=ls())




#### general population

rm(list=ls())
list=seq(as.Date("2020-02-01"), as.Date("2021-12-01"), "month")

for (i in 1:length(list)){
df=read_csv(here::here("output","measures", paste0("input_general_population_",list[i],".csv.gz")))

df$patient_index_date=as.Date(list[i])

df=df%>%
  filter(is.na(covid_admission_date),
      #   is.na(icu_date_admitted),
         is.na(died_date_cpns),
         is.na(died_date_ons_covid))

df$cal_YM=format(df$patient_index_date,"%Y-%m")

write_csv(df, here::here("output", paste0("control_general_population_",list[i],".csv")))
}
