# duplicated patient id can't extract cohort 
# split case and control


library('tidyverse')
library("ggplot2")
library('plyr')
library('dplyr')
library('lubridate')


rm(list=ls())
setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")

#"2002"no case
filename=c("2003","2004","2005","2006","2007","2008","2009","2010","2011","2012",
           "2101","2102","2103","2104","2105","2106","2107","2108","2109","2110","2111","2112")

datelist=seq(as.Date("2020-03-01"), by = "month", length.out = 22)


#  monthly controls
for (i in 1:length(filename)){

df=read_csv(paste0("matched_combined_general_population_infection_",filename[i],".csv"))


control= df%>% dplyr::filter(case==0)
control$patient_index_date=as.Date(datelist[i]) # original index date

write_csv(control, here::here("output", paste0("matched_outcome_1_control_",filename[i],".csv")))

rm(df,control)
}



# all cases

temp <- vector("list", length(filename))

for (i in 1:length(filename)){
  
  df=read_csv(paste0("matched_combined_general_population_infection_",filename[i],".csv"))
  
  case= df%>% dplyr::filter(case==1)
  
  temp[[i]] =case
  
  rm(df,case)
}

case=plyr::ldply(temp, data.frame)

write_csv(case, here::here("output", "matched_outcome_1_case.csv"))