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

df <- readRDS("cohort2.rds")
df$incident_prevalent <- ifelse(df$ab_prevalent == 0 & df$ab_prevalent_infection == 0,"incident","prevalent")

### outcome 1: no repeat, ab type ok 
### outcome 2: no repeat, ab type not ok 
### outcome 3: repeat
### throat

throattype <- c("Phenoxymethylpenicillin", "Clarithromycin", "Erythromycin")

df1 <- df %>% filter(infection== "Sore throat")
df1 <- df1 %>% mutate(outcome = case_when(df1$ab_repeat==0 & df1$type %in% throattype ~ 1,
                          df1$ab_repeat==0 & df1$type %in% throattype == FALSE ~ 2,
                          df1$ab_repeat==1  ~ 3))

### URTI

urtitype <- c("Phenoxymethylpenicillin", "Erythromycin", "Clarithromycin")

df2 <- df %>% filter(infection== "URTI")
df2 <- df2 %>% mutate(outcome = case_when(df2$ab_repeat==0 & df2$type %in% urtitype ~ 1,
                          df2$ab_repeat==0 & df2$type %in% urtitype == FALSE ~ 2,
                          df2$ab_repeat==1  ~ 3)) 

### Sinusitis

sinusitistype <- c("Amoxicillin", "Phenoxymethylpenicillin", "Doxycycline",
 "Erythromycin", "Clarithromycin", "Co-amoxiclav")

df3 <- df %>% filter(infection== "Sinusitis")
df3 <- df3 %>% mutate(outcome = case_when(df3$ab_repeat==0 & df3$type %in% sinusitistype ~ 1,
                          df3$ab_repeat==0 & df3$type %in% sinusitistype == FALSE ~ 2,
                          df3$ab_repeat==1  ~ 3))

### otitis externa

ot_externatype <- c("Flucloxacillin", "Clarithromycin", "Neomycin", "Ciprofloxacin", "Erythromycin")

df4 <- df %>% filter(infection== "Otitis externa")
df4 <- df4 %>% mutate(outcome = case_when(df4$ab_repeat==0 & df4$type %in% ot_externatype ~ 1,
                          df4$ab_repeat==0 & df4$type %in% ot_externatype == FALSE ~ 2,
                          df4$ab_repeat==1  ~ 3))

### otitis media

otmediatype <- c("Amoxicillin", "Erythromycin", "Clarithromycin", "Co-amoxiclav")

df5 <- df %>% filter(infection== "Otitis media")
df5 <- df5 %>% mutate(outcome = case_when(df5$ab_repeat==0 & df5$type %in% otmediatype ~ 1,
                          df5$ab_repeat==0 & df5$type %in% otmediatype == FALSE ~ 2,
                          df5$ab_repeat==1  ~ 3))

### COPD

copdtype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Co-amoxiclav", 
"Trimethoprim", "Levofloxacin", "Piperacillin")

df6 <- df %>% filter(infection== "COPD")
df6 <- df6 %>% mutate(outcome = case_when(df6$ab_repeat==0 & df6$type %in% copdtype ~ 1,
                          df6$ab_repeat==0 & df6$type %in% copdtype == FALSE ~ 2,
                          df6$ab_repeat==1  ~ 3)) 

### Cough

coughtype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Erythromycin")

df7 <- df %>% filter(infection== "Cough")
df7 <- df7 %>% mutate(outcome = case_when(df7$ab_repeat==0 & df7$type %in% coughtype ~ 1,
                          df7$ab_repeat==0 & df7$type %in% coughtype == FALSE ~ 2,
                          df7$ab_repeat==1  ~ 3))

### Pneumonia

pneumoniatype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Erythromycin", "Co-amoxiclav", "Levofloxacin")

df8 <- df %>% filter(infection== "Pneumonia")
df8 <- df8 %>% mutate(outcome = case_when(df8$ab_repeat==0 & df8$type %in% pneumoniatype ~ 1,
                          df8$ab_repeat==0 & df8$type %in% pneumoniatype == FALSE ~ 2,
                          df8$ab_repeat==1  ~ 3)) 

### lrti

lrtitype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Azithromycin", "Erythromycin",
              "Levofloxacin", "Co-amoxiclav", "Ofloxacin", "Moxifloxacin", "Ciprofloxacin")

df9 <- df %>% filter(infection== "LRTI")
df9 <- df9 %>% mutate(outcome = case_when(df9$ab_repeat==0 & df9$type %in% lrtitype ~ 1,
                          df9$ab_repeat==0 & df9$type %in% lrtitype == FALSE ~ 2,
                          df9$ab_repeat==1  ~ 3))

### uti

utitype <- c("Amoxicillin", "Ampicillin", "Cefaclor", "Cefadroxil", "Cefalexin",
 "Cefazolin", "Cefixime", "Cefoxitin", "Cefprozil", "Cefradine", "Ceftazidime",
  "Ceftriaxone", "Cefuroxime", "Ceftazidime", "Ceftriaxone", "Chloramphenicol",
   "Co-amoxiclav", "Fosfomycin", "Levofloxacin", "Norfloxacin", "Ofloxacin", "Pivampicillin", "Trimethoprim",
    "Nitrofurantoin" )

df10 <- df %>% filter(infection== "UTI")
df10 <- df10 %>% mutate(outcome = case_when(df10$ab_repeat==0 & df10$type %in% utitype ~ 1,
                          df10$ab_repeat==0 & df10$type %in% utitype == FALSE ~ 2,
                          df10$ab_repeat==1  ~ 3))

DF <- rbind(df1,df2,df3,df4,df5,df6,df7,df8,df9,df10)
DF$incident_prevalent <- as.factor(DF$incident_prevalent)
DF$outcome <- as.factor(DF$outcome)
DF$ethnicity_6 <- as.factor(DF$ethnicity_6)
DF$imd <- as.factor(DF$imd)
DF$region <- as.factor(DF$region)
DF$charlsonGrp <- as.factor(DF$charlsonGrp)
DF$antibiotics_12mb4 <- as.factor(DF$antibiotics_12mb4)  
DF$incident_prevalent <- relevel(DF$incident_prevalent, ref = "incident")                                          
DF$outcome <- relevel(DF$outcome, ref = "1")
DF$ethnicity_6 <- relevel(DF$ethnicity_6, ref = "White")
DF$imd <- relevel(DF$imd, ref = "1")
DF$region <- relevel(DF$region, ref = "East")
DF$charlsonGrp <- relevel(DF$charlsonGrp, ref = "zero")
DF$antibiotics_12mb4 <- relevel(DF$antibiotics_12mb4, ref = "0")
DF <- DF %>% dplyr::select(outcome,age,sex,ethnicity_6,region,charlsonGrp,imd,incident_prevalent,antibiotics_12mb4,infection)
DF <- DF %>% filter (DF$sex=="M"|DF$sex=="F")
DF <- DF %>% filter (!is.na(outcome))
DF <- DF %>% filter (!is.na(ethnicity_6))
DF <- DF %>% filter (!is.na(imd))
DF <- DF %>% filter (!is.na(region))
DF <- DF %>% filter (!is.na(charlsonGrp))
DF <- DF %>% filter (!is.na(age))
DF <- DF %>% filter (!is.na(sex))
DF <- DF %>% filter (!is.na(antibiotics_12mb4))
DF <- DF %>% filter (!is.na(incident_prevalent))

write_csv(DF, here::here("output", "model_preparation.csv"))


# generate data table in All level #
DF_all_frequency <- DF %>% group_by(infection,incident_prevalent,outcome) %>% summarise(
  numOutcome = n(),
)

DF_all_count <- DF %>% group_by(infection,incident_prevalent) %>% summarise(
  numEligible = n(),
)
DF_all_frequency <- merge(DF_all_frequency,DF_all_count,by=c("infection","incident_prevalent"))

DF_all_frequency$percentage <- DF_all_frequency$numOutcome*100/DF_all_frequency$numEligible

write_csv(DF_all_frequency, here::here("output", "model_preparation_table.csv"))

throat_ab_frequency <- select(df1,type)
urti_ab_frequency <- select(df2,type)
sinusitis_ab_frequency <- select(df3,type)
ot_externa_ab_frequency <- select(df4,type)
ot_media_ab_frequency <- select(df5,type)
copd_ab_frequency <- select(df6,type)
cough_ab_frequency <- select(df7,type)
pneumonia_ab_frequency <- select(df8,type)
lrti_ab_frequency <- select(df9,type)
uti_ab_frequency <- select(df10,type)


colsfortab <- colnames(throat_ab_frequency)
throat_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "throat_ab_frequency.csv"))

colsfortab <- colnames(urti_ab_frequency)
urti_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "urti_ab_frequency.csv"))

colsfortab <- colnames(sinusitis_ab_frequency)
sinusitis_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "sinusitis_ab_frequency.csv"))

colsfortab <- colnames(ot_externa_ab_frequency)
ot_externa_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "ot_externa_ab_frequency.csv"))

colsfortab <- colnames(ot_media_ab_frequency)
ot_media_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "ot_media_ab_frequency.csv"))

colsfortab <- colnames(copd_ab_frequency)
copd_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "copd_ab_frequency.csv"))

colsfortab <- colnames(cough_ab_frequency)
cough_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "cough_ab_frequency.csv"))

colsfortab <- colnames(pneumonia_ab_frequency)
pneumonia_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "pneumonia_ab_frequency.csv"))

colsfortab <- colnames(lrti_ab_frequency)
lrti_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "lrti_ab_frequency.csv"))

colsfortab <- colnames(uti_ab_frequency)
uti_ab_frequency %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "uti_ab_frequency.csv"))