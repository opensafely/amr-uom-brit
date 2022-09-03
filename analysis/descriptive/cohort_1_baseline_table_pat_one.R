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

df.19 <- readRDS("combined_c1_2019.rds")

set.seed(777)

df0_1pat.19 <- df.19 %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)

# generate data table 
dttable <- select(df0_1pat.19,age_group,sex,imd,region,charlsonGrp,ethnicity_6)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cohort_1_baseline_2019_pat_one.csv"))

rm(df0_1pat.19,dttable)

###################################################################################################
df.20 <- readRDS("combined_c1_2020.rds")

set.seed(777)

df0_1pat.20 <- df.20 %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)

# generate data table 
dttable <- select(df0_1pat.20,age_group,sex,imd,region,charlsonGrp,ethnicity_6)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cohort_1_baseline_2020_pat_one.csv"))

rm(df0_1pat.20,dttable)

###################################################################################################
df.21 <- readRDS("combined_c1_2021.rds")

set.seed(777)

df0_1pat.21 <- df.21 %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)

# generate data table 
dttable <- select(df0_1pat.21,age_group,sex,imd,region,charlsonGrp,ethnicity_6)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cohort_1_baseline_2021_pat_one.csv"))

rm(df0_1pat.21,dttable)

###################################################################################################
DF <- bind_rows(df.19,df.20,df.21)

dttable <- select(DF,age_group,sex,imd,region,charlsonGrp,ethnicity_6)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "cohort_1_baseline_all.csv"))