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

num_record <- length(df$patient_id)
num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))

overall_counts <- as.data.frame(cbind(num_record, num_pats,num_pracs))
write_csv(overall_counts, here::here("output", "cohort_1_2019_overallcount.csv"))


# generate data table 
DF <- select(df,age,sex,imd,region,charlsonGrp,ethnicity_6,type,infection,indication,ab_prevalent,
ab_prevalent_infection,ab_repeat,ab_history)

DF$indication <- as.factor(DF$indication)
DF$ab_prevalent <- as.factor(DF$ab_prevalent)
DF$ab_prevalent_infection <- as.factor(DF$ab_prevalent_infection)
DF$ab_repeat <- as.factor(DF$ab_repeat)
DF$ab_history <- ifelse(is.na(DF$ab_history),0,DF$ab_history)
DF<- DF %>% 
  mutate(antibiotics_12mb4 = case_when(ab_history >=3 ~ "3",
                             ab_history == 2  ~ "2",
                             ab_history == 1  ~ "1",
                             ab_history == 0  ~ "0"))
DF$antibiotics_12mb4<- as.factor(DF$antibiotics_12mb4)

DF <- DF %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                          age>=16 & age<=44 ~ "16-44",
                                          age>=45 & age<=64 ~ "45-64",
                                          age>=65 ~ "65+"))  
                                                
dttable <- select(DF,age_group,sex,imd,region,charlsonGrp,ethnicity_6,type,infection,indication,ab_prevalent,
ab_prevalent_infection,ab_repeat,antibiotics_12mb4) 

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cohort_1_baseline_table_2019.csv"))

