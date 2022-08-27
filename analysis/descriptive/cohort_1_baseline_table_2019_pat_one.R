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

df <- readRDS("cohort_1_dataframe_2019.rds")

set.seed(777)

df0_1pat <- df %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)

# generate data table 
DF <- select(df0_1pat,age,sex,imd,region,charlsonGrp,ethnicity_6)

DF <- DF %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                          age>=16 & age<=44 ~ "16-44",
                                          age>=45 & age<=64 ~ "45-64",
                                          age>=65 ~ "65+"))  
                                                
dttable <- select(DF,age_group,sex,imd,region,charlsonGrp,ethnicity_6) 

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cohort_1_baseline_2019_pat_one.csv"))

