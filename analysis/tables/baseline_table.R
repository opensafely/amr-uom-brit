
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate charlson comorbidity scores and baseline table for service evaluation
# # # # # # # # # # # # # # # # # # # # #

## install package
#install.packages("tableone")

## Import libraries---
library("tidyverse") 
#library("ggplot2")
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
#library("finalfit")
#library("tableone")
#library("gtsummary")

setwd(here::here("output", "measures"))

### read data  ###
### 1.1 import patient-level data(study definition input.csv) to summarize antibiotics counts
############ loop reading multiple CSV files ################
# read file list from input.csv
csvFiles = list.files(pattern="input_2", full.names = TRUE)
temp <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles)){
  filename <- csvFiles[i]
  temp_df <- read_csv(filename)
  filename <- basename(filename)
  filename <-str_remove(filename, "input_")
  filename <-str_remove(filename, ".csv.gz")
  
  #add to per-month temp df
  temp_df$date <- filename
  mutate(temp_df, date = as.Date(date, "%Y-%m-%d"))
  
  #add df to list
  temp[[i]] <- temp_df
}

# combine list -> data.table/data.frame
df_input <- rbindlist(temp, fill=TRUE)
rm(temp,csvFiles,i)# remove temporary list

## select rows of interest
#df_input <- select(df_input, age, sex, region, ethnicity, antibacterial_12mb4, date)

df_input$date <- as.Date(df_input$date)
df_input$cal_mon <- month(df_input$date)
df_input$cal_year <- year(df_input$date)
 
# remove last month data
last.date=max(df_input$date)
df=df_input%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))
num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))

overall_counts <- as.data.frame(cbind(first_mon, last_mon, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "overall_counts_blt.csv"))
  
  
## randomly select one observation for each patient 
## in the study period to generate baseline table for service evaluation
df_one_pat <- df %>% group_by(patient_id) %>%
  arrange(date, .group_by=TRUE) %>%
  sample_n(1)

## create charlson index
df_one_pat$cancer<- ifelse(df_one_pat$cancer_comor == 1, 2, 0)
df_one_pat$cvd <- ifelse(df_one_pat$cerebrovascular_comor == 1, 1, 0)
df_one_pat$copd <- ifelse(df_one_pat$chronic_obstructive_pulmonary_comor == 1, 1, 0)
df_one_pat$heart_failure <- ifelse(df_one_pat$heart_failure_comor == 1, 1, 0)
df_one_pat$connective_tissue <- ifelse(df_one_pat$connective_tissue_comor == 1, 1, 0)
df_one_pat$dementia <- ifelse(df_one_pat$dementia_comor == 1, 1, 0)
df_one_pat$diabetes <- ifelse(df_one_pat$diabetes_comor == 1, 1, 0)
df_one_pat$diabetes_complications <- ifelse(df_one_pat$diabetes_complications_comor == 1, 2, 0)
df_one_pat$hemiplegia <- ifelse(df_one_pat$hemiplegia_comor == 1, 2, 0)
df_one_pat$hiv <- ifelse(df_one_pat$hiv_comor == 1, 6, 0)
df_one_pat$metastatic_cancer <- ifelse(df_one_pat$metastatic_cancer_comor == 1, 6, 0)
df_one_pat$mild_liver <- ifelse(df_one_pat$mild_liver_comor == 1, 1, 0)
df_one_pat$mod_severe_liver <- ifelse(df_one_pat$mod_severe_liver_comor == 1, 3, 0)
df_one_pat$mod_severe_renal <- ifelse(df_one_pat$mod_severe_renal_comor == 1, 2, 0)
df_one_pat$mi <- ifelse(df_one_pat$mi_comor == 1, 1, 0)
df_one_pat$peptic_ulcer <- ifelse(df_one_pat$peptic_ulcer_comor == 1, 1, 0)
df_one_pat$peripheral_vascular <- ifelse(df_one_pat$peripheral_vascular_comor == 1, 1, 0)

## total charlson for each patient 
charlson=c("cancer","cvd", "copd", "heart_failure", "connective_tissue",
        "dementia", "diabetes", "diabetes_complications", "hemiplegia",
        "hiv", "metastatic_cancer", "mild_liver", "mod_severe_liver", 
        "mod_severe_renal", "mi", "peptic_ulcer", "peripheral_vascular")
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
                             bmi< 18.5 ~ "underweight",
                             bmi>=18.5 & bmi<24.9 ~ "healthy weight",
                             bmi>=25 & bmi<29.9 ~ "overweight",
                             bmi>30 ~"obese"))
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
#summary(df_one_pat$gp_count)
df_one_pat$gp_count <- ifelse(df_one_pat$gp_count > 0, 
                              df_one_pat$gp_count, 0)


### flu vac in 12m before random index date
#summary(df_one_pat$flu_vaccine)
df_one_pat$flu_vaccine <- as.factor(df_one_pat$flu_vaccine)


## Any covid vaccine
df_one_pat$covrx1=ifelse(df_one_pat$covrx1_dat>0,1,0)
df_one_pat$covrx2=ifelse(df_one_pat$covrx2_dat>0,1,0)
df_one_pat$covrx=ifelse(df_one_pat$covrx1>0|df_one_pat$covrx2>0,1,0)
df_one_pat$covrx<-as.factor(df_one_pat$covrx)
#str(df_one_pat$covrx)

# ever died
df_one_pat$died_ever <- ifelse(df_one_pat$died_date != "", 1, 0)
df_one_pat$died_ever <- as.factor(df_one_pat$died_ever)
#summary(df_one_pat$died_ever)

## covid positive ever
df_one_pat$covid_positive<- df_one_pat$Covid_test_result_sgss
df_one_pat$covid_positive<-as.factor(df_one_pat$covid_positive)


## select variables for the baseline table
bltab_vars <- select(df_one_pat, date, patient_id, practice, age, age_cat, sex, bmi, 
                     bmi_cat, ethnicity_6, charlsonGrp, smoking_cat, flu_vaccine,
                     covid_positive, died_ever, covrx, imd)

# generate data table 

# baseline_tab <-
#   bltab_vars %>%
#   summarise(
#     n = n(),
#     age_median = median(age),
#     age_Q1 = quantile(age, 0.25),
#     age_Q3 = quantile(age, 0.75),
#     age_mean = mean(age),
#     "0-4" = mean(age_cat=="0-4")
#     )


#trying with tbl_summary() in gtsummary
#test <- bltab_vars %>% rownames_to_column()

# columns for baseline table
#colsfortab <- colnames(bltab_vars)[-c(2:3)] # patient ID, practice id
#bltab_vars %>% summary_factorlist(explanatory = colsfortab) -> t

#str(t)
#blt <- CreateTableOne(data=bltab_vars)
#blt_all_levs <- print(blt, showAllLevels=T, quote=F)
#View(blt_all_levs)

#write_csv(t, here::here("output", "blt_one_random_obs_perpat.csv"))
#write.csv(blt_all_levs, "blt_one_random_obs_perpat.csv")

