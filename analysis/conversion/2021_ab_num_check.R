library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

df1 <- readRDS("process_2_21_part_1.rds")
df2 <- readRDS("process_2_21_part_2.rds")
df1 <- bind_rows(df1)
df2 <- bind_rows(df2)
DF <- rbind(df1,df2)
rm(df1,df2)
DF <- select(DF,patient_id,date,ab_prevalent,ab_prevalent_infection, ab_repeat, ab_history)

num_record <- as.data.frame(length(DF$date))
write_csv(num_record, here::here("output", "number_check.csv"))


rm(list=ls())
setwd(here::here("output"))

# file list
csvFiles = list.files(pattern="input_ab_type_2021_2021", full.names = FALSE)

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
DF_ab$date[DF_ab$date == ""] <- NA
DF_ab=DF_ab%>%filter(!is.na(date))

num_record <- as.data.frame(length(DF_ab$date))
write_csv(num_record, here::here("output", "number_check_normal.csv"))

DF_ab$infection[DF_ab$infection == ""] <- NA
DF_ab <- select(DF_ab,type,infection)

colsfortab <- colnames(DF_ab)
DF_ab %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "frequency_check_2021.csv"))