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

df1 <- merge(DF1,df2.1,by=c("patient_id"))
rm(DF1,df2.1)
df2 <- merge(DF2,df2.2,by=c("patient_id"))
rm(DF2,df2.2)
df3 <- merge(DF3,df2.3,by=c("patient_id"))
rm(DF3,df2.3)

df <- rbind(df1,df2,df3)
rm(df1,df2,df3)

df$ethnicity_6 <- as.factor(df$ethnicity_6)
df$imd <- as.factor(df$imd)
df$region <- as.factor(df$region)
df$charlsonGrp <- as.factor(df$charlsonGrp)
df$ab12b4 <- as.factor(df$ab12b4)
df <- df %>% dplyr::select(practice,patient_id,incidental,infection,type,repeat_ab,age,sex,ethnicity_6,region,charlsonGrp,imd,ab12b4,date)
df <- df %>% filter (df$sex=="M"|df$sex=="F")
df <- df %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                          age>=16 & age<=44 ~ "16-44",
                                          age>=45 & age<=64 ~ "45-64",
                                          age>=65 ~ "65+"))

saveRDS(df, "cohort_1.rds")