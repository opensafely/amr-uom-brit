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
DF <- DF %>% filter(date <= as.Date("2021-12-31"))
DF <- DF %>% filter(age > 3)
setwd(here::here("output"))
df2.1 <- read_csv("prepared_var_2019.csv") %>% select(-c(age,sex))
df2.2 <- read_csv("prepared_var_2020.csv") %>% select(-c(age,sex))
df2.3 <- read_csv("prepared_var_2021.csv") %>% select(-c(age,sex))
df2 <- rbind(df2.1,df2.2,df2.3)
df <- merge(DF,df2,by=c("patient_id"))
rm(DF,df2)





### outcome 1: no repeat, ab type ok 
### outcome 2: no repeat, ab type not ok 
### outcome 3: repeat


utitype <- c("Amoxicillin", "Ampicillin", "Cefaclor", "Cefadroxil", "Cefalexin",
 "Cefazolin", "Cefixime", "Cefoxitin", "Cefprozil", "Cefradine", "Ceftazidime",
  "Ceftriaxone", "Cefuroxime", "Ceftazidime", "Ceftriaxone", "Chloramphenicol",
   "Co-amoxiclav", "Fosfomycin", "Levofloxacin", "Norfloxacin", "Ofloxacin", "Pivampicillin", "Trimethoprim",
    "Nitrofurantoin" )

df1 <- df %>% filter(incidental==1) %>% filter(infection== "UTI")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% utitype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% utitype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "uti_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "uti_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)

