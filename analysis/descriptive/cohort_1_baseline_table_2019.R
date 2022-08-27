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

DF <- readRDS("cohort_1_dataframe.rds")

# generate data table 
dttable <- select(DF, age, sex, imd, region, charlsonGrp,ethnicity,ethnicity_6) 


dttable <- dttable %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                          age>=16 & age<=44 ~ "16-44",
                                          age>=45 & age<=64 ~ "45-64",
                                          age>=65 ~ "65+"))                 

dttable <- select(dttable, age_group, sex, imd ,region, charlsonGrp, ethnicity, ethnicity_6) 

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cohort_1_baseline_table_2019.csv"))

