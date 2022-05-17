library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

DF <- readRDS("cleaned_indication_ab.rds")

# recode
DF$date <- as.Date(DF$date)
DF <- DF %>% filter(date >= as.Date("2021-01-01"))
DF <- DF %>% filter(date <= as.Date("2021-12-31"))
DF <- DF %>% filter(age > 3)
DF <- DF %>% select(patient_id, "patient_index_date" = date)
DF <- DF[,-1]
DF <- distinct(DF, patient_id, .keep_all = TRUE)
num_pats <- length(unique(DF$patient_id))
overall_counts <- as.data.frame(num_pats)
write_csv(DF, here::here("output", "ab_id_date_2021.csv"))
write_csv(overall_counts, here::here("output", "num_pats_count_2021.csv"))