# # # # # # # # # # # # # # # # # # # # #
# This script:
# generate baseline table
# round to nearest 5
# 
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")
# extracted dataset after matching
DF1=read_csv("input_outcome.csv")

## add variables to extracted cohort:"subclass","case", 
DF2 <- read_rds("matched_patients.rds")

#DF2 = subset(DF2,select=c("patient_id","age","sex","set_id","case", "match_counts","stp"))
DF2 = DF2%>%select(c("patient_id","sex","stp","subclass","case","patient_index_date"))

#df=merge(DF1,DF2,by=c("patient_id","age","sex","stp"),all.x=T) can't merge with dummy data
df=merge(DF2,DF1,by=c("patient_id","sex","stp","patient_index_date"),all=T)
rm(DF1,DF2)
