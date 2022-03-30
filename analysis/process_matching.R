# # # # # # # # # # # # # # # # # # # # #
# This script:
# merge case and control groups & add variables for 
# outcome 2: hospital admission
# outcome 3: icu and death
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

setwd(here::here("output"))
###### matching1:2 ###### 
# extracted dataset after maching
DF1=read_csv("input_outcome_2_2.csv")

## add variables to extracted cohort:"set_id","case", "match_counts"   
DF2 <- read_csv("matched_combined_infection_hosp_2.csv
")
#DF2 = subset(DF2,select=c("patient_id","age","sex","set_id","case", "match_counts","stp"))
DF2 = subset(DF2,select=c("patient_id","set_id","case", "match_counts"))

#df=merge(DF1,DF2,by=c("patient_id","age","sex","stp"),all.x=T) can;t merge with dummy data
df=merge(DF1,DF2,by=c("patient_id"),all.x=T)
rm(DF1,DF2)

######## time ##########

## wave  
df$wave=ifelse(df$patient_index_date > as.Date("2020-11-30"),"3", # wave3(national vaccination programme):Dec2020--Dec,2021
               ifelse(df$patient_index_date > as.Date("2020-08-31"),"2", # wave2(test for wider population): Sep-Dec,2020
                      ifelse( df$patient_index_date > as.Date("2020-01-31"),"1","0")))# wave1(test for health workers):Feb-Aug,2020

#1 die before patient_index_date/#2 die after patient_index_date/# 0 never die
df$died_ever=ifelse(df$ons_died_date < df$patient_index_date, 1, 2)
df$died_ever=ifelse(is.na(df$ons_died_date),0,df$died_ever)
df=df%>%filter(died_ever != 1) # exclude died before index


#1 deregister before patient_index_date/#2 deregister after patient_index_date/# 0 never de-register
df$dereg_ever=ifelse(df$dereg_date < df$patient_index_date, 1, 2)
df$dereg_ever=ifelse(is.na(df$dereg_date),0,df$dereg_ever)
df=df%>%filter(died_ever != 1) # exclude de-register before index


####### matching variables ########
## age
df=df%>%filter(df$age_cat != "0")
df$age_cat <- factor(df$age_cat, levels=c("0-4", "18-29","30-39","40-49","50-59","60-69","70-79","80+"))



######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
# count number of types
df$ab_types=rowSums(df[col]>0)
df=df[ ! names(df) %in% col]

##antibiotic prescribing frequency

df$ab_last_date=as.Date(df$ab_last_date)
df$ab_first_date=as.Date(df$ab_first_date)

# use AB more than once
df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$ab_freq=df$ab_prescriptions/df$interval
df$ab_freq.type=df$ab_types/df$interval

df$lastABtime=as.integer(difftime(df$ab_last_date,df$patient_index_date,unit="day"))

## quintile category

# quintile<-function(x){
#   ifelse(x>quantile(x,.8),"5",
#          ifelse(x>quantile(x,.6),"4",
#                 ifelse(x>quantile(x,.4),"3",
#                        ifelse(x>quantile(x,.2),"2","1"))))}

# df$ab_qn=quintile(df$ab_prescriptions)
# df$br_ab_qn=quintile(df$broad_ab_prescriptions)

df=df%>%mutate(ab_qn=ntile(ab_prescriptions,5),
               br_ab_qn=ntile(broad_ab_prescriptions,5))

df$ab_qn=as.factor(df$ab_qn)
df$br_ab_qn=as.factor(df$br_ab_qn)



######## confounding variables #########
## ethnicity
df$ethnicity=ifelse(is.na(df$ethnicity),"6",df$ethnicity)
df=df%>%mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                       ethnicity == 2  ~ "Mixed",
                                       ethnicity == 3  ~ "South Asian",
                                       ethnicity == 4  ~ "Black",
                                       ethnicity == 5  ~ "Other",
                                       ethnicity == 6   ~ "Unknown"))
df$ethnicity_6=as.factor(df$ethnicity_6)

## BMI category
#bmi 
#remove very low observations
df$bmi=ifelse(df$bmi<15 | df$bmi>50, NA, df$bmi)
# bmi categories 
df<- df %>% 
  mutate(bmi_cat = case_when(is.na(bmi) ~ "Unknown",
                             bmi<18.5 ~ "Underweight",
                             bmi<25  ~ "Healthy weight",
                             bmi<30 ~ "Overweight",
                             bmi>=30  ~"Obese"))
df$bmi_cat<- as.factor(df$bmi_cat)
#summary(df_one_pat$bmi_cat)


##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "Current",
                                        smoking_status=="E" ~ "Former",
                                        smoking_status=="N" ~ "Never",
                                        smoking_status=="M" ~ "Unknown", 
                                        is.na(smoking_status) ~ "Unknown"))

### CCI
df$cancer<- ifelse(df$cancer_comor == 1, 2, 0)
df$cvd <- ifelse(df$cardiovascular_comor == 1, 1, 0)
df$copd <- ifelse(df$chronic_obstructive_pulmonary_comor == 1, 1, 0)
df$heart_failure <- ifelse(df$heart_failure_comor == 1, 1, 0)
df$connective_tissue <- ifelse(df$connective_tissue_comor == 1, 1, 0)
df$dementia <- ifelse(df$dementia_comor == 1, 1, 0)
df$diabetes <- ifelse(df$diabetes_comor == 1, 1, 0)
df$diabetes_complications <- ifelse(df$diabetes_complications_comor == 1, 2, 0)
df$hemiplegia <- ifelse(df$hemiplegia_comor == 1, 2, 0)
df$hiv <- ifelse(df$hiv_comor == 1, 6, 0)
df$metastatic_cancer <- ifelse(df$metastatic_cancer_comor == 1, 6, 0)
df$mild_liver <- ifelse(df$mild_liver_comor == 1, 1, 0)
df$mod_severe_liver <- ifelse(df$mod_severe_liver_comor == 1, 3, 0)
df$mod_severe_renal <- ifelse(df$mod_severe_renal_comor == 1, 2, 0)
df$mi <- ifelse(df$mi_comor == 1, 1, 0)
df$peptic_ulcer <- ifelse(df$peptic_ulcer_comor == 1, 1, 0)
df$peripheral_vascular <- ifelse(df$peripheral_vascular_comor == 1, 1, 0)

comor=c("cancer_comor","cardiovascular_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor")
df$Charlson=rowSums(df[comor])
df= df[!names(df)%in%comor]

df=df%>%mutate(CCI=case_when(Charlson<1 ~ "Very low",
                             Charlson<3 ~ "Low",
                             Charlson<5 ~ "Medium",
                             Charlson<7 ~ "High",
                             Charlson>=7 ~ "Very high"))

CCI_comor=c("cancer","cvd","copd","heart_failure","connective_tissue","dementia","diabetes","diabetes_complications","hemiplegia","hiv","metastatic_cancer","mild_liver","mod_severe_liver","mod_severe_renal","mi","peptic_ulcer","peripheral_vascular")
df= df[!names(df)%in%CCI_comor]


# covid vaccine
df$covrx1_ever=ifelse(is.na(df$covrx1_dat),0,1)
df$covrx2_ever=ifelse(is.na(df$covrx2_dat),0,1)
df$covrx_ever=ifelse(df$covrx1_ever>0|df$covrx2_ever>0,1,0)



# variables for analysis
df=subset(df,select=c("wave","patient_id","set_id","case", "match_counts","sex","age","age_cat","stp","region","ethnicity_6","bmi","bmi_cat","CCI","Charlson","smoking_cat_3","imd","care_home","covrx_ever","flu_vaccine", "ab_prescriptions","broad_ab_prescriptions","ab_types","interval","ab_freq","ab_freq.type", "lastABtime","ab_qn", "br_ab_qn"))



write_csv(df, here::here("output", "matched_outcome_2.csv"))
rm(list=ls())



###### matching1:4 ###### 
# extracted dataset after maching
DF1=read_csv("input_outcome_2_4.csv")

## add variables to extracted cohort:"set_id","case", "match_counts"   
DF2 <- read_csv("matched_combined_infection_hosp_4.csv
")
#DF2 = subset(DF2,select=c("patient_id","age","sex","set_id","case", "match_counts","stp"))
DF2 = subset(DF2,select=c("patient_id","set_id","case", "match_counts"))

#df=merge(DF1,DF2,by=c("patient_id","age","sex","stp"),all.x=T) can;t merge with dummy data
df=merge(DF1,DF2,by=c("patient_id"),all.x=T)
rm(DF1,DF2)

######## time ##########

## wave  
df$wave=ifelse(df$patient_index_date > as.Date("2020-11-30"),"3", # wave3(national vaccination programme):Dec2020--Dec,2021
               ifelse(df$patient_index_date > as.Date("2020-08-31"),"2", # wave2(test for wider population): Sep-Dec,2020
                      ifelse( df$patient_index_date > as.Date("2020-01-31"),"1","0")))# wave1(test for health workers):Feb-Aug,2020

#1 die before patient_index_date/#2 die after patient_index_date/# 0 never die
df$died_ever=ifelse(df$ons_died_date < df$patient_index_date, 1, 2)
df$died_ever=ifelse(is.na(df$ons_died_date),0,df$died_ever)
df=df%>%filter(died_ever != 1) # exclude died before index


#1 deregister before patient_index_date/#2 deregister after patient_index_date/# 0 never de-register
df$dereg_ever=ifelse(df$dereg_date < df$patient_index_date, 1, 2)
df$dereg_ever=ifelse(is.na(df$dereg_date),0,df$dereg_ever)
df=df%>%filter(died_ever != 1) # exclude de-register before index


####### matching variables ########
## age
df=df%>%filter(df$age_cat != "0")
df$age_cat <- factor(df$age_cat, levels=c("0-4", "18-29","30-39","40-49","50-59","60-69","70-79","80+"))



######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
# count number of types
df$ab_types=rowSums(df[col]>0)
df=df[ ! names(df) %in% col]

##antibiotic prescribing frequency

df$ab_last_date=as.Date(df$ab_last_date)
df$ab_first_date=as.Date(df$ab_first_date)

# use AB more than once
df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$ab_freq=df$ab_prescriptions/df$interval
df$ab_freq.type=df$ab_types/df$interval

df$lastABtime=as.integer(difftime(df$ab_last_date,df$patient_index_date,unit="day"))

## quintile category

# quintile<-function(x){
#   ifelse(x>quantile(x,.8),"5",
#          ifelse(x>quantile(x,.6),"4",
#                 ifelse(x>quantile(x,.4),"3",
#                        ifelse(x>quantile(x,.2),"2","1"))))}

# df$ab_qn=quintile(df$ab_prescriptions)
# df$br_ab_qn=quintile(df$broad_ab_prescriptions)

df=df%>%mutate(ab_qn=ntile(ab_prescriptions,5),
               br_ab_qn=ntile(broad_ab_prescriptions,5))

df$ab_qn=as.factor(df$ab_qn)
df$br_ab_qn=as.factor(df$br_ab_qn)



######## confounding variables #########
## ethnicity
df$ethnicity=ifelse(is.na(df$ethnicity),"6",df$ethnicity)
df=df%>%mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                       ethnicity == 2  ~ "Mixed",
                                       ethnicity == 3  ~ "South Asian",
                                       ethnicity == 4  ~ "Black",
                                       ethnicity == 5  ~ "Other",
                                       ethnicity == 6   ~ "Unknown"))
df$ethnicity_6=as.factor(df$ethnicity_6)

## BMI category
#bmi 
#remove very low observations
df$bmi=ifelse(df$bmi<15 | df$bmi>50, NA, df$bmi)
# bmi categories 
df<- df %>% 
  mutate(bmi_cat = case_when(is.na(bmi) ~ "Unknown",
                             bmi<18.5 ~ "Underweight",
                             bmi<25  ~ "Healthy weight",
                             bmi<30 ~ "Overweight",
                             bmi>=30  ~"Obese"))
df$bmi_cat<- as.factor(df$bmi_cat)
#summary(df_one_pat$bmi_cat)


##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "Current",
                                        smoking_status=="E" ~ "Former",
                                        smoking_status=="N" ~ "Never",
                                        smoking_status=="M" ~ "Unknown", 
                                        is.na(smoking_status) ~ "Unknown"))

### CCI
df$cancer<- ifelse(df$cancer_comor == 1, 2, 0)
df$cvd <- ifelse(df$cardiovascular_comor == 1, 1, 0)
df$copd <- ifelse(df$chronic_obstructive_pulmonary_comor == 1, 1, 0)
df$heart_failure <- ifelse(df$heart_failure_comor == 1, 1, 0)
df$connective_tissue <- ifelse(df$connective_tissue_comor == 1, 1, 0)
df$dementia <- ifelse(df$dementia_comor == 1, 1, 0)
df$diabetes <- ifelse(df$diabetes_comor == 1, 1, 0)
df$diabetes_complications <- ifelse(df$diabetes_complications_comor == 1, 2, 0)
df$hemiplegia <- ifelse(df$hemiplegia_comor == 1, 2, 0)
df$hiv <- ifelse(df$hiv_comor == 1, 6, 0)
df$metastatic_cancer <- ifelse(df$metastatic_cancer_comor == 1, 6, 0)
df$mild_liver <- ifelse(df$mild_liver_comor == 1, 1, 0)
df$mod_severe_liver <- ifelse(df$mod_severe_liver_comor == 1, 3, 0)
df$mod_severe_renal <- ifelse(df$mod_severe_renal_comor == 1, 2, 0)
df$mi <- ifelse(df$mi_comor == 1, 1, 0)
df$peptic_ulcer <- ifelse(df$peptic_ulcer_comor == 1, 1, 0)
df$peripheral_vascular <- ifelse(df$peripheral_vascular_comor == 1, 1, 0)

comor=c("cancer_comor","cardiovascular_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor")
df$Charlson=rowSums(df[comor])
df= df[!names(df)%in%comor]

df=df%>%mutate(CCI=case_when(Charlson<1 ~ "Very low",
                             Charlson<3 ~ "Low",
                             Charlson<5 ~ "Medium",
                             Charlson<7 ~ "High",
                             Charlson>=7 ~ "Very high"))

CCI_comor=c("cancer","cvd","copd","heart_failure","connective_tissue","dementia","diabetes","diabetes_complications","hemiplegia","hiv","metastatic_cancer","mild_liver","mod_severe_liver","mod_severe_renal","mi","peptic_ulcer","peripheral_vascular")
df= df[!names(df)%in%CCI_comor]


# covid vaccine
df$covrx1_ever=ifelse(is.na(df$covrx1_dat),0,1)
df$covrx2_ever=ifelse(is.na(df$covrx2_dat),0,1)
df$covrx_ever=ifelse(df$covrx1_ever>0|df$covrx2_ever>0,1,0)



# variables for analysis
df=subset(df,select=c("wave","patient_id","set_id","case", "match_counts","sex","age","age_cat","stp","region","ethnicity_6","bmi","bmi_cat","CCI","Charlson","smoking_cat_3","imd","care_home","covrx_ever","flu_vaccine", "ab_prescriptions","broad_ab_prescriptions","ab_types","interval","ab_freq","ab_freq.type", "lastABtime","ab_qn", "br_ab_qn"))



write_csv(df, here::here("output", "matched_outcome_4.csv"))
rm(list=ls())


###### matching1:6 ###### 
# extracted dataset after maching
DF1=read_csv("input_outcome_2_6.csv")

## add variables to extracted cohort:"set_id","case", "match_counts"   
DF2 <- read_csv("matched_combined_infection_hosp_6.csv")

#DF2 = subset(DF2,select=c("patient_id","age","sex","set_id","case", "match_counts","stp"))
DF2 = subset(DF2,select=c("patient_id","set_id","case", "match_counts"))

#df=merge(DF1,DF2,by=c("patient_id","age","sex","stp"),all.x=T) can;t merge with dummy data
df=merge(DF1,DF2,by=c("patient_id"),all.x=T)
rm(DF1,DF2)

######## time ##########

## wave  
df$wave=ifelse(df$patient_index_date > as.Date("2020-11-30"),"3", # wave3(national vaccination programme):Dec2020--Dec,2021
               ifelse(df$patient_index_date > as.Date("2020-08-31"),"2", # wave2(test for wider population): Sep-Dec,2020
                      ifelse( df$patient_index_date > as.Date("2020-01-31"),"1","0")))# wave1(test for health workers):Feb-Aug,2020

#1 die before patient_index_date/#2 die after patient_index_date/# 0 never die
df$died_ever=ifelse(df$ons_died_date < df$patient_index_date, 1, 2)
df$died_ever=ifelse(is.na(df$ons_died_date),0,df$died_ever)
df=df%>%filter(died_ever != 1) # exclude died before index


#1 deregister before patient_index_date/#2 deregister after patient_index_date/# 0 never de-register
df$dereg_ever=ifelse(df$dereg_date < df$patient_index_date, 1, 2)
df$dereg_ever=ifelse(is.na(df$dereg_date),0,df$dereg_ever)
df=df%>%filter(died_ever != 1) # exclude de-register before index


####### matching variables ########
## age
df=df%>%filter(df$age_cat != "0")
df$age_cat <- factor(df$age_cat, levels=c("0-4", "18-29","30-39","40-49","50-59","60-69","70-79","80+"))



######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
# count number of types
df$ab_types=rowSums(df[col]>0)
df=df[ ! names(df) %in% col]

##antibiotic prescribing frequency

df$ab_last_date=as.Date(df$ab_last_date)
df$ab_first_date=as.Date(df$ab_first_date)

# use AB more than once
df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$ab_freq=df$ab_prescriptions/df$interval
df$ab_freq.type=df$ab_types/df$interval

df$lastABtime=as.integer(difftime(df$ab_last_date,df$patient_index_date,unit="day"))

## quintile category

# quintile<-function(x){
#   ifelse(x>quantile(x,.8),"5",
#          ifelse(x>quantile(x,.6),"4",
#                 ifelse(x>quantile(x,.4),"3",
#                        ifelse(x>quantile(x,.2),"2","1"))))}

# df$ab_qn=quintile(df$ab_prescriptions)
# df$br_ab_qn=quintile(df$broad_ab_prescriptions)

df=df%>%mutate(ab_qn=ntile(ab_prescriptions,5),
               br_ab_qn=ntile(broad_ab_prescriptions,5))

df$ab_qn=as.factor(df$ab_qn)
df$br_ab_qn=as.factor(df$br_ab_qn)



######## confounding variables #########
## ethnicity
df$ethnicity=ifelse(is.na(df$ethnicity),"6",df$ethnicity)
df=df%>%mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                       ethnicity == 2  ~ "Mixed",
                                       ethnicity == 3  ~ "South Asian",
                                       ethnicity == 4  ~ "Black",
                                       ethnicity == 5  ~ "Other",
                                       ethnicity == 6   ~ "Unknown"))
df$ethnicity_6=as.factor(df$ethnicity_6)

## BMI category
#bmi 
#remove very low observations
df$bmi=ifelse(df$bmi<15 | df$bmi>50, NA, df$bmi)
# bmi categories 
df<- df %>% 
  mutate(bmi_cat = case_when(is.na(bmi) ~ "Unknown",
                             bmi<18.5 ~ "Underweight",
                             bmi<25  ~ "Healthy weight",
                             bmi<30 ~ "Overweight",
                             bmi>=30  ~"Obese"))
df$bmi_cat<- as.factor(df$bmi_cat)
#summary(df_one_pat$bmi_cat)


##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "Current",
                                        smoking_status=="E" ~ "Former",
                                        smoking_status=="N" ~ "Never",
                                        smoking_status=="M" ~ "Unknown", 
                                        is.na(smoking_status) ~ "Unknown"))

### CCI
df$cancer<- ifelse(df$cancer_comor == 1, 2, 0)
df$cvd <- ifelse(df$cardiovascular_comor == 1, 1, 0)
df$copd <- ifelse(df$chronic_obstructive_pulmonary_comor == 1, 1, 0)
df$heart_failure <- ifelse(df$heart_failure_comor == 1, 1, 0)
df$connective_tissue <- ifelse(df$connective_tissue_comor == 1, 1, 0)
df$dementia <- ifelse(df$dementia_comor == 1, 1, 0)
df$diabetes <- ifelse(df$diabetes_comor == 1, 1, 0)
df$diabetes_complications <- ifelse(df$diabetes_complications_comor == 1, 2, 0)
df$hemiplegia <- ifelse(df$hemiplegia_comor == 1, 2, 0)
df$hiv <- ifelse(df$hiv_comor == 1, 6, 0)
df$metastatic_cancer <- ifelse(df$metastatic_cancer_comor == 1, 6, 0)
df$mild_liver <- ifelse(df$mild_liver_comor == 1, 1, 0)
df$mod_severe_liver <- ifelse(df$mod_severe_liver_comor == 1, 3, 0)
df$mod_severe_renal <- ifelse(df$mod_severe_renal_comor == 1, 2, 0)
df$mi <- ifelse(df$mi_comor == 1, 1, 0)
df$peptic_ulcer <- ifelse(df$peptic_ulcer_comor == 1, 1, 0)
df$peripheral_vascular <- ifelse(df$peripheral_vascular_comor == 1, 1, 0)

comor=c("cancer_comor","cardiovascular_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor")
df$Charlson=rowSums(df[comor])
df= df[!names(df)%in%comor]

df=df%>%mutate(CCI=case_when(Charlson<1 ~ "Very low",
                             Charlson<3 ~ "Low",
                             Charlson<5 ~ "Medium",
                             Charlson<7 ~ "High",
                             Charlson>=7 ~ "Very high"))

CCI_comor=c("cancer","cvd","copd","heart_failure","connective_tissue","dementia","diabetes","diabetes_complications","hemiplegia","hiv","metastatic_cancer","mild_liver","mod_severe_liver","mod_severe_renal","mi","peptic_ulcer","peripheral_vascular")
df= df[!names(df)%in%CCI_comor]


# covid vaccine
df$covrx1_ever=ifelse(is.na(df$covrx1_dat),0,1)
df$covrx2_ever=ifelse(is.na(df$covrx2_dat),0,1)
df$covrx_ever=ifelse(df$covrx1_ever>0|df$covrx2_ever>0,1,0)



# variables for analysis
df=subset(df,select=c("wave","patient_id","set_id","case", "match_counts","sex","age","age_cat","stp","region","ethnicity_6","bmi","bmi_cat","CCI","Charlson","smoking_cat_3","imd","care_home","covrx_ever","flu_vaccine", "ab_prescriptions","broad_ab_prescriptions","ab_types","interval","ab_freq","ab_freq.type", "lastABtime","ab_qn", "br_ab_qn"))



write_csv(df, here::here("output", "matched_outcome_6.csv"))
rm(list=ls())