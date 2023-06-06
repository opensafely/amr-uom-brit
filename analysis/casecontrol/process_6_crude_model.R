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
# Define the list of infections
infections <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "pneumonia")

# Iterate over each infection in the list
for (infection in infections) {

  # Load data for the current infection
  case_infection <- readRDS(here::here("output", "processed", paste0("case_",infection,".rds")))
  control_infection <- readRDS(here::here("output", "processed",paste0("control_",infection,".rds")))
  
  df <- rbind(case_infection, control_infection)

df$care_home_type_ba <- df %>% mutate() 
df$care_home_type_ba<-  case_when(
  df$care_home_type == "U" ~ "FALSE",
  df$care_home_type == "NA" ~ "FALSE",
  df$care_home_type == "PC" ~ "TRUE",
  df$care_home_type == "PN" ~ "TRUE",
  df$care_home_type == "PS" ~ "TRUE")

df$ab_treatment <- df %>% mutate() 
df$ab_treatment<-  case_when(
  df$ab_frequency == "0" ~ "FALSE",
  df$ab_frequency == "1" ~ "TRUE",
  df$ab_frequency == "2-3" ~ "TRUE",
  df$ab_frequency == ">3" ~ "TRUE")


df$case=as.numeric(df$case) #1/0
df$set_id=as.factor(df$set_id)#pair id
df$charlsonGrp= relevel(as.factor(df$charlsonGrp), ref="zero")
df$patient_index_date <- as.Date(df$patient_index_date, format = "%Y%m%d")

df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                      patient_index_date >=as.Date("2020-03-26") & patient_index_date < as.Date("2021-03-08") ~ "2",
                                      patient_index_date >= as.Date("2021-03-08") ~ "3"))
df$covid=relevel(as.factor(df$covid), ref="1")



# Select necessary columns
columns <- c("set_id","case", "region", "imd", "ethnicity", "bmi", "smoking_status_comb",
             "hypertension", "chronic_respiratory_disease", "asthma", "chronic_cardiac_disease",
             "diabetes_controlled", "cancer", "haem_cancer", "chronic_liver_disease", "stroke",
             "dementia", "other_neuro", "organ_kidney_transplant", "asplenia", "ra_sle_psoriasis",
             "immunosuppression", "learning_disability", "sev_mental_ill", "alcohol_problems",
             "care_home_type_ba", "ckd_rrt", "ab_treatment", "charlsonGrp","covid")

df<- select(df,columns)

mod=clogit(case ~ ab_treatment + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", paste0(infection,"_model_1.csv")))

mod=clogit(case ~ covid*ab_treatment + ab_treatment + strata(set_id), df)

sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", paste0(infection,"_model_2.csv")))
## Renal 

mod=clogit(case ~ ab_treatment + ckd_rrt + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", paste0(infection,"_model_3.csv")))

## Renal 2
mod=clogit(case ~ ckd_rrt*ab_treatment + ab_treatment + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", paste0(infection,"_model_4.csv")))
## CCI

mod=clogit(case ~ ab_treatment + charlsonGrp + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", paste0(infection,"_model_5.csv")))
}
