
# # # # # # # # # # # # # # # # # # # # #
# This script:
# define covid infection (case) & potiential control group
# 
# 
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')


#### COVID INFECTION

# impoprt data
df <- read_csv(here::here("output", "control_covid_infection.csv"))


# split data by month (for matching general population)

list=sort(unique(df$cal_YM))
filename=c("2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012",
"2101","2102","2103","2104","2105","2106","2107","2108","2109","2110","2111","2112")

for (i in 1:length(list)){
  DF=subset(df,cal_YM==list[i])
  
  write_csv(DF, here::here("output", paste0("covid_infection_",filename[i],".csv")))
}

rm(list=ls())


