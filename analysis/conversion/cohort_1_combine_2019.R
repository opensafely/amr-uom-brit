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
DF <- readRDS("process_1_2019.rds")

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

DF2 <- readRDS("process_2_2019.rds")
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

df_input <- read_csv("input_ab_demographic_2019.csv",
               col_types = cols_only(
                 patient_id = col_integer(),
                 patient_index_date = col_date(format = ""),
                 ethnicity = col_integer(),
                 imd = col_integer(),
                 practice = col_integer(),
                 region = col_character(),
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
                 peripheral_vascular_comor = col_integer()
               ),
               na = character())



## create charlson index
df_input$cancer_comor<- ifelse(df_input$cancer_comor == 1L, 2L, 0L)
df_input$cardiovascular_comor <- ifelse(df_input$cardiovascular_comor == 1L, 1L, 0L)
df_input$chronic_obstructive_pulmonary_comor <- ifelse(df_input$chronic_obstructive_pulmonary_comor == 1L, 1L, 0)
df_input$heart_failure_comor <- ifelse(df_input$heart_failure_comor == 1L, 1L, 0L)
df_input$connective_tissue_comor <- ifelse(df_input$connective_tissue_comor == 1L, 1L, 0L)
df_input$dementia_comor <- ifelse(df_input$dementia_comor == 1L, 1L, 0L)
df_input$diabetes_comor <- ifelse(df_input$diabetes_comor == 1L, 1L, 0L)
df_input$diabetes_complications_comor <- ifelse(df_input$diabetes_complications_comor == 1L, 2L, 0L)
df_input$hemiplegia_comor <- ifelse(df_input$hemiplegia_comor == 1L, 2L, 0L)
df_input$hiv_comor <- ifelse(df_input$hiv_comor == 1L, 6L, 0L)
df_input$metastatic_cancer_comor <- ifelse(df_input$metastatic_cancer_comor == 1L, 6L, 0L)
df_input$mild_liver_comor <- ifelse(df_input$mild_liver_comor == 1L, 1L, 0L)
df_input$mod_severe_liver_comor <- ifelse(df_input$mod_severe_liver_comor == 1L, 3L, 0L)
df_input$mod_severe_renal_comor <- ifelse(df_input$mod_severe_renal_comor == 1L, 2L, 0L)
df_input$mi_comor <- ifelse(df_input$mi_comor == 1L, 1L, 0L)
df_input$peptic_ulcer_comor <- ifelse(df_input$peptic_ulcer_comor == 1L, 1L, 0L)
df_input$peripheral_vascular_comor <- ifelse(df_input$peripheral_vascular_comor == 1L, 1L, 0L)

## total charlson for each patient 
charlson=c("cancer_comor","cardiovascular_comor","chronic_obstructive_pulmonary_comor",
           "heart_failure_comor","connective_tissue_comor", "dementia_comor",
           "diabetes_comor","diabetes_complications_comor","hemiplegia_comor",
           "hiv_comor","metastatic_cancer_comor" ,"mild_liver_comor",
           "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor",
           "peptic_ulcer_comor" , "peripheral_vascular_comor" )

df_input$charlson_score=rowSums(df_input[charlson])

## Charlson - as a catergorical group variable
df_input <- df_input %>%
  mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                 charlson_score >2 & charlson_score <=4 ~ 3,
                                 charlson_score >4 & charlson_score <=6 ~ 4,
                                 charlson_score >=7 ~ 5,
                                 charlson_score == 0 ~ 1))

df_input$charlsonGrp <- as.factor(df_input$charlsonGrp)
df_input$charlsonGrp <- factor(df_input$charlsonGrp, 
                                 labels = c("zero", "low", "medium", "high", "very high"))
df_input <- select(df_input,-all_of(charlson))
df_input$region<- as.factor(df_input$region)


# imd levels
# int 0,1,2,3,4,5
# make it a factor variable and 0 is missing
df_input$imd <- ifelse(is.na(df_input$imd),"0",df_input$imd)
df_input$imd <- as.factor(df_input$imd)

## ethnicity
df_input$ethnicity=ifelse(is.na(df_input$ethnicity),"0",df_input$ethnicity)
df_input <- df_input %>% 
  mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                 ethnicity == 2 ~ "Mixed",
                                 ethnicity == 3 ~ "Asian or Asian British",
                                 ethnicity == 4 ~ "Black or Black British",
                                 ethnicity == 5 ~ "Other Ethnic Groups",
                                 ethnicity == 0 ~ "Unknown"))
df_input$ethnicity_6 <- as.factor(df_input$ethnicity_6)

## region: replace "" with NA
df_input$region[df_input$region == ""] <- NA

## select variables for cohort 1
df <- select(df_input,patient_id,ethnicity,imd,region,charlsonGrp,ethnicity_6,practice) 

DF <- left_join(DF,df, by = "patient_id")

saveRDS(DF, "combined_c1_2019.rds")

DF_check <- select(DF,type,infection,indication,age_group,sex,ab_prevalent,ab_prevalent_infection,ab_repeat,
antibiotics_12mb4,ethnicity_6,imd,region,charlsonGrp)

colsfortab <- colnames(DF_check)
DF_check %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "combined_c1_2019_check.csv"))