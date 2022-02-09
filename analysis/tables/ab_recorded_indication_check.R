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
csvFiles = c("input_antibiotics_2020_2020-01-01.csv.gz","input_antibiotics_2020_2020-02-01.csv.gz","input_antibiotics_2020_2020-03-01.csv.gz",
"input_antibiotics_2020_2020-04-01.csv.gz","input_antibiotics_2020_2020-05-01.csv.gz","input_antibiotics_2020_2020-06-01.csv.gz",
"input_antibiotics_2020_2020-07-01.csv.gz","input_antibiotics_2020_2020-08-01.csv.gz","input_antibiotics_2020_2020-09-01.csv.gz",
"input_antibiotics_2020_2020-10-01.csv.gz","input_antibiotics_2020_2020-11-01.csv.gz","input_antibiotics_2020_2020-12-01.csv.gz")
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
df$ab_counts_9=rowSums(df[ab_count_10[1:9]])
df$ab_counts_8=rowSums(df[ab_count_10[1:8]])
df$ab_counts_7=rowSums(df[ab_count_10[1:7]])
df$ab_counts_6=rowSums(df[ab_count_10[1:6]])
df$ab_counts_5=rowSums(df[ab_count_10[1:5]])
df$ab_counts_4=rowSums(df[ab_count_10[1:4]])
df$ab_counts_3=rowSums(df[ab_count_10[1:3]])
df$ab_counts_2=rowSums(df[ab_count_10[1:2]])

df=df%>%summarise(ab_counts_10=sum(ab_counts_10),
                  ab_counts_9=sum(ab_counts_9),
                  ab_counts_8=sum(ab_counts_8),
                  ab_counts_7=sum(ab_counts_7),
                  ab_counts_6=sum(ab_counts_6),
                  ab_counts_5=sum(ab_counts_5),
                  ab_counts_4=sum(ab_counts_4),
                  ab_counts_3=sum(ab_counts_3),
                  ab_counts_2=sum(ab_counts_2),
                  antibacterial_brit=sum(antibacterial_brit))%>%
  mutate(date=as.Date(datelist[i]))

temp[[i]] <-df
rm(df)
}

library('plyr')
# combine list -> data.table/data.frame
DF <-plyr::ldply(temp, data.frame) 


DF$percent_10=DF$ab_counts_10/DF$antibacterial_brit
DF$percent_9=DF$ab_counts_9/DF$antibacterial_brit
DF$percent_8=DF$ab_counts_8/DF$antibacterial_brit
DF$percent_7=DF$ab_counts_7/DF$antibacterial_brit
DF$percent_6=DF$ab_counts_6/DF$antibacterial_brit
DF$percent_5=DF$ab_counts_5/DF$antibacterial_brit
DF$percent_4=DF$ab_counts_4/DF$antibacterial_brit
DF$percent_3=DF$ab_counts_3/DF$antibacterial_brit
DF$percent_2=DF$ab_counts_2/DF$antibacterial_brit


write_csv(DF, here::here("output", "check_ab_extraction.csv"))



DF.line=DF[,11:20]
DF.line=DF.line%>%gather(sum.counts,percent,"percent_10","percent_9","percent_8","percent_7","percent_6","percent_5","percent_4","percent_3","percent_2",-date)

DF.line$sum.counts=factor(DF.line$sum.counts,levels=c("percent_10","percent_9","percent_8","percent_7","percent_6","percent_5","percent_4","percent_3","percent_2"))

line=ggplot(data=DF.line, aes(x=sum.counts, y=percent, group=date)) +
  geom_line(aes(linetype=as.character(date)))

ggsave(plot= line,
  filename="check_ab_extraction.jpeg", path=here::here("output"))