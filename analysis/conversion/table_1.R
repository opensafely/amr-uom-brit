library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

setwd(here::here("output"))

### import 2019 demographic information ###

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

## region: replace "" with NA --> Unknown
df_input$region[df_input$region == ""] <- NA
df_input$region=ifelse(is.na(df_input$region),"Unknown",df_input$region)

## select variables for cohort 1
df1 <- select(df_input,patient_id,imd,region,charlsonGrp,ethnicity_6,practice) 
saveRDS(df1, "demographic_2019.rds")
num_pats_2019 <- length(unique(df1$patient_id))
num_prac_2019 <- length(unique(df1$practice))

rm(df_input)

### import 2020 demographic information ###

df_input <- read_csv("input_ab_demographic_2020.csv",
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

## region: replace "" with NA --> Unknown
df_input$region[df_input$region == ""] <- NA
df_input$region=ifelse(is.na(df_input$region),"Unknown",df_input$region)

## select variables for cohort 1
df2 <- select(df_input,patient_id,imd,region,charlsonGrp,ethnicity_6,practice) 
saveRDS(df2, "demographic_2020.rds")
num_pats_2020 <- length(unique(df2$patient_id))
num_prac_2020 <- length(unique(df2$practice))

rm(df_input)

### import 2021 demographic information ###

df_input <- read_csv("input_ab_demographic_2021.csv",
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

## region: replace "" with NA --> Unknown
df_input$region[df_input$region == ""] <- NA
df_input$region=ifelse(is.na(df_input$region),"Unknown",df_input$region)

## select variables for cohort 1
df3 <- select(df_input,patient_id,imd,region,charlsonGrp,ethnicity_6,practice) 
saveRDS(df3, "demographic_2021.rds")
num_pats_2021 <- length(unique(df3$patient_id))
num_prac_2021 <- length(unique(df3$practice))

rm(df_input)


### combine 3 year records ###

DF <- bind_rows(df1,df2,df3)

num_pats_all <- length(unique(DF$patient_id))
num_prac_all <- length(unique(DF$practice))




overall_counts <- as.data.frame(cbind(num_pats_2019,num_prac_2019,num_pats_2020,num_prac_2020,
num_pats_2021,num_prac_2021,num_pats_all,num_prac_all))

write_csv(overall_counts, here::here("output", "table_1_pat_prac.csv"))

