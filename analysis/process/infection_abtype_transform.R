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

indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa")


################# UTI


# file list
csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# variables names list
prevalent_check=paste0("hx_ab_uti_date_",rep(1:4))#prevalent check
ab_category=paste0("uti_abtype",rep(1:4))#ab type
infec_date=paste0("uti_date_",rep(1:4)) #infection records


# read columns
col_spec <-cols_only( patient_id = 'd',
                    
                      uti_abtype1 = 'c',
                      uti_abtype2 = 'c',
                      uti_abtype3 = 'c',
                      uti_abtype4 = 'c',
                      
                      hx_ab_uti_date_1 ='d',
                      hx_ab_uti_date_2 ='d',
                      hx_ab_uti_date_3 ='d',
                      hx_ab_uti_date_4 ='d',
                      
                      uti_date_1 = 'c',
                      uti_date_2 = 'c',
                      uti_date_3 = 'c',
                      uti_date_4 = 'c',
                      
                      age = 'd',
                      sex = 'c'
                     )
                    


# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))

for (i in seq_along(csvFiles_19)){
  
  # read in one-month data
  df <- read_csv(csvFiles_19[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_19[i]
  
  # exclude observation without AB prescription date
  #DF=DF%>%filter(!is.na(date))
  #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_19=temp
rm(temp)




# transform dataset & create list 2020
temp <- vector("list", length(csvFiles_20))

for (i in seq_along(csvFiles_20)){
  
  # read in one-month data
  df <- read_csv(csvFiles_20[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_20[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_20=temp
rm(temp)

# transform dataset & create list 2021
temp <- vector("list", length(csvFiles_21))

for (i in seq_along(csvFiles_21)){
  
  # read in one-month data
  df <- read_csv(csvFiles_21[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_21[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_21=temp
rm(temp)


# transform dataset & create list 2022
temp <- vector("list", length(csvFiles_22))

for (i in seq_along(csvFiles_22)){
  
  # read in one-month data
  df <- read_csv(csvFiles_22[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_22[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_22=temp
rm(temp)

DF=c(DF_19,DF_20,DF_21,DF_22)


saveRDS(DF,"abtype_uti.rds")

rm(list=ls())




################# Lrti


# file list
csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# variables names list
prevalent_check=paste0("hx_ab_lrti_date_",rep(1:4))#prevalent check
ab_category=paste0("lrti_abtype",rep(1:4))#ab type
infec_date=paste0("lrti_date_",rep(1:4)) #infection records


# read columns
col_spec <-cols_only( patient_id = 'd',
                    
                      lrti_abtype1 = 'c',
                      lrti_abtype2 = 'c',
                      lrti_abtype3 = 'c',
                      lrti_abtype4 = 'c',
                      
                      hx_ab_lrti_date_1 ='d',
                      hx_ab_lrti_date_2 ='d',
                      hx_ab_lrti_date_3 ='d',
                      hx_ab_lrti_date_4 ='d',
                      
                      lrti_date_1 = 'c',
                      lrti_date_2 = 'c',
                      lrti_date_3 = 'c',
                      lrti_date_4 = 'c',
                      
                      age = 'd',
                      sex = 'c'
                     )
                    


# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))

for (i in seq_along(csvFiles_19)){
  
  # read in one-month data
  df <- read_csv(csvFiles_19[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_19[i]
  
  # exclude observation without AB prescription date
  #DF=DF%>%filter(!is.na(date))
  #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_19=temp
rm(temp)




# transform dataset & create list 2020
temp <- vector("list", length(csvFiles_20))

for (i in seq_along(csvFiles_20)){
  
  # read in one-month data
  df <- read_csv(csvFiles_20[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_20[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_20=temp
rm(temp)

# transform dataset & create list 2021
temp <- vector("list", length(csvFiles_21))

for (i in seq_along(csvFiles_21)){
  
  # read in one-month data
  df <- read_csv(csvFiles_21[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_21[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_21=temp
rm(temp)


# transform dataset & create list 2022
temp <- vector("list", length(csvFiles_22))

for (i in seq_along(csvFiles_22)){
  
  # read in one-month data
  df <- read_csv(csvFiles_22[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_22[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_22=temp
rm(temp)

DF=c(DF_19,DF_20,DF_21,DF_22)


saveRDS(DF,"abtype_lrti.rds")

rm(list=ls())






################# Urti


# file list
csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# variables names list
prevalent_check=paste0("hx_ab_urti_date_",rep(1:4))#prevalent check
ab_category=paste0("urti_abtype",rep(1:4))#ab type
infec_date=paste0("urti_date_",rep(1:4)) #infection records


# read columns
col_spec <-cols_only( patient_id = 'd',
                    
                      urti_abtype1 = 'c',
                      urti_abtype2 = 'c',
                      urti_abtype3 = 'c',
                      urti_abtype4 = 'c',
                      
                      hx_ab_urti_date_1 ='d',
                      hx_ab_urti_date_2 ='d',
                      hx_ab_urti_date_3 ='d',
                      hx_ab_urti_date_4 ='d',
                      
                      urti_date_1 = 'c',
                      urti_date_2 = 'c',
                      urti_date_3 = 'c',
                      urti_date_4 = 'c',
                      
                      age = 'd',
                      sex = 'c'
                     )
                    


# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))

for (i in seq_along(csvFiles_19)){
  
  # read in one-month data
  df <- read_csv(csvFiles_19[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_19[i]
  
  # exclude observation without AB prescription date
  #DF=DF%>%filter(!is.na(date))
  #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_19=temp
rm(temp)




# transform dataset & create list 2020
temp <- vector("list", length(csvFiles_20))

for (i in seq_along(csvFiles_20)){
  
  # read in one-month data
  df <- read_csv(csvFiles_20[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_20[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_20=temp
rm(temp)

# transform dataset & create list 2021
temp <- vector("list", length(csvFiles_21))

for (i in seq_along(csvFiles_21)){
  
  # read in one-month data
  df <- read_csv(csvFiles_21[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_21[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_21=temp
rm(temp)


# transform dataset & create list 2022
temp <- vector("list", length(csvFiles_22))

for (i in seq_along(csvFiles_22)){
  
  # read in one-month data
  df <- read_csv(csvFiles_22[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_22[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_22=temp
rm(temp)

DF=c(DF_19,DF_20,DF_21,DF_22)


saveRDS(DF,"abtype_urti.rds")

rm(list=ls())




################# Sinusitis


# file list
csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# variables names list
prevalent_check=paste0("hx_ab_sinusitis_date_",rep(1:4))#prevalent check
ab_category=paste0("sinusitis_abtype",rep(1:4))#ab type
infec_date=paste0("sinusitis_date_",rep(1:4)) #infection records


# read columns
col_spec <-cols_only( patient_id = 'd',
                    
                      sinusitis_abtype1 = 'c',
                      sinusitis_abtype2 = 'c',
                      sinusitis_abtype3 = 'c',
                      sinusitis_abtype4 = 'c',
                      
                      hx_ab_sinusitis_date_1 ='d',
                      hx_ab_sinusitis_date_2 ='d',
                      hx_ab_sinusitis_date_3 ='d',
                      hx_ab_sinusitis_date_4 ='d',
                      
                      sinusitis_date_1 = 'c',
                      sinusitis_date_2 = 'c',
                      sinusitis_date_3 = 'c',
                      sinusitis_date_4 = 'c',
                      
                      age = 'd',
                      sex = 'c'
                     )
                    


# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))

for (i in seq_along(csvFiles_19)){
  
  # read in one-month data
  df <- read_csv(csvFiles_19[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_19[i]
  
  # exclude observation without AB prescription date
  #DF=DF%>%filter(!is.na(date))
  #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_19=temp
rm(temp)




# transform dataset & create list 2020
temp <- vector("list", length(csvFiles_20))

for (i in seq_along(csvFiles_20)){
  
  # read in one-month data
  df <- read_csv(csvFiles_20[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_20[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_20=temp
rm(temp)

# transform dataset & create list 2021
temp <- vector("list", length(csvFiles_21))

for (i in seq_along(csvFiles_21)){
  
  # read in one-month data
  df <- read_csv(csvFiles_21[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_21[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_21=temp
rm(temp)


# transform dataset & create list 2022
temp <- vector("list", length(csvFiles_22))

for (i in seq_along(csvFiles_22)){
  
  # read in one-month data
  df <- read_csv(csvFiles_22[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_22[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_22=temp
rm(temp)

DF=c(DF_19,DF_20,DF_21,DF_22)


saveRDS(DF,"abtype_sinusitis.rds")

rm(list=ls())




################# Ot_externa


# file list
csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# variables names list
prevalent_check=paste0("hx_ab_ot_externa_date_",rep(1:4))#prevalent check
ab_category=paste0("ot_externa_abtype",rep(1:4))#ab type
infec_date=paste0("ot_externa_date_",rep(1:4)) #infection records


# read columns
col_spec <-cols_only( patient_id = 'd',
                    
                      ot_externa_abtype1 = 'c',
                      ot_externa_abtype2 = 'c',
                      ot_externa_abtype3 = 'c',
                      ot_externa_abtype4 = 'c',
                      
                      hx_ab_ot_externa_date_1 ='d',
                      hx_ab_ot_externa_date_2 ='d',
                      hx_ab_ot_externa_date_3 ='d',
                      hx_ab_ot_externa_date_4 ='d',
                      
                      ot_externa_date_1 = 'c',
                      ot_externa_date_2 = 'c',
                      ot_externa_date_3 = 'c',
                      ot_externa_date_4 = 'c',
                      
                      age = 'd',
                      sex = 'c'
                     )
                    


# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))

for (i in seq_along(csvFiles_19)){
  
  # read in one-month data
  df <- read_csv(csvFiles_19[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_19[i]
  
  # exclude observation without AB prescription date
  #DF=DF%>%filter(!is.na(date))
  #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_19=temp
rm(temp)




# transform dataset & create list 2020
temp <- vector("list", length(csvFiles_20))

for (i in seq_along(csvFiles_20)){
  
  # read in one-month data
  df <- read_csv(csvFiles_20[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_20[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_20=temp
rm(temp)

# transform dataset & create list 2021
temp <- vector("list", length(csvFiles_21))

for (i in seq_along(csvFiles_21)){
  
  # read in one-month data
  df <- read_csv(csvFiles_21[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_21[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_21=temp
rm(temp)


# transform dataset & create list 2022
temp <- vector("list", length(csvFiles_22))

for (i in seq_along(csvFiles_22)){
  
  # read in one-month data
  df <- read_csv(csvFiles_22[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_22[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_22=temp
rm(temp)

DF=c(DF_19,DF_20,DF_21,DF_22)


saveRDS(DF,"abtype_ot_externa.rds")

rm(list=ls())




################# Otmedia


# file list
csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# variables names list
prevalent_check=paste0("hx_ab_otmedia_date_",rep(1:4))#prevalent check
ab_category=paste0("otmedia_abtype",rep(1:4))#ab type
infec_date=paste0("otmedia_date_",rep(1:4)) #infection records


# read columns
col_spec <-cols_only( patient_id = 'd',
                    
                      otmedia_abtype1 = 'c',
                      otmedia_abtype2 = 'c',
                      otmedia_abtype3 = 'c',
                      otmedia_abtype4 = 'c',
                      
                      hx_ab_otmedia_date_1 ='d',
                      hx_ab_otmedia_date_2 ='d',
                      hx_ab_otmedia_date_3 ='d',
                      hx_ab_otmedia_date_4 ='d',
                      
                      otmedia_date_1 = 'c',
                      otmedia_date_2 = 'c',
                      otmedia_date_3 = 'c',
                      otmedia_date_4 = 'c',
                      
                      age = 'd',
                      sex = 'c'
                     )
                    


# transform dataset & create list 2019
temp <- vector("list", length(csvFiles_19))

for (i in seq_along(csvFiles_19)){
  
  # read in one-month data
  df <- read_csv(csvFiles_19[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_19[i]
  
  # exclude observation without AB prescription date
  #DF=DF%>%filter(!is.na(date))
  #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_19=temp
rm(temp)




# transform dataset & create list 2020
temp <- vector("list", length(csvFiles_20))

for (i in seq_along(csvFiles_20)){
  
  # read in one-month data
  df <- read_csv(csvFiles_20[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_20[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_20=temp
rm(temp)

# transform dataset & create list 2021
temp <- vector("list", length(csvFiles_21))

for (i in seq_along(csvFiles_21)){
  
  # read in one-month data
  df <- read_csv(csvFiles_21[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")
  
  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_21[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_21=temp
rm(temp)


# transform dataset & create list 2022
temp <- vector("list", length(csvFiles_22))

for (i in seq_along(csvFiles_22)){
  
  # read in one-month data
  df <- read_csv(csvFiles_22[i],
                 col_types = col_spec )
  df <- df %>% mutate_all(na_if,"")

  #### patient/row --> infection consultqtion/row
  
  # prevalent_AB_date
  df1=df%>%select(patient_id,age,sex,all_of(prevalent_check))
  colnames(df1)[4:7]=paste0("time",rep(1:4))
  df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
  rm(df1)
  
  # ab_category 
  df2=df%>%select(patient_id,age,sex,all_of(ab_category))
  colnames(df2)[4:7]=paste0("time",rep(1:4))
  df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
  rm(df2)
  
  # infection date
  df3=df%>%select(patient_id,age,sex,all_of(infec_date))
  colnames(df3)[4:7]=paste0("time",rep(1:4))
  df3.1=df3%>%gather(times,date,paste0("time",rep(1:4)))
  
  # merge
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))

  DF=DF%>%filter(!is.na(date)) # has infection date means has infection
  
  # create date column
  DF$date=date_22[i]
  
  
 
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df)
  
}

DF_22=temp
rm(temp)

DF=c(DF_19,DF_20,DF_21,DF_22)


saveRDS(DF,"abtype_otmedia.rds")

rm(list=ls())




### This script is to transger patinet/row --> infection_consultation_times/ row
### every patient has 4 times of ab extraction 
### variabless include:
### patient(id), age, sex, times(1-4), prevalent(1/0),ab type,  


# # ## Import libraries---
# # library("tidyverse") 
# # #library("ggplot2")
# # #library('plyr')
# # library('dplyr')#conflict with plyr; load after plyr
# # library('lubridate')
# # #library('stringr')
# # #library("data.table")
# # #library("ggpubr")

# # rm(list=ls())
# # setwd(here::here("output", "measures"))
# # #setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")

# # indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa")


# # ################# UTI


# # # file list
# # csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
# # csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
# # csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
# # csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# # # date list
# # date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
# # date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
# # date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
# # date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# # # variables names list
# # prevalent_check=paste0("hx_ab_uti_date_",rep(1:4))#prevalent check
# # ab_category=paste0("uti_abtype",rep(1:4))#ab type


# # # read columns
# # col_spec <-cols_only( patient_id = 'd',
                    
# #                       uti_abtype1 = 'c',
# #                       uti_abtype2 = 'c',
# #                       uti_abtype3 = 'c',
# #                       uti_abtype4 = 'c',
                      
# #                       hx_ab_uti_date_1 ='d',
# #                       hx_ab_uti_date_2 ='d',
# #                       hx_ab_uti_date_3 ='d',
# #                       hx_ab_uti_date_4 ='d',
                      
# #                       age = 'd',
# #                       sex = 'c'
# #                      )
                    


# # # transform dataset & create list 2019
# # temp <- vector("list", length(csvFiles_19))

# # for (i in seq_along(csvFiles_19)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_19[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_19[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_19=temp
# # rm(temp)




# # # transform dataset & create list 2020
# # temp <- vector("list", length(csvFiles_20))

# # for (i in seq_along(csvFiles_20)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_20[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_20[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_20=temp
# # rm(temp)

# # # transform dataset & create list 2021
# # temp <- vector("list", length(csvFiles_21))

# # for (i in seq_along(csvFiles_21)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_21[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_21[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_21=temp
# # rm(temp)


# # # transform dataset & create list 2022
# # temp <- vector("list", length(csvFiles_22))

# # for (i in seq_along(csvFiles_22)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_22[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_22[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_22=temp
# # rm(temp)

# # DF=c(DF_19,DF_20,DF_21,DF_22)


# # saveRDS(DF,"abtype_uti.rds")

# # rm(list=ls())




# # ################# Lrti


# # # file list
# # csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
# # csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
# # csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
# # csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# # # date list
# # date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
# # date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
# # date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
# # date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# # # variables names list
# # prevalent_check=paste0("hx_ab_lrti_date_",rep(1:4))#prevalent check
# # ab_category=paste0("lrti_abtype",rep(1:4))#ab type


# # # read columns
# # col_spec <-cols_only( patient_id = 'd',
                    
# #                       lrti_abtype1 = 'c',
# #                       lrti_abtype2 = 'c',
# #                       lrti_abtype3 = 'c',
# #                       lrti_abtype4 = 'c',
                      
# #                       hx_ab_lrti_date_1 ='d',
# #                       hx_ab_lrti_date_2 ='d',
# #                       hx_ab_lrti_date_3 ='d',
# #                       hx_ab_lrti_date_4 ='d',
                      
# #                       age = 'd',
# #                       sex = 'c'
# #                      )
                    


# # # transform dataset & create list 2019
# # temp <- vector("list", length(csvFiles_19))

# # for (i in seq_along(csvFiles_19)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_19[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_19[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_19=temp
# # rm(temp)




# # # transform dataset & create list 2020
# # temp <- vector("list", length(csvFiles_20))

# # for (i in seq_along(csvFiles_20)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_20[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_20[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_20=temp
# # rm(temp)

# # # transform dataset & create list 2021
# # temp <- vector("list", length(csvFiles_21))

# # for (i in seq_along(csvFiles_21)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_21[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_21[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_21=temp
# # rm(temp)


# # # transform dataset & create list 2022
# # temp <- vector("list", length(csvFiles_22))

# # for (i in seq_along(csvFiles_22)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_22[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_22[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_22=temp
# # rm(temp)

# # DF=c(DF_19,DF_20,DF_21,DF_22)


# # saveRDS(DF,"abtype_lrti.rds")

# # rm(list=ls())









# # ################# Urti


# # # file list
# # csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
# # csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
# # csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
# # csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# # # date list
# # date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
# # date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
# # date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
# # date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# # # variables names list
# # prevalent_check=paste0("hx_ab_urti_date_",rep(1:4))#prevalent check
# # ab_category=paste0("urti_abtype",rep(1:4))#ab type


# # # read columns
# # col_spec <-cols_only( patient_id = 'd',
                    
# #                       urti_abtype1 = 'c',
# #                       urti_abtype2 = 'c',
# #                       urti_abtype3 = 'c',
# #                       urti_abtype4 = 'c',
                      
# #                       hx_ab_urti_date_1 ='d',
# #                       hx_ab_urti_date_2 ='d',
# #                       hx_ab_urti_date_3 ='d',
# #                       hx_ab_urti_date_4 ='d',
                      
# #                       age = 'd',
# #                       sex = 'c'
# #                      )
                    


# # # transform dataset & create list 2019
# # temp <- vector("list", length(csvFiles_19))

# # for (i in seq_along(csvFiles_19)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_19[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_19[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_19=temp
# # rm(temp)




# # # transform dataset & create list 2020
# # temp <- vector("list", length(csvFiles_20))

# # for (i in seq_along(csvFiles_20)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_20[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_20[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_20=temp
# # rm(temp)

# # # transform dataset & create list 2021
# # temp <- vector("list", length(csvFiles_21))

# # for (i in seq_along(csvFiles_21)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_21[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_21[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_21=temp
# # rm(temp)


# # # transform dataset & create list 2022
# # temp <- vector("list", length(csvFiles_22))

# # for (i in seq_along(csvFiles_22)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_22[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_22[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_22=temp
# # rm(temp)

# # DF=c(DF_19,DF_20,DF_21,DF_22)


# # saveRDS(DF,"abtype_urti.rds")

# # rm(list=ls())




# # ################# Sinusitis


# # # file list
# # csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
# # csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
# # csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
# # csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# # # date list
# # date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
# # date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
# # date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
# # date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# # # variables names list
# # prevalent_check=paste0("hx_ab_sinusitis_date_",rep(1:4))#prevalent check
# # ab_category=paste0("sinusitis_abtype",rep(1:4))#ab type


# # # read columns
# # col_spec <-cols_only( patient_id = 'd',
                    
# #                       sinusitis_abtype1 = 'c',
# #                       sinusitis_abtype2 = 'c',
# #                       sinusitis_abtype3 = 'c',
# #                       sinusitis_abtype4 = 'c',
                      
# #                       hx_ab_sinusitis_date_1 ='d',
# #                       hx_ab_sinusitis_date_2 ='d',
# #                       hx_ab_sinusitis_date_3 ='d',
# #                       hx_ab_sinusitis_date_4 ='d',
                      
# #                       age = 'd',
# #                       sex = 'c'
# #                      )
                    


# # # transform dataset & create list 2019
# # temp <- vector("list", length(csvFiles_19))

# # for (i in seq_along(csvFiles_19)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_19[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_19[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_19=temp
# # rm(temp)




# # # transform dataset & create list 2020
# # temp <- vector("list", length(csvFiles_20))

# # for (i in seq_along(csvFiles_20)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_20[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_20[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_20=temp
# # rm(temp)

# # # transform dataset & create list 2021
# # temp <- vector("list", length(csvFiles_21))

# # for (i in seq_along(csvFiles_21)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_21[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_21[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_21=temp
# # rm(temp)


# # # transform dataset & create list 2022
# # temp <- vector("list", length(csvFiles_22))

# # for (i in seq_along(csvFiles_22)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_22[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_22[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_22=temp
# # rm(temp)

# # DF=c(DF_19,DF_20,DF_21,DF_22)


# # saveRDS(DF,"abtype_sinusitis.rds")

# # rm(list=ls())





# # ################# Ot_externa


# # # file list
# # csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
# # csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
# # csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
# # csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# # # date list
# # date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
# # date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
# # date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
# # date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# # # variables names list
# # prevalent_check=paste0("hx_ab_ot_externa_date_",rep(1:4))#prevalent check
# # ab_category=paste0("ot_externa_abtype",rep(1:4))#ab type


# # # read columns
# # col_spec <-cols_only( patient_id = 'd',
                    
# #                       ot_externa_abtype1 = 'c',
# #                       ot_externa_abtype2 = 'c',
# #                       ot_externa_abtype3 = 'c',
# #                       ot_externa_abtype4 = 'c',
                      
# #                       hx_ab_ot_externa_date_1 ='d',
# #                       hx_ab_ot_externa_date_2 ='d',
# #                       hx_ab_ot_externa_date_3 ='d',
# #                       hx_ab_ot_externa_date_4 ='d',
                      
# #                       age = 'd',
# #                       sex = 'c'
# #                      )
                    


# # # transform dataset & create list 2019
# # temp <- vector("list", length(csvFiles_19))

# # for (i in seq_along(csvFiles_19)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_19[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_19[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_19=temp
# # rm(temp)




# # # transform dataset & create list 2020
# # temp <- vector("list", length(csvFiles_20))

# # for (i in seq_along(csvFiles_20)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_20[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_20[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_20=temp
# # rm(temp)

# # # transform dataset & create list 2021
# # temp <- vector("list", length(csvFiles_21))

# # for (i in seq_along(csvFiles_21)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_21[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_21[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_21=temp
# # rm(temp)


# # # transform dataset & create list 2022
# # temp <- vector("list", length(csvFiles_22))

# # for (i in seq_along(csvFiles_22)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_22[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_22[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_22=temp
# # rm(temp)

# # DF=c(DF_19,DF_20,DF_21,DF_22)


# # saveRDS(DF,"abtype_ot_externa.rds")

# # rm(list=ls())




# # ################# Otmedia


# # # file list
# # csvFiles_19 = list.files(pattern="input_infection_abtype_2019", full.names = FALSE)
# # csvFiles_20 = list.files(pattern="input_infection_abtype_2020", full.names = FALSE)
# # csvFiles_21 = list.files(pattern="input_infection_abtype_2021", full.names = FALSE)
# # csvFiles_22 = list.files(pattern="input_infection_abtype_2022", full.names = FALSE)


# # # date list
# # date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
# # date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
# # date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
# # date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")

# # # variables names list
# # prevalent_check=paste0("hx_ab_otmedia_date_",rep(1:4))#prevalent check
# # ab_category=paste0("otmedia_abtype",rep(1:4))#ab type


# # # read columns
# # col_spec <-cols_only( patient_id = 'd',
                    
# #                       otmedia_abtype1 = 'c',
# #                       otmedia_abtype2 = 'c',
# #                       otmedia_abtype3 = 'c',
# #                       otmedia_abtype4 = 'c',
                      
# #                       hx_ab_otmedia_date_1 ='d',
# #                       hx_ab_otmedia_date_2 ='d',
# #                       hx_ab_otmedia_date_3 ='d',
# #                       hx_ab_otmedia_date_4 ='d',
                      
# #                       age = 'd',
# #                       sex = 'c'
# #                      )
                    


# # # transform dataset & create list 2019
# # temp <- vector("list", length(csvFiles_19))

# # for (i in seq_along(csvFiles_19)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_19[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_19[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_19=temp
# # rm(temp)




# # # transform dataset & create list 2020
# # temp <- vector("list", length(csvFiles_20))

# # for (i in seq_along(csvFiles_20)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_20[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_20[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_20=temp
# # rm(temp)

# # # transform dataset & create list 2021
# # temp <- vector("list", length(csvFiles_21))

# # for (i in seq_along(csvFiles_21)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_21[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_21[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_21=temp
# # rm(temp)


# # # transform dataset & create list 2022
# # temp <- vector("list", length(csvFiles_22))

# # for (i in seq_along(csvFiles_22)){
  
# #   # read in one-month data
# #   df <- read_csv(csvFiles_22[i],
# #                  col_types = col_spec )
  
# #   #### patient/row --> infection consultqtion/row
  
# #   # prevalent_AB_date
# #   df1=df%>%select(patient_id,age,sex,prevalent_check)
# #   colnames(df1)[4:7]=paste0("time",rep(1:4))
# #   df1.1=df1%>%gather(times,prevalent,paste0("time",rep(1:4)))
# #   rm(df1)

# #   # ab_category 
# #   df2=df%>%select(patient_id,age,sex,ab_category)
# #   colnames(df2)[4:7]=paste0("time",rep(1:4))
# #   df2.1=df2%>%gather(times,abtype,paste0("time",rep(1:4)))
# #   rm(df2)
  
# #   # merge
# #   #DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
# #   #DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  
# #   # create date column
# #   DF$date=date_22[i]
  
# #   # exclude observation without AB prescription date
# #   #DF=DF%>%filter(!is.na(date))
# #   #DF$date=as.Date(DF$date,origin="1970-01-01")
  
  
  
# #   temp[[i]] <- DF
# #   rm(DF,df1.1,df2.1,df)
  
# # }

# # DF_22=temp
# # rm(temp)

# # DF=c(DF_19,DF_20,DF_21,DF_22)


# # saveRDS(DF,"abtype_otmedia.rds")

# # rm(list=ls())