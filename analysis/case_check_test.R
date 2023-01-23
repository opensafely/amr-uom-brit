
# # # # # # # # # # # # # # # # # # # # #
#              This script:             #
#            check case cohort          #
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library("tidyverse") 
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

# import data
col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),               
                        patient_id = col_number()
)

df <- read_csv(here::here("output", "input_case_test.csv"),
                col_types = col_spec)

# raw count in step 0 #
step0 <- length(df$patient_id)

df$cal_year <- year(df$patient_index_date)
df$cal_mon <- month(df$patient_index_date)
df$cal_day <- 1
df$monPlot <- as.Date(with(df,paste(cal_year,cal_mon,cal_day,sep="-")),"%Y-%m-%d")


###  by IMD
df.plot <- df %>% dplyr::group_by(monPlot,imd) %>% dplyr::summarise(value = length(patient_id))
write_csv(df.plot, here::here("output", "case_test.csv"))