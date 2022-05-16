library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output"))

DF <- read_csv("ab_id_date_2019.csv")
num_pats <- length(unique(DF$patient_id))

# recode
DF2 <- read_csv("input_demographic_2019.csv")
num_pats2 <- length(unique(DF2$patient_id))
overall_counts <- as.data.frame(cbind(num_pats, num_pats2))
write_csv(overall_counts, here::here("output", "extraction_test.csv"))