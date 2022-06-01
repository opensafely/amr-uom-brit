### This script is for preparing the variables for repeat antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

DF <- readRDS("cleaned_indication_ab.rds")

# recode
DF$date <- as.Date(DF$date)
DF <- DF %>% filter(date <= as.Date("2021-12-31"))
DF <- DF %>% filter(age > 3)
setwd(here::here("output"))
df2.1 <- read_csv("prepared_var_2019.csv") %>% select(-c(age,sex))
df2.2 <- read_csv("prepared_var_2020.csv") %>% select(-c(age,sex))
df2.3 <- read_csv("prepared_var_2021.csv") %>% select(-c(age,sex))
df2 <- rbind(df2.1,df2.2,df2.3)
df <- merge(DF,df2,by=c("patient_id"))
rm(DF,df2)
df <- df %>% filter(!is.na(infection))

df$ethnicity_6 <- as.factor(df$ethnicity_6)
df$imd <- as.factor(df$imd)
df$region <- as.factor(df$region)
df$charlsonGrp <- as.factor(df$charlsonGrp)
df$ab12b4 <- as.factor(df$ab12b4)
df <- df %>% dplyr::select(practice,patient_id,incidental,infection,repeat_ab,age,sex,ethnicity_6,region,charlsonGrp,imd,ab12b4,date)
df <- df %>% filter (df$sex=="M"|df$sex=="F")
df <- df %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                          age>=16 & age<=44 ~ "16-44",
                                          age>=45 & age<=64 ~ "45-64",
                                          age>=65 ~ "65+"))

### Table 1. Description and descriptive statistics
# columns for  table
num_record <- length(df$patient_id)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))
num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))

overall_counts <- as.data.frame(cbind(first_mon, last_mon, num_pats, num_pracs,num_record))
write_csv(overall_counts, here::here("output", "cohort_2_count.csv"))
rm(overall_counts,first_mon, last_mon, num_pats, num_pracs,num_record) 

df0 <- df %>% dplyr::select(incidental,infection,repeat_ab,age,sex,ethnicity_6,region,charlsonGrp,imd,ab12b4)

colsfortab <- colnames(df0)
df0 %>% summary_factorlist(explanatory = colsfortab) -> t1
write_csv(t1, here::here("output", "repeat_overall_tab.csv"))


df1 <- df %>% filter(incidental==1) 
rm(df)

num_record <- length(df1$patient_id)
first_mon <- (format(min(df1$date), "%m-%Y"))
last_mon <- (format(max(df1$date), "%m-%Y"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))

overall_counts <- as.data.frame(cbind(first_mon, last_mon, num_pats, num_pracs,num_record))
write_csv(overall_counts, here::here("output", "cohort_3_count.csv"))
rm(overall_counts,first_mon, last_mon, num_pats, num_pracs,num_record) 

df1 <- df1 %>% dplyr::select(infection,repeat_ab,age,sex,ethnicity_6,region,charlsonGrp,imd,ab12b4)

### Table 1. Description and descriptive statistics
# columns for  table
colsfortab <- colnames(df1)
df1 %>% summary_factorlist(explanatory = colsfortab) -> t2
write_csv(t2, here::here("output", "repeat_incident_tab.csv"))