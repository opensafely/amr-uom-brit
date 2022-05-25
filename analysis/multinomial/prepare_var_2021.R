### This script is for preparing the variables for repeat antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output"))

df_input <- read_csv("input_demographic_2021.csv",
               col_types = cols_only(
                 patient_id = col_integer(),
                 patient_index_date = col_date(format = ""),
                 age = col_integer(),
                 sex = col_character(),
                 stp = col_character(),
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


# remove last month data
#last.date=max(df_input$date)
#df=df_input%>% filter(date!=last.date)
first_mon <- (format(min(df_input$patient_index_date), "%m-%Y"))
last_mon <- (format(max(df_input$patient_index_date), "%m-%Y"))
num_pats <- length(unique(df_input$patient_id))
num_pracs <- length(unique(df_input$practice))

overall_counts <- as.data.frame(cbind(first_mon, last_mon, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "prepare_var_count_2021.csv"))
rm(overall_counts) 

## randomly select one observation for each patient 
## in the study period to generate baseline table for service evaluation

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
#summary(df_one_pat$imd) #str(df_one_pat$imd) ## int 0,1,2,3,4,5
# make it a factor variable and 0 is missing
df_input$imd<- as.factor(df_input$imd)

## ethnicity
df_input$ethnicity=ifelse(is.na(df_input$ethnicity),"6",df_input$ethnicity)
df_input <- df_input %>% 
  mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                 ethnicity == 2  ~ "Mixed",
                                 ethnicity == 3  ~ "South Asian",
                                 ethnicity == 4  ~ "Black",
                                 ethnicity == 5  ~ "Other",
                                 ethnicity == 6   ~ "Unknown"))
df_input$ethnicity_6 <- as.factor(df_input$ethnicity_6)


## select variables for the baseline table
df <- select(df_input, patient_id, patient_index_date, age, sex, ethnicity,imd, 
             practice, region, charlsonGrp, ethnicity_6) 
rm(df_input)
write_csv(df, here::here("output", "prepared_var_2021.csv"))
rm(df_input)
# generate data table 
dttable <- select(df, age, sex, ethnicity, imd , 
                  region, charlsonGrp, ethnicity_6) 

# columns for baseline table
colsfortab <- colnames(dttable)
dttable %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "blt_var_2021.csv"))