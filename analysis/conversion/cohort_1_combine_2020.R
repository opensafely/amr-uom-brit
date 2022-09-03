####   This script is to combine ab_type & ab_predictor & ab_demographic ####
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

### import ab_type ###
DF <- readRDS("process_1_2020.rds")

#### recode ab_type and creat indication (sameday infection = 1/no infection = 0) ###

DF$infection=recode(DF$infection,
                    asthma ="Asthma",
                    cold="Cold",
                    cough="Cough",
                    copd="COPD",
                    pneumonia="Pneumonia",
                    renal="Renal",
                    sepsis="Sepsis",
                    throat="Sore throat",
                    uti = "UTI",
                    lrti = "LRTI",
                    urti = "URTI",
                    sinusits = "Sinusitis",
                    otmedia = "Otitis media",
                    ot_externa = "Otitis externa")
DF$infection[DF$infection == ""] <- NA
DF$indication <- ifelse(is.na(DF$infection),0,1)

### import ab_predictor ###

DF2 <- readRDS("process_2_2020.rds")
DF2 <- bind_rows(DF2)
DF2 <- dplyr::select(DF2,patient_id,date,ab_prevalent,ab_prevalent_infection, ab_repeat, ab_history)

DF <- merge(DF,DF2,by=c("patient_id","date"))
rm(DF2)

### recode the varaibles so far ###

DF$indication <- as.factor(DF$indication)
DF$ab_prevalent <- as.factor(DF$ab_prevalent)
DF$ab_prevalent_infection <- as.factor(DF$ab_prevalent_infection)
DF$ab_repeat <- as.factor(DF$ab_repeat)
DF$ab_history <- ifelse(is.na(DF$ab_history),0,DF$ab_history)
DF<- DF %>% 
  mutate(antibiotics_12mb4 = case_when(ab_history >=3 ~ "3+",
                             ab_history == 2  ~ "2",
                             ab_history == 1  ~ "1",
                             ab_history == 0  ~ "0"))
DF$antibiotics_12mb4<- as.factor(DF$antibiotics_12mb4)

DF <- DF %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                          age>=16 & age<=44 ~ "16-44",
                                          age>=45 & age<=64 ~ "45-64",
                                          age>=65 ~ "65+"))  


### import ab_demographic ###

setwd(here::here("output"))

DF3 <- readRDS("demographic_2020.rds")

DF <- left_join(DF,DF3, by = "patient_id")

saveRDS(DF, "combined_c1_2020.rds")

DF_check <- dplyr::select(DF,type,infection,indication,age_group,sex,ab_prevalent,ab_prevalent_infection,ab_repeat,
antibiotics_12mb4,ethnicity_6,imd,region,charlsonGrp)

colsfortab <- colnames(DF_check)
DF_check %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "combined_c1_2020_chekc.csv"))

