library("tidyverse") 
library('dplyr')
library('lubridate')


rm(list=ls())
setwd(here::here("output", "measures"))

# file list
csvFiles = c("input_ab_type_2021_2021-01-01.csv.gz","input_ab_type_2021_2021-02-01.csv.gz","input_ab_type_2021_2021-03-01.csv.gz",
"input_ab_type_2021_2021-04-01.csv.gz","input_ab_type_2021_2021-05-01.csv.gz","input_ab_type_2021_2021-06-01.csv.gz",
"input_ab_type_2021_2021-07-01.csv.gz","input_ab_type_2021_2021-08-01.csv.gz","input_ab_type_2021_2021-09-01.csv.gz",
"input_ab_type_2021_2021-10-01.csv.gz","input_ab_type_2021_2021-11-01.csv.gz","input_ab_type_2021_2021-12-01.csv.gz")

# variables
ab_date_12=paste0("AB_date_",rep(1:12))
ab_category=paste0("AB_date_",rep(1:12),"_indication")
ab_type=paste0("Ab_date_",rep(1:12),"_type")

## save 2021 part 1 record

temp <- vector("list", length(csvFiles))
for (i in seq_along(csvFiles)){
  # read in one-month data
  df <- read_csv(csvFiles[i])
  
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
  
  temp[[i]] <- DF
}

DF_ab <- bind_rows(temp)
DF_ab=DF_ab%>%filter(!is.na(date))
DF_ab$infection[DF_ab$infection == ""] <- NA

saveRDS(DF_ab, "process_1_2021.rds")