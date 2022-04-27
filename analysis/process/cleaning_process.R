library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')


rm(list=ls())
setwd(here::here("output", "measures"))

df1 <- readRDS('infect_all_2019.rds')
df2 <- readRDS('infect_all_2020.rds')
df3 <- readRDS('infect_all_2021.rds')
df4 <- readRDS('infect_all_2022.rds')
df5 <- readRDS('infect_all_pre.rds')
df1 <- bind_rows(df1)
df2 <- bind_rows(df2)
df3 <- bind_rows(df3)

DF1 <- rbind(df1,df2,df3,df4,df5)
rm(df1,df2,df3,df4,df5)

df1 <- readRDS('ab_type_pre.rds')
df2 <- readRDS('ab_type_2019.rds')
df3 <- readRDS('ab_type_2020.rds')
df4 <- readRDS('ab_type_2021.rds')
df5 <- readRDS('ab_type_2022.rds')
df2 <- bind_rows(df2)
df3 <- bind_rows(df3)
df4 <- bind_rows(df4)

DF2 <- rbind(df1,df2,df3,df4,df5)
rm(df1,df2,df3,df4,df5)

DF1 <- DF1 %>% rename(infect_times = times)
DF1 <- DF1 %>% select(patient_id,age,sex,date,infection)

DF2 <- DF2 %>% select(patient_id,age,sex,date,type,infection)
DF <- full_join(DF1, DF2, by = c("patient_id","date","infection"))

DF$age <- ifelse(is.na(DF$age.x),DF$age.y,DF$age.x)
DF <- DF[,c(-2,-6)]
DF$sex <- ifelse(is.na(DF$sex.x),DF$sex.y,DF$sex.x)
DF <- DF[,c(-2,-5)]

saveRDS(DF, "cleaned_ab_infection.rds")