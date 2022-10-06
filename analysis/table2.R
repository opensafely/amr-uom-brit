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



####### after matching ########
DF=readRDS("matched_outcome.rds")
DF=DF%>%dplyr::select("case","ethnicity_6",  "bmi_cat",  "CCI",  "smoking_cat_3","imd","care_home_type","care_home","covrx_ever","flu_vaccine",
                      "cancer_comor","cerebrovascular_disease_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor","hiv_comor")
DF$case=as.factor(DF$case)
DF$imd=as.character(DF$imd)
case.num=sum(DF$case==1)
contr.num=sum(DF$case==0)


# select variables
explanatory<- c("ethnicity_6",  "bmi_cat",  "CCI",  "smoking_cat_3","imd","care_home","covrx_ever","flu_vaccine",
                "cancer_comor","cerebrovascular_disease_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor","hiv_comor")
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


#ethnicity
round_tbl[c(1:6),"percent_0"]=round_tbl[c(1:6),3]/sum(round_tbl[c(1:6),3])*100
round_tbl[c(1:6),"percent_1"]=round_tbl[c(1:6),4]/sum(round_tbl[c(1:6),4])*100

# bmi cat
round_tbl[c(7:11),"percent_0"]=round_tbl[c(7:11),3]/sum(round_tbl[c(7:11),3])*100
round_tbl[c(7:11),"percent_1"]=round_tbl[c(7:11),4]/sum(round_tbl[c(7:11),4])*100

#CCI
round_tbl[c(12:16),"percent_0"]=round_tbl[c(12:16),3]/sum(round_tbl[c(12:16),3])*100
round_tbl[c(12:16),"percent_1"]=round_tbl[c(12:16),4]/sum(round_tbl[c(12:16),4])*100

# smoking
round_tbl[c(17:20),"percent_0"]=round_tbl[c(17:20),3]/sum(round_tbl[c(17:20),3])*100
round_tbl[c(17:20),"percent_1"]=round_tbl[c(17:20),4]/sum(round_tbl[c(17:20),4])*100

# IMD
round_tbl[c(21:26),"percent_0"]=round_tbl[c(21:26),3]/sum(round_tbl[c(21:26),3])*100
round_tbl[c(21:26),"percent_1"]=round_tbl[c(21:26),4]/sum(round_tbl[c(21:26),4])*100

# care home, covid & flu vaccine

# commodities- 17 conditions
round_tbl[c(27:66),"percent_0"]=round_tbl[c(27:66),3]/contr.num
round_tbl[c(27:66),"percent_1"]=round_tbl[c(27:66),4]/case.num

write.csv(round_tbl,"table2_matched.csv")

rm(list=ls())


###### random sampling #######
DF <- read_rds("matched_outcome.rds")
DF=DF%>% dplyr::group_by(case,subclass)%>% sample_n(1)

DF=DF%>%dplyr::select("case","ethnicity_6",  "bmi_cat",  "CCI",  "smoking_cat_3","imd","care_home_type","care_home","covrx_ever","flu_vaccine",
                      "cancer_comor","cerebrovascular_disease_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor","hiv_comor")
DF$case=as.factor(DF$case)
DF$imd=as.character(DF$imd)

case.num=sum(DF$case==1)
contr.num=sum(DF$case==0)


# select variables
explanatory<- c("ethnicity_6",  "bmi_cat",  "CCI",  "smoking_cat_3","imd","care_home","covrx_ever","flu_vaccine",
                "cancer_comor","cerebrovascular_disease_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor","hiv_comor")
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


#ethnicity
round_tbl[c(1:6),"percent_0"]=round_tbl[c(1:6),3]/sum(round_tbl[c(1:6),3])*100
round_tbl[c(1:6),"percent_1"]=round_tbl[c(1:6),4]/sum(round_tbl[c(1:6),4])*100

# bmi cat
round_tbl[c(7:11),"percent_0"]=round_tbl[c(7:11),3]/sum(round_tbl[c(7:11),3])*100
round_tbl[c(7:11),"percent_1"]=round_tbl[c(7:11),4]/sum(round_tbl[c(7:11),4])*100

#CCI
round_tbl[c(12:16),"percent_0"]=round_tbl[c(12:16),3]/sum(round_tbl[c(12:16),3])*100
round_tbl[c(12:16),"percent_1"]=round_tbl[c(12:16),4]/sum(round_tbl[c(12:16),4])*100

# smoking
round_tbl[c(17:20),"percent_0"]=round_tbl[c(17:20),3]/sum(round_tbl[c(17:20),3])*100
round_tbl[c(17:20),"percent_1"]=round_tbl[c(17:20),4]/sum(round_tbl[c(17:20),4])*100

# IMD
round_tbl[c(21:26),"percent_0"]=round_tbl[c(21:26),3]/sum(round_tbl[c(21:26),3])*100
round_tbl[c(21:26),"percent_1"]=round_tbl[c(21:26),4]/sum(round_tbl[c(21:26),4])*100

# care home, covid & flu vaccine

# commodities- 17 conditions
round_tbl[c(27:66),"percent_0"]=round_tbl[c(27:66),3]/contr.num
round_tbl[c(27:66),"percent_1"]=round_tbl[c(27:66),4]/case.num

write.csv(round_tbl,"table2_random.csv")
