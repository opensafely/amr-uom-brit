##############

library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())


df <- read_csv(
    here::here("output", "measures", "measure_broad_op_brit_abtype_age.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 antibacterial_brit_abtype  = col_character(),
                 
                 # Outcomes
                 antibacterial_brit   = col_double(),
                 population  = col_double(),
                 value = col_double(),
                 age_cat = col_character(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)


df$cal_year <- year(df$date)

df.all <- df %>% group_by(cal_year,age_cat) %>% summarise(
    ab_count = sum(antibacterial_brit)
)

df.abtype <- df %>% group_by(cal_year,age_cat,antibacterial_brit_abtype) %>% summarise(
    type_count = sum(antibacterial_brit)
)

df.freq.talbe <- merge(df.abtype,df.all,by = c("cal_year","age_cat"))
df.freq.talbe$prop <- df.freq.talbe$type_count/df.freq.talbe$ab_count

write_csv(df.freq.talbe, here::here("output", "TPP_ab_frequency_table.csv"))