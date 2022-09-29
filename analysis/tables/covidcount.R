

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

setwd(here::here("output"))

### read data  ###
### use new synthesised .rds files for faster loading

df.20 <- read.csv('input_covidnum_2020.csv.gz')
df.21 <- read.csv('input_covidnum_2021.csv.gz')
df.22 <- read.csv('input_covidnum_2022.csv.gz')

df.20_pos <- df.20%>%filter(Positive_test_event==1)%>%summarise(count20=length(patient_id))
df.21_pos <- df.21%>%filter(Positive_test_event==1)%>%summarise(count21=length(patient_id))
df.22_pos <- df.22%>%filter(Positive_test_event==1)%>%summarise(count22=length(patient_id))

df.20_neg <- df.20%>%filter(Positive_test_event==0)%>%summarise(count20=length(patient_id))
df.21_neg <- df.21%>%filter(Positive_test_event==0)%>%summarise(count21=length(patient_id))
df.22_neg <- df.22%>%filter(Positive_test_event==0)%>%summarise(count22=length(patient_id))

df <-cbind(df.20_pos,df.21_pos,df.22_pos,df.20_neg,df.21_neg,df.22_neg)

write_csv(df, here::here("output", "covid_count.csv"))

