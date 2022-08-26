####   This script is to extract the id in cohort 1 in 2019 ####

library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

df1 <- readRDS("process_1_19_part_1.rds")
df2 <- readRDS("process_1_19_part_2.rds")
df1 <- bind_rows(df1)
df2 <- bind_rows(df2)
DF <- rbind(df1,df2)
rm(df1,df2)

# recode
DF$date <- as.Date(DF$date)
DF <- DF %>% select(patient_id, "patient_index_date" = date)
num_records <- length(DF$patient_id)
num_pats <- length(unique(DF$patient_id))
DF <- distinct(DF, patient_id, .keep_all = TRUE)
overall_counts <- as.data.frame(cbind(num_records,num_pats))
write_csv(DF, here::here("output", "cohort_1_id.csv"))
write_csv(overall_counts, here::here("output", "cohort_1_pat_num.csv"))