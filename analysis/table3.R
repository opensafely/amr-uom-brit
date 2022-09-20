# # # # # # # # # # # # # # # # # # # # #
# This script:
# generate baseline table
# round to nearest 5
# 
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library("ggplot2")
library("plyr")
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")



####### ab level count ########
DF=readRDS("matched_outcome.rds")
DF=DF%>%dplyr::select("case","total_ab","level","ab_types")
DF$level=as.factor(DF$level)
DF$case=as.factor(DF$case)
case.num=sum(DF$case==1)
contr.num=sum(DF$case==0)


# select variables
explanatory<- c("total_ab","ab_types","level")
dependent <- "case"

#table
tbl=DF%>% summary_factorlist(dependent, explanatory)

round_tbl=tbl
#remove percentage
round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
round_tbl[,3]=as.numeric(round_tbl[,3])
round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

round_tbl[,4]=as.numeric(round_tbl[,4])
round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)


# level
round_tbl[c(3:8),"percent_0"]=round_tbl[c(3:8),3]/sum(round_tbl[c(3:8),3])*100
round_tbl[c(3:8),"percent_1"]=round_tbl[c(3:8),4]/sum(round_tbl[c(3:8),4])*100

# continuous variables
round_tbl[c(1:2),c(3:4)]=tbl[c(1:2),c(3:4)]


write.csv(round_tbl,"table3.csv")

rm(list=ls())

####### ab summary ########
rm(list=ls())

df=readRDS("matched_outcome.rds")
df$level=as.factor(df$level)
df$case=as.factor(df$case)

df00=df%>%dplyr::select("case","total_ab" ,"level")%>%dplyr::filter(case==0)
df01=df%>%dplyr::select("case","total_ab" ,"level")%>%dplyr::filter(case==1)

#  case
l1=rbind(summary(df01[df01$level==0,]$total_ab),
         summary(df01[df01$level==1,]$total_ab),
         summary(df01[df01$level==2,]$total_ab),
         summary(df01[df01$level==3,]$total_ab),
         summary(df01[df01$level==4,]$total_ab),
         summary(df01[df01$level==5,]$total_ab))
l1=data.frame(l1)

l1=l1%>%select("Median","X1st.Qu.", "X3rd.Qu.","Mean","Min.","Max.")

rownames(l1)<-c("level0","level1","level2","level3","level4","level5")
l1$case="1"

# control
l0=rbind(summary(df00[df00$level==0,]$total_ab),
         summary(df00[df00$level==1,]$total_ab),
         summary(df00[df00$level==2,]$total_ab),
         summary(df00[df00$level==3,]$total_ab),
         summary(df00[df00$level==4,]$total_ab),
         summary(df00[df00$level==5,]$total_ab))

l0=data.frame(l0)

l0=l0%>%select("Median","X1st.Qu.", "X3rd.Qu.","Mean","Min.","Max.")

rownames(l0)<-c("level0","level1","level2","level3","level4","level5")

l0$case="0"

DF=rbind(l1,l0)

write.csv(DF,"table3_ab.csv")

