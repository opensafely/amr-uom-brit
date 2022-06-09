### This script is for preparing the variables for repeat antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

DF <- readRDS("cleaned_indication_ab.rds")

# recode
DF$date <- as.Date(DF$date)
DF <- DF %>% filter(date <= as.Date("2021-12-31"))
DF <- DF %>% filter(age > 3)
DF1 <- DF %>% filter(date <= as.Date("2019-12-31") & date >= as.Date("2019-01-01"))
DF2 <- DF %>% filter(date <= as.Date("2020-12-31") & date >= as.Date("2020-01-01"))
DF3 <- DF %>% filter(date <= as.Date("2021-12-31") & date >= as.Date("2021-01-01"))

setwd(here::here("output"))
df2.1 <- read_csv("prepared_var_2019.csv") %>% select(-c(age,sex))
df2.2 <- read_csv("prepared_var_2020.csv") %>% select(-c(age,sex))
df2.3 <- read_csv("prepared_var_2021.csv") %>% select(-c(age,sex))
df3.1 <- read_csv("prepared_var_extra_2019.csv") %>% select(c(bmi_cat, smoking_cat_3, hospital_counts))
df3.2 <- read_csv("prepared_var_extra_2020.csv") %>% select(c(bmi_cat, smoking_cat_3, hospital_counts))
df3.3 <- read_csv("prepared_var_extra_2021.csv") %>% select(c(bmi_cat, smoking_cat_3, hospital_counts))

df1 <- merge(DF1,df2.1,by=c("patient_id"))
df1 <- merge(df1,df3.1,by=c("patient_id"))
rm(DF1,df2.1,df3.1)
df2 <- merge(DF2,df2.2,by=c("patient_id"))
df2 <- merge(df2,df3.2,by=c("patient_id"))
rm(DF2,df2.2,df3.2)
df3 <- merge(DF3,df2.3,by=c("patient_id"))
df3 <- merge(df3,df3.3,by=c("patient_id"))
rm(DF3,df2.3,df3.3)

df <- rbind(df1,df2,df3)
rm(df1,df2,df3)





### outcome 1: no repeat, ab type ok 
### outcome 2: no repeat, ab type not ok 
### outcome 3: repeat
### throat

throattype <- c("Phenoxymethylpenicillin", "Clarithromycin", "Erythromycin")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "Sore throat")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% throattype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% throattype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "throat_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "throat_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)

### URTI

urtitype <- c("Phenoxymethylpenicillin", "Erythromycin", "Clarithromycin")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "URTI")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% urtitype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% urtitype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "urti_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "urti_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)   

### Sinusitis

sinusitistype <- c("Amoxicillin", "Phenoxymethylpenicillin", "Doxycycline",
 "Erythromycin", "Clarithromycin", "Co-amoxiclav")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "Sinusitis")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% sinusitistype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% sinusitistype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "sinusitis_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sinusitis_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)  

### otitis externa

ot_externatype <- c("Flucloxacillin", "Clarithromycin", "Neomycin", "Ciprofloxacin", "Erythromycin")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "Otitis externa")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% ot_externatype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% ot_externatype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "ot_externa_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "ot_externa_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)  

### otitis media

otmediatype <- c("Amoxicillin", "Erythromycin", "Clarithromycin", "Co-amoxiclav")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "Otitis media")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% otmediatype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% otmediatype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "otmedia_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "otmedia_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)  

### COPD

copdtype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Co-amoxiclav", 
"Trimethoprim", "Levofloxacin", "Piperacillin")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "COPD")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% copdtype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% copdtype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "copd_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "copd_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)  

### Cough

coughtype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Erythromycin")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "Cough")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% coughtype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% coughtype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "cough_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "cough_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)  

### Pneumonia

pneumoniatype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Erythromycin", "Co-amoxiclav", "Levofloxacin")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "Pneumonia")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% pneumoniatype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% pneumoniatype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "pneumonia_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "pneumonia_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)  


### lrti

lrtitype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Azithromycin", "Erythromycin",
              "Levofloxacin", "Co-amoxiclav", "Ofloxacin", "Moxifloxacin", "Ciprofloxacin")

df1 <- df %>% filter(incidental==1) %>% filter(infection== "LRTI")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% lrtitype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% lrtitype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "lrti_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "lrti_count.csv"))
rm(num_record, num_pats, num_pracs,overall_counts,df1)  
### uti

utitype <- c("Amoxicillin", "Ampicillin", "Cefaclor", "Cefadroxil", "Cefalexin",
 "Cefazolin", "Cefixime", "Cefoxitin", "Cefprozil", "Cefradine", "Ceftazidime",
  "Ceftriaxone", "Cefuroxime", "Ceftazidime", "Ceftriaxone", "Chloramphenicol",
   "Co-amoxiclav", "Fosfomycin", "Levofloxacin", "Norfloxacin", "Ofloxacin", "Pivampicillin", "Trimethoprim",
    "Nitrofurantoin" )

df1 <- df %>% filter(incidental==1) %>% filter(infection== "UTI")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% utitype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% utitype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))
write_csv(df1, here::here("output", "uti_outcome.csv"))
num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))
num_record <- length(df1$patient_id)

overall_counts <- as.data.frame(cbind(num_record, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "uti_count.csv"))



