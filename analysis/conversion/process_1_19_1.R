### This script is to transfer patinet/row --> ab_prescription_times/ row
### every patient has 12 times of ab extraction 
### variabless include:
### part 1: patient(id), age, sex, times(1-12), ab_date, ab_indication, ab_type
### part 2: patient(id), age, sex, times(1-12), ab_date, ab_prevalent, ab_prevalent_infection, ab_repeat, ab_history

library("tidyverse") 
library('dplyr')
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

### part 1 ### 

# file list
csvFiles_19 = c("input_ab_type_2019_2019-01-01.csv.gz","input_ab_type_2019_2019-02-01.csv.gz","input_ab_type_2019_2019-03-01.csv.gz",
                "input_ab_type_2019_2019-04-01.csv.gz","input_ab_type_2019_2019-05-01.csv.gz","input_ab_type_2019_2019-06-01.csv.gz")
# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-06-01"), "month")

# variables
ab_date_12=paste0("AB_date_",rep(1:12))
ab_category=paste0("AB_date_",rep(1:12),"_indication")
ab_type=paste0("Ab_date_",rep(1:12),"_type")

## save 2019 part 1 record

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
                   patient_id = col_integer()
                 ),
                 na = character())
  
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
  
  DF=DF%>%filter(!is.na(date))
  DF$Date=date_19[i]
  
  temp[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1)
  
}

saveRDS(temp, "process_1_19_part_1.rds")
rm(temp)
