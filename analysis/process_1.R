
# # # # # # # # # # # # # # # # # # # # #
#              This script:             #
#           define case cohort          #
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
col_spec_1 <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        stp = col_character(),
                        region = col_character(),
                        has_outcome_1yr = col_number(),
                        uti_record = col_number(),
                        lrti_record = col_number(),
                        urti_record = col_number(),
                        sinusitis_record = col_number(),
                        ot_externa_record = col_number(),
                        ot_media_record = col_number(),
                        pneumonia_record = col_number(),
                        patient_id = col_number()
)

col_spec_2 <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        stp = col_character(),
                        region = col_character(),
                        has_outcome_1yr = col_number(),
                        has_outcome_6weekafter = col_number(),
                        uti_record = col_number(),
                        lrti_record = col_number(),
                        urti_record = col_number(),
                        sinusitis_record = col_number(),
                        ot_externa_record = col_number(),
                        ot_media_record = col_number(),
                        pneumonia_record = col_number(),
                        patient_id = col_number()
)

df <- read_csv(here::here("output", "input_case.csv"),
                col_types = col_spec_1)

df_match <- read_csv(here::here("output", "input_control.csv"),
                col_types = col_spec_2)


# filter cohort (defalut)
df = df %>% filter(!is.na(patient_index_date)) 

# check cohort_case
dttable <- select(df,age,sex,stp,region,has_outcome_1yr,uti_record,lrti_record,urti_record,sinusitis_record,ot_externa_record,
ot_media_record,pneumonia_record)
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
write_csv(t, here::here("output", "table_case_0.csv"))

df_1 <- df %>% filter(has_outcome_1yr == "0")
dttable_1 <- select(df_1,age,sex,stp,region,uti_record,lrti_record,urti_record,sinusitis_record,ot_externa_record,
ot_media_record,pneumonia_record)
colsfortab_1 <- colnames(dttable_1)
dttable_1 %>% summary_factorlist(explanatory = colsfortab_1) -> t1
write_csv(t1, here::here("output", "table_case_1.csv"))


# filter cohort (defalut)
df_match = df_match %>% filter(!is.na(patient_index_date)) 

# check cohort_control
dt <- select(df_match,age,sex,stp,region,has_outcome_1yr,has_outcome_6weekafter,uti_record,lrti_record,urti_record,sinusitis_record,ot_externa_record,
ot_media_record,pneumonia_record)
coldt <- colnames(dt)
dt %>% summary_factorlist(explanatory = coldt) -> t2
write_csv(t2, here::here("output", "table_control_0.csv"))


df_match_1 <- df_match %>% filter(has_outcome_6weekafter == "0")
df_match_1 <- df_match_1 %>% filter(has_outcome_1yr == "0")
dt_1 <- select(df_match_1,age,sex,stp,region,uti_record,lrti_record,urti_record,sinusitis_record,ot_externa_record,
ot_media_record,pneumonia_record)
coldt_1 <- colnames(dt_1)
dt_1 %>% summary_factorlist(explanatory = coldt_1) -> t3
write_csv(t3, here::here("output", "table_control_1.csv"))

## select urti for matching ##

case_csv <- df_1 %>% filter (urti_record == "1")

match_csv <- df_match_1 %>% filter (urti_record == "1")

write_csv(case_csv, here::here("output", "case_csv.csv"))
write_csv(match_csv, here::here("output", "match_csv.csv"))
