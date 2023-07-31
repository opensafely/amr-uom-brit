# # # # # # # # # # # # # # # # # # # # #
# This script:
# generate baseline table
# round to nearest 5
# 
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library('dplyr')
library('plyr')
library("data.table")
library("finalfit")

DF=readRDS(here::here("output","matched_ab.rds"))

# categorised ab exposure variables
col=c("case","subclass",
      "total_ab","ab_types","prescribe_times",
      "exposure_period","recent_ab_days", 
      "broad_prop","broad_ab_prescriptions",
      "interval_mean","interval_med" ,"interval_sd","interval_CV",
      "length_mean","length_med", "length_sd","length_CV")

DF=DF %>% mutate_at(col,as.numeric)

Quartile=data.frame()

for (k in 3:17) {
  
  cut_value=quantile(DF[,col[k]],c(0.25,0.5,0.75))

  DF[,paste0(col[k],"_group")]=ifelse(
    DF[,col[k]] <= cut_value[1],1,NA)  
  
  DF[,paste0(col[k],"_group")]=ifelse(
    DF[,col[k]] > cut_value[1] & DF[,col[k]]<= cut_value[2],2, 
    DF[,paste0(col[k],"_group")])  
  
  DF[,paste0(col[k],"_group")]=ifelse(
    DF[,col[k]] > cut_value[2] & DF[,col[k]]<= cut_value[3],3, 
    DF[,paste0(col[k],"_group")])  
  
  DF[,paste0(col[k],"_group")]=ifelse(
    DF[,col[k]] > cut_value[3],4,DF[,paste0(col[k],"_group")])  
  
  DF[,paste0(col[k],"_group")]=ifelse(
    is.na( DF[,col[k]]) ,0 ,DF[,paste0(col[k],"_group")])  
  
  Quartile[,k]= cut_value
}

# save cut value of each variables
Quartile=Quartile[,-c(1:2)]
colnames(Quartile)=c(
                     "total_ab","ab_types","prescribe_times",
                     "exposure_period","recent_ab_days", 
                     "broad_prop","broad_ab_prescriptions",
                     "interval_mean","interval_med" ,"interval_sd","interval_CV",
                     "length_mean","length_med", "length_sd","length_CV")
write.csv(Quartile,here::here("output","table3_quartile.csv"))


# select variables
DF=DF%>%dplyr::select( "case",
                       "total_ab_group","exposure_period_group","interval_mean_group","interval_sd_group","recent_ab_days_group","ab_types_group","broad_ab_prescriptions_group",
                       "total_ab", "exposure_period","recent_ab_days","interval_mean","interval_sd","ab_types","broad_ab_prescriptions")

DF= DF %>% 
  mutate_at(c(1:8),as.factor)

DF= DF %>% 
  mutate_at(c(9:15), as.numeric)


# categorical variables
explanatory<- c("total_ab_group","exposure_period_group","interval_mean_group","interval_sd_group","recent_ab_days_group","ab_types_group","broad_ab_prescriptions_group",
                "total_ab", "exposure_period","recent_ab_days","interval_mean","interval_sd","ab_types","broad_ab_prescriptions")
dependent <- "case"
tbl=DF%>% summary_factorlist(dependent, explanatory, p=T)

# continuous variables
#explanatory<- c()
#tbl2=DF%>% summary_factorlist(dependent, explanatory, 
  #                       cont = "median", p=T)

round_tbl=tbl
#remove percentage
round_tbl[,3]=gsub("\\(.*?\\)","",round_tbl[,3])
round_tbl[,4]=gsub("\\(.*?\\)","",round_tbl[,4])

#round to 5
round_tbl[,3]=as.numeric(round_tbl[,3])
round_tbl[,3]=plyr::round_any(round_tbl[,3], 5, f = round)

round_tbl[,4]=as.numeric(round_tbl[,4])
round_tbl[,4]=plyr::round_any(round_tbl[,4], 5, f = round)



# median (IQR)

explanatory<- c("total_ab", "exposure_period","recent_ab_days","interval_mean","interval_sd","ab_types","broad_ab_prescriptions")
dependent <- "case"
tbl2=DF%>% summary_factorlist(dependent, explanatory, p=T, cont = "median")

round_tbl=rbind(round_tbl,tbl2)

#write.csv(tbl1,"table3_group.csv")
write.csv(round_tbl,here::here("output","table3.csv"))

rm(list=ls())

# median (IQR) per levels
col<- c("total_ab", "exposure_period","recent_ab_days","interval_mean","interval_sd","ab_types","broad_ab_prescriptions")

table=data.frame()
for (i in 1:5) {
  
  L1=quantile(DF[col[i]==1,col[i]],c(0.25,0.5,0.75))
  L2=quantile(DF[col[i]==2,col[i]],c(0.25,0.5,0.75))
  L3=quantile(DF[col[i]==3,col[i]],c(0.25,0.5,0.75))
  L4=quantile(DF[col[i]==4,col[i]],c(0.25,0.5,0.75)) 

  tbl=rbind(L1,L2,L3,L4)
  row.names(tbl)=c(paste0(col[i],"_L1"),paste0(col[i],"_L2"),paste0(col[i],"_L3"),paste0(col[i],"_L4"))
  table=rbind(table,tbl)
}

for (i in 6:7) {
  
  L1=quantile(DF[col[i]==1,col[i]],c(0.25,0.5,0.75))
  L2=quantile(DF[col[i]==2,col[i]],c(0.25,0.5,0.75))
  L3=quantile(DF[col[i]==3,col[i]],c(0.25,0.5,0.75))

  tbl=rbind(L1,L2,L3)
  row.names(tbl)=c(paste0(col[i],"_L1"),paste0(col[i],"_L2"),paste0(col[i],"_L3"))
  table=rbind(table,tbl)
}

write.csv(table,here::here("output","table3_group.csv"))
