## Import libraries---
library("tidyverse") 
#library("ggplot2")
#library('plyr')
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')
#library('stringr')
#library("data.table")
#library("ggpubr")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")


# file list
csvFiles = c("input_antibiotics_2_2020-01-01.csv.gz","input_antibiotics_2_2020-02-01.csv.gz","input_antibiotics_2_2020-03-01.csv.gz",
             "input_antibiotics_2_2020-04-01.csv.gz","input_antibiotics_2_2020-05-01.csv.gz","input_antibiotics_2_2020-06-01.csv.gz",
             "input_antibiotics_2_2020-07-01.csv.gz","input_antibiotics_2_2020-08-01.csv.gz","input_antibiotics_2_2020-09-01.csv.gz",
             "input_antibiotics_2_2020-10-01.csv.gz","input_antibiotics_2_2020-11-01.csv.gz","input_antibiotics_2_2020-12-01.csv.gz")

datelist= c("2020-01-01","2020-02-01","2020-03-01","2020-04-01","2020-05-01","2020-06-01","2020-07-01","2020-08-01","2020-09-01","2020-10-01","2020-11-01","2020-12-01")
# variables names list
#prevalent_check=paste0("prevalent_AB_date_",rep(1:10))
ab_count_10=paste0("AB_date_",rep(1:10),"_count")
ab_category=paste0("AB_date_",rep(1:10),"_indication")
#indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat","uncoded")
#ab_date_10=paste0("AB_date_",rep(1:10))




##### read data: one month


temp <- vector("list", length(csvFiles))

for (i in 1:6){

  df <- read_csv(csvFiles[i],
  col_types = cols_only(
                 antibacterial_brit=col_double(),
                 AB_date_1_count=col_double(),
                 AB_date_2_count=col_double(),
                 AB_date_3_count=col_double(),
                 AB_date_4_count=col_double(),
                 AB_date_5_count=col_double(),
                 AB_date_6_count=col_double(),
                 AB_date_7_count=col_double(),
                 AB_date_8_count=col_double(),
                 AB_date_9_count=col_double(),
                 AB_date_10_count=col_double()
               ))

# filter all antibiotics users
df=df%>%filter(antibacterial_brit !=0)

# sum total ab counts in 10 extractions
df$ab_counts_10=rowSums(df[ab_count_10])

df=df%>%summarise(ab_counts_10=sum(ab_counts_10),
                  antibacterial_brit=sum(antibacterial_brit))%>%
  mutate(date=as.Date(datelist[i]))

temp[[i]] <-df
rm(df)
}

library('plyr')
# combine list -> data.table/data.frame
DF <-plyr::ldply(temp, data.frame) 

DF$percent=DF$ab_counts_10/DF$antibacterial_bri

write_csv(DF, here::here("output", "check_ab_extraction.csv"))



