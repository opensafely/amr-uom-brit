library("dplyr")
library("tidyverse")
library("lubridate")
library("ggsci")


rm(list=ls())
setwd(here::here("output"))


col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        sepsis_type = col_integer(),       
                        patient_id = col_number()
)


lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")

df <- read_csv("case_ch.csv",
                col_types = col_spec)


df1 <- df %>% filter(patient_index_date <= as.Date("2019-06-30"))
df2 <- df %>% filter(patient_index_date > as.Date("2019-06-30") & patient_index_date <= as.Date("2019-12-31"))
df3 <- df %>% filter(patient_index_date > as.Date("2019-12-31") & patient_index_date <= as.Date("2020-06-30"))
df4 <- df %>% filter(patient_index_date > as.Date("2020-06-30") & patient_index_date <= as.Date("2020-12-31"))
df5 <- df %>% filter(patient_index_date > as.Date("2020-12-31") & patient_index_date <= as.Date("2021-06-30"))
df6 <- df %>% filter(patient_index_date > as.Date("2021-06-30") & patient_index_date <= as.Date("2021-12-31"))
df7 <- df %>% filter(patient_index_date > as.Date("2021-12-31") & patient_index_date <= as.Date("2022-06-30"))
df8 <- df %>% filter(patient_index_date > as.Date("2022-06-30") & patient_index_date <= as.Date("2022-12-31"))

write_csv(df1, here::here("output", "case_191.csv"))
write_csv(df2, here::here("output", "case_192.csv"))
write_csv(df3, here::here("output", "case_201.csv"))
write_csv(df4, here::here("output", "case_202.csv"))
write_csv(df5, here::here("output", "case_211.csv"))
write_csv(df6, here::here("output", "case_212.csv"))
write_csv(df7, here::here("output", "case_221.csv"))
write_csv(df8, here::here("output", "case_222.csv"))

col_spec1 <-cols_only(age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(), 
                        patient_id = col_number()
)

dfcontrol191 <- read_csv("input_control_1.csv",
                col_types = col_spec1)

dfcontrol191$patient_index_date <-as.Date("2019-03-31")
write_csv(dfcontrol191, here::here("output", "control_191.csv"))

dfcontrol192 <- read_csv("input_control_2.csv",
                col_types = col_spec1)

dfcontrol192$patient_index_date <-as.Date("2019-09-30")

write_csv(dfcontrol192, here::here("output", "control_192.csv"))

dfcontrol201 <- read_csv("input_control_3.csv",
                col_types = col_spec1)

dfcontrol201$patient_index_date <-as.Date("2020-03-31")

write_csv(dfcontrol201, here::here("output", "control_201.csv"))

dfcontrol202 <- read_csv("input_control_4.csv",
                col_types = col_spec1)

dfcontrol202$patient_index_date <-as.Date("2020-09-30")

write_csv(dfcontrol202, here::here("output", "control_202.csv"))

dfcontrol211 <- read_csv("input_control_5.csv",
                col_types = col_spec1)

dfcontrol211$patient_index_date <-as.Date("2021-03-31")

write_csv(dfcontrol211, here::here("output", "control_211.csv"))

dfcontrol212 <- read_csv("input_control_6.csv",
                col_types = col_spec1)

dfcontrol212$patient_index_date <-as.Date("2021-09-30")

write_csv(dfcontrol212, here::here("output", "control_212.csv"))

dfcontrol221 <- read_csv("input_control_7.csv",
                col_types = col_spec1)

dfcontrol221$patient_index_date <-as.Date("2022-03-31")

write_csv(dfcontrol221, here::here("output", "control_221.csv"))

dfcontrol222 <- read_csv("input_control_8.csv",
                col_types = col_spec1)

dfcontrol222$patient_index_date <-as.Date("2022-09-30")

write_csv(dfcontrol222, here::here("output", "control_222.csv"))