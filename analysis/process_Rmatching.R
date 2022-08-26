# # # # # # # # # # # # # # # # # # # # #
# This script:
# merge case and control groups & sort variables for analysis
# 
# 
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")
# extracted dataset after matching
DF1=read_csv("input_outcome.csv")

## add variables to extracted cohort:"subclass","case", 
DF2 <- read_rds("matched_patients.rds")

#DF2 = subset(DF2,select=c("patient_id","age","sex","set_id","case", "match_counts","stp"))
DF2 = DF2%>%select(c("patient_id","sex","stp","subclass","case","patient_index_date"))

#df=merge(DF1,DF2,by=c("patient_id","age","sex","stp"),all.x=T) can't merge with dummy data
df=merge(DF2,DF1,by=c("patient_id","sex","stp","patient_index_date"),all=F)
rm(DF1,DF2)

df$case=as.factor(df$case)

######## time ##########

## wave  
df$wave=ifelse(df$patient_index_date >= as.Date("2021-05-01"),"3", 
               ifelse(df$patient_index_date >= as.Date("2020-09-01"),"2", 
                      ifelse( df$patient_index_date >= as.Date("2020-02-01"),"1","0")))

####### matching variables ########
## age
#df=df%>%filter(df$age_cat != "0")
#df$age_cat <- factor(df$age_cat, levels=c( "18-29","30-39","40-49","50-59","60-69","70-79","80+"))
df=df%>% select(-"age_cat")

           
#  df=df%>% mutate(age_cat = case_when(
#             is.na(age) ~ "Unknown",
#             age >= 18 & age < 30 ~  "18-29" ,
#             age >= 30 & age < 40 ~ "30-39" ,
#             age >= 40 & age < 50 ~ "40-49" ,
#             age >= 50 & age < 60 ~  "50-59" ,
#             age >= 60 & age < 70 ~ "60-69",
#             age >= 70 & age < 80 ~ "70-79",
#             age >= 80 & age <= 110 ~ "80+"))

df$age_cat=ifelse(df$age<30,"18-29",
                   ifelse(df$age<40,"30-39",
                          ifelse(df$age<50,"40-49",
                                 ifelse(df$age<60,"50-59",
                                        ifelse(df$age<70,"60-69",
                                               ifelse(df$age<80,"70-79","80+"))))))
df$age_cat <- factor(df$age_cat, levels=c("18-29","30-39","40-49","50-59","60-69","70-79","80+"))


######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")

df[col]=df[col]%>%mutate_all(~replace(., is.na(.), 0)) # recode NA -> 0
df$total_ab=rowSums(df[col])# total types number -> total ab prescription

df[col]=ifelse(df[col]>0,1,0) # number of matches-> binary flag(1,0)
df$ab_types=rowSums(df[col]>0)# count number of types
write_rds(df[col], here::here("output", "abtype79.rds"))
df=df[ ! names(df) %in% col]

df$ab_types=ifelse(is.na(df$ab_types),0,df$ab_types) # no ab 

##antibiotic prescribing frequency

df$ab_last_date=as.Date(df$ab_last_date)
df$ab_first_date=as.Date(df$ab_first_date)

# use AB more than once
df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$lastABtime=as.integer(difftime(df$patient_index_date,df$ab_last_date,unit="day"))
df$lastABtime=ifelse(is.na(df$lastABtime),0,df$lastABtime)

## quintile category
 #quintile<-function(x){
  # ifelse(is.na(x)|x==0,"0",
   #       ifelse(x>quantile(x,.8),"5",
    #             ifelse(x>quantile(x,.6),"4",
     #                   ifelse(x>quantile(x,.4),"3",
      #                         ifelse(x>quantile(x,.2),"2","1")))))}

 
# df$ab_qn=quintile(df$ab_prescriptions)
# df$br_ab_qn=quintile(df$broad_ab_prescriptions)




# set ab quintile category - compare two ways # 

##### I.  ab_prescription

### 1.1-ab quintile = according to unique ab prescription numbers
df$ab_prescriptions=ifelse(df$ab_prescriptions==0,NA,df$ab_prescriptions) # filter no ab
qn_num=unique(df$ab_prescriptions)
qn_cat1=quantile(qn_num,0.2,na.rm=T)
qn_cat2=quantile(qn_num,0.4,na.rm=T)
qn_cat3=quantile(qn_num,0.6,na.rm=T)
qn_cat4=quantile(qn_num,0.8,na.rm=T)

df$ab_qn_5=ifelse(is.na(df$ab_prescriptions),0,
                  ifelse(df$ab_prescriptions<=qn_cat1,1,
                         ifelse(df$ab_prescriptions<=qn_cat2,2,
                                ifelse(df$ab_prescriptions<=qn_cat3,3,
                                       ifelse(df$ab_prescriptions<=qn_cat4,4,5)
                                       ))))

### 1.2-broad ab quintile = according to unique broad ab prescription numbers
df$broad_ab_prescriptions=ifelse(df$broad_ab_prescriptions==0,NA,df$broad_ab_prescriptions) # filter no ab+no br ab
br_qn_num=unique(df$broad_ab_prescriptions)
br_qn_cat1=quantile(br_qn_num,0.2,na.rm=T)
br_qn_cat2=quantile(br_qn_num,0.4,na.rm=T)
br_qn_cat3=quantile(br_qn_num,0.6,na.rm=T)
br_qn_cat4=quantile(br_qn_num,0.8,na.rm=T)

df$br_ab_qn_5=ifelse(is.na(df$broad_ab_prescriptions),0,
                  ifelse(df$broad_ab_prescriptions<=br_qn_cat1,1,
                         ifelse(df$broad_ab_prescriptions<=br_qn_cat2,2,
                                ifelse(df$broad_ab_prescriptions<=br_qn_cat3,3,
                                       ifelse(df$broad_ab_prescriptions<=br_qn_cat4,4,5)
                                ))))
df$br_ab_qn_5=ifelse(is.na(df$ab_prescriptions),"without any ab",
                   ifelse(is.na(df$broad_ab_prescriptions)|df$broad_ab_prescriptions==0,"without broad ab",
                          df$br_ab_qn_5))

### 2.1-ab quintile = according to ab prescription numbers
df$ab_prescriptions=ifelse(df$ab_prescriptions==0,NA,df$ab_prescriptions) # filter no ab
df=df%>%mutate(ab_qn=ntile(ab_prescriptions,5))
df$ab_qn=ifelse(is.na(df$ab_qn),0,df$ab_qn)# no ab ->0; ab exp. ->1~5
df$ab_qn=as.factor(df$ab_qn)

### 2.2-broad ab quintile = according to broad ab prescription numbers
df$broad_ab=ifelse(is.na(df$ab_prescriptions)| # without any ab
              is.na(df$broad_ab_prescriptions)|df$broad_ab_prescriptions==0,NA, # without broad ab
                       df$broad_ab_prescriptions) # with broad ab
df=df%>%mutate(br_ab_qn=ntile(broad_ab,5))
df$br_ab_qn=ifelse(is.na(df$ab_prescriptions),"without any ab",
                   ifelse(is.na(df$broad_ab_prescriptions)|df$broad_ab_prescriptions==0,"without broad ab",
                          df$br_ab_qn))
                

df$br_ab_qn=ifelse(is.na(df$br_ab_qn),0,df$br_ab_qn)
df$br_ab_qn=as.factor(df$br_ab_qn)

# ab_continuous 
df$ab_prescriptions=ifelse(is.na(df$ab_prescriptions),0,df$ab_prescriptions) # recode NA to 0
df$broad_ab_prescriptions=ifelse(is.na(df$broad_ab_prescriptions),0,df$broad_ab_prescriptions) # recode NA to 0



#### II. total ab- calculated from 79 knid ab
df$total_ab=ifelse(df$total_ab==0,NA,df$total_ab) # filter no ab
#qn_num=unique(df$total_ab)
qn_cat1=quantile(df$total_ab,0.2,na.rm=T)
qn_cat2=quantile(df$total_ab,0.4,na.rm=T)
qn_cat3=quantile(df$total_ab,0.6,na.rm=T)
qn_cat4=quantile(df$total_ab,0.8,na.rm=T)


df$level=ifelse(df$total_ab <=qn_cat1,1,NA)
df$level=ifelse(df$total_ab >qn_cat1 & df$total_ab <=qn_cat2,2,df$level)
df$level=ifelse(df$total_ab >qn_cat2 & df$total_ab <=qn_cat3,3,df$level)
df$level=ifelse(df$total_ab >qn_cat3 & df$total_ab <=qn_cat4,4,df$level)
df$level=ifelse(df$total_ab >qn_cat4,5,df$level)


df$level=ifelse(is.na(df$level),0,df$level)


### 1.1-ab quintile = according to unique ab prescription numbers
#df$total_ab=ifelse(df$total_ab==0,NA,df$total_ab) # filter no ab
qn_num=unique(df$total_ab)
qn_cat1=quantile(qn_num,0.2,na.rm=T)
qn_cat2=quantile(qn_num,0.4,na.rm=T)
qn_cat3=quantile(qn_num,0.6,na.rm=T)
qn_cat4=quantile(qn_num,0.8,na.rm=T)

df$total_ab_qn_5=ifelse(is.na(df$total_ab),0,
                        ifelse(df$total_ab<=qn_cat1,1,
                               ifelse(df$total_ab<=qn_cat2,2,
                                      ifelse(df$total_ab<=qn_cat3,3,
                                             ifelse(df$total_ab<=qn_cat4,4,5)
                                      ))))

### 1.2-broad ab quintile = according to unique broad ab prescription numbers
df$broad_ab_prescriptions=ifelse(df$broad_ab_prescriptions==0,NA,df$broad_ab_prescriptions) # filter no ab+no br ab
br_qn_num=unique(df$broad_ab_prescriptions)
br_qn_cat1=quantile(br_qn_num,0.2,na.rm=T)
br_qn_cat2=quantile(br_qn_num,0.4,na.rm=T)
br_qn_cat3=quantile(br_qn_num,0.6,na.rm=T)
br_qn_cat4=quantile(br_qn_num,0.8,na.rm=T)

df$br_total_ab_qn_5=ifelse(is.na(df$total_ab),0,
                     ifelse(df$broad_ab_prescriptions<=br_qn_cat1,1,
                            ifelse(df$broad_ab_prescriptions<=br_qn_cat2,2,
                                   ifelse(df$broad_ab_prescriptions<=br_qn_cat3,3,
                                          ifelse(df$broad_ab_prescriptions<=br_qn_cat4,4,5)
                                   ))))
df$br_total_ab_qn_5=ifelse(is.na(df$total_ab),"without any ab",
                     ifelse(is.na(df$broad_ab_prescriptions)|df$broad_ab_prescriptions==0,"without broad ab",
                            df$br_total_ab_qn_5))


### 2.1-ab quintile = according to total ab numbers
df$total_ab=ifelse(df$total_ab==0,NA,df$total_ab) # filter no ab
df=df%>%mutate(total_ab_qn=ntile(total_ab,5))
df$total_ab_qn=ifelse(is.na(df$total_ab_qn),0,df$total_ab_qn)# no ab ->0; ab exp. ->1~5
df$total_ab_qn=as.factor(df$total_ab_qn)

# ab_continuous 
df$total_ab=ifelse(is.na(df$total_ab),0,df$total_ab) # recode NA to 0






######## confounding variables #########
# ethnicity
#df$ethnicity=ifelse(is.na(df$ethnicity),"6",df$ethnicity)
df=df%>%mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                       ethnicity == 2  ~ "Mixed",
                                       ethnicity == 3  ~ "South Asian",
                                       ethnicity == 4  ~ "Black",
                                       ethnicity == 5  ~ "Other"))
                               #        ethnicity == 6   ~ "Unknown"))
df$ethnicity_6=as.factor(df$ethnicity_6)
df$ethnicity_6 <- factor(df$ethnicity_6, levels=c("White", "South Asian","Black","Mixed","Other"))

# df$ethnicity=as.factor(df$ethnicity)
# df$ethnicity_6=ifelse(df$ethnicity == 1 , "White",
#                    ifelse(df$ethnicity == 2  , "Mixed",
#                           ifelse(df$ethnicity == 3 , "South Asian",
#                                  ifelse(df$ethnicity == 4 , "Black",
#                                         ifelse(df$ethnicity == 5  , "Other","Unknown")))))
# df$ethnicity_6=as.factor(df$ethnicity_6)

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
df$bmi_cat <- factor(df$bmi_cat, levels=c("Healthy weight", "Underweight","Overweight","Obese","Unknown"))


##smoking status
df=df%>%mutate(smoking_cat_3= case_when(smoking_status=="S" ~ "Current",
                                        smoking_status=="E" ~ "Former",
                                        smoking_status=="N" ~ "Never",
                                        smoking_status=="M" ~ "Unknown", 
                                        is.na(smoking_status) ~ "Unknown"))
df$smoking_cat_3 <- factor(df$smoking_cat_3, levels=c("Never", "Current","Former","Unknown"))



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

df$cerebrovascular_disease_comor=df$cardiovascular_comor #correct name

comor=c("cancer_comor","cerebrovascular_disease_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor")
df$Charlson=rowSums(df[comor])
write_rds(df[comor], here::here("output", "comor17.rds"))

#df= df[!names(df)%in%comor]

df=df%>%mutate(CCI=case_when(Charlson<1 ~ "Zero",
                             Charlson<3 ~ "Low",
                             Charlson<5 ~ "Medium",
                             Charlson<7 ~ "High",
                             Charlson>=7 ~ "Very high"))
df$CCI <- factor(df$CCI, levels=c("Zero", "Low","Medium","High","Very high"))


CCI_comor=c("cancer","cvd","copd","heart_failure","connective_tissue","dementia","diabetes","diabetes_complications","hemiplegia","hiv","metastatic_cancer","mild_liver","mod_severe_liver","mod_severe_renal","mi","peptic_ulcer","peripheral_vascular")
#df= df[!names(df)%in%CCI_comor]


# covid vaccine
df$covrx1_ever=ifelse(is.na(df$covrx1_dat),0,1)
df$covrx2_ever=ifelse(is.na(df$covrx2_dat),0,1)
df$covrx_ever=ifelse(df$covrx1_ever>0|df$covrx2_ever>0,1,0)


# infections remove from main extraction
#inf=c("asthma_counts","cold_counts","copd_counts", "cough_counts", "lrti_counts", "ot_externa_counts", "otmedia_counts", "pneumonia_counts", 
#      "renal_counts", "sepsis_counts", "sinusitis_counts", "throat_counts", "urti_counts","uti_counts","infection_counts_all","infection_counts_6")
#df=df %>%mutate_at(inf, ~replace_na(., 0))

#hospitalisation
df$hospital_counts=ifelse(is.na(df$hospital_counts),0,df$hospital_counts)

# care_home_type

df$care_home_type=ifelse(df$care_home_type=="Yes",1,0)



# variables for analysis
df2=subset(df,select=c("wave","patient_index_date","patient_id","subclass","case","sex","age","age_cat","stp","region","ethnicity_6","bmi","bmi_cat","CCI","Charlson","smoking_cat_3","imd","care_home","covrx_ever","flu_vaccine",
"ab_types","interval", "lastABtime","ab_prescriptions","ab_qn_5","ab_qn","total_ab","total_ab_qn_5","total_ab_qn","broad_ab_prescriptions", "br_ab_qn","br_ab_qn_5","br_total_ab_qn_5","level",
"cancer_comor","cerebrovascular_disease_comor", "chronic_obstructive_pulmonary_comor", "heart_failure_comor", "connective_tissue_comor", "dementia_comor", "diabetes_comor", "diabetes_complications_comor", "hemiplegia_comor", "hiv_comor", "metastatic_cancer_comor", "mild_liver_comor", "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor", "peptic_ulcer_comor", "peripheral_vascular_comor",
#"cancer","cvd","copd","heart_failure","connective_tissue","dementia","diabetes","diabetes_complications","hemiplegia","hiv","metastatic_cancer","mild_liver","mod_severe_liver","mod_severe_renal","mi","peptic_ulcer","peripheral_vascular",
"care_home_type","hospital_counts"
))

write_rds(df2, here::here("output", "matched_outcome.rds"))


# check again
df=df%>%filter(is.na(ons_died_date_before))
df=df%>%filter(is.na(dereg_date))
write_rds(df, here::here("output", "matched_outcome_check.rds"))

rm(list=ls())


