## This script is to transfer patinet/row --> ab_prescription_times/ row
### every patient has 12 times of ab extraction 
### variabless include:
### patient(id), age, sex, times(1-10), ab_date, prevalent(1/0),ab_count, ab type,  

library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

ab_date_12=paste0("AB_date_",rep(1:12))
ab_category=paste0("AB_date_",rep(1:12),"_indication")
ab_type=paste0("Ab_date_",rep(1:12),"_type")

  df <- read_csv(('input_antibiotics_type_2022-01-01.csv.gz'),
                 col_types = cols_only(
                   AB_date_1 = col_date(format = ""),
                   AB_date_2 = col_date(format = ""),
                   AB_date_3 = col_date(format = ""),
                   AB_date_4 = col_date(format = ""),
                   AB_date_5 = col_date(format = ""),
                   AB_date_6 = col_date(format = ""),
                   AB_date_7 = col_date(format = ""),
                   AB_date_8 = col_date(format = ""),
                   AB_date_9 = col_date(format = ""),
                   AB_date_10 = col_date(format = ""),
                   AB_date_11 = col_date(format = ""),
                   AB_date_12 = col_date(format = ""),
                   age = col_double(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_double(),
                   antibacterial_brit = col_double(),
                   AB_date_1_indication = col_character(),
                   AB_date_2_indication = col_character(),
                   AB_date_3_indication = col_character(),
                   AB_date_4_indication = col_character(),
                   AB_date_5_indication = col_character(),
                   AB_date_6_indication = col_character(),
                   AB_date_7_indication = col_character(),
                   AB_date_8_indication = col_character(),
                   AB_date_9_indication = col_character(),
                   AB_date_10_indication = col_character(),
                   AB_date_11_indication = col_character(),
                   AB_date_12_indication = col_character(),
                   Ab_date_1_type = col_character(),
                   Ab_date_2_type = col_character(),
                   Ab_date_3_type = col_character(),
                   Ab_date_4_type = col_character(),
                   Ab_date_5_type = col_character(),
                   Ab_date_6_type = col_character(),
                   Ab_date_7_type = col_character(),
                   Ab_date_8_type = col_character(),
                   Ab_date_9_type = col_character(),
                   Ab_date_10_type = col_character(),
                   Ab_date_11_type = col_character(),
                   Ab_date_12_type = col_character(),
                   patient_id = col_double()
                 ),
                 na = character())

  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,all_of(ab_type))
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,type,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  
  DF1=DF%>%filter(!is.na(date))
  DF1$Date=as.Date("2022-01-01")

  rm(df,DF,df1.1,df2.1,df3.1)

  df <- read_csv(('input_antibiotics_type_2022-02-01.csv.gz'),
                 col_types = cols_only(
                   AB_date_1 = col_date(format = ""),
                   AB_date_2 = col_date(format = ""),
                   AB_date_3 = col_date(format = ""),
                   AB_date_4 = col_date(format = ""),
                   AB_date_5 = col_date(format = ""),
                   AB_date_6 = col_date(format = ""),
                   AB_date_7 = col_date(format = ""),
                   AB_date_8 = col_date(format = ""),
                   AB_date_9 = col_date(format = ""),
                   AB_date_10 = col_date(format = ""),
                   AB_date_11 = col_date(format = ""),
                   AB_date_12 = col_date(format = ""),
                   age = col_double(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_double(),
                   antibacterial_brit = col_double(),
                   AB_date_1_indication = col_character(),
                   AB_date_2_indication = col_character(),
                   AB_date_3_indication = col_character(),
                   AB_date_4_indication = col_character(),
                   AB_date_5_indication = col_character(),
                   AB_date_6_indication = col_character(),
                   AB_date_7_indication = col_character(),
                   AB_date_8_indication = col_character(),
                   AB_date_9_indication = col_character(),
                   AB_date_10_indication = col_character(),
                   AB_date_11_indication = col_character(),
                   AB_date_12_indication = col_character(),
                   Ab_date_1_type = col_character(),
                   Ab_date_2_type = col_character(),
                   Ab_date_3_type = col_character(),
                   Ab_date_4_type = col_character(),
                   Ab_date_5_type = col_character(),
                   Ab_date_6_type = col_character(),
                   Ab_date_7_type = col_character(),
                   Ab_date_8_type = col_character(),
                   Ab_date_9_type = col_character(),
                   Ab_date_10_type = col_character(),
                   Ab_date_11_type = col_character(),
                   Ab_date_12_type = col_character(),
                   patient_id = col_double()
                 ),
                 na = character())

  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,all_of(ab_type))
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,type,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  
  DF2=DF%>%filter(!is.na(date))
  DF2$Date=as.Date("2022-02-01")

  rm(df,DF,df1.1,df2.1,df3.1)

DF <- rbind(DF1,DF2)

saveRDS(DF, "ab_type_2022.rds")
