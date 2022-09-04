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

### throat

df1 <- df %>% filter(infection== "Sore throat")

### URTI

df2 <- df %>% filter(infection== "URTI")

### Sinusitis

df3 <- df %>% filter(infection== "Sinusitis")

### otitis externa

df4 <- df %>% filter(infection== "Otitis externa")

### otitis media

df5 <- df %>% filter(infection== "Otitis media")

### COPD

df6 <- df %>% filter(infection== "COPD")

### Cough

df7 <- df %>% filter(infection== "Cough")

### Pneumonia

df8 <- df %>% filter(infection== "Pneumonia")

### lrti

df9 <- df %>% filter(infection== "LRTI")

### uti

df10 <- df %>% filter(infection== "UTI")


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