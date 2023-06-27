# # # # # # # # # # # # # # # # # # # # #
# This script:
# generate baseline table
# round to nearest 5
# 
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library("ggplot2")
#library("plyr")
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

DF=readRDS(here::here("output","matched_ab.rds"))
DF=DF%>%dplyr::select( "case",
                       "total_ab_group","exposure_period_group","interval_mean_group","interval_sd_group","recent_ab_days_group","ab_types_group","broad_ab_prescriptions_group",
                       "total_ab", "exposure_period","recent_ab_days","interval_mean","interval_sd","ab_types","broad_ab_prescriptions")


DF= DF %>% 
  mutate_at(c(1:8),as.factor)

DF= DF %>% 
  mutate_at(c(9:15), as.numeric)


# select variables
explanatory<- c("total_ab_group","exposure_period_group","interval_mean_group","interval_sd_group","recent_ab_days_group","ab_types_group","broad_ab_prescriptions_group")
dependent <- "case"

contd<- c("total_ab", "exposure_period","recent_ab_days","interval_mean","interval_sd","ab_types","broad_ab_prescriptions")
#table
tbl1=DF%>% summary_factorlist(dependent, explanatory)
tbl2=DF%>% summary_factorlist(dependent, contd)

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


write.csv(tbl1,"table3_group.csv")
write.csv(tbl2,"table3#.csv")

rm(list=ls())



