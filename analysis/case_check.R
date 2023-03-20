
# # # # # # # # # # # # # # # # # # # # #
#              This script:             #
#            check case cohort          #
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

# import data
col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        historic_sepsis_gp = col_number(),
                        historic_sepsis_hosp = col_number(),
                        had_sepsis_within_2day = col_number(),
                        SGSS_positive_6weeks = col_number(),
                        GP_positive_6weeks = col_number(),
                        covid_admission_6weeks = col_number(),                 
                        patient_id = col_number()
)

df <- read_csv(here::here("output", "input_case.csv"),
                col_types = col_spec)

df <- df %>% filter(patient_index_date <= as.Date("2022-06-30"))

# raw count in step 0 #
step0 <- length(df$patient_id)
# Identify incident sepsis only, Check any historic record of sepsis in their GP & Hosp record (14 days)#
df <- df %>% mutate(incident_sepsis = case_when(historic_sepsis_gp == 0 & historic_sepsis_hosp == 0 ~ "1",
                                                historic_sepsis_gp == 0 & historic_sepsis_hosp == 1 ~ "0",
                                                historic_sepsis_gp == 1 & historic_sepsis_hosp == 0 ~ "0",
                                                historic_sepsis_gp == 1 & historic_sepsis_hosp == 1 ~ "0"))

df <- df %>% filter (incident_sepsis == 1)
step1 <- length(df$patient_id)

# Identify cases without COVID-19 infection only
df$noCOVID <- ifelse(df$SGSS_positive_6weeks == 0 & df$GP_positive_6weeks == 0 & df$covid_admission_6weeks ==0,1,0)
df <- df %>% filter (noCOVID == 1)
step2 <- length(df$patient_id)

#Check Community-acquired sepsis or hospital-acquired sepsis
#1--community 2-- hospital #
df$sepsis_type <- ifelse(df$had_sepsis_within_2day == 0,1,2)

write_csv(df, here::here("output", "case_ch.csv"))

df <- df %>% filter(sepsis_type == 1) 
step3 <- length(df$patient_id)

t <- as.data.frame(cbind(step0,step1,step2,step3))
write_csv(t, here::here("output", "case_check.csv"))

# frequency check
DF_check <- select(df,sex,region,imd)
DF_check$imd <- as.factor(DF_check$imd)
colsfortab <- colnames(DF_check)
DF_check %>% summary_factorlist(explanatory = colsfortab) -> t1

write_csv(t1, here::here("output", "case_frequency_check.csv"))
