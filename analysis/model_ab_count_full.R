
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)

# import data
col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        sepsis_type = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

col_spec1 <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

df1.1<- read_csv(here::here("output", "matched_cases_191.csv"), col_types = col_spec)
df2.1<- read_csv(here::here("output", "matched_cases_192.csv"), col_types = col_spec)
df1.2<- read_csv(here::here("output", "matched_cases_201.csv"), col_types = col_spec)
df2.2<- read_csv(here::here("output", "matched_cases_202.csv"), col_types = col_spec)
df1.3<- read_csv(here::here("output", "matched_cases_211.csv"), col_types = col_spec)
df2.3<- read_csv(here::here("output", "matched_cases_212.csv"), col_types = col_spec)
df3.1<- read_csv(here::here("output", "matched_cases_221.csv"), col_types = col_spec)
case<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)

df1.1<- read_csv(here::here("output", "matched_matches_191.csv"), col_types = col_spec1)
df2.1<- read_csv(here::here("output", "matched_matches_192.csv"), col_types = col_spec1)
df1.2<- read_csv(here::here("output", "matched_matches_201.csv"), col_types = col_spec1)
df2.2<- read_csv(here::here("output", "matched_matches_202.csv"), col_types = col_spec1)
df1.3<- read_csv(here::here("output", "matched_matches_211.csv"), col_types = col_spec1)
df2.3<- read_csv(here::here("output", "matched_matches_212.csv"), col_types = col_spec1)
df3.1<- read_csv(here::here("output", "matched_matches_221.csv"), col_types = col_spec1)

control<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)
control <- control[,-6]
case_date <-select(case,set_id,patient_index_date,sepsis_type)
control <- merge(control,case_date,by = "set_id")
df <- bind_rows(case,control)

control_var <- readRDS("output/processed/input_control_data.rds")
case_var <- readRDS("output/processed/input_case_data.rds")
control_var <-control_var[,-(3:7)]
case_var <-case_var[,-(3:7)]

case <-merge(case,case_var,by=c("patient_id","patient_index_date"))
control <-merge(control,control_var,by=c("patient_id","patient_index_date"))

case_ab <- readRDS("output/processed/input_case_ab.rds")
control_ab <- readRDS("output/processed/input_control_ab.rds")
case_ab <- select(case_ab,patient_id,patient_index_date,ab_frequency)
control_ab <- select(control_ab,patient_id,patient_index_date,ab_frequency)

case <-merge(case,case_ab,by=c("patient_id","patient_index_date"))
control <-merge(control,control_ab,by=c("patient_id","patient_index_date"))
df <- bind_rows(case,control)


# outcome

df$care_home_type_ba <- df %>% mutate() 
df$care_home_type_ba<-  case_when(
  df$care_home_type == "U" ~ "FALSE",
  df$care_home_type == "NA" ~ "FALSE",
  df$care_home_type == "PC" ~ "TRUE",
  df$care_home_type == "PN" ~ "TRUE",
  df$care_home_type == "PS" ~ "TRUE")

df$case=as.numeric(df$case) #1/0
df$set_id=as.factor(df$set_id)#pair id
df$imd= relevel(as.factor(df$imd), ref="5")
df$smoking_status= relevel(as.factor(df$smoking_status), ref="Never")
df$ab_frequency= relevel(as.factor(df$ab_frequency), ref="0")
df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                      patient_index_date >=as.Date("2020-03-26")&patient_index_date < as.Date("2021-03-08") ~ "2",
                                      patient_index_date >= as.Date("2021-03-08") ~ "3"))
df$covid=relevel(as.factor(df$covid), ref="1")
df1 <- df %>% filter(sepsis_type=="1")
df2 <- df %>% filter(sepsis_type=="2")




mod=clogit(case ~ region + ethnicity + bmi + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency+ strata(set_id), df)
sum.mod=summary(mod)
sum.mod



result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"
write_csv(DF, here::here("output", "model_ab_count_full.csv"))

Antibiotic_prescriptions <- DF[49:51,]

mod=clogit(case ~ ab_frequency + strata(set_id), df)
sum.mod=summary(mod)
sum.mod
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"
write_csv(DF, here::here("output", "model_ab_count_unadjust.csv"))