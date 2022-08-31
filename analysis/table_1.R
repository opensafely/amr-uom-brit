## Import libraries---
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

### 2019

rm(list=ls())
setwd(here::here("output"))

df <- read_csv(("input_patient_characteristics_2019.csv.gz"),
                 col_types = cols_only(
                   age = col_integer(),
                   age_cat = col_character(),
                   sex = col_character(),
                   practice = col_integer(),
                   ethnicity = col_integer(),
                   region = col_character(),
                   imd = col_integer(),
                   Tested_for_covid_event = col_integer(),
                   Positive_test_event = col_integer(),
                   patient_id = col_integer()
                 ),
                 na = character())

num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))
overall_counts <- as.data.frame(cbind(num_pats,num_pracs))
write_csv(overall_counts, here::here("output", "table1_2019_overallcount.csv"))


# generate data table 
DF <- select(df,age,sex,imd,region,ethnicity,Tested_for_covid_event,Positive_test_event)

# imd levels
# int 0,1,2,3,4,5
# make it a factor variable and 0 is missing
DF$imd <- ifelse(is.na(DF$imd),"0",DF$imd)
DF$imd <- as.factor(DF$imd)

## ethnicity                                         
DF$ethnicity=ifelse(is.na(DF$ethnicity),"0",DF$ethnicity)
DF <- DF %>% 
  mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                 ethnicity == 2 ~ "Mixed",
                                 ethnicity == 3 ~ "Asian or Asian British",
                                 ethnicity == 4 ~ "Black or Black British",
                                 ethnicity == 5 ~ "Other Ethnic Groups",
                                 ethnicity == 0 ~ "Unknown"))

DF$ethnicity_6 <- as.factor(DF$ethnicity_6)    
DF$Tested_for_covid_event <- as.factor(DF$Tested_for_covid_event)
DF$Positive_test_event <- as.factor(DF$Positive_test_event)
DF <- DF %>% mutate(age_group = case_when(age<18 ~ "<18",
                                          age>=18 & age<=64 ~ "18-64",
                                          age>=65 ~ ">64"))  
                                       
                                          
dttable <- select(DF,age_group,sex,imd,region,ethnicity_6,Tested_for_covid_event,Positive_test_event)

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "table1_2019.csv"))