
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate charlson comorbidity scores and baseline table for service evaluation
# # # # # # # # # # # # # # # # # # # # #

## install package
#install.packages("tableone")

## Import libraries---
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

setwd(here::here("output", "measures"))

### read data  ###
### use new synthesised .rds files for faster loading

df_input <- read_rds('basic_record_2020.rds')

df_input$date <- as.Date(df_input$date)
#df_input$cal_mon <- month(df_input$date)
#df_input$cal_year <- year(df_input$date)
 
# remove last month data
#last.date=max(df_input$date)
#df=df_input%>% filter(date!=last.date)
first_mon <- (format(min(df_input$date), "%m-%Y"))
last_mon <- (format(max(df_input$date), "%m-%Y"))
num_pats <- length(unique(df_input$patient_id))
num_pracs <- length(unique(df_input$practice))

overall_counts <- as.data.frame(cbind(first_mon, last_mon, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "overall_counts_blt_2020.csv"))
rm(overall_counts) 

## randomly select one observation for each patient 
## in the study period to generate baseline table for service evaluation
df<-df_input
df_one_pat <- df %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)

## clear environment to make more space on server...? 
rm(df_input, df)  

## create charlson index
df_one_pat$cancer_comor<- ifelse(df_one_pat$cancer_comor == 1L, 2L, 0L)
df_one_pat$cardiovascular_comor <- ifelse(df_one_pat$cardiovascular_comor == 1L, 1L, 0L)
df_one_pat$chronic_obstructive_pulmonary_comor <- ifelse(df_one_pat$chronic_obstructive_pulmonary_comor == 1L, 1L, 0)
df_one_pat$heart_failure_comor <- ifelse(df_one_pat$heart_failure_comor == 1L, 1L, 0L)
df_one_pat$connective_tissue_comor <- ifelse(df_one_pat$connective_tissue_comor == 1L, 1L, 0L)
df_one_pat$dementia_comor <- ifelse(df_one_pat$dementia_comor == 1L, 1L, 0L)
df_one_pat$diabetes_comor <- ifelse(df_one_pat$diabetes_comor == 1L, 1L, 0L)
df_one_pat$diabetes_complications_comor <- ifelse(df_one_pat$diabetes_complications_comor == 1L, 2L, 0L)
df_one_pat$hemiplegia_comor <- ifelse(df_one_pat$hemiplegia_comor == 1L, 2L, 0L)
df_one_pat$hiv_comor <- ifelse(df_one_pat$hiv_comor == 1L, 6L, 0L)
df_one_pat$metastatic_cancer_comor <- ifelse(df_one_pat$metastatic_cancer_comor == 1L, 6L, 0L)
df_one_pat$mild_liver_comor <- ifelse(df_one_pat$mild_liver_comor == 1L, 1L, 0L)
df_one_pat$mod_severe_liver_comor <- ifelse(df_one_pat$mod_severe_liver_comor == 1L, 3L, 0L)
df_one_pat$mod_severe_renal_comor <- ifelse(df_one_pat$mod_severe_renal_comor == 1L, 2L, 0L)
df_one_pat$mi_comor <- ifelse(df_one_pat$mi_comor == 1L, 1L, 0L)
df_one_pat$peptic_ulcer_comor <- ifelse(df_one_pat$peptic_ulcer_comor == 1L, 1L, 0L)
df_one_pat$peripheral_vascular_comor <- ifelse(df_one_pat$peripheral_vascular_comor == 1L, 1L, 0L)

## total charlson for each patient 
charlson=c("cancer_comor","cardiovascular_comor","chronic_obstructive_pulmonary_comor",
           "heart_failure_comor","connective_tissue_comor", "dementia_comor",
           "diabetes_comor","diabetes_complications_comor","hemiplegia_comor",
           "hiv_comor","metastatic_cancer_comor" ,"mild_liver_comor",
           "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor",
           "peptic_ulcer_comor" , "peripheral_vascular_comor" )

df_one_pat$charlson_score=rowSums(df_one_pat[charlson])

## Charlson - as a catergorical group variable
df_one_pat <- df_one_pat %>%
  mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                charlson_score >2 & charlson_score <=4 ~ 3,
                                charlson_score >4 & charlson_score <=6 ~ 4,
                                charlson_score >=7 ~ 5,
                                charlson_score == 0 ~ 1))

df_one_pat$charlsonGrp <- as.factor(df_one_pat$charlsonGrp)
df_one_pat$charlsonGrp <- factor(df_one_pat$charlsonGrp, 
                                 labels = c("zero", "low", "medium", "high", "very high"))

#bmi 
#remove very low observations
df_one_pat$bmi <- ifelse(df_one_pat$bmi <8 | df_one_pat$bmi>50, NA, df_one_pat$bmi)
# bmi categories 
df_one_pat<- df_one_pat %>% 
  mutate(bmi_cat = case_when(is.na(bmi) ~ "unknown",
                             bmi>=8 & bmi< 18.5 ~ "underweight",
                             bmi>=18.5 & bmi<=24.9 ~ "healthy weight",
                             bmi>24.9 & bmi<=29.9 ~ "overweight",
                             bmi>29.9 ~"obese"))
df_one_pat$bmi_cat<- as.factor(df_one_pat$bmi_cat)
#summary(df_one_pat$bmi_cat)

df_one_pat$age_cat<- as.factor(df_one_pat$age_cat)
df_one_pat$region<- as.factor(df_one_pat$region)

# smoking
#str(df_one_pat$smoking_status) #factor with 5 levels - so doesnt recognise missing values
df_one_pat <- df_one_pat %>% 
  mutate(smoking_cat = case_when(smoking_status=="S" ~ "current",
                                 smoking_status=="E" ~ "former",
                                 smoking_status=="N" ~ "never",
                                 smoking_status=="M"| smoking_status=="" ~ "unknown"))
df_one_pat$smoking_cat<- as.factor(df_one_pat$smoking_cat)
#summary(df_one_pat$smoking_cat)

# imd levels
#summary(df_one_pat$imd) #str(df_one_pat$imd) ## int 0,1,2,3,4,5
# make it a factor variable and 0 is missing
df_one_pat$imd<- as.factor(df_one_pat$imd)

## ethnicity
df_one_pat$ethnicity=ifelse(is.na(df_one_pat$ethnicity),"6",df_one_pat$ethnicity)
df_one_pat <- df_one_pat %>% 
  mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                 ethnicity == 2  ~ "Mixed",
                                 ethnicity == 3  ~ "South Asian",
                                 ethnicity == 4  ~ "Black",
                                 ethnicity == 5  ~ "Other",
                                 ethnicity == 6   ~ "Unknown"))
df_one_pat$ethnicity_6 <- as.factor(df_one_pat$ethnicity_6)
#table(df_one_pat$ethnicity_6)


# count of GP consultations in 12m before random index date
#summary(df_one_pat$gp_count) #negative values in dummy data
df_one_pat$gp_count <- ifelse(df_one_pat$gp_count > 0, 
                              df_one_pat$gp_count, 0)


### flu vac in 12m before random index date
#summary(df_one_pat$flu_vaccine)
df_one_pat$flu_vaccine <- as.factor(df_one_pat$flu_vaccine)


# ## Any covid vaccine
# str(df_one_pat$covrx1_dat)
# summary(df_one_pat$covrx1_dat)
# summary(df_one_pat$covrx2_dat)
df_one_pat$covrx1=ifelse(is.na(df_one_pat$covrx1_dat),0,1)
df_one_pat$covrx2=ifelse(is.na(df_one_pat$covrx2_dat),0,1)
df_one_pat$covrx=ifelse(df_one_pat$covrx1 >0 | df_one_pat$covrx2 >0, 1, 0)
df_one_pat$covrx <- as.factor(df_one_pat$covrx)
# #summary(df_one_pat$covrx)


# ever died
df_one_pat$died_ever <- ifelse(is.na(df_one_pat$died_date),0,1)
df_one_pat$died_ever <- as.factor(df_one_pat$died_ever)
#summary(df_one_pat$died_ever)

## covid positive ever
#df_one_pat$covid_positive<- df_one_pat$Covid_test_result_sgss
#df_one_pat$covid_positive<-as.factor(df_one_pat$covid_positive)
df_one_pat$Covid_test_result_sgss<- as.factor(df_one_pat$Covid_test_result_sgss)

df_one_pat$hx_indications <- as.factor(df_one_pat$hx_indications)
df_one_pat$hx_antibiotics <- as.factor(df_one_pat$hx_antibiotics)


## select variables for the baseline table
bltab_vars <- select(df_one_pat, date, age, age_cat, sex, bmi, 
                     bmi_cat, ethnicity_6, charlsonGrp, smoking_cat, 
                     flu_vaccine, gp_count, antibacterial_brit,
                     antibacterial_12mb4, broad_spectrum_antibiotics_prescriptions, 
                     Covid_test_result_sgss, imd, hx_indications, hx_antibiotics, 
                     covrx, died_ever) 
# generate data table 


# columns for baseline table
colsfortab <- colnames(bltab_vars)
bltab_vars %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "blt_one_random_obs_perpat_2020.csv"))
