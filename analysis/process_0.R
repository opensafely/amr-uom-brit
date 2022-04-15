# # # # # # # # # # # # # # # # # # # # #
# This script:
# exclude COVID case in general population
# for extract patients who have not develope  to COVID
# 
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')



rm(list=ls())
setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")


filename=c("2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012",
           "2101","2102","2103","2104","2105","2106","2107","2108","2109","2110","2111","2112")
# date list
datelist= seq(as.Date("2020-02-01"), as.Date("2021-12-01"), "month")

for (i in 1:length(filename)){
  DF=read_csv( paste0("input_general_population_",filename[i],".csv"))
  
  DF=DF%>%
    filter(is.na(primary_care_covid_date),
           is.na(SGSS_positive_test_date),
           is.na(covid_admission_date),
           is.na(died_date_cpns), 
           is.na(died_date_ons_covid))
  
  DF$patient_index_date=datelist[i]
  
  write_csv(DF, here::here("output", paste0("general_population_",filename[i],".csv")))
  
  rm(DF)
}



