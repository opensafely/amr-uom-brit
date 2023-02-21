#### This script is for calculating mortality rate and draw the table ####

require('tidyverse')
require("gtsummary")
library(car)
library(data.table)
library(gridExtra)
library(purrr)
library(dplyr)
library(survival)
library(rms)

df <- readRDS("output/processed/input_model_c_h.rds")
df <- df %>% filter(case==1)

df$agegroup = case_when(
  df$age < 18 ~ "<18",
  df$age >= 18 & df$age < 40 ~ "18-39",
  df$age >= 40 & df$age < 50 ~ "40-49",
  df$age >= 50 & df$age < 60 ~ "50-59",
  df$age >= 60 & df$age < 70 ~ "60-69",
  df$age >= 70 & df$age < 80 ~ "70-79",
  df$age >= 80 ~ "80+")
df_died <- df %>% filter(died_any_30d == 1) 
###Age###
df_age <- df %>% group_by(covid,agegroup) %>% summarise(count= n())
df_age_died <- df_died %>% group_by(covid,agegroup) %>% summarise(died_count= n())
df1 <- merge(df_age,df_age_died,by =c("covid","agegroup"))

###Sex###
df_sex <- df %>% group_by(covid,sex) %>% summarise(count= n())
df_sex_died <- df_died %>% group_by(covid,sex) %>% summarise(died_count= n())
df2 <- merge(df_sex,df_sex_died,by =c("covid","sex"))

### Region ###
df_region <- df %>% group_by(covid,region) %>% summarise(count= n())
df_region_died <- df_died %>% group_by(covid,region) %>% summarise(died_count= n())
df3 <- merge(df_region,df_region_died,by =c("covid","region"))

### IMD ###
df_imd <- df %>% group_by(covid,imd) %>% summarise(count= n())
df_imd_died <- df_died %>% group_by(covid,imd) %>% summarise(died_count= n())
df4 <- merge(df_imd,df_imd_died,by =c("covid","imd"))

### Ethnicity ###
df_ethnicity <- df %>% group_by(covid,ethnicity) %>% summarise(count= n())
df_ethnicity_died <- df_died %>% group_by(covid,ethnicity) %>% summarise(died_count= n())
df5 <- merge(df_ethnicity,df_ethnicity_died,by =c("covid","ethnicity"))


df<-bind_rows(df1,df2,df3,df4,df5)
df$rate <- df$died_count/df$count
write_csv(df, here::here("output", "mortality_table_all.csv"))

df <- readRDS("output/processed/input_model_c.rds")
df <- df %>% filter(case==1)

df$agegroup = case_when(
  df$age < 18 ~ "<18",
  df$age >= 18 & df$age < 40 ~ "18-39",
  df$age >= 40 & df$age < 50 ~ "40-49",
  df$age >= 50 & df$age < 60 ~ "50-59",
  df$age >= 60 & df$age < 70 ~ "60-69",
  df$age >= 70 & df$age < 80 ~ "70-79",
  df$age >= 80 ~ "80+")
df_died <- df %>% filter(died_any_30d == 1) 
###Age###
df_age <- df %>% group_by(covid,agegroup) %>% summarise(count= n())
df_age_died <- df_died %>% group_by(covid,agegroup) %>% summarise(died_count= n())
df1 <- merge(df_age,df_age_died,by =c("covid","agegroup"))

###Sex###
df_sex <- df %>% group_by(covid,sex) %>% summarise(count= n())
df_sex_died <- df_died %>% group_by(covid,sex) %>% summarise(died_count= n())
df2 <- merge(df_sex,df_sex_died,by =c("covid","sex"))

### Region ###
df_region <- df %>% group_by(covid,region) %>% summarise(count= n())
df_region_died <- df_died %>% group_by(covid,region) %>% summarise(died_count= n())
df3 <- merge(df_region,df_region_died,by =c("covid","region"))

### IMD ###
df_imd <- df %>% group_by(covid,imd) %>% summarise(count= n())
df_imd_died <- df_died %>% group_by(covid,imd) %>% summarise(died_count= n())
df4 <- merge(df_imd,df_imd_died,by =c("covid","imd"))

### Ethnicity ###
df_ethnicity <- df %>% group_by(covid,ethnicity) %>% summarise(count= n())
df_ethnicity_died <- df_died %>% group_by(covid,ethnicity) %>% summarise(died_count= n())
df5 <- merge(df_ethnicity,df_ethnicity_died,by =c("covid","ethnicity"))


df<-bind_rows(df1,df2,df3,df4,df5)
df$rate <- df$died_count/df$count
write_csv(df, here::here("output", "mortality_table_c.csv"))


df <- readRDS("output/processed/input_model_h.rds")
df <- df %>% filter(case==1)

df$agegroup = case_when(
  df$age < 18 ~ "<18",
  df$age >= 18 & df$age < 40 ~ "18-39",
  df$age >= 40 & df$age < 50 ~ "40-49",
  df$age >= 50 & df$age < 60 ~ "50-59",
  df$age >= 60 & df$age < 70 ~ "60-69",
  df$age >= 70 & df$age < 80 ~ "70-79",
  df$age >= 80 ~ "80+")
df_died <- df %>% filter(died_any_30d == 1) 
###Age###
df_age <- df %>% group_by(covid,agegroup) %>% summarise(count= n())
df_age_died <- df_died %>% group_by(covid,agegroup) %>% summarise(died_count= n())
df1 <- merge(df_age,df_age_died,by =c("covid","agegroup"))

###Sex###
df_sex <- df %>% group_by(covid,sex) %>% summarise(count= n())
df_sex_died <- df_died %>% group_by(covid,sex) %>% summarise(died_count= n())
df2 <- merge(df_sex,df_sex_died,by =c("covid","sex"))

### Region ###
df_region <- df %>% group_by(covid,region) %>% summarise(count= n())
df_region_died <- df_died %>% group_by(covid,region) %>% summarise(died_count= n())
df3 <- merge(df_region,df_region_died,by =c("covid","region"))

### IMD ###
df_imd <- df %>% group_by(covid,imd) %>% summarise(count= n())
df_imd_died <- df_died %>% group_by(covid,imd) %>% summarise(died_count= n())
df4 <- merge(df_imd,df_imd_died,by =c("covid","imd"))

### Ethnicity ###
df_ethnicity <- df %>% group_by(covid,ethnicity) %>% summarise(count= n())
df_ethnicity_died <- df_died %>% group_by(covid,ethnicity) %>% summarise(died_count= n())
df5 <- merge(df_ethnicity,df_ethnicity_died,by =c("covid","ethnicity"))


df<-bind_rows(df1,df2,df3,df4,df5)
df$rate <- df$died_count/df$count
write_csv(df, here::here("output", "mortality_table_h.csv"))
