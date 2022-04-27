## This script is to transfer patinet/row --> ab_infection_times/ row
### every patient has 4 times of infection extraction per month
### variabless include:
### patient(id), age, sex, times(1-4), infection_date, infection_count, ab_infection(1-4)-binary flag

library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

# variables names list
infect_date_4=paste0("indication_date_",rep(1:4))
ab_flag_4=paste0("ab_indication_date_",rep(1:4))
infect_category_4=paste0("indication_date_",rep(1:4),"_type")


  df <- read_csv(('input_infection_all_2022-01-01.csv.gz'),
                 col_types = cols_only(
                   indication_date_1 = col_date(format = ""),
                   indication_date_2 = col_date(format = ""),
                   indication_date_3 = col_date(format = ""),
                   indication_date_4 = col_date(format = ""),
                   ab_indication_date_1 = col_integer(),
                   ab_indication_date_2 = col_integer(),
                   ab_indication_date_3 = col_integer(),
                   ab_indication_date_4 = col_integer(),
                   indication_date_1_type = col_character(),
                   indication_date_2_type = col_character(),
                   indication_date_3_type = col_character(),
                   indication_date_4_type = col_character(),
                   age = col_integer(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_integer(),
                   infection_count = col_integer(),
                   patient_id = col_integer()
                 ),
                 na = character())

  # filter all patients with infection record
  df=df%>%filter(infection_count !=0)
  
  df1=df%>%select(patient_id,age,sex,all_of(infect_date_4))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:4)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,all_of(ab_flag_4))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abflag,paste0("time",rep(1:4)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,all_of(infect_category_4))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:4)))
  rm(df3)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  
  DF1=DF%>%filter(!is.na(date))
  DF1$Date=as.Date("2022-01-01")

  rm(df,DF,df1.1,df2.1,df3.1)

  df <- read_csv(('input_infection_all_2022-02-01.csv.gz'),
                 col_types = cols_only(
                   indication_date_1 = col_date(format = ""),
                   indication_date_2 = col_date(format = ""),
                   indication_date_3 = col_date(format = ""),
                   indication_date_4 = col_date(format = ""),
                   ab_indication_date_1 = col_integer(),
                   ab_indication_date_2 = col_integer(),
                   ab_indication_date_3 = col_integer(),
                   ab_indication_date_4 = col_integer(),
                   indication_date_1_type = col_character(),
                   indication_date_2_type = col_character(),
                   indication_date_3_type = col_character(),
                   indication_date_4_type = col_character(),
                   age = col_integer(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_integer(),
                   infection_count = col_integer(),
                   patient_id = col_integer()
                 ),
                 na = character())

  # filter all patients with infection record
  df=df%>%filter(infection_count !=0)
  
  df1=df%>%select(patient_id,age,sex,all_of(infect_date_4))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:4)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,all_of(ab_flag_4))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abflag,paste0("time",rep(1:4)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,all_of(infect_category_4))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:4)))
  rm(df3)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  
  DF2=DF%>%filter(!is.na(date))
  DF2$Date=as.Date("2022-02-01")

  rm(df,DF,df1.1,df2.1,df3.1)

DF <- rbind(DF1,DF2)

saveRDS(DF, "infect_all_2022.rds")
