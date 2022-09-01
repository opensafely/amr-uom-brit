####   This script is to extract the id in cohort 1 in 2019 ####


library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

### id extraction 2019 ###

DF <- readRDS("process_1_2019.rds")

# recode
DF <- DF %>% select(patient_id, "patient_index_date" = date)
num_records <- length(DF$patient_id)
num_pats <- length(unique(DF$patient_id))
DF <- distinct(DF, patient_id, .keep_all = TRUE)
overall_counts <- as.data.frame(cbind(num_records,num_pats))
write_csv(DF, here::here("output", "cohort_1_id_2019.csv"))
write_csv(overall_counts, here::here("output", "cohort_1_pat_num_2019.csv"))

rm(DF,overall_counts)

### id extraction 2020 ###

DF <- readRDS("process_1_2020.rds")

# recode
DF <- DF %>% select(patient_id, "patient_index_date" = date)
num_records <- length(DF$patient_id)
num_pats <- length(unique(DF$patient_id))
DF <- distinct(DF, patient_id, .keep_all = TRUE)
overall_counts <- as.data.frame(cbind(num_records,num_pats))
write_csv(DF, here::here("output", "cohort_1_id_2020.csv"))
write_csv(overall_counts, here::here("output", "cohort_1_pat_num_2020.csv"))

rm(DF,overall_counts)

### id extraction 2021 ###

DF <- readRDS("process_1_2021.rds")

# recode
DF <- DF %>% select(patient_id, "patient_index_date" = date)
num_records <- length(DF$patient_id)
num_pats <- length(unique(DF$patient_id))
DF <- distinct(DF, patient_id, .keep_all = TRUE)
overall_counts <- as.data.frame(cbind(num_records,num_pats))
write_csv(DF, here::here("output", "cohort_1_id_2021.csv"))
write_csv(overall_counts, here::here("output", "cohort_1_pat_num_2021.csv"))

