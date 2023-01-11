
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
col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        stp = col_character(),
                        region = col_character(),
                        imd = col_integer(),
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

df <- read_csv(here::here("output", "input_sepsis_2019.csv"),
                col_types = col_spec)


# filter cohort (defalut)
df = df %>% filter(!is.na(patient_index_date)) 
df$imd <- ifelse(is.na(df$imd),"0",df$imd)
df$imd <- as.factor(df$imd)
# check cohort_case
dttable <- select(df,age,sex,stp,region,imd,has_outcome_1yr,uti_record,lrti_record,urti_record,sinusitis_record,ot_externa_record,
ot_media_record,pneumonia_record)
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
write_csv(t, here::here("output", "table_sepsis_2019_0.csv"))

df_1 <- df %>% filter(has_outcome_1yr == "0")
dttable_1 <- select(df_1,age,sex,stp,region,imd,uti_record,lrti_record,urti_record,sinusitis_record,ot_externa_record,
ot_media_record,pneumonia_record)
colsfortab_1 <- colnames(dttable_1)
dttable_1 %>% summary_factorlist(explanatory = colsfortab_1) -> t1
write_csv(t1, here::here("output", "table_sepsis_2019_1.csv"))

