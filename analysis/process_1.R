
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
                        cancer_comor = col_integer(),
                        cardiovascular_comor = col_integer(),
                        chronic_obstructive_pulmonary_comor = col_integer(),
                        heart_failure_comor = col_integer(),
                        connective_tissue_comor = col_integer(),
                        dementia_comor = col_integer(),
                        diabetes_comor = col_integer(),
                        diabetes_complications_comor = col_integer(),
                        hemiplegia_comor = col_integer(),
                        hiv_comor = col_integer(),
                        metastatic_cancer_comor = col_integer(),
                        mild_liver_comor = col_integer(),
                        mod_severe_liver_comor = col_integer(),
                        mod_severe_renal_comor = col_integer(),
                        mi_comor = col_integer(),
                        peptic_ulcer_comor = col_integer(),
                        peripheral_vascular_comor = col_integer(),                      
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
                        cancer_comor = col_integer(),
                        cardiovascular_comor = col_integer(),
                        chronic_obstructive_pulmonary_comor = col_integer(),
                        heart_failure_comor = col_integer(),
                        connective_tissue_comor = col_integer(),
                        dementia_comor = col_integer(),
                        diabetes_comor = col_integer(),
                        diabetes_complications_comor = col_integer(),
                        hemiplegia_comor = col_integer(),
                        hiv_comor = col_integer(),
                        metastatic_cancer_comor = col_integer(),
                        mild_liver_comor = col_integer(),
                        mod_severe_liver_comor = col_integer(),
                        mod_severe_renal_comor = col_integer(),
                        mi_comor = col_integer(),
                        peptic_ulcer_comor = col_integer(),
                        peripheral_vascular_comor = col_integer(),  
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

## create charlson index
case_csv$cancer_comor<- ifelse(case_csv$cancer_comor == 1L, 2L, 0L)
case_csv$cardiovascular_comor <- ifelse(case_csv$cardiovascular_comor == 1L, 1L, 0L)
case_csv$chronic_obstructive_pulmonary_comor <- ifelse(case_csv$chronic_obstructive_pulmonary_comor == 1L, 1L, 0)
case_csv$heart_failure_comor <- ifelse(case_csv$heart_failure_comor == 1L, 1L, 0L)
case_csv$connective_tissue_comor <- ifelse(case_csv$connective_tissue_comor == 1L, 1L, 0L)
case_csv$dementia_comor <- ifelse(case_csv$dementia_comor == 1L, 1L, 0L)
case_csv$diabetes_comor <- ifelse(case_csv$diabetes_comor == 1L, 1L, 0L)
case_csv$diabetes_complications_comor <- ifelse(case_csv$diabetes_complications_comor == 1L, 2L, 0L)
case_csv$hemiplegia_comor <- ifelse(case_csv$hemiplegia_comor == 1L, 2L, 0L)
case_csv$hiv_comor <- ifelse(case_csv$hiv_comor == 1L, 6L, 0L)
case_csv$metastatic_cancer_comor <- ifelse(case_csv$metastatic_cancer_comor == 1L, 6L, 0L)
case_csv$mild_liver_comor <- ifelse(case_csv$mild_liver_comor == 1L, 1L, 0L)
case_csv$mod_severe_liver_comor <- ifelse(case_csv$mod_severe_liver_comor == 1L, 3L, 0L)
case_csv$mod_severe_renal_comor <- ifelse(case_csv$mod_severe_renal_comor == 1L, 2L, 0L)
case_csv$mi_comor <- ifelse(case_csv$mi_comor == 1L, 1L, 0L)
case_csv$peptic_ulcer_comor <- ifelse(case_csv$peptic_ulcer_comor == 1L, 1L, 0L)
case_csv$peripheral_vascular_comor <- ifelse(case_csv$peripheral_vascular_comor == 1L, 1L, 0L)

## total charlson for each patient 
charlson=c("cancer_comor","cardiovascular_comor","chronic_obstructive_pulmonary_comor",
           "heart_failure_comor","connective_tissue_comor", "dementia_comor",
           "diabetes_comor","diabetes_complications_comor","hemiplegia_comor",
           "hiv_comor","metastatic_cancer_comor" ,"mild_liver_comor",
           "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor",
           "peptic_ulcer_comor" , "peripheral_vascular_comor" )

case_csv$charlson_score=rowSums(case_csv[charlson])

## Charlson - as a catergorical group variable
case_csv <- case_csv %>%
  mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                 charlson_score >2 & charlson_score <=4 ~ 3,
                                 charlson_score >4 & charlson_score <=6 ~ 4,
                                 charlson_score >=7 ~ 5,
                                 charlson_score == 0 ~ 1))

case_csv$charlsonGrp <- as.factor(case_csv$charlsonGrp)
case_csv$charlsonGrp <- factor(case_csv$charlsonGrp, 
                                 labels = c("zero", "low", "medium", "high", "very high"))
case_csv <- select(case_csv,-all_of(charlson))

write_csv(case_csv, here::here("output", "case_csv.csv"))

## create charlson index
match_csv$cancer_comor<- ifelse(match_csv$cancer_comor == 1L, 2L, 0L)
match_csv$cardiovascular_comor <- ifelse(match_csv$cardiovascular_comor == 1L, 1L, 0L)
match_csv$chronic_obstructive_pulmonary_comor <- ifelse(match_csv$chronic_obstructive_pulmonary_comor == 1L, 1L, 0)
match_csv$heart_failure_comor <- ifelse(match_csv$heart_failure_comor == 1L, 1L, 0L)
match_csv$connective_tissue_comor <- ifelse(match_csv$connective_tissue_comor == 1L, 1L, 0L)
match_csv$dementia_comor <- ifelse(match_csv$dementia_comor == 1L, 1L, 0L)
match_csv$diabetes_comor <- ifelse(match_csv$diabetes_comor == 1L, 1L, 0L)
match_csv$diabetes_complications_comor <- ifelse(match_csv$diabetes_complications_comor == 1L, 2L, 0L)
match_csv$hemiplegia_comor <- ifelse(match_csv$hemiplegia_comor == 1L, 2L, 0L)
match_csv$hiv_comor <- ifelse(match_csv$hiv_comor == 1L, 6L, 0L)
match_csv$metastatic_cancer_comor <- ifelse(match_csv$metastatic_cancer_comor == 1L, 6L, 0L)
match_csv$mild_liver_comor <- ifelse(match_csv$mild_liver_comor == 1L, 1L, 0L)
match_csv$mod_severe_liver_comor <- ifelse(match_csv$mod_severe_liver_comor == 1L, 3L, 0L)
match_csv$mod_severe_renal_comor <- ifelse(match_csv$mod_severe_renal_comor == 1L, 2L, 0L)
match_csv$mi_comor <- ifelse(match_csv$mi_comor == 1L, 1L, 0L)
match_csv$peptic_ulcer_comor <- ifelse(match_csv$peptic_ulcer_comor == 1L, 1L, 0L)
match_csv$peripheral_vascular_comor <- ifelse(match_csv$peripheral_vascular_comor == 1L, 1L, 0L)

match_csv$charlson_score=rowSums(match_csv[charlson])

## Charlson - as a catergorical group variable
match_csv <- match_csv %>%
  mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                 charlson_score >2 & charlson_score <=4 ~ 3,
                                 charlson_score >4 & charlson_score <=6 ~ 4,
                                 charlson_score >=7 ~ 5,
                                 charlson_score == 0 ~ 1))

match_csv$charlsonGrp <- as.factor(match_csv$charlsonGrp)
match_csv$charlsonGrp <- factor(match_csv$charlsonGrp, 
                                 labels = c("zero", "low", "medium", "high", "very high"))
match_csv <- select(match_csv,-all_of(charlson))


write_csv(match_csv, here::here("output", "match_csv.csv"))
