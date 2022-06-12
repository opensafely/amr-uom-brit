### This script is for preparing the variables for broad spectrum antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

df <- readRDS("cohort_1.rds")

df <- df %>% filter(incidental==1)

### outcome 1: no repeat, ab type ok 
### outcome 2: no repeat, ab type not ok 
### outcome 3: repeat
### throat

throattype <- c("Phenoxymethylpenicillin", "Clarithromycin", "Erythromycin")

df1 <- df %>% filter(infection== "Sore throat")
df1 <- df1 %>% mutate(outcome = case_when(df1$repeat_ab==0 & df1$type %in% throattype ~ 1,
                          df1$repeat_ab==0 & df1$type %in% throattype == FALSE ~ 2,
                          df1$repeat_ab==1  ~ 3))

### URTI

urtitype <- c("Phenoxymethylpenicillin", "Erythromycin", "Clarithromycin")

df2 <- df %>% filter(infection== "URTI")
df2 <- df2 %>% mutate(outcome = case_when(df2$repeat_ab==0 & df2$type %in% urtitype ~ 1,
                          df2$repeat_ab==0 & df2$type %in% urtitype == FALSE ~ 2,
                          df2$repeat_ab==1  ~ 3)) 

### Sinusitis

sinusitistype <- c("Amoxicillin", "Phenoxymethylpenicillin", "Doxycycline",
 "Erythromycin", "Clarithromycin", "Co-amoxiclav")

df3 <- df %>% filter(infection== "Sinusitis")
df3 <- df3 %>% mutate(outcome = case_when(df3$repeat_ab==0 & df3$type %in% sinusitistype ~ 1,
                          df3$repeat_ab==0 & df3$type %in% sinusitistype == FALSE ~ 2,
                          df3$repeat_ab==1  ~ 3))

### otitis externa

ot_externatype <- c("Flucloxacillin", "Clarithromycin", "Neomycin", "Ciprofloxacin", "Erythromycin")

df4 <- df %>% filter(infection== "Otitis externa")
df4 <- df4 %>% mutate(outcome = case_when(df4$repeat_ab==0 & df4$type %in% ot_externatype ~ 1,
                          df4$repeat_ab==0 & df4$type %in% ot_externatype == FALSE ~ 2,
                          df4$repeat_ab==1  ~ 3))

### otitis media

otmediatype <- c("Amoxicillin", "Erythromycin", "Clarithromycin", "Co-amoxiclav")

df5 <- df %>% filter(infection== "Otitis media")
df5 <- df5 %>% mutate(outcome = case_when(df5$repeat_ab==0 & df5$type %in% otmediatype ~ 1,
                          df5$repeat_ab==0 & df5$type %in% otmediatype == FALSE ~ 2,
                          df5$repeat_ab==1  ~ 3))

### COPD

copdtype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Co-amoxiclav", 
"Trimethoprim", "Levofloxacin", "Piperacillin")

df6 <- df %>% filter(infection== "COPD")
df6 <- df6 %>% mutate(outcome = case_when(df6$repeat_ab==0 & df6$type %in% copdtype ~ 1,
                          df6$repeat_ab==0 & df6$type %in% copdtype == FALSE ~ 2,
                          df6$repeat_ab==1  ~ 3)) 

### Cough

coughtype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Erythromycin")

df7 <- df %>% filter(infection== "Cough")
df7 <- df7 %>% mutate(outcome = case_when(df7$repeat_ab==0 & df7$type %in% coughtype ~ 1,
                          df7$repeat_ab==0 & df7$type %in% coughtype == FALSE ~ 2,
                          df7$repeat_ab==1  ~ 3))

### Pneumonia

pneumoniatype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Erythromycin", "Co-amoxiclav", "Levofloxacin")

df8 <- df %>% filter(infection== "Pneumonia")
df8 <- df8 %>% mutate(outcome = case_when(df8$repeat_ab==0 & df8$type %in% pneumoniatype ~ 1,
                          df8$repeat_ab==0 & df8$type %in% pneumoniatype == FALSE ~ 2,
                          df8$repeat_ab==1  ~ 3)) 

### lrti

lrtitype <- c("Amoxicillin", "Doxycycline", "Clarithromycin", "Azithromycin", "Erythromycin",
              "Levofloxacin", "Co-amoxiclav", "Ofloxacin", "Moxifloxacin", "Ciprofloxacin")

df9 <- df %>% filter(infection== "LRTI")
df9 <- df9 %>% mutate(outcome = case_when(df9$repeat_ab==0 & df9$type %in% lrtitype ~ 1,
                          df9$repeat_ab==0 & df9$type %in% lrtitype == FALSE ~ 2,
                          df9$repeat_ab==1  ~ 3))

### uti

utitype <- c("Amoxicillin", "Ampicillin", "Cefaclor", "Cefadroxil", "Cefalexin",
 "Cefazolin", "Cefixime", "Cefoxitin", "Cefprozil", "Cefradine", "Ceftazidime",
  "Ceftriaxone", "Cefuroxime", "Ceftazidime", "Ceftriaxone", "Chloramphenicol",
   "Co-amoxiclav", "Fosfomycin", "Levofloxacin", "Norfloxacin", "Ofloxacin", "Pivampicillin", "Trimethoprim",
    "Nitrofurantoin" )

df10 <- df %>% filter(infection== "UTI")
df10 <- df10 %>% mutate(outcome = case_when(df10$repeat_ab==0 & df10$type %in% utitype ~ 1,
                          df10$repeat_ab==0 & df10$type %in% utitype == FALSE ~ 2,
                          df10$repeat_ab==1  ~ 3))

df <- rbind(df1,df2,df3,df4,df5,df6,df6,df8,df9,df10)

write_csv(df, here::here("output", "ten_infection_outcome.csv"))



