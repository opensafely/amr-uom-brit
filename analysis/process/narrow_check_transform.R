### This script is to transfer patinet/row --> ab_prescription_times/ row
### every patient has 12 times of ab extraction 
### variabless include:
### patient(id), age, sex, times(1-10), ab_date, prevalent(1/0),ab_count, ab type,  


library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

# file list
csvFiles_19 = list.files(pattern="input_antibiotics_type_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_antibiotics_type_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_antibiotics_type_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_antibiotics_type_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

prevalent_check=paste0("prevalent_AB_date_",rep(1:12))
ab_count_12=paste0("AB_date_",rep(1:12),"_count") 
ab_type=paste0("Ab_date_",rep(1:12),"_type")
ab_date_12=paste0("AB_date_",rep(1:12))
broad_check=paste0("Ab_date_",rep(1:12),"_broad_check")

## save 2019 record
temp <- vector("list", length(csvFiles_19))
for (i in seq_along(csvFiles_19)){
  # read in one-month data
  df <- read_csv((csvFiles_19[i]),
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
                   age = col_integer(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_integer(),
                   antibacterial_brit = col_integer(),
                   prevalent_AB_date_1 = col_double(),
                   prevalent_AB_date_2 = col_double(),
                   prevalent_AB_date_3 = col_double(),
                   prevalent_AB_date_4 = col_double(),
                   prevalent_AB_date_5 = col_double(),
                   prevalent_AB_date_6 = col_double(),
                   prevalent_AB_date_7 = col_double(),
                   prevalent_AB_date_8 = col_double(),
                   prevalent_AB_date_9 = col_double(),
                   prevalent_AB_date_10 = col_double(),
                   prevalent_AB_date_11 = col_double(),
                   prevalent_AB_date_12 = col_double(),
                   AB_date_1_count = col_integer(),
                   AB_date_2_count = col_integer(),
                   AB_date_3_count = col_integer(),
                   AB_date_4_count = col_integer(),
                   AB_date_5_count = col_integer(),
                   AB_date_6_count = col_integer(),
                   AB_date_7_count = col_integer(),
                   AB_date_8_count = col_integer(),
                   AB_date_9_count = col_integer(),
                   AB_date_10_count = col_integer(),
                   AB_date_11_count = col_integer(),
                   AB_date_12_count = col_integer(),
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
                   Ab_date_1_broad_check = col_double(),
                   Ab_date_2_broad_check = col_double(),
                   Ab_date_3_broad_check = col_double(),
                   Ab_date_4_broad_check = col_double(),
                   Ab_date_5_broad_check = col_double(),
                   Ab_date_6_broad_check = col_double(),
                   Ab_date_7_broad_check = col_double(),
                   Ab_date_8_broad_check = col_double(),
                   Ab_date_9_broad_check = col_double(),
                   Ab_date_10_broad_check = col_double(),
                   Ab_date_11_broad_check = col_double(),
                   Ab_date_12_broad_check = col_double(),
                   patient_id = col_integer()
                 ),
                 na = character())
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,ab_count_12)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,count,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,broad_check)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df3)
  
  df4=df%>%select(patient_id,age,sex,ab_type)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,type,paste0("time",rep(1:12)))
  rm(df4)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_19[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_type_2019.rds")
rm(temp)

## save 2020 record
temp <- vector("list", length(csvFiles_20))
for (i in seq_along(csvFiles_20)){
  # read in one-month data
  df <- read_csv((csvFiles_20[i]),
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
                   age = col_integer(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_integer(),
                   antibacterial_brit = col_integer(),
                   prevalent_AB_date_1 = col_double(),
                   prevalent_AB_date_2 = col_double(),
                   prevalent_AB_date_3 = col_double(),
                   prevalent_AB_date_4 = col_double(),
                   prevalent_AB_date_5 = col_double(),
                   prevalent_AB_date_6 = col_double(),
                   prevalent_AB_date_7 = col_double(),
                   prevalent_AB_date_8 = col_double(),
                   prevalent_AB_date_9 = col_double(),
                   prevalent_AB_date_10 = col_double(),
                   prevalent_AB_date_11 = col_double(),
                   prevalent_AB_date_12 = col_double(),
                   AB_date_1_count = col_integer(),
                   AB_date_2_count = col_integer(),
                   AB_date_3_count = col_integer(),
                   AB_date_4_count = col_integer(),
                   AB_date_5_count = col_integer(),
                   AB_date_6_count = col_integer(),
                   AB_date_7_count = col_integer(),
                   AB_date_8_count = col_integer(),
                   AB_date_9_count = col_integer(),
                   AB_date_10_count = col_integer(),
                   AB_date_11_count = col_integer(),
                   AB_date_12_count = col_integer(),
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
                   Ab_date_1_broad_check = col_double(),
                   Ab_date_2_broad_check = col_double(),
                   Ab_date_3_broad_check = col_double(),
                   Ab_date_4_broad_check = col_double(),
                   Ab_date_5_broad_check = col_double(),
                   Ab_date_6_broad_check = col_double(),
                   Ab_date_7_broad_check = col_double(),
                   Ab_date_8_broad_check = col_double(),
                   Ab_date_9_broad_check = col_double(),
                   Ab_date_10_broad_check = col_double(),
                   Ab_date_11_broad_check = col_double(),
                   Ab_date_12_broad_check = col_double(),
                   patient_id = col_integer()
                 ),
                 na = character())
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,ab_count_12)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,count,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,broad_check)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df3)
  
  df4=df%>%select(patient_id,age,sex,ab_type)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,type,paste0("time",rep(1:12)))
  rm(df4)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_20[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_type_2020.rds")
rm(temp)

## save 2021 record
temp <- vector("list", length(csvFiles_21))
for (i in seq_along(csvFiles_21)){
  # read in one-month data
  df <- read_csv((csvFiles_21[i]),
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
                   age = col_integer(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_integer(),
                   antibacterial_brit = col_integer(),
                   prevalent_AB_date_1 = col_double(),
                   prevalent_AB_date_2 = col_double(),
                   prevalent_AB_date_3 = col_double(),
                   prevalent_AB_date_4 = col_double(),
                   prevalent_AB_date_5 = col_double(),
                   prevalent_AB_date_6 = col_double(),
                   prevalent_AB_date_7 = col_double(),
                   prevalent_AB_date_8 = col_double(),
                   prevalent_AB_date_9 = col_double(),
                   prevalent_AB_date_10 = col_double(),
                   prevalent_AB_date_11 = col_double(),
                   prevalent_AB_date_12 = col_double(),
                   AB_date_1_count = col_integer(),
                   AB_date_2_count = col_integer(),
                   AB_date_3_count = col_integer(),
                   AB_date_4_count = col_integer(),
                   AB_date_5_count = col_integer(),
                   AB_date_6_count = col_integer(),
                   AB_date_7_count = col_integer(),
                   AB_date_8_count = col_integer(),
                   AB_date_9_count = col_integer(),
                   AB_date_10_count = col_integer(),
                   AB_date_11_count = col_integer(),
                   AB_date_12_count = col_integer(),
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
                   Ab_date_1_broad_check = col_double(),
                   Ab_date_2_broad_check = col_double(),
                   Ab_date_3_broad_check = col_double(),
                   Ab_date_4_broad_check = col_double(),
                   Ab_date_5_broad_check = col_double(),
                   Ab_date_6_broad_check = col_double(),
                   Ab_date_7_broad_check = col_double(),
                   Ab_date_8_broad_check = col_double(),
                   Ab_date_9_broad_check = col_double(),
                   Ab_date_10_broad_check = col_double(),
                   Ab_date_11_broad_check = col_double(),
                   Ab_date_12_broad_check = col_double(),
                   patient_id = col_integer()
                 ),
                 na = character())
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,ab_count_12)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,count,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,broad_check)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df3)
  
  df4=df%>%select(patient_id,age,sex,ab_type)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,type,paste0("time",rep(1:12)))
  rm(df4)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_21[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_type_2021.rds")
rm(temp)

## save 2022 record
temp <- vector("list", length(csvFiles_22))
for (i in seq_along(csvFiles_22)){
  # read in one-month data
  df <- read_csv((csvFiles_22[i]),
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
                   age = col_integer(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_integer(),
                   antibacterial_brit = col_integer(),
                   prevalent_AB_date_1 = col_double(),
                   prevalent_AB_date_2 = col_double(),
                   prevalent_AB_date_3 = col_double(),
                   prevalent_AB_date_4 = col_double(),
                   prevalent_AB_date_5 = col_double(),
                   prevalent_AB_date_6 = col_double(),
                   prevalent_AB_date_7 = col_double(),
                   prevalent_AB_date_8 = col_double(),
                   prevalent_AB_date_9 = col_double(),
                   prevalent_AB_date_10 = col_double(),
                   prevalent_AB_date_11 = col_double(),
                   prevalent_AB_date_12 = col_double(),
                   AB_date_1_count = col_integer(),
                   AB_date_2_count = col_integer(),
                   AB_date_3_count = col_integer(),
                   AB_date_4_count = col_integer(),
                   AB_date_5_count = col_integer(),
                   AB_date_6_count = col_integer(),
                   AB_date_7_count = col_integer(),
                   AB_date_8_count = col_integer(),
                   AB_date_9_count = col_integer(),
                   AB_date_10_count = col_integer(),
                   AB_date_11_count = col_integer(),
                   AB_date_12_count = col_integer(),
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
                   Ab_date_1_broad_check = col_double(),
                   Ab_date_2_broad_check = col_double(),
                   Ab_date_3_broad_check = col_double(),
                   Ab_date_4_broad_check = col_double(),
                   Ab_date_5_broad_check = col_double(),
                   Ab_date_6_broad_check = col_double(),
                   Ab_date_7_broad_check = col_double(),
                   Ab_date_8_broad_check = col_double(),
                   Ab_date_9_broad_check = col_double(),
                   Ab_date_10_broad_check = col_double(),
                   Ab_date_11_broad_check = col_double(),
                   Ab_date_12_broad_check = col_double(),
                   patient_id = col_integer()
                 ),
                 na = character())
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,ab_count_12)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,count,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,broad_check)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df3)
  
  df4=df%>%select(patient_id,age,sex,ab_type)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,type,paste0("time",rep(1:12)))
  rm(df4)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_22[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_type_2022.rds")
rm(temp)