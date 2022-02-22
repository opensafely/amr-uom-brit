# duplicated patient id can't extract cohort 
# split case and control


library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')


rm(list=ls())
setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")

#"2002"no case
filename=c("2003","2004","2005","2006","2007","2008","2009","2010","2011","2012",
           "2101","2102","2103","2104","2105","2106","2107","2108","2109","2110","2111","2112")

datelist=seq(as.Date("2020-03-01"), by = "month", length.out = 22)



for (i in 1:length(filename)){

df=read_csv(paste0("matched_combined_general_population_infection_",filename[i],".csv"))

case= df%>% filter(case==1)

control= df%>% filter(case==0)
control$patient_index_date=as.Date(datelist[i])


write_csv(case, here::here("output", paste0("matched_outcome_1_case_",filename[i],".csv")))

write_csv(control, here::here("output", paste0("matched_outcome_1_control_",filename[i],".csv")))

rm(df,case,control)
}