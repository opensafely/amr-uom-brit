
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)

# import data
col_spec_case <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        sepsis_type = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

col_spec_control <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

df1.1<- read_csv(here::here("output", "matched_cases_191.csv"), col_types = col_spec_case)
df2.1<- read_csv(here::here("output", "matched_cases_192.csv"), col_types = col_spec_case)
df1.2<- read_csv(here::here("output", "matched_cases_201.csv"), col_types = col_spec_case)
df2.2<- read_csv(here::here("output", "matched_cases_202.csv"), col_types = col_spec_case)
df1.3<- read_csv(here::here("output", "matched_cases_211.csv"), col_types = col_spec_case)
df2.3<- read_csv(here::here("output", "matched_cases_212.csv"), col_types = col_spec_case)
df3.1<- read_csv(here::here("output", "matched_cases_221.csv"), col_types = col_spec_case)
case<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)

df1.1<- read_csv(here::here("output", "matched_matches_191.csv"), col_types = col_spec_control)
df2.1<- read_csv(here::here("output", "matched_matches_192.csv"), col_types = col_spec_control)
df1.2<- read_csv(here::here("output", "matched_matches_201.csv"), col_types = col_spec_control)
df2.2<- read_csv(here::here("output", "matched_matches_202.csv"), col_types = col_spec_control)
df1.3<- read_csv(here::here("output", "matched_matches_211.csv"), col_types = col_spec_control)
df2.3<- read_csv(here::here("output", "matched_matches_212.csv"), col_types = col_spec_control)
df3.1<- read_csv(here::here("output", "matched_matches_221.csv"), col_types = col_spec_control)

control<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)
control <- control[,-6]
case_date <-select(case,set_id,patient_index_date,sepsis_type)
control <- merge(control,case_date,by = "set_id")
df <- bind_rows(case,control)

## add var of interest
control_var <- readRDS("output/processed/input_control_data.rds")
case_var <- readRDS("output/processed/input_case_data.rds")
control_var <-control_var[,-(3:7)]
case_var <-case_var[,-(3:7)]

case <-merge(case,case_var,by=c("patient_id","patient_index_date"))
control <-merge(control,control_var,by=c("patient_id","patient_index_date"))

## add ab prescription
case_ab <- readRDS("output/processed/input_case_ab.rds")
control_ab <- readRDS("output/processed/input_control_ab.rds")
case_ab <- select(case_ab,patient_id,patient_index_date,ab_frequency,ab_type_num)
control_ab <- select(control_ab,patient_id,patient_index_date,ab_frequency,ab_type_num)

case <-merge(case,case_ab,by=c("patient_id","patient_index_date"))
control <-merge(control,control_ab,by=c("patient_id","patient_index_date"))

## add ab prescription within 6 weeks
case_ab <- readRDS("output/processed/input_case_ab_6w.rds")
control_ab <- readRDS("output/processed/input_control_ab_6w.rds")
case_ab <- select(case_ab,patient_id,patient_index_date,ab_frequency_6w,ab_type_num_6w)
control_ab <- select(control_ab,patient_id,patient_index_date,ab_frequency_6w,ab_type_num_6w)

case <-merge(case,case_ab,by=c("patient_id","patient_index_date"))
control <-merge(control,control_ab,by=c("patient_id","patient_index_date"))

## add fixed bmi & 30-day death
var_add <-cols_only(patient_index_date = col_date(format = ""),
                     bmi = col_character(),
                     died_any_30d = col_integer(),
                     patient_id = col_number()
)
case_addvar <- read_csv(here::here("output", "input_case_var_add.csv"), col_types = var_add)
control_addvar_191 <- read_csv(here::here("output", "input_control_var_add_191.csv"), col_types = var_add)
control_addvar_192 <- read_csv(here::here("output", "input_control_var_add_192.csv"), col_types = var_add)
control_addvar_201 <- read_csv(here::here("output", "input_control_var_add_201.csv"), col_types = var_add)
control_addvar_202 <- read_csv(here::here("output", "input_control_var_add_202.csv"), col_types = var_add)
control_addvar_211 <- read_csv(here::here("output", "input_control_var_add_211.csv"), col_types = var_add)
control_addvar_212 <- read_csv(here::here("output", "input_control_var_add_212.csv"), col_types = var_add)
control_addvar_221 <- read_csv(here::here("output", "input_control_var_add_221.csv"), col_types = var_add)

control_addvar <- bind_rows(control_addvar_191,control_addvar_192,
control_addvar_201,control_addvar_202,
control_addvar_211,control_addvar_212,
control_addvar_221)

case_addvar <- case_addvar %>% rename_at('bmi', ~'bmi_adult')
control_addvar <- control_addvar %>% rename_at('bmi', ~'bmi_adult')

case <-merge(case,case_addvar,by=c("patient_id","patient_index_date"))
control <-merge(control,control_addvar,by=c("patient_id","patient_index_date"))

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
df$bmi_adult = relevel(as.factor(df$bmi_adult), ref="Healthy range (18.5-24.9)")
df$ab_frequency= relevel(as.factor(df$ab_frequency), ref="0")
df$ab_type_num= relevel(as.factor(df$ab_type_num), ref="0")

df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                      patient_index_date >=as.Date("2020-03-26")&patient_index_date < as.Date("2021-03-08") ~ "2",
                                      patient_index_date >= as.Date("2021-03-08") ~ "3"))
df$covid=relevel(as.factor(df$covid), ref="1")
df1 <- df %>% filter(sepsis_type=="1")
df2 <- df %>% filter(sepsis_type=="2")


# Save output ---
output_dir <- here("output", "processed")
fs::dir_create(output_dir)
saveRDS(object = df,
        file = paste0(output_dir, "/input_", "model_c_h", ".rds"),
        compress = TRUE)
saveRDS(object = df1,
        file = paste0(output_dir, "/input_", "model_c", ".rds"),
        compress = TRUE)
saveRDS(object = df2,
        file = paste0(output_dir, "/input_", "model_h", ".rds"),
        compress = TRUE)