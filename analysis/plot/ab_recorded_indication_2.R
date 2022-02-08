## Import libraries---
library("tidyverse") 
library("ggplot2")
library('plyr')
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")

rm(list=ls())

setwd(here::here("output", "measures"))

### read data  ###
### import input_antibiotics_2_XXXX-XX-XX.csv 
############ loop reading multiple CSV files ################
# read file list from input.csv
csvFiles = list.files(pattern="input_antibiotics_2_", full.names = TRUE)
temp <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles)){
  filename <- csvFiles[i]
  temp_df <- read_csv(filename)
  filename <- basename(filename)
  filename <-str_remove(filename, "input_antibiotics_2_")
  filename <-str_remove(filename, ".csv.gz")
  
  #add to per-month temp df
  temp_df$date <- filename
  mutate(temp_df, date = as.Date(date, "%Y-%m-%d"))
  
  #add df to list
  temp[[i]] <- temp_df
}

# combine list -> data.table/data.frame
df <-plyr::ldply(temp, data.frame) 
rm(temp,csvFiles,i,temp_df,filename)# remove temporary list
############ loop reading multiple CSV files ################


### remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=min(df$date)
last_mon= max(df$date)

df$date=as.Date(df$date)

# filter all antibiotics users
df=df%>%filter(antibacterial_brit !=0)

# variables names list
prevalent_check=paste0("prevalent_AB_date_",rep(1:10))
ab_count_10=paste0("AB_date_",rep(1:10),"_count")
ab_category=paste0("AB_date_",rep(1:10),"_indication")
indications=c("uti","lrti","urti","sinusits","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat","uncoded")


#replace NA with "uncoded" in AB_indication_1-10 columns
for (i in 1:10){
df[,ab_category[i]]=ifelse(is.na(df[,ab_category[i]]),"uncoded", df[,ab_category[i]])}



####### prevalent prescriptions #######
df1=df

# select prevalent case ->count AB numbers
df1$total_ab_counts=0
for (i in 1:10){ #ab_date1....10
  df1$total_ab_counts=ifelse(df1[,prevalent_check[i]]==1, # if prevalent=1
                     df1[,ab_count_10[i]] + df1$total_ab_counts, df1$total_ab_counts) # sum(ab_count_date1,...10)
  }

# select prevalent case -> count AB numbers by infection
df1[,indications[1:15]]=0 # create empty columns: df$uti, df$urti,.....df$uncoded
for (i in 1:10)
  for (j in 1:15){ #uti,urti,....uncoded)
  df1[,indications[j]]=ifelse(df1[,prevalent_check[i]]==1 &  # if prevalent=1
                               df1[,ab_category[i]]==indications[j], # and ab_date_1_category==uti
                    df1[,ab_count_10[i]]+df1[,indications[j]],  df1[,indications[j]]) # sum(ab_count_date1,...10)

  }
# # summarise AB counts by infections per month
# df1.1=df1%>%dplyr::group_by(date)%>%
#   dplyr::summarise(uti=sum(uti),
#                    urti=sum(urti),
#                    lrti=sum(lrti),
#                    sinusits=sum(sinusits),
#                    otmedia=sum(otmedia),
#                    ot_externa=sum(ot_externa),
#                    asthma=sum(asthma),
#                    cold=sum(cold),
#                    cough=sum(cough),
#                    copd=sum(copd),
#                    pneumonia=sum(pneumonia),
#                    renal=sum(renal),
#                    sepsis=sum(sepsis),
#                    throat=sum(throat),
#                    uncoded=sum(uncoded))
# names(df1.1)[5]<-"sinusitis"# fix typo

# df1.2=df1.1%>%gather(types,counts,"uncoded","uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat",-date)

# # reorder types
# df1.2$types=factor(df1.2$types,levels=c("uncoded","uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat"))
# #stackedbar  
# plot1.2=ggplot(df1.2, aes(x=date, y=counts, fill=types))+
#   geom_bar(position="stack", stat="identity") +
#   geom_vline(xintercept = as.Date("2020-03-01"), linetype="dashed",color = "grey", size=0.5)+
#   geom_vline(xintercept = as.Date("2020-11-01"), linetype="dashed",color = "grey", size=0.5)+
#   geom_vline(xintercept = as.Date("2021-01-01"), linetype="dashed",color = "grey", size=0.5)+
#   labs(
#     title = "Propotion of antibiotics prescriptions with indications- Prevalent prescribing",
#     x = "Time", 
#     y = "number of antibiotic prescriptions")+
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# ggsave(
#   plot= plot1.2,
#   filename="ab_recoded_prevalent.jpeg", path=here::here("output"))





###### incident prescriptions ###### 
df2=df
# select prevalent case ->count AB numbers
df2$total_ab_counts=0
for (i in 1:10){ #ab_date1....10
  df2$total_ab_counts=ifelse(df2[,prevalent_check[i]]==0, # if prevalent=0
                             df2[,ab_count_10[i]] + df2$total_ab_counts, df2$total_ab_counts) # sum(ab_count_date1,...10)
}

# select prevalent case -> count AB numbers by infection
df2[,indications[1:15]]=0 # create empty columns: df$uti, df$urti,.....df$uncoded
for (i in 1:10)
  for (j in 1:15){ #uti,urti,....uncoded)
    df2[,indications[j]]=ifelse(df2[,prevalent_check[i]]==0 &  # if prevalent=0
                                  df2[,ab_category[i]]==indications[j], # and ab_date_1_category==uti
                                df2[,ab_count_10[i]]+df2[,indications[j]],  df2[,indications[j]]) # sum(ab_count_date1,...10)
    
  }

# # summarise AB counts by infections per month
# df2.1=df2%>%dplyr::group_by(date)%>%
#   dplyr::summarise(uti=sum(uti),
#                    urti=sum(urti),
#                    lrti=sum(lrti),
#                    sinusits=sum(sinusits),
#                    otmedia=sum(otmedia),
#                    ot_externa=sum(ot_externa),
#                    asthma=sum(asthma),
#                    cold=sum(cold),
#                    cough=sum(cough),
#                    copd=sum(copd),
#                    pneumonia=sum(pneumonia),
#                    renal=sum(renal),
#                    sepsis=sum(sepsis),
#                    throat=sum(throat),
#                    uncoded=sum(uncoded))
# names(df2.1)[5]<-"sinusitis"# fix typo


# df2.2=df2.1%>%gather(types,counts,"uncoded","uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat",-date)

# df2.2$types=factor(df2.2$types,levels=c("uncoded","uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat"))

# #stackedbar  
# plot2.2=ggplot(df2.2, aes(x=date, y=counts, fill=types))+
#   geom_bar(position="stack", stat="identity") +
#   geom_vline(xintercept = as.Date("2020-03-01"), linetype="dashed",color = "grey", size=0.5)+
#   geom_vline(xintercept = as.Date("2020-11-01"), linetype="dashed",color = "grey", size=0.5)+
#   geom_vline(xintercept = as.Date("2021-01-01"), linetype="dashed",color = "grey", size=0.5)+
#   labs(
#     title = "Propotion of antibiotics prescriptions with indications- Incident prescribing",
#     x = "Time", 
#     y = "number of antibiotic prescriptions")+
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# ggsave(
#   plot= plot2.2,
#   filename="ab_recoded_incident.jpeg", path=here::here("output"))

# rm(df1.1,df2.1,df1.2,df2.2)






##### check data ##### 

df_gp=df%>%dplyr::group_by(date,practice)%>%
  dplyr::summarise(total_ab_brit=sum(antibacterial_brit))

# prevalent
df1_gp=df1%>%dplyr::group_by(date,practice)%>%
  dplyr::summarise(total_ab_prevalence=sum(total_ab_counts))

# incident
df2_gp=df2%>%dplyr::group_by(date,practice)%>%
  dplyr::summarise(total_ab_incidence=sum(total_ab_counts))

# prevalence+incidence
df1_2_gp=merge(df1_gp,df2_gp,by=c("date","practice"))

# rate= counts from 10 extractions / antibiotics_brit numbers
df_check_gp=merge(df1_2_gp,df_gp,by=c("date","practice") )
df_check_gp$included=df_check_gp$total_ab_prevalence+df_check_gp$total_ab_incidence
df_check_gp$rate=df_check_gp$included/df_check_gp$total_ab_brit

# 25-75 percentile plot check for GP-level data
df_summary <- df_check_gp %>% dplyr::group_by(date) %>%
  dplyr::mutate(mean = mean(rate,na.rm=TRUE),
         lowquart= quantile(rate, na.rm=TRUE)[2],
         highquart= quantile(rate, na.rm=TRUE)[4],
         ninefive= quantile(rate, na.rm=TRUE, c(0.95)),
         five=quantile(rate, na.rm=TRUE, c(0.05)))

num_uniq_prac=length(unique(as.factor(df_summary$practice)))

plot_percentile <- ggplot(df_summary, aes(x=date))+
  geom_line(aes(y=mean),color="steelblue")+
  geom_point(aes(y=mean),color="steelblue")+
  geom_line(aes(y=lowquart), color="darkred", linetype=3)+
  geom_point(aes(y=lowquart), color="darkred", linetype=3)+
  geom_line(aes(y=highquart), color="darkred", linetype=3)+
  geom_point(aes(y=highquart), color="darkred", linetype=3)+
  geom_line(aes(y=ninefive), color="black", linetype=3)+
  geom_point(aes(y=ninefive), color="black", linetype=3)+
  geom_line(aes(y=five), color="black", linetype=3)+
  geom_point(aes(y=five), color="black", linetype=3)+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  labs(
    title = "antibiotics prescriptions",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", num_uniq_prac,"TPP Practices"),
    x = "Time",
    y = "% covered by this study"
  )+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")))+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")))

ggsave(
  plot= plot_percentile,
  filename="check_prescriptions_cover_GP.jpeg", path=here::here("output")) 


# overall: incidence+precalence vs. antibiotics_brit numbers
df_check_gp2=df_check_gp%>%dplyr:: group_by(date)%>%
  dplyr::summarise(prevalence=sum(total_ab_prevalence),
                   incidence=sum(total_ab_incidence),
                   total_brit=sum(total_ab_brit))
df_check_gp2.2=df_check_gp2%>%gather(types,counts,"prevalence","incidence","total_brit",-date)
#bar  
plot_overall=ggplot(df_check_gp2.2, aes(x=date, y=counts,fill=types))+
  geom_bar( position=position_dodge(),stat="identity") +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype="dashed",color = "grey", size=0.5)+
  geom_vline(xintercept = as.Date("2020-11-01"), linetype="dashed",color = "grey", size=0.5)+
  geom_vline(xintercept = as.Date("2021-01-01"), linetype="dashed",color = "grey", size=0.5)+
  labs(
    title = "comparison of 10 extractions of AB records and exact AB numbers",
    x = "Time", 
    y = "number of antibiotic prescriptions")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggsave(
  plot= plot_overall,
  filename="check_prescriptions_cover.jpeg", path=here::here("output")) 