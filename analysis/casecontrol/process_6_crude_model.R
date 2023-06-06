# Load the necessary libraries
library(readr)
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)


case_uti <- readRDS(here::here("output", "processed","case_uti.rds"))
control_uti <- readRDS(here::here("output", "processed","control_uti.rds"))
df <- rbind(case_uti,control_uti)

df$care_home_type_ba <- df %>% mutate() 
df$care_home_type_ba<-  case_when(
  df$care_home_type == "U" ~ "FALSE",
  df$care_home_type == "NA" ~ "FALSE",
  df$care_home_type == "PC" ~ "TRUE",
  df$care_home_type == "PN" ~ "TRUE",
  df$care_home_type == "PS" ~ "TRUE")

df$case=as.numeric(df$case) #1/0
df$set_id=as.factor(df$set_id)#pair id
df$imd= relevel(as.factor(df$imd), ref="5 (least deprived)")
df$smoking_status= relevel(as.factor(df$smoking_status_comb), ref="Never and unknown")
df$bmi = relevel(as.factor(df$bmi), ref="Healthy range (18.5-24.9 kg/m2)")
df$ab_frequency= relevel(as.factor(df$ab_frequency), ref="0")
df$charlsonGrp= relevel(as.factor(df$charlsonGrp), ref="zero")

df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                      patient_index_date >=as.Date("2020-03-26")&patient_index_date < as.Date("2021-03-08") ~ "2",
                                      patient_index_date >= as.Date("2021-03-08") ~ "3"))
df$covid=relevel(as.factor(df$covid), ref="1")



# Select necessary columns
columns <- c("set_id","case", "region", "imd", "ethnicity", "bmi", "smoking_status_comb",
             "hypertension", "chronic_respiratory_disease", "asthma", "chronic_cardiac_disease",
             "diabetes_controlled", "cancer", "haem_cancer", "chronic_liver_disease", "stroke",
             "dementia", "other_neuro", "organ_kidney_transplant", "asplenia", "ra_sle_psoriasis",
             "immunosuppression", "learning_disability", "sev_mental_ill", "alcohol_problems",
             "care_home_type_ba", "ckd_rrt", "ab_frequency", "ab_type_num", "charlsonGrp","covid")

df<- select(df,columns)

mod=clogit(case ~ ab_frequency + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", "uti_model_1.csv"))

mod=clogit(case ~ covid*ab_frequency + ab_frequency + strata(set_id), df)

sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", "uti_model_2.csv"))
## Renal 

mod=clogit(case ~ ab_frequency + ckd_rrt + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", "uti_model_3.csv"))
## CCI

mod=clogit(case ~ ab_frequency + charlsonGrp + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", "uti_model_4.csv"))
