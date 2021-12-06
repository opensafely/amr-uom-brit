
# # # # # # # # # # # # # # # # # # # # #
# This script:
# define covid infection (case) & potiential control group
# 
# 
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library('dplyr')
library('lubridate')

#### COVID INFECTION

# impoprt data
df1 <- read_csv(here::here("output", "input_covid_SGSS.csv"))
df2<- read_csv(here::here("output", "input_covid_primarycare.csv"))


write_csv(df, here::here("output", "input_covid_icu&died.csv"))
