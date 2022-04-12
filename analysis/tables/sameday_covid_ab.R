
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
df <- df %>% filter(covid_positive_1 == 1 |covid_positive_2 == 1)

num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sameday_positive.csv"))
rm(overall_counts)

df2<- select(df, age, age_cat, sex,sgss_ab_prescribed, sgss_ab_prescribed_2)
# # columns for baseline table
colsfortab <- colnames(df2)
df2 %>% summary_factorlist(explanatory = colsfortab) -> t
write_csv(t, here::here("output", "sameday_ab.csv"))

