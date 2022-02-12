### This script is to transger patinet/row --> ab_prescription_times/ row
### every patient has 10 times of ab extraction 
### variabless include:
### patient(id), age, sex, times(1-10), ab_date, prevalent(1/0),ab_count, infection type,  


## Import libraries---
library("tidyverse") 
#library("ggplot2")
#library('plyr')
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')
#library('stringr')
#library("data.table")
#library("ggpubr")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")




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

# variables names list
prevalent_check=paste0("prevalent_AB_date_",rep(1:12))
#ab_count_12=paste0("AB_date_",rep(1:12),"_count") # change to binary flag
ab_category=paste0("AB_date_",rep(1:12),"_indication")
#indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat","uncoded")
#ab_date_12=paste0("AB_date_",rep(1:12))






# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))

for (i in seq_along(csvFiles_19)){
# read in one-month data
  df <- read_csv(csvFiles_19[i])
  #  here::here("output", "measures", csvFiles_19[i]))
  
  # filter all antibiotics users
  df=df%>%filter(!is.na(antibacterial_brit))
  
  #### patient/row --> prescription/row
  
  # ab_date_1-12
 # df1=df%>%select(patient_id,age,sex,ab_date_12)
  #colnames(df1)[4:15]=paste0("time",rep(1:12))
  #df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  #rm(df1)
  # prevalent_AB_date_1-10
  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)
 # # "AB_date_count"1-10
 # df3=df%>%select(patient_id,age,sex,ab_count_10)
 # colnames(df3)[4:15]=paste0("time",rep(1:10))
  #df3.1=df3%>%gather(times,count,paste0("time",rep(1:10)))
  #rm(df3)
  # ab_category 1-10
  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)
  
  # merge
  #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(df2.1,df3.1,by=c("patient_id","age","sex","times"))
  #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  # create date column
  DF$date=as.Date(date_19[i])
  
  # exclude observation without AB prescription date
  #DF=DF%>%filter(!is.na(date))
  #DF$date=as.Date(DF$date,origin="1970-01-01")
  

 
  temp[[i]] <- DF
  rm(DF,df2.1,df3.1,df)
  
}
#write_rds(temp, "recorded_ab_2019.rds")
saveRDS(temp, "recorded_ab_indication_2019.rds")

rm(temp)








# transform dataset & create list 2020
temp <- vector("list", length(csvFiles_20))

for (i in seq_along(csvFiles_20)){

  # read in one-month data
  df <- read_csv(csvFiles_20[i])
  
  # filter all antibiotics users
  #df=df%>%filter(!is.na(AB_date_1))
   df=df%>%filter(!is.na(antibacterial_brit))
  
  #### patient/row --> prescription/row
  
  # prevalent_AB_date_1-10
  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)

  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)
  
  # merge
  DF=merge(df2.1,df3.1,by=c("patient_id","age","sex","times"))
  
  # create date column
  DF$date=as.Date(date_20[i])
    
  temp[[i]] <- DF
  rm(DF,df2.1,df3.1,df)
}
#write_rds(temp, "recorded_ab_2020.rds")
saveRDS(temp,  "recorded_ab_indication_2020.rds")

rm(temp)



# transform dataset & create list 2021
temp <- vector("list", length(csvFiles_21))

for (i in seq_along(csvFiles_21)){

  # read in one-month data
  df <- read_csv(csvFiles_21[i])
  
  # filter all antibiotics users
  #df=df%>%filter(!is.na(AB_date_1))
   df=df%>%filter(!is.na(antibacterial_brit))
  #### patient/row --> prescription/row
  
  # prevalent_AB_date_1-10
  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)

  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)
  
  # merge
  DF=merge(df2.1,df3.1,by=c("patient_id","age","sex","times"))
  
  # create date column
  DF$date=as.Date(date_21[i])
    
  temp[[i]] <- DF
  rm(DF,df2.1,df3.1,df)
}
#write_rds(temp, "recorded_ab_2021.rds")
saveRDS(temp, "recorded_ab_indication_2021.rds")

rm(temp)




# transform dataset & create list 2022
temp <- vector("list", length(csvFiles_22))

for (i in seq_along(csvFiles_22)){

  # read in one-month data
  df <- read_csv(csvFiles_22[i])
  
  # filter all antibiotics users
 # df=df%>%filter(!is.na(AB_date_1))
   df=df%>%filter(!is.na(antibacterial_brit))
  #### patient/row --> prescription/row
  
  # prevalent_AB_date_1-10
  df2=df%>%select(patient_id,age,sex,prevalent_check)
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
  rm(df2)

  df3=df%>%select(patient_id,age,sex,ab_category)
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
  rm(df3)
  
  # merge
  DF=merge(df2.1,df3.1,by=c("patient_id","age","sex","times"))
  
  # create date column
  DF$date=as.Date(date_22[i])
    
  temp[[i]] <- DF
  rm(DF,df2.1,df3.1,df)
  
}
#write_rds(temp, "recorded_ab_2022.rds")
saveRDS(temp,"recorded_ab_indication_2022.rds")

rm(temp)



