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

df <- readRDS("cohort_1.rds")

df<- df %>% dplyr::select(type,age,sex,date)
df <- df %>% mutate(age_group = case_when(age>3 & age<=10 ~ "3-10",
                                          age>=11 & age<=20 ~ "11-20",
                                          age>=21 & age<=30 ~ "21-30",
                                          age>=31 & age<=40 ~ "31-40",
                                          age>=41 & age<=50 ~ "41-50",
                                          age>=51 & age<=60 ~ "51-60",
                                          age>=61 & age<=70 ~ "61-70",
                                          age>=71 ~ "70+"))


df_ab <- df %>% group_by(sex,age_group) %>% summarise(
  numOutcome = n(),
)

write_csv(df_ab, here::here("output", "age_sex_ab_check.csv"))


df.19 <- df %>% filter(date <= as.Date("2019-12-31")& date >= as.Date("2019-01-01"))

df_ab <- df.19 %>% group_by(sex,age_group) %>% summarise(
  numOutcome = n(),
)

write_csv(df_ab, here::here("output", "age_sex_ab_check_2019.csv"))

df.20 <- df %>% filter(date <= as.Date("2020-12-31")& date >= as.Date("2020-01-01"))

df_ab <- df.20 %>% group_by(sex,age_group) %>% summarise(
  numOutcome = n(),
)

write_csv(df_ab, here::here("output", "age_sex_ab_check_2020.csv"))

df.21 <- df %>% filter(date <= as.Date("2021-12-31")& date >= as.Date("2021-01-01"))

df_ab <- df.21 %>% group_by(sex,age_group) %>% summarise(
  numOutcome = n(),
)

write_csv(df_ab, here::here("output", "age_sex_ab_check_2021.csv"))

