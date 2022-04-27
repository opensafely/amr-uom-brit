## This script is to transfer patinet/row --> ab_infection_times/ row
### every patient has 4 times of infection extraction per month
### variabless include:
### patient(id), age, sex, times(1-4), infection_date, infection_count, ab_infection(1-4)-binary flag,  

library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

# file list
csvFiles_19 = list.files(pattern="input_infection_all_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_infection_all_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_infection_all_2021", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")


# variables names list
infect_date_4=paste0("indication_date_",rep(1:4))
ab_flag_4=paste0("ab_indication_date_",rep(1:4))
infect_category_4=paste0("indication_date_",rep(1:4),"_type")

## save 2019 record
temp <- vector("list", length(csvFiles_19))
for (i in seq_along(csvFiles_19)){
  # read in one-month data
  df <- read_csv((csvFiles_19[i]),
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
  
  DF=DF%>%filter(!is.na(date))
  DF$Date=date_19[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1)
  
}

saveRDS(temp, "infect_all_2019.rds")
rm(temp)

## save 2020 record
temp <- vector("list", length(csvFiles_20))
for (i in seq_along(csvFiles_20)){
  # read in one-month data
  df <- read_csv((csvFiles_20[i]),
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
  
  DF=DF%>%filter(!is.na(date))
  DF$Date=date_20[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1)
  
}

saveRDS(temp, "infect_all_2020.rds")
rm(temp)

## save 2021 record
temp <- vector("list", length(csvFiles_21))
for (i in seq_along(csvFiles_21)){
  # read in one-month data
  df <- read_csv((csvFiles_21[i]),
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
  
  DF=DF%>%filter(!is.na(date))
  DF$Date=date_21[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1)
  
}

saveRDS(temp, "infect_all_2021.rds")
rm(temp)