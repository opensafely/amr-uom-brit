

## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')
install.packages("Epi")
library("Epi")


df <- read_csv("/Users/yayang/Documents/GitHub/amr-uom-brit/output/input_covid_SGSS.csv")

# import data
df1 <- read_csv("/Users/yayang/Documents/GitHub/amr-uom-brit/output/input_covid_SGSS.csv")
df2 <- read_csv("/Users/yayang/Documents/GitHub/amr-uom-brit/output/input_covid_admission.csv")

df1 =df1%>%filter(patient_index_date>0) # SGSS case
df2 =df2%>%filter(patient_index_date>0) # admission case

df1$status=0
df2$status=1

df1$entry=as.Date("2020-02-01")
df2$entry=as.Date("2020-02-01")

df=rbind(df1,df2)



# cwcc matching
dfcc <- ccwc(entry    = entry,    # Time of entry to follow-up
               exit     = patient_index_date,    # Time of exit from follow-up
               fail     = status,    # Status on exit (1 = Fail, 0 = Censored)
               origin   = 0,    # Origin of analysis time scale
               controls = 1,      # The number of controls to be selected for each case
               data     = df,   # data frame
               include  = patient_id, # List of other variables to be carried across into the case-control study
               match    = list(sex,age),    # List of categorical variables on which to match cases and controls
               silent   = TRUE)




