
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate charlson comorbidity scores and baseline table for service evaluation
# # # # # # # # # # # # # # # # # # # # #

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

setwd(here::here("output", "measures"))

### read data  ###
### use new synthesised .rds files for faster loading

df <- read.csv('input_covrx_2022.csv', na.strings = "")


# ## Any covid vaccine
# str(df_one_pat$covrx1_dat)
# summary(df_one_pat$covrx1_dat)
# summary(df_one_pat$covrx2_dat)
df$covrx1=ifelse(is.na(df$covrx1_dat),0,1)
df$covrx2=ifelse(is.na(df$covrx2_dat),0,1)
df$covrx=ifelse(df$covrx1 >0 | df$covrx2 >0, 1, 0)

number=sum(df$covrx)


write.table(number, here::here("output", "covrx_2022.txt"))

