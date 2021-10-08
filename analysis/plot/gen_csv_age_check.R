
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a tabl to show the age distributionof elderly population (65+)
# Overall quantiles, by practice
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---
library('tidyverse')
library('dplyr')
library('lubridate')

# impoprt data
df <- read_csv(
  here::here("output", "input_elderly.csv"),
  col_types = cols_only(
    
    # Identifier
#    practice = col_integer(),
 #   
 #   # Outcomes
 #   antibacterial_prescriptions  = col_double(),
 ##   population  = col_double(),
 #   value = col_double(),
 #   
 #   # Date
 #   date = col_date(format="%Y-%m-%d")
  #  
  #),
  #na = character()
  )


age_quant <- as.data.frame(quantile(df$age, na.rm=TRUE))
colnames(age_quant)[1] <- "age"
write.csv(age_quant, here::here("output", "age_quant.csv"))