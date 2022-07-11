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

df <- readRDS("cohort_1.rds")

df <- df %>% filter(!is.na(infection))

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

set.seed(777)

df0_1pat <- df %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)


df0 <- df %>% dplyr::select(incidental,infection,repeat_ab,age,sex,ethnicity_6,region,charlsonGrp,imd,ab12b4)

colsfortab <- colnames(df0)
df0 %>% summary_factorlist(explanatory = colsfortab) -> t1
write_csv(t1, here::here("output", "repeat_overall_tab.csv"))


df0_1pat <- df0_1pat %>% dplyr::select(age,sex,ethnicity_6,region,charlsonGrp,imd)
colsfortab0_1pat  <- colnames(df0_1pat)
df0_1pat %>% summary_factorlist(explanatory = colsfortab0_1pat) -> t0_1
write_csv(t0_1, here::here("output", "cohort_2_pat_one.csv"))


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

set.seed(777)

df1_1pat <- df1 %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)


df1 <- df1 %>% dplyr::select(infection,repeat_ab,age,sex,ethnicity_6,region,charlsonGrp,imd,ab12b4)

### Table 1. Description and descriptive statistics
# columns for  table
colsfortab <- colnames(df1)
df1 %>% summary_factorlist(explanatory = colsfortab) -> t2
write_csv(t2, here::here("output", "repeat_incident_tab.csv"))

df1_1pat <- df1_1pat %>% dplyr::select(age,sex,ethnicity_6,region,charlsonGrp,imd)
colsfortab1_1pat  <- colnames(df1_1pat)
df1_1pat %>% summary_factorlist(explanatory = colsfortab1_1pat) -> t1_1
write_csv(t1_1, here::here("output", "cohort_3_pat_one.csv"))