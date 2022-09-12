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


####### before matching ########

# case
df1 <- read.csv("case_covid_icu_death.csv")
df1$case=1

# control
df0 <- read.csv("control_covid_hosp.csv")
df0$case=0

# combine dataset
DF=rbind(df0,df1)
DF$case=as.factor(DF$case) #group
## age_cat
DF$age_cat=ifelse(DF$age<30,"18-29",
                   ifelse(DF$age<40,"30-39",
                          ifelse(DF$age<50,"40-49",
                                 ifelse(DF$age<60,"50-59",
                                        ifelse(DF$age<70,"60-69",
                                               ifelse(DF$age<80,"70-79","80+"))))))

DF$age_cat <- factor(DF$age_cat, levels=c("18-29","30-39","40-49","50-59","60-69","70-79","80+"))
DF$wave=ifelse(DF$patient_index_date >= as.Date("2021-05-01"),"3", 
                ifelse(DF$patient_index_date >= as.Date("2020-09-01"),"2", 
                       ifelse(DF$patient_index_date >= as.Date("2020-02-01"),"1","0")))


DF=DF%>%dplyr::select(case,wave,sex,age,age_cat,region)

# select variables
explanatory<- c("wave","sex","age","age_cat","region")
dependent <- "case"

#table
tbl=DF%>% summary_factorlist(dependent, explanatory)

round_tbl=tbl
#remove percentage
round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
round_tbl[,3]=as.numeric(round_tbl[,3])
round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

round_tbl[,4]=as.numeric(round_tbl[,4])
round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)


#wave
round_tbl[c(1:3),"percent_0"]=round_tbl[c(1:3),3]/sum(round_tbl[c(1:3),3])*100
round_tbl[c(1:3),"percent_1"]=round_tbl[c(1:3),4]/sum(round_tbl[c(1:3),4])*100

# gender
round_tbl[c(4:5),"percent_0"]=round_tbl[c(4:5),3]/sum(round_tbl[c(4:5),3])*100
round_tbl[c(4:5),"percent_1"]=round_tbl[c(4:5),4]/sum(round_tbl[c(4:5),4])*100

#age_cat
round_tbl[c(7:13),"percent_0"]=round_tbl[c(7:13),3]/sum(round_tbl[c(7:13),3])*100
round_tbl[c(7:13),"percent_1"]=round_tbl[c(7:13),4]/sum(round_tbl[c(7:13),4])*100

# region 
round_tbl[c(14:22),"percent_0"]=round_tbl[c(14:22),3]/sum(round_tbl[c(14:22),3])*100
round_tbl[c(14:22),"percent_1"]=round_tbl[c(14:22),4]/sum(round_tbl[c(14:22),4])*100

# age 
round_tbl[6,c(3:4)]=tbl[6,c(3:4)]

write.csv(round_tbl,"table1_unmatched.csv")

rm(list=ls())

####### after matching ########
DF=readRDS("matched_outcome.rds")
DF=DF%>%dplyr::select(case,wave,sex,age,age_cat,region)
DF$case=as.factor(DF$case)

# select variables
explanatory<- c("wave","sex","age","age_cat","region")
dependent <- "case"

#table
tbl=DF%>% summary_factorlist(dependent, explanatory)

round_tbl=tbl
#remove percentage
round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
round_tbl[,3]=as.numeric(round_tbl[,3])
round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

round_tbl[,4]=as.numeric(round_tbl[,4])
round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)


#wave
round_tbl[c(1:3),"percent_0"]=round_tbl[c(1:3),3]/sum(round_tbl[c(1:3),3])*100
round_tbl[c(1:3),"percent_1"]=round_tbl[c(1:3),4]/sum(round_tbl[c(1:3),4])*100

# gender
round_tbl[c(4:5),"percent_0"]=round_tbl[c(4:5),3]/sum(round_tbl[c(4:5),3])*100
round_tbl[c(4:5),"percent_1"]=round_tbl[c(4:5),4]/sum(round_tbl[c(4:5),4])*100

#age_cat
round_tbl[c(7:13),"percent_0"]=round_tbl[c(7:13),3]/sum(round_tbl[c(7:13),3])*100
round_tbl[c(7:13),"percent_1"]=round_tbl[c(7:13),4]/sum(round_tbl[c(7:13),4])*100

# region 
round_tbl[c(14:22),"percent_0"]=round_tbl[c(14:22),3]/sum(round_tbl[c(14:22),3])*100
round_tbl[c(14:22),"percent_1"]=round_tbl[c(14:22),4]/sum(round_tbl[c(14:22),4])*100

# age 
round_tbl[6,c(3:4)]=tbl[6,c(3:4)]

write.csv(round_tbl,"table1_matched.csv")

rm(list=ls())


###### random sampling #######
DF <- read_rds("matched_outcome.rds")
DF=DF%>% dplyr::group_by(case,subclass)%>% sample_n(1)

DF=DF%>%dplyr::select(case,wave,sex,age,age_cat,region)
DF$case=as.factor(DF$case)

# select variables
explanatory<- c("wave","sex","age","age_cat","region")
dependent <- "case"

#table
tbl=DF%>% summary_factorlist(dependent, explanatory)

round_tbl=tbl
#remove percentage
round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
round_tbl[,3]=as.numeric(round_tbl[,3])
round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

round_tbl[,4]=as.numeric(round_tbl[,4])
round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)


#wave
round_tbl[c(1:3),"percent_0"]=round_tbl[c(1:3),3]/sum(round_tbl[c(1:3),3])*100
round_tbl[c(1:3),"percent_1"]=round_tbl[c(1:3),4]/sum(round_tbl[c(1:3),4])*100

# gender
round_tbl[c(4:5),"percent_0"]=round_tbl[c(4:5),3]/sum(round_tbl[c(4:5),3])*100
round_tbl[c(4:5),"percent_1"]=round_tbl[c(4:5),4]/sum(round_tbl[c(4:5),4])*100

#age_cat
round_tbl[c(7:13),"percent_0"]=round_tbl[c(7:13),3]/sum(round_tbl[c(7:13),3])*100
round_tbl[c(7:13),"percent_1"]=round_tbl[c(7:13),4]/sum(round_tbl[c(7:13),4])*100

# region 
round_tbl[c(14:22),"percent_0"]=round_tbl[c(14:22),3]/sum(round_tbl[c(14:22),3])*100
round_tbl[c(14:22),"percent_1"]=round_tbl[c(14:22),4]/sum(round_tbl[c(14:22),4])*100

# age 
round_tbl[6,c(3:4)]=tbl[6,c(3:4)]

write.csv(round_tbl,"table1_random.csv")

rm(list=ls())
