
library("dplyr")
library("tidyverse")
library("lubridate")
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

DF$date[DF$date == ""] <- NA
DF=DF%>%filter(!is.na(date))

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
  df <- read_csv((csvFiles[i]),
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

  DF$date[DF$date == ""] <- NA
  DF=DF%>%filter(!is.na(date))
  
}

DF_ab <- bind_rows(temp)
num_record <- as.data.frame(length(DF_ab$date))
write_csv(num_record, here::here("output", "number_check_normal.csv"))


dttable <- select(DF_ab,type,infection)

colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "frequency_check_2021.csv"))