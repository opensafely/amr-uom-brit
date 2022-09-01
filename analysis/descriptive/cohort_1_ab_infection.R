## Import libraries---
library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")


rm(list=ls())
setwd(here::here("output", "measures"))

df1 <- readRDS("process_1_2019.rds")
df2 <- readRDS("process_1_2020.rds")
df3 <- readRDS("process_1_2021.rds")

df1 <- select(df1,type,infection)
colsfortab <- colnames(df1)
df1 %>% summary_factorlist(explanatory = colsfortab) -> t1

write_csv(t1, here::here("output", "frequency_2019.csv"))

df2 <- select(df2,type,infection)
colsfortab <- colnames(df2)
df2 %>% summary_factorlist(explanatory = colsfortab) -> t2

write_csv(t2, here::here("output", "frequency_2020.csv"))

df3 <- select(df3,type,infection)
colsfortab <- colnames(df3)
df3 %>% summary_factorlist(explanatory = colsfortab) -> t3

write_csv(t3, here::here("output", "frequency_2021.csv"))

df <-rbind(df1,df2,df3)
colsfortab <- colnames(df)
df %>% summary_factorlist(explanatory = colsfortab) -> t4

write_csv(t4, here::here("output", "frequency_all.csv"))