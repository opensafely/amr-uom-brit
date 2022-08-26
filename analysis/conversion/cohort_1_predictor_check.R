####   This script is to extract the id in cohort 1 in 2019 ####

library("dplyr")
library("tidyverse")
library("lubridate")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

### id extraction 2019 ###

df1 <- readRDS("process_2_19_part_1.rds")
df2 <- readRDS("process_2_19_part_2.rds")
df1 <- bind_rows(df1)
df2 <- bind_rows(df2)
DF <- rbind(df1,df2)
rm(df1,df2)



num_records <- length(DF$patient_id)
num_pats <- length(unique(DF$patient_id))
overall_counts <- as.data.frame(cbind(num_records,num_pats))
write_csv(overall_counts, here::here("output", "cohort_1_predictor_pat_num_2019.csv"))

DF <- select(DF,age, sex,ab_prevalent,ab_prevalent_infection, ab_repeat, ab_history)

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
DF <- select(DF,age, sex,ab_prevalent,ab_prevalent_infection, ab_repeat, antibiotics_12mb4)

colsfortab <- colnames(DF)
DF %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "cohort_1_predictor_tab_2019.csv"))