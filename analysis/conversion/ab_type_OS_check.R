

library("dplyr")
library("tidyverse")
library("lubridate")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

### id extraction 2019 ###

df1 <- readRDS("process_ab_type_OS.rds")
df1 <- bind_rows(df1)


DF <- select(df1,type,infection)

colsfortab <- colnames(DF)
DF %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "ab_type_OS_check.csv"))