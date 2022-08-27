

library("dplyr")
library("tidyverse")
library("lubridate")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

### id extraction 2019 ###

df1 <- readRDS("process_1_19_part_1.rds")
df2 <- readRDS("process_1_19_part_2.rds")
df1 <- bind_rows(df1)
df2 <- bind_rows(df2)
DF <- rbind(df1,df2)
rm(df1,df2)

DF <- select(DF,type,infection)

colsfortab <- colnames(DF)
DF %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "cohort_1_type_check.csv"))