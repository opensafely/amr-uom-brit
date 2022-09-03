library("tidyverse") 
library('dplyr')
library('lubridate')

setwd(here::here("output"))

#####  cohort 1  ##### All ab prescription record

df.19 <- readRDS("combined_c1_2019.rds")
df.20 <- readRDS("combined_c1_2020.rds")
df.21 <- readRDS("combined_c1_2021.rds")

cohort1 <- bind_rows(df.19,df.20,df.21)

rm(df.19,df.20,df.21)

saveRDS(cohort1, "cohort1.rds")

#####  cohort 2  ##### incident/prevalent infection recorded in coded group

cohort2 <- cohort1 %>% filter(indication == 1,.keep_all = TRUE)

saveRDS(cohort2, "cohort2.rds")

