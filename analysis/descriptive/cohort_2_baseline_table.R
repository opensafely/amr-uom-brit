## Import libraries---
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

setwd(here::here("output"))

DF <- readRDS("cohort2.rds")

dttable <- select(DF,age_group,sex,imd,region,charlsonGrp,ethnicity_6,ab_repeat,ab_prevalent,ab_prevalent_infection,antibiotics_12mb4)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "cohort_2_baseline_all.csv"))

rm(dttable)


set.seed(777)

df0_1pat.all <- DF %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)

# generate data table 
dttable <- select(df0_1pat.all,age_group,sex,imd,region,charlsonGrp,ethnicity_6)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cohort_2_baseline_all_pat_one.csv"))