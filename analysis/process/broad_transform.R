library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

# file list
csvFiles_19 = list.files(pattern="input_antibiotics_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_antibiotics_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_antibiotics_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_antibiotics_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

prevalent_check=paste0("prevalent_AB_date_",rep(1:12))
#ab_count_12=paste0("AB_date_",rep(1:12),"_count") # change to binary flag
ab_category=paste0("AB_date_",rep(1:12),"_indication")
indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat","uncoded")
ab_date_12=paste0("AB_date_",rep(1:12))
broad_check=paste0("Ab_date_",rep(1:12),"_broad_check")


temp <- vector("list", length(csvFiles_19))
for (i in seq_along(csvFiles_19)){
  # read in one-month data
  df <- read_csv(csvFiles_19[i])
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)

  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)

  df4=df%>%select(patient_id,age,sex,broad_check)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df4)

  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_19[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_broad_2019.rds")
rm(temp)

temp <- vector("list", length(csvFiles_20))
for (i in seq_along(csvFiles_20)){
  # read in one-month data
  df <- read_csv(csvFiles_20[i])
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)

  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)

  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)

  df4=df%>%select(patient_id,age,sex,broad_check)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df4)

  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_20[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_broad_2020.rds")
rm(temp)

temp <- vector("list", length(csvFiles_21))
for (i in seq_along(csvFiles_21)){
  # read in one-month data
  df <- read_csv(csvFiles_21[i])
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)

  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)

  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)

  df4=df%>%select(patient_id,age,sex,broad_check)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df4)

  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_21[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_broad_2021.rds")
rm(temp)

temp <- vector("list", length(csvFiles_22))
for (i in seq_along(csvFiles_22)){
  # read in one-month data
  df <- read_csv(csvFiles_22[i])
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)

  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)

  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)

  df4=df%>%select(patient_id,age,sex,broad_check)
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,broad_spectrum,paste0("time",rep(1:12)))
  rm(df4)

  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$date=date_22[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}

saveRDS(temp, "recorded_ab_broad_2022.rds")
rm(temp)