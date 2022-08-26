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
csvFiles_19_2 = c("input_ab_predictor_2019_2019-07-01.csv.gz","input_ab_predictor_2019_2019-08-01.csv.gz",
                  "input_ab_predictor_2019_2019-09-01.csv.gz","input_ab_predictor_2019_2019-10-01.csv.gz",
                  "input_ab_predictor_2019_2019-11-01.csv.gz","input_ab_predictor_2019_2019-12-01.csv.gz")

# date list
date_19= seq(as.Date("2019-07-01"), as.Date("2019-12-01"), "month")

# variables
ab_date_12=paste0("AB_date_",rep(1:12))
ab_prevalent=paste0("prevalent_AB_date_",rep(1:12))
ab_prevalent_infection=paste0("prevalent_infection_AB_date_",rep(1:12))
ab_repeat=paste0("repeat_AB_date_",rep(1:12))
ab_history=paste0("ab_history_date_",rep(1:12))

## save 2019 part 2 record

temp2 <- vector("list", length(csvFiles_19_2))
for (i in seq_along(csvFiles_19_2)){
  # read in one-month data
  df <- read_csv((csvFiles_19_2[i]),
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
                   prevalent_AB_date_1 = col_integer(),
                   prevalent_AB_date_2 = col_integer(),
                   prevalent_AB_date_3 = col_integer(),
                   prevalent_AB_date_4 = col_integer(),
                   prevalent_AB_date_5 = col_integer(),
                   prevalent_AB_date_6 = col_integer(),
                   prevalent_AB_date_7 = col_integer(),
                   prevalent_AB_date_8 = col_integer(),
                   prevalent_AB_date_9 = col_integer(),
                   prevalent_AB_date_10 = col_integer(),
                   prevalent_AB_date_11 = col_integer(),
                   prevalent_AB_date_12 = col_integer(),
                   prevalent_infection_AB_date_1 = col_integer(),
                   prevalent_infection_AB_date_2 = col_integer(),
                   prevalent_infection_AB_date_3 = col_integer(),
                   prevalent_infection_AB_date_4 = col_integer(),
                   prevalent_infection_AB_date_5 = col_integer(),
                   prevalent_infection_AB_date_6 = col_integer(),
                   prevalent_infection_AB_date_7 = col_integer(),
                   prevalent_infection_AB_date_8 = col_integer(),
                   prevalent_infection_AB_date_9 = col_integer(),
                   prevalent_infection_AB_date_10 = col_integer(),
                   prevalent_infection_AB_date_11 = col_integer(),
                   prevalent_infection_AB_date_12 = col_integer(),
                   repeat_AB_date_1 = col_integer(),
                   repeat_AB_date_2 = col_integer(),
                   repeat_AB_date_3 = col_integer(),
                   repeat_AB_date_4 = col_integer(),
                   repeat_AB_date_5 = col_integer(),
                   repeat_AB_date_6 = col_integer(),
                   repeat_AB_date_7 = col_integer(),
                   repeat_AB_date_8 = col_integer(),
                   repeat_AB_date_9 = col_integer(),
                   repeat_AB_date_10 = col_integer(),
                   repeat_AB_date_11 = col_integer(),
                   repeat_AB_date_12 = col_integer(),
                   ab_history_date_1 = col_double(),
                   ab_history_date_2 = col_double(),
                   ab_history_date_3 = col_double(),
                   ab_history_date_4 = col_double(),
                   ab_history_date_5 = col_double(),
                   ab_history_date_6 = col_double(),
                   ab_history_date_7 = col_double(),
                   ab_history_date_8 = col_double(),
                   ab_history_date_9 = col_double(),
                   ab_history_date_10 = col_double(),
                   ab_history_date_11 = col_double(),
                   ab_history_date_12 = col_double(),
                   patient_id = col_integer()
                 ),
                 na = character())
  
  df1=df%>%select(patient_id,age,sex,ab_date_12)
  colnames(df1)[4:15]=paste0("time",rep(1:12))
  df1.1=df1%>%gather(times,date,paste0("time",rep(1:12)))
  rm(df1)
  
  df2=df%>%select(patient_id,age,sex,all_of(ab_prevalent))
  colnames(df2)[4:15]=paste0("time",rep(1:12))
  df2.1=df2%>%gather(times,ab_prevalent,paste0("time",rep(1:12)))
  rm(df2)
  
  df3=df%>%select(patient_id,age,sex,all_of(ab_prevalent_infection))
  colnames(df3)[4:15]=paste0("time",rep(1:12))
  df3.1=df3%>%gather(times,ab_prevalent_infection,paste0("time",rep(1:12)))
  rm(df3)
  
  df4=df%>%select(patient_id,age,sex,all_of(ab_repeat))
  colnames(df4)[4:15]=paste0("time",rep(1:12))
  df4.1=df4%>%gather(times,ab_repeat,paste0("time",rep(1:12)))
  rm(df4)
  
  df5=df%>%select(patient_id,age,sex,all_of(ab_history))
  colnames(df5)[4:15]=paste0("time",rep(1:12))
  df5.1=df5%>%gather(times,ab_history,paste0("time",rep(1:12)))
  rm(df5)
  
  DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))
  DF=merge(DF,df5.1,by=c("patient_id","age","sex","times"))
  
  DF=DF%>%filter(!is.na(date))
  DF$Date=date_19[i]
  
  temp2[[i]] <- DF
  rm(DF,df1.1,df2.1,df3.1,df4.1,df5.1)
  
}

saveRDS(temp2, "process_2_19_part_2.rds")
rm(temp2)