
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate baseline table to check new COVID variables by extracting one cohort
# not by month
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---
library("tidyverse") 
library('dplyr')
library('lubridate')
#library('stringr')
#library("data.table")
#library("ggpubr")
library("finalfit")

setwd(here::here("output"))

#### read file list from input.csv

df <- read_csv(
  here::here("output", "input_sameday_ab.csv.gz"),
  col_types = cols_only(
    age = col_number(),
    age_cat = col_factor(),
    sex = col_factor(),
    practice = col_number(),#
    first_positive_test_date = col_date(format = ""),
    sgss_ab_prescribed = col_integer(),
    second_positive_test_date = col_date(format = ""),
    sgss_ab_prescribed_2 = col_integer(),
    patient_id = col_number())
)
  

## select covid group
df$covid_positive_1=ifelse(is.na(df$first_positive_test_date),0,1)
df$covid_positive_2=ifelse(is.na(df$second_positive_test_date),0,1)
df1 <- df %>% filter(covid_positive_1 == 1)
df2 <- df1 %>% filter(covid_positive_2 == 1)

num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sameday_positive_1.csv"))
rm(overall_counts,num_pats,num_pracs)

num_pats <- length(unique(df2$patient_id))
num_pracs <- length(unique(df2$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sameday_positive_2.csv"))
rm(overall_counts,num_pats,num_pracs)

df1<- select(df1, age, age_cat, sex,sgss_ab_prescribed)
# # columns for baseline table
colsfortab <- colnames(df1)
df1 %>% summary_factorlist(explanatory = colsfortab) -> t1
write_csv(t1, here::here("output", "sameday_ab_1.csv"))

df2<- select(df2, age, age_cat, sex, sgss_ab_prescribed_2)
# # columns for baseline table
colsfortab <- colnames(df2)
df2 %>% summary_factorlist(explanatory = colsfortab) -> t2
write_csv(t2, here::here("output", "sameday_ab_2.csv"))


