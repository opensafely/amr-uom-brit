
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a tabl to show the age distributionof elderly population (65+)
# Overall quantiles, by practice
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---
library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

# impoprt data
df <- read_csv(
  here::here("output", "measures", "measure_antibiotics_overall.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    antibacterial_prescriptions  = col_double(),
    population  = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )


age_quant <- as.data.frame(quantile(df$age, na.rm=TRUE))
colnames(age_quant)[1] <- "age"
write.csv(age_quant, file="age_quant.csv")

#quantile(df$value, c(0.05, 0.95),na.rm=TRUE)


ggsave(
  plot= plot_percentile,
  filename="overall_25th_75th_percentile.png", path=here::here("output"),
)
