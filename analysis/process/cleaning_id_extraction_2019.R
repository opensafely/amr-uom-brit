library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

DF <- readRDS("cleaned_indication_ab.rds")

# recode
DF$date <- as.Date(DF$date)
DF <- DF %>% filter(date <= as.Date("2019-12-31"))
DF <- DF %>% filter(age > 3)
DF <- DF %>% select(patient_id, "patient_index_date" = date)

write_csv(DF, here::here("output", "ab_id_date_2019.csv"))