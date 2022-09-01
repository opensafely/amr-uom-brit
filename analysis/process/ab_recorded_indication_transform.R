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
csvFiles_19 = list.files(pattern="input_ab_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_ab_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_ab_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_ab_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# variables names list
prevalent_check=paste0("prevalent_AB_date_",rep(1:12))
#ab_count_12=paste0("AB_date_",rep(1:12),"_count") # change to binary flag
ab_category=paste0("AB_date_",rep(1:12),"_indication")
indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat","uncoded")
ab_date_12=paste0("AB_date_",rep(1:12))

# read columns
col_spec <-cols_only( patient_id = 'd',

                   AB_date_1 = 'c',
                   AB_date_2 = 'c',
                   AB_date_3 = 'c',
                   AB_date_4 = 'c',
                   AB_date_5 = 'c',
                   AB_date_6 = 'c',
                   AB_date_7 = 'c',
                   AB_date_8 = 'c',
                   AB_date_9 = 'c',
                   AB_date_10 = 'c',
                   AB_date_11 = 'c',
                   AB_date_12 = 'c',
                   AB_date_1_indication = 'c',
                   AB_date_2_indication = 'c',
                   AB_date_3_indication = 'c',
                   AB_date_4_indication = 'c',
                   AB_date_5_indication = 'c',
                   AB_date_6_indication = 'c',
                   AB_date_7_indication = 'c',
                   AB_date_8_indication = 'c',
                   AB_date_9_indication = 'c',
                   AB_date_10_indication = 'c',
                   AB_date_11_indication = 'c',
                   AB_date_12_indication = 'c',
                   prevalent_AB_date_1  ='d',
                   prevalent_AB_date_2  ='d',
                   prevalent_AB_date_3  ='d',
                   prevalent_AB_date_4  ='d',
                   prevalent_AB_date_5  ='d',
                   prevalent_AB_date_6  ='d',
                   prevalent_AB_date_7  ='d',
                   prevalent_AB_date_8  ='d',
                   prevalent_AB_date_9  ='d',
                   prevalent_AB_date_10 ='d',
                   prevalent_AB_date_11  ='d',
                   prevalent_AB_date_12 ='d',
                      age = 'd',
                      sex = 'c',
                    antibacterial_brit="d"
                     )




# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))
for (i in seq_along(csvFiles_19)){
  # read in one-month data
  df <- read_csv(csvFiles_19[i], 
  col_types= col_spec, na="")
  
  # filter all antibiotics users
  df=df%>%filter(antibacterial_brit !=0)
  
 
  #### patient/row --> prescription/row
  
  # ab_date_1-12
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
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
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
  # exclude observation without AB prescription date
  DF=DF%>%filter(!is.na(date))

   # create date column
   DF$date=date_19[i]
  
  
 
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1)
  
}
#write_rds(temp, "recorded_ab_2019.rds")
saveRDS(temp, "recorded_ab_2019.rds")
rm(temp)







# # # # transform dataset & create list 2020
# # # temp <- vector("list", length(csvFiles_20))
# # # for (i in seq_along(csvFiles_20)){
# # #   # read in one-month data
# # #   df <- read_csv(csvFiles_20[i],
# # #     col_types= col_spec, na="")

  
# # #   # filter all antibiotics users
# # #   df=df%>%filter(antibacterial_brit !=0)
  
# # #   #### patient/row --> prescription/row
  
# # #   # ab_date_1-12
# # #   df1=df%>%select(patient_id,age,sex,ab_date_12)
# # #   colnames(df1)[4:15]=paste0("time",rep(1:12))
# # #   df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
# # #   rm(df1)
# # #   # prevalent_AB_date_1-10
# # #   df2=df%>%select(patient_id,age,sex,prevalent_check)
# # #   colnames(df2)[4:15]=paste0("time",rep(1:12))
# # #   df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
# # #   rm(df2)
# # #  # # "AB_date_count"1-10
# # #  # df3=df%>%select(patient_id,age,sex,ab_count_10)
# # #  # colnames(df3)[4:15]=paste0("time",rep(1:10))
# # #   #df3.1=df3%>%gather(times,count,paste0("time",rep(1:10)))
# # #   #rm(df3)
# # #   # ab_category 1-10
# # #   df3=df%>%select(patient_id,age,sex,ab_category)
# # #   colnames(df3)[4:15]=paste0("time",rep(1:12))
# # #   df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
# # #   rm(df3)
  
# # #   # merge
# # #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# # #   DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
# # #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# # #   # exclude observation without AB prescription date
# # #   DF=DF%>%filter(!is.na(date))
# # #   # create date column
# # #   DF$date=date_20[i]
  
 
# # #   temp[[i]] <- DF
# # #   rm(DF,df1.1,df2.1,df3.1)
  
# # # }
# # # #write_rds(temp, "recorded_ab_2020.rds")
# # # saveRDS(temp,  "recorded_ab_2020.rds")
# # # rm(temp)



# # # # transform dataset & create list 2021
# # # temp <- vector("list", length(csvFiles_21))
# # # for (i in seq_along(csvFiles_21)){
# # #   # read in one-month data
# # #   df <- read_csv(csvFiles_21[i],  col_types= col_spec, na="")
  
# # #   # filter all antibiotics users
# # #   df=df%>%filter(antibacterial_brit !=0)
  
  
# # #   #### patient/row --> prescription/row
  
# # #   # ab_date_1-12
# # #   df1=df%>%select(patient_id,age,sex,ab_date_12)
# # #   colnames(df1)[4:15]=paste0("time",rep(1:12))
# # #   df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
# # #   rm(df1)
# # #   # prevalent_AB_date_1-10
# # #   df2=df%>%select(patient_id,age,sex,prevalent_check)
# # #   colnames(df2)[4:15]=paste0("time",rep(1:12))
# # #   df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
# # #   rm(df2)
# # #  # # "AB_date_count"1-10
# # #  # df3=df%>%select(patient_id,age,sex,ab_count_10)
# # #  # colnames(df3)[4:15]=paste0("time",rep(1:10))
# # #   #df3.1=df3%>%gather(times,count,paste0("time",rep(1:10)))
# # #   #rm(df3)
# # #   # ab_category 1-10
# # #   df3=df%>%select(patient_id,age,sex,ab_category)
# # #   colnames(df3)[4:15]=paste0("time",rep(1:12))
# # #   df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
# # #   rm(df3)
  
# # #   # merge
# # #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# # #   DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
# # #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# # #   # exclude observation without AB prescription date
# # #   DF=DF%>%filter(!is.na(date))
# # #   # create date column
# # #   DF$date=date_21[i]
  
  
 
# # #   temp[[i]] <- DF
# # #   rm(DF,df1.1,df2.1,df3.1)
  
# # # }
# # # #write_rds(temp, "recorded_ab_2021.rds")
# # # saveRDS(temp, "recorded_ab_2021.rds")
# # # rm(temp)





# # # # transform dataset & create list 2022
# # # temp <- vector("list", length(csvFiles_22))
# # # for (i in seq_along(csvFiles_22)){
# # #   # read in one-month data
# # #   df <- read_csv(csvFiles_22[i],  col_types= col_spec, na="")

  
# # #   # filter all antibiotics users
# # #   df=df%>%filter(antibacterial_brit !=0)
  
  
# # #   #### patient/row --> prescription/row
  
# # #   # ab_date_1-12
# # #   df1=df%>%select(patient_id,age,sex,ab_date_12)
# # #   colnames(df1)[4:15]=paste0("time",rep(1:12))
# # #   df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
# # #   rm(df1)
# # #   # prevalent_AB_date_1-10
# # #   df2=df%>%select(patient_id,age,sex,prevalent_check)
# # #   colnames(df2)[4:15]=paste0("time",rep(1:12))
# # #   df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:12)))
# # #   rm(df2)
# # #  # # "AB_date_count"1-10
# # #  # df3=df%>%select(patient_id,age,sex,ab_count_10)
# # #  # colnames(df3)[4:15]=paste0("time",rep(1:10))
# # #   #df3.1=df3%>%gather(times,count,paste0("time",rep(1:10)))
# # #   #rm(df3)
# # #   # ab_category 1-10
# # #   df3=df%>%select(patient_id,age,sex,ab_category)
# # #   colnames(df3)[4:15]=paste0("time",rep(1:12))
# # #   df3.1=df3%>%gather(times,infection,paste0("time",rep(1:12)))
# # #   rm(df3)
  
# # #   # merge
# # #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# # #   DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
# # #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# # #   # exclude observation without AB prescription date
# # #   DF=DF%>%filter(!is.na(date))
  
# # #   # create date column
# # #   DF$date=date_22[i]
  
 
# # #   temp[[i]] <- DF
# # #   rm(DF,df1.1,df2.1,df3.1)

# # # }
# # # #write_rds(temp, "recorded_ab_2022.rds")
# # # saveRDS(temp,"recorded_ab_2022.rds")