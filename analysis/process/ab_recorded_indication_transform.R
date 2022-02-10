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


# # ### read data_ 2020-01-01 ro 2020-06-01
# # ### mport patient-level data(study definition input.csv) to summarize antibiotics counts
# # ############ loop reading multiple CSV files ################
# # # read file list from input.csv
csvFiles = list.files(pattern="input_antibiotics_2_", full.names = TRUE)
csvFiles =csvFiles [1:6] # select half year

temp <- vector("list", length(csvFiles))

# # for (i in seq_along(csvFiles)){
# #   filename <- csvFiles[i]
# #   temp_df <- read_csv(filename)
# #   filename <- basename(filename)
# #   filename <-str_remove(filename, "input_antibiotics_2_")
# #   filename <-str_remove(filename, ".csv.gz")
  
# #   #add to per-month temp df
# #   temp_df$date <- filename
# #   mutate(temp_df, date = as.Date(date, "%Y-%m-%d"))
  
# #   #add df to list
# #   temp[[i]] <- temp_df
# # }

# # # combine list -> data.table/data.frame
# # df <-plyr::ldply(temp, data.frame) 
# # rm(temp,csvFiles,i,temp_df,filename)# remove temporary list

# # filter all antibiotics users
# df=df%>%filter(antibacterial_brit !=0)

# ### remove last month data
# last.date=max(df$date)
# df=df%>% filter(date!=last.date)
# first_mon=min(df$date)
# last_mon= max(df$date)

# df$date=as.Date(df$date)

# read in files
csvFiles = c("input_antibiotics_2020_2020-01-01.csv.gz","input_antibiotics_2020_2020-02-01.csv.gz","input_antibiotics_2020_2020-03-01.csv.gz",
"input_antibiotics_2020_2020-04-01.csv.gz","input_antibiotics_2020_2020-05-01.csv.gz","input_antibiotics_2020_2020-06-01.csv.gz",
"input_antibiotics_2020_2020-07-01.csv.gz","input_antibiotics_2020_2020-08-01.csv.gz","input_antibiotics_2020_2020-09-01.csv.gz",
"input_antibiotics_2020_2020-10-01.csv.gz","input_antibiotics_2020_2020-11-01.csv.gz","input_antibiotics_2020_2020-12-01.csv.gz")
datelist= c("2020-01-01","2020-02-01","2020-03-01","2020-04-01","2020-05-01","2020-06-01","2020-07-01","2020-08-01","2020-09-01","2020-10-01","2020-11-01","2020-12-01")

# variables names list
prevalent_check=paste0("prevalent_AB_date_",rep(1:10))
ab_count_10=paste0("AB_date_",rep(1:10),"_count") # change to binary flag
ab_category=paste0("AB_date_",rep(1:10),"_indication")
indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat","uncoded")
ab_date_10=paste0("AB_date_",rep(1:10))

# #replace NA with "uncoded" in AB_indication_1-10 columns
# for (i in 1:10){
#   df[,ab_category[i]]=ifelse(is.na(df[,ab_category[i]]),"uncoded", df[,ab_category[i]])}


for (i in 1:6){
######### 2020-01-01 ##############
# read in one-month data
df <- read_csv(
  here::here("output", "measures", csvFiles[i]))

# filter all antibiotics users
df=df%>%filter(antibacterial_brit !=0)

# create date column
df$date=as.Date(datelist[i])


#### patient/row --> prescription/row

# ab_date_1-10
df1=df%>%select(patient_id,age,sex,ab_date_10)
colnames(df1)[4:13]=paste0("time",rep(1:10))
df1.1=df1%>%gather(times,date,paste0("time",rep(1:10)))
rm(df1)
# prevalent_AB_date_1-10
df2=df%>%select(patient_id,age,sex,prevalent_check)
colnames(df2)[4:13]=paste0("time",rep(1:10))
df2.1=df2%>%gather(times,prevalent,paste0("time",rep(1:10)))
rm(df2)
# "AB_date_count"1-10
df3=df%>%select(patient_id,age,sex,ab_count_10)
colnames(df3)[4:13]=paste0("time",rep(1:10))
df3.1=df3%>%gather(times,count,paste0("time",rep(1:10)))
rm(df3)
# ab_category 1-10
df4=df%>%select(patient_id,age,sex,ab_category)
colnames(df4)[4:13]=paste0("time",rep(1:10))
df4.1=df4%>%gather(times,infection,paste0("time",rep(1:10)))
rm(df4)

# merge
DF=merge(df1.1,df2.1,by=c("patient_id","age","sex","times"))
DF=merge(DF,df3.1,by=c("patient_id","age","sex","times"))
DF=merge(DF,df4.1,by=c("patient_id","age","sex","times"))

# exclude observation without AB prescription date
DF=DF%>%filter(!is.na(date))
DF$date=as.Date(DF$date,origin="1970-01-01")

write_rds(DF, here::here("output", "measures",paste0("ab_",datelist[i],".rds")))

rm(DF,df1.1,df2.1,df3.1,df4.1)
  
}