### This script is for preparing the variables for repeat antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

DF <- readRDS("cleaned_indication_ab.rds")

# recode
DF$date <- as.Date(DF$date)
DF <- DF %>% filter(date <= as.Date("2019-12-31"))
DF <- DF %>% filter(age > 3)
setwd(here::here("output"))
df2 <- read_csv("prepared_var_2019.csv") %>% select(-c(age,sex))
df <- merge(DF,df2,by=c("patient_id"))
rm(DF,df2)

lrtitype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Azithromycin", "Erythromycin",
              "Levofloxacin", "Co-amoxiclav", "Ofloxacin", "Moxifloxacin", "Ciprofloxacin")



### outcome 1: no repeat, ab type ok 
### outcome 2: no repeat, ab type not ok 
### outcome 3: repeat
df1 <- df %>% filter(incidental==1) %>% filter(infection== "LRTI")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% lrtitype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% lrtitype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "lrti_outcome_2019.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "lrti_count_2019.csv"))