
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

list=c("2020-02","2020-03", "2020-04", "2020-05", "2020-06", "2020-07", "2020-08", "2020-09", "2020-10","2020-11", "2020-12", 
          "2021-01", "2021-02", "2021-03", "2021-04", "2021-05", "2021-06", "2021-07", "2021-08", "2021-09", "2021-10", "2021-11","2021-12")
filename=c("2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012",
           "2101","2102","2103","2104","2105","2106","2107","2108","2109","2110","2111","2112")

for (i in 1:length(list)){
  DF=subset(df,cal_YM==list[i])
  
  write_csv(DF, here::here("output", paste0("covid_infection_",filename[i],".csv")))
}

rm(list=ls())


