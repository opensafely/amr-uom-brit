
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a table to show the age distribution of elderly population (65+)
# Overall quantiles
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---
library('tidyverse')
library('dplyr')

setwd(here::here("output"))

df <- read.csv(file=here::here("output", "input_elderly.csv.gz"))

age_quant <- as.data.frame(quantile(df$age, na.rm=TRUE))
colnames(age_quant)[1] <- "age"

write_csv(age_quant, here::here("output", "age_quant.csv"))