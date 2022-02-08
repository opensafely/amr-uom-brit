
# # # # # # # # # # # # # # # # # # # # #
# This script:
# define variables for analysis
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library('dplyr')
library('lubridate')


#### outcome1: general population vs infection 

# add variables to extracted cohort:"set_id","case", "match_counts"   
# impoprt data
df1 <- read_csv(here::here("output", "matched_combined_general_population_infection.csv"))
df1 = subset(df1,select=c("patient_id","age","sex","set_id","case", "match_counts"))
df2 <- read_csv(here::here("output", "input_control.csv"))

df=merge(df2,df1,by=c("patient_id","age","sex"),all.x=T)

# df$start_date=as.Date("2020-02-01")
# df$end_date=as.Date("2021-12-31")

######## time ##########
## exit_date: end of observation
#1.case: outcome date
#df$exit_date=df$patient_index_date

##2.control: exit_date(deregister or died)
#df$exit.min=pmin(df$dereg_date,df$ons_died_date,na.rm=T)
#df$exit_date[is.na(df$exit_date)]=df$exit.min[is.na(df$exit_date)]
##3.control: study end date
#df$exit_date[is.na(df$exit_date)]=df$end_date[is.na(df$exit_date)]

## age
df$age_cat <- factor(df$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))


## wave  
df$wave=ifelse(df$patient_index_date> as.Date("2021-09-30"),"5", # wave5(booster):Oct--Dec2021
                      ifelse(df$patient_index_date> as.Date("2021-02-28"),"4", # wave4(second dose):Mar-Sep,2021
                             ifelse(df$patient_index_date > as.Date("2020-11-30"),"3", # wave3(national vaccination programme):Dec2020--Feb,2021
                                    ifelse(df$patient_index_date > as.Date("2020-08-31"),"2", # wave2(test for wider population): Sep-Nov,2020
                                           ifelse( df$patient_index_date > as.Date("2020-01-31"),"1","0")))))# wave1(test for health workers):Feb-Aug,2020



######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
# count number of types
df$ab_types=rowSums(df[col]>0)


##antibiotic prescribing frequency

df$ab_last_date=as.Date(df$ab_last_date)
df$ab_first_date=as.Date(df$ab_first_date)

df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$ab_freq=df$ab_prescriptions/df$interval
df$ab_freq.type=df$ab_types/df$interval

df$lastABtime=as.integer(difftime(df$ab_last_date,df$patient_index_date,unit="day"))

## quantile category

quintile<-function(x){
  ifelse(x>quantile(x,.8),"5",
         ifelse(x>quantile(x,.6),"4",
                ifelse(x>quantile(x,.4),"3",
                       ifelse(x>quantile(x,.2),"2","1"))))}

df$ab_qn=quintile(df$ab_prescriptions)
df$br_ab_qn=quintile(df$broad_ab_prescriptions)

######## confounding variables #########
## ethnicity
df$ethnicity=ifelse(is.na(df$ethnicity),"6",df$ethnicity)
df=df%>%mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                       ethnicity == 2  ~ "Mixed",
                                       ethnicity == 3  ~ "South Asian",
                                       ethnicity == 4  ~ "Black",
                                       ethnicity == 5  ~ "Other",
                                       ethnicity == 6   ~ "Unknown"))
## BMI category
# https://www.sciencedirect.com/science/article/pii/S0140673621006346
# https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/01_eth_cr_analysis_dataset.do

# remove strange values
df$bmi=ifelse(df$bmi<15 | df$bmi>50, NA, df$bmi)
# restrict measurement within 10 years
df$bmi.time=difftime(df$patient_index_date, df$bmi_date_measured,unit="days")
df$bmi=ifelse(df$bmi.time>365*10 | df$bmi.time<0,NA,df$bmi)

# bmi_cat
# BMI in kg/m2 was grouped into six categories using the WHO classification, with adjustments for South Asian ethnicity: 
#underweight (<18·5 kg/m2), normal weight (18·5–24·9 kg/m2), overweight (25·0–29·9 kg/m2 ); obese I (30·0–34·9 kg/m2 ); obese II (35·0–39·9 kg/m2); and obese III (≥40 kg/m2). 
# South Asian:normal weight (18·5–22.9 kg/m2), overweight (23–27·4 kg/m2); obese I (27·5–32·4 kg/m2); obese II (32·5–37·4 kg/m2); and obese III [≥37·5 kg/m2]. 

df=df%>%mutate(bmi_cat_6.nonSA=case_when(is.na(bmi) ~"unknown",
                                         bmi<18.5 ~"under weight",
                                         bmi<25 ~"normal weight",
                                         bmi<30 ~"over weight",
                                         bmi>30|bmi==30 ~"obese"))
                                   #       bmi<35 ~"obese I",
                                   #       bmi<40 ~"obese II",
                                   #       bmi>40|bmi==40 ~ "obese III"
                                   #       ))
                        

df=df%>%mutate(bmi_cat_6.SA= case_when(is.na(bmi) ~"unknown",
                                       bmi<18.5 ~"under weight",
                                       bmi<23 ~"normal weight",
                                       bmi<27.5 ~"over weight",
                                       bmi>27.5|bmi==27.5 ~"obese"))
                                   #     bmi<32.5 ~"obese I",
                                   #     bmi<37.5 ~"obese II",
                                   #     bmi>37.5|bmi==37.5 ~ "obese III"))

df$bmi_cat_6=ifelse(df$ethnicity==3, df$bmi_cat_6.SA,df$bmi_cat_6.nonSA)

##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "current",
                                      smoking_status=="E" ~ "former",
                                      smoking_status=="N" ~ "never",
                                      smoking_status=="M" ~ "unknown", 
                                      is.na(smoking_status) ~ "unknown"))



# covid vaccine
df$covrx1=ifelse(is.na(df$covrx1_dat),0,1)
df$covrx2=ifelse(is.na(df$covrx2_dat),0,1)
df$covrx=ifelse(df$covrx1>0|df$covrx2>0,1,0)



### CCI
df$cancer_comor=ifelse(is.na(df$cancer_comor),0,2)
df$cardiovascular_comor=ifelse(is.na(df$cardiovascular_comor),0,1)
df$chronic_obstructive_pulmonary_comor=ifelse(is.na(df$chronic_obstructive_pulmonary_comor),0,1)
df$heart_failure_comor=ifelse(is.na(df$heart_failure_comor),0,1)
df$connective_tissue_comor=ifelse(is.na(df$connective_tissue_comor),0,1)
df$dementia_comor=ifelse(is.na(df$dementia_comor),0,1)
df$diabetes_comor=ifelse(is.na(df$diabetes_comor),0,1)
df$diabetes_complications_comor=ifelse(is.na(df$diabetes_complications_comor),0,2)
df$hemiplegia_comor=ifelse(is.na(df$hemiplegia_comor),0,2)
df$hiv_comor=ifelse(is.na(df$hiv_comor),0,6)
df$metastatic_cancer_comor=ifelse(is.na(df$metastatic_cancer_comor),0,6)
df$mild_liver_comor=ifelse(is.na(df$mild_liver_comor),0,1)
df$mod_severe_liver_comor=ifelse(is.na(df$mod_severe_liver_comor),0,3)
df$mod_severe_renal_comor=ifelse(is.na(df$mod_severe_renal_comor),0,2)
df$mi_comor=ifelse(is.na(df$mi_comor),0,1)
df$peptic_ulcer_comor=ifelse(is.na(df$peptic_ulcer_comor),0,1)
df$peripheral_vascular_comor=ifelse(is.na(df$peripheral_vascular_comor),0,1)

comor=c("cancer_comor","cardiovascular_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor")
df$Charlson=rowSums(df[comor])


df=df%>%mutate(CCI=case_when(Charlson<1 ~ "very low",
                             Charlson<3 ~ "low",
                             Charlson<5 ~ "medium",
                             Charlson<7 ~ "high",
                             Charlson>7 | Charlson==7 ~ "very high"))



write_csv(df, here::here("output", "matched_outcome1.csv"))

rm(list=ls())




#### outcome2: infection vs hops admission

# impoprt data
df <- read_csv(here::here("output", "matched_combined_infection_hosp.csv"))

# df$start_date=as.Date("2020-02-01")
# df$end_date=as.Date("2021-12-31")

######## time ##########
## exit_date: end of observation
#1.case: outcome date
#df$exit_date=df$patient_index_date

##2.control: exit_date(deregister or died)
#df$exit.min=pmin(df$dereg_date,df$ons_died_date,na.rm=T)
#df$exit_date[is.na(df$exit_date)]=df$exit.min[is.na(df$exit_date)]
##3.control: study end date
#df$exit_date[is.na(df$exit_date)]=df$end_date[is.na(df$exit_date)]

## age
df$age_cat <- factor(df$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))


## wave  
df$wave=ifelse(df$patient_index_date> as.Date("2021-09-30"),"5", # wave5(booster):Oct--Dec2021
                      ifelse(df$patient_index_date> as.Date("2021-02-28"),"4", # wave4(second dose):Mar-Sep,2021
                             ifelse(df$patient_index_date > as.Date("2020-11-30"),"3", # wave3(national vaccination programme):Dec2020--Feb,2021
                                    ifelse(df$patient_index_date > as.Date("2020-08-31"),"2", # wave2(test for wider population): Sep-Nov,2020
                                           ifelse( df$patient_index_date > as.Date("2020-01-31"),"1","0")))))# wave1(test for health workers):Feb-Aug,2020



######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
# count number of types
df$ab_types=rowSums(df[col]>0)


##antibiotic prescribing frequency

df$ab_last_date=as.Date(df$ab_last_date)
df$ab_first_date=as.Date(df$ab_first_date)

df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$ab_freq=df$ab_prescriptions/df$interval
df$ab_freq.type=df$ab_types/df$interval

df$lastABtime=as.integer(difftime(df$ab_last_date,df$patient_index_date,unit="day"))

## quantile category

quintile<-function(x){
  ifelse(x>quantile(x,.8),"5",
         ifelse(x>quantile(x,.6),"4",
                ifelse(x>quantile(x,.4),"3",
                       ifelse(x>quantile(x,.2),"2","1"))))}

df$ab_qn=quintile(df$ab_prescriptions)
df$br_ab_qn=quintile(df$broad_ab_prescriptions)

######## confounding variables #########
## ethnicity
df$ethnicity=ifelse(is.na(df$ethnicity),"6",df$ethnicity)
df=df%>%mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                       ethnicity == 2  ~ "Mixed",
                                       ethnicity == 3  ~ "South Asian",
                                       ethnicity == 4  ~ "Black",
                                       ethnicity == 5  ~ "Other",
                                       ethnicity == 6   ~ "Unknown"))
## BMI category
# https://www.sciencedirect.com/science/article/pii/S0140673621006346
# https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/01_eth_cr_analysis_dataset.do

# remove strange values
df$bmi=ifelse(df$bmi<15 | df$bmi>50, NA, df$bmi)
# restrict measurement within 10 years
df$bmi.time=difftime(df$patient_index_date, df$bmi_date_measured,unit="days")
df$bmi=ifelse(df$bmi.time>365*10 | df$bmi.time<0,NA,df$bmi)

# bmi_cat
# BMI in kg/m2 was grouped into six categories using the WHO classification, with adjustments for South Asian ethnicity: 
#underweight (<18·5 kg/m2), normal weight (18·5–24·9 kg/m2), overweight (25·0–29·9 kg/m2 ); obese I (30·0–34·9 kg/m2 ); obese II (35·0–39·9 kg/m2); and obese III (≥40 kg/m2). 
# South Asian:normal weight (18·5–22.9 kg/m2), overweight (23–27·4 kg/m2); obese I (27·5–32·4 kg/m2); obese II (32·5–37·4 kg/m2); and obese III [≥37·5 kg/m2]. 

df=df%>%mutate(bmi_cat_6.nonSA=case_when(is.na(bmi) ~"unknown",
                                         bmi<18.5 ~"under weight",
                                         bmi<25 ~"normal weight",
                                         bmi<30 ~"over weight",
                                         bmi>30|bmi==30 ~"obese"))
                                   #       bmi<35 ~"obese I",
                                   #       bmi<40 ~"obese II",
                                   #       bmi>40|bmi==40 ~ "obese III"
                                   #       ))
                        

df=df%>%mutate(bmi_cat_6.SA= case_when(is.na(bmi) ~"unknown",
                                       bmi<18.5 ~"under weight",
                                       bmi<23 ~"normal weight",
                                       bmi<27.5 ~"over weight",
                                       bmi>27.5|bmi==27.5 ~"obese"))
                                   #     bmi<32.5 ~"obese I",
                                   #     bmi<37.5 ~"obese II",
                                   #     bmi>37.5|bmi==37.5 ~ "obese III"))

df$bmi_cat_6=ifelse(df$ethnicity==3, df$bmi_cat_6.SA,df$bmi_cat_6.nonSA)

##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "current",
                                      smoking_status=="E" ~ "former",
                                      smoking_status=="N" ~ "never",
                                      smoking_status=="M" ~ "unknown", 
                                      is.na(smoking_status) ~ "unknown"))



# covid vaccine
df$covrx1=ifelse(df$covrx1_dat>0,1,0)
df$covrx2=ifelse(df$covrx2_dat>0,1,0)
df$covrx=ifelse(df$covrx1>0|df$covrx2>0,1,0)



### CCI
df$cancer_comor=ifelse(is.na(df$cancer_comor),0,2)
df$cardiovascular_comor=ifelse(is.na(df$cardiovascular_comor),0,1)
df$chronic_obstructive_pulmonary_comor=ifelse(is.na(df$chronic_obstructive_pulmonary_comor),0,1)
df$heart_failure_comor=ifelse(is.na(df$heart_failure_comor),0,1)
df$connective_tissue_comor=ifelse(is.na(df$connective_tissue_comor),0,1)
df$dementia_comor=ifelse(is.na(df$dementia_comor),0,1)
df$diabetes_comor=ifelse(is.na(df$diabetes_comor),0,1)
df$diabetes_complications_comor=ifelse(is.na(df$diabetes_complications_comor),0,2)
df$hemiplegia_comor=ifelse(is.na(df$hemiplegia_comor),0,2)
df$hiv_comor=ifelse(is.na(df$hiv_comor),0,6)
df$metastatic_cancer_comor=ifelse(is.na(df$metastatic_cancer_comor),0,6)
df$mild_liver_comor=ifelse(is.na(df$mild_liver_comor),0,1)
df$mod_severe_liver_comor=ifelse(is.na(df$mod_severe_liver_comor),0,3)
df$mod_severe_renal_comor=ifelse(is.na(df$mod_severe_renal_comor),0,2)
df$mi_comor=ifelse(is.na(df$mi_comor),0,1)
df$peptic_ulcer_comor=ifelse(is.na(df$peptic_ulcer_comor),0,1)
df$peripheral_vascular_comor=ifelse(is.na(df$peripheral_vascular_comor),0,1)

comor=c("cancer_comor","cardiovascular_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor")
df$Charlson=rowSums(df[comor])


df=df%>%mutate(CCI=case_when(Charlson<1 ~ "very low",
                             Charlson<3 ~ "low",
                             Charlson<5 ~ "medium",
                             Charlson<7 ~ "high",
                             Charlson>7 | Charlson==7 ~ "very high"))



write_csv(df, here::here("output", "matched_outcome2.csv"))

rm(list=ls())







#### outcome3: hops admission vs. death

# impoprt data
df <- read_csv(here::here("output", "matched_combined_hosp_icu_death.csv"))

# df$start_date=as.Date("2020-02-01")
# df$end_date=as.Date("2021-12-31")

######## time ##########
## exit_date: end of observation
#1.case: outcome date
#df$exit_date=df$patient_index_date

##2.control: exit_date(deregister or died)
#df$exit.min=pmin(df$dereg_date,df$ons_died_date,na.rm=T)
#df$exit_date[is.na(df$exit_date)]=df$exit.min[is.na(df$exit_date)]
##3.control: study end date
#df$exit_date[is.na(df$exit_date)]=df$end_date[is.na(df$exit_date)]


## age
df$age_cat <- factor(df$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))


## wave  
df$wave=ifelse(df$patient_index_date> as.Date("2021-09-30"),"5", # wave5(booster):Oct--Dec2021
                      ifelse(df$patient_index_date> as.Date("2021-02-28"),"4", # wave4(second dose):Mar-Sep,2021
                             ifelse(df$patient_index_date > as.Date("2020-11-30"),"3", # wave3(national vaccination programme):Dec2020--Feb,2021
                                    ifelse(df$patient_index_date > as.Date("2020-08-31"),"2", # wave2(test for wider population): Sep-Nov,2020
                                           ifelse( df$patient_index_date > as.Date("2020-01-31"),"1","0")))))# wave1(test for health workers):Feb-Aug,2020



######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
# count number of types
df$ab_types=rowSums(df[col]>0)


##antibiotic prescribing frequency

df$ab_last_date=as.Date(df$ab_last_date)
df$ab_first_date=as.Date(df$ab_first_date)

df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$ab_freq=df$ab_prescriptions/df$interval
df$ab_freq.type=df$ab_types/df$interval

df$lastABtime=as.integer(difftime(df$ab_last_date,df$patient_index_date,unit="day"))

## quantile category

quintile<-function(x){
  ifelse(x>quantile(x,.8),"5",
         ifelse(x>quantile(x,.6),"4",
                ifelse(x>quantile(x,.4),"3",
                       ifelse(x>quantile(x,.2),"2","1"))))}

df$ab_qn=quintile(df$ab_prescriptions)
df$br_ab_qn=quintile(df$broad_ab_prescriptions)

######## confounding variables #########
## ethnicity
df$ethnicity=ifelse(is.na(df$ethnicity),"6",df$ethnicity)
df=df%>%mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                       ethnicity == 2  ~ "Mixed",
                                       ethnicity == 3  ~ "South Asian",
                                       ethnicity == 4  ~ "Black",
                                       ethnicity == 5  ~ "Other",
                                       ethnicity == 6   ~ "Unknown"))
## BMI category
# https://www.sciencedirect.com/science/article/pii/S0140673621006346
# https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/01_eth_cr_analysis_dataset.do

# remove strange values
df$bmi=ifelse(df$bmi<15 | df$bmi>50, NA, df$bmi)
# restrict measurement within 10 years
df$bmi.time=difftime(df$patient_index_date, df$bmi_date_measured,unit="days")
df$bmi=ifelse(df$bmi.time>365*10 | df$bmi.time<0,NA,df$bmi)

# bmi_cat
# BMI in kg/m2 was grouped into six categories using the WHO classification, with adjustments for South Asian ethnicity: 
#underweight (<18·5 kg/m2), normal weight (18·5–24·9 kg/m2), overweight (25·0–29·9 kg/m2 ); obese I (30·0–34·9 kg/m2 ); obese II (35·0–39·9 kg/m2); and obese III (≥40 kg/m2). 
# South Asian:normal weight (18·5–22.9 kg/m2), overweight (23–27·4 kg/m2); obese I (27·5–32·4 kg/m2); obese II (32·5–37·4 kg/m2); and obese III [≥37·5 kg/m2]. 

df=df%>%mutate(bmi_cat_6.nonSA=case_when(is.na(bmi) ~"unknown",
                                         bmi<18.5 ~"under weight",
                                         bmi<25 ~"normal weight",
                                         bmi<30 ~"over weight",
                                         bmi>30|bmi==30 ~"obese"))
                                   #       bmi<35 ~"obese I",
                                   #       bmi<40 ~"obese II",
                                   #       bmi>40|bmi==40 ~ "obese III"
                                   #       ))
                        

df=df%>%mutate(bmi_cat_6.SA= case_when(is.na(bmi) ~"unknown",
                                       bmi<18.5 ~"under weight",
                                       bmi<23 ~"normal weight",
                                       bmi<27.5 ~"over weight",
                                       bmi>27.5|bmi==27.5 ~"obese"))
                                   #     bmi<32.5 ~"obese I",
                                   #     bmi<37.5 ~"obese II",
                                   #     bmi>37.5|bmi==37.5 ~ "obese III"))

df$bmi_cat_6=ifelse(df$ethnicity==3, df$bmi_cat_6.SA,df$bmi_cat_6.nonSA)

##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "current",
                                      smoking_status=="E" ~ "former",
                                      smoking_status=="N" ~ "never",
                                      smoking_status=="M" ~ "unknown", 
                                      is.na(smoking_status) ~ "unknown"))



# covid vaccine
df$covrx1=ifelse(df$covrx1_dat>0,1,0)
df$covrx2=ifelse(df$covrx2_dat>0,1,0)
df$covrx=ifelse(df$covrx1>0|df$covrx2>0,1,0)



### CCI
df$cancer_comor=ifelse(is.na(df$cancer_comor),0,2)
df$cardiovascular_comor=ifelse(is.na(df$cardiovascular_comor),0,1)
df$chronic_obstructive_pulmonary_comor=ifelse(is.na(df$chronic_obstructive_pulmonary_comor),0,1)
df$heart_failure_comor=ifelse(is.na(df$heart_failure_comor),0,1)
df$connective_tissue_comor=ifelse(is.na(df$connective_tissue_comor),0,1)
df$dementia_comor=ifelse(is.na(df$dementia_comor),0,1)
df$diabetes_comor=ifelse(is.na(df$diabetes_comor),0,1)
df$diabetes_complications_comor=ifelse(is.na(df$diabetes_complications_comor),0,2)
df$hemiplegia_comor=ifelse(is.na(df$hemiplegia_comor),0,2)
df$hiv_comor=ifelse(is.na(df$hiv_comor),0,6)
df$metastatic_cancer_comor=ifelse(is.na(df$metastatic_cancer_comor),0,6)
df$mild_liver_comor=ifelse(is.na(df$mild_liver_comor),0,1)
df$mod_severe_liver_comor=ifelse(is.na(df$mod_severe_liver_comor),0,3)
df$mod_severe_renal_comor=ifelse(is.na(df$mod_severe_renal_comor),0,2)
df$mi_comor=ifelse(is.na(df$mi_comor),0,1)
df$peptic_ulcer_comor=ifelse(is.na(df$peptic_ulcer_comor),0,1)
df$peripheral_vascular_comor=ifelse(is.na(df$peripheral_vascular_comor),0,1)

comor=c("cancer_comor","cardiovascular_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor")
df$Charlson=rowSums(df[comor])


df=df%>%mutate(CCI=case_when(Charlson<1 ~ "very low",
                             Charlson<3 ~ "low",
                             Charlson<5 ~ "medium",
                             Charlson<7 ~ "high",
                             Charlson>7 | Charlson==7 ~ "very high"))



write_csv(df, here::here("output", "matched_outcome3.csv"))

rm(list=ls())
