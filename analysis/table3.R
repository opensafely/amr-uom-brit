# # # # # # # # # # # # # # # # # # # # #
# This script:
# generate baseline table
# round to nearest 5
# 
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library("ggplot2")
library("plyr")
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")

col <- read_rds("abtype.rds")


####### training ########
DF=readRDS("train_X.rds")
DF=DF%>%dplyr::select( "case",
                       "prescribe_time_0","prescribe_time_1","prescribe_time_2","prescribe_time_3","AB_1_type","AB_6wk_type" ,"ab_6w_binary",
                       "total_ab", "ab_prescriptions","ab_types","prescribe_times","exposure_period","recent_ab_days", "broad_prop","broad_ab_prescriptions","AB_6wk","interval_mean","interval_med","interval_sd","interval_CV","length_mean","length_med" , "length_sd", "length_CV",col
                       )
DF=DF%>%filter(total_ab>0)

str(DF)

DF= DF %>% 
  mutate_at(c(1:8),as.factor)

DF= DF %>% 
  mutate_at(c(9:25), as.numeric)#80

case.num=sum(DF$case==1)
contr.num=sum(DF$case==0)
case.num
contr.num
str(DF)

# select variables
explanatory<- c("prescribe_time_0","prescribe_time_1","prescribe_time_2","prescribe_time_3","AB_1_type","AB_6wk_type" ,"ab_6w_binary",
                "total_ab", "ab_prescriptions","ab_types","prescribe_times","exposure_period","recent_ab_days", "broad_prop","broad_ab_prescriptions","AB_6wk","interval_mean","interval_med","interval_sd","interval_CV","length_mean","length_med" , "length_sd", "length_CV",col)
dependent <- "case"

#table
tbl=DF%>% summary_factorlist(dependent, explanatory)

#round_tbl=tbl
#remove percentage
#round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
#round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
#round_tbl[,3]=as.numeric(round_tbl[,3])
#round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

#round_tbl[,4]=as.numeric(round_tbl[,4])
#round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)


# level
#[c(12:73),"percent_0"]=round_tbl[c(12:73),3]/sum(round_tbl[c(12:73),3])*100
#round_tbl[c(12:73),"percent_1"]=round_tbl[c(12:73),4]/sum(round_tbl[c(12:73),4])*100

# continuous variables
#round_tbl[c(1:11),c(3:4)]=tbl[c(1:11),c(3:4)]


write.csv(tbl,"table3_train.csv")

rm(list=ls())




####### validation ########

col <- read_rds(here::here("output","abtype.rds"))

DF=readRDS("valid_X.rds")
DF=DF%>%dplyr::select( "case",
                       "prescribe_time_0","prescribe_time_1","prescribe_time_2","prescribe_time_3","AB_1_type","AB_6wk_type" ,"ab_6w_binary",
                       "total_ab", "ab_prescriptions","ab_types","prescribe_times","exposure_period","recent_ab_days", "broad_prop","broad_ab_prescriptions","AB_6wk","interval_mean","interval_med","interval_sd","interval_CV","length_mean","length_med" , "length_sd", "length_CV",col
)
DF=DF%>%filter(total_ab>0)


str(DF)

DF= DF %>% 
  mutate_at(c(1:8),as.factor)

DF= DF %>% 
  mutate_at(c(9:25), as.numeric)#80

case.num=sum(DF$case==1)
contr.num=sum(DF$case==0)
case.num
contr.num
str(DF)

# select variables
explanatory<- c("prescribe_time_0","prescribe_time_1","prescribe_time_2","prescribe_time_3","AB_1_type","AB_6wk_type" ,"ab_6w_binary",
                "total_ab", "ab_prescriptions","ab_types","prescribe_times","exposure_period","recent_ab_days", "broad_prop","broad_ab_prescriptions","AB_6wk","interval_mean","interval_med","interval_sd","interval_CV","length_mean","length_med" , "length_sd", "length_CV",col)
dependent <- "case"


#table
tbl=DF%>% summary_factorlist(dependent, explanatory)

#round_tbl=tbl
#remove percentage
#round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
#round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
#round_tbl[,3]=as.numeric(round_tbl[,3])
#round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

#round_tbl[,4]=as.numeric(round_tbl[,4])
#round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)


# level
#[c(12:73),"percent_0"]=round_tbl[c(12:73),3]/sum(round_tbl[c(12:73),3])*100
#round_tbl[c(12:73),"percent_1"]=round_tbl[c(12:73),4]/sum(round_tbl[c(12:73),4])*100

# continuous variables
#round_tbl[c(1:11),c(3:4)]=tbl[c(1:11),c(3:4)]


write.csv(tbl,"table3_valid.csv")

rm(list=ls())



##### all

####### training ########
DF1=readRDS("train_X.rds")
DF2=readRDS("valid_X.rds")
DF=rbind(DF1,DF2)

col <- read_rds(here::here("output","abtype.rds"))

DF=DF%>%dplyr::select( "case",
                       "prescribe_time_0","prescribe_time_1","prescribe_time_2","prescribe_time_3","AB_1_type","AB_6wk_type" ,"ab_6w_binary",
                       "total_ab", "ab_prescriptions","ab_types","prescribe_times","exposure_period","recent_ab_days", "broad_prop","broad_ab_prescriptions","AB_6wk","interval_mean","interval_med","interval_sd","interval_CV","length_mean","length_med" , "length_sd", "length_CV",col
)

DF=DF%>%filter(total_ab>0)

str(DF)

DF= DF %>% 
  mutate_at(c(1:8),as.factor)

DF= DF %>% 
  mutate_at(c(9:25), as.numeric)#80

case.num=sum(DF$case==1)
contr.num=sum(DF$case==0)
case.num
contr.num
str(DF)

# select variables
explanatory<- c("prescribe_time_0","prescribe_time_1","prescribe_time_2","prescribe_time_3","AB_1_type","AB_6wk_type" ,"ab_6w_binary",
                "total_ab", "ab_prescriptions","ab_types","prescribe_times","exposure_period","recent_ab_days", "broad_prop","broad_ab_prescriptions","AB_6wk","interval_mean","interval_med","interval_sd","interval_CV","length_mean","length_med" , "length_sd", "length_CV",col)
dependent <- "case"

#table
tbl=DF%>% summary_factorlist(dependent, explanatory)

#round_tbl=tbl
#remove percentage
#round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
#round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
#round_tbl[,3]=as.numeric(round_tbl[,3])
#round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

#round_tbl[,4]=as.numeric(round_tbl[,4])
#round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)


# level
#[c(12:73),"percent_0"]=round_tbl[c(12:73),3]/sum(round_tbl[c(12:73),3])*100
#round_tbl[c(12:73),"percent_1"]=round_tbl[c(12:73),4]/sum(round_tbl[c(12:73),4])*100

# continuous variables
#round_tbl[c(1:11),c(3:4)]=tbl[c(1:11),c(3:4)]


write.csv(tbl,"table3_all.csv")

rm(list=ls())
