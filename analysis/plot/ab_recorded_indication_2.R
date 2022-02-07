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
### 1.1 import study definition input.csv
############ loop reading multiple CSV files ################
# read file list from input.csv
csvFiles = list.files(pattern="input_antibiotics_", full.names = TRUE)
temp <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles)){
  filename <- csvFiles[i]
  temp_df <- read_csv(filename)
  filename <- basename(filename)
  filename <-str_remove(filename, "input_antibiotics_")
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


## count prescriptions by infection per patient
uti=c("uti_ab_count_1","uti_ab_count_2","uti_ab_count_3","uti_ab_count_4" )
lrti=c("lrti_ab_count_1"     ,  "lrti_ab_count_2"     ,  "lrti_ab_count_3"    ,   "lrti_ab_count_4" )
urti=c("urti_ab_count_1"    ,   "urti_ab_count_2"     ,  "urti_ab_count_3"   ,    "urti_ab_count_4"   )
sinusitis=c("sinusitis_ab_count_1", "sinusitis_ab_count_2" ,"sinusitis_ab_count_3" , "sinusitis_ab_count_4")
otmedia=c("otmedia_ab_count_1"  ,  "otmedia_ab_count_2"   , "otmedia_ab_count_3"  ,  "otmedia_ab_count_4" )
ot_externa=c("ot_externa_ab_count_1" ,"ot_externa_ab_count_2" ,"ot_externa_ab_count_3","ot_externa_ab_count_4")
asthma=c("asthma_ab_count_1"   ,  "asthma_ab_count_2"   ,  "asthma_ab_count_3"    , "asthma_ab_count_4" )
cold=c("cold_ab_count_1"    ,   "cold_ab_count_2"    ,   "cold_ab_count_3"    ,   "cold_ab_count_4")
cough=c("cough_ab_count_1"  ,   "cough_ab_count_2"  ,    "cough_ab_count_3"  ,    "cough_ab_count_4")
copd=c("copd_ab_count_1"    ,   "copd_ab_count_2"  ,     "copd_ab_count_3"   ,    "copd_ab_count_4" )
pneumonia=c("pneumonia_ab_count_1" , "pneumonia_ab_count_2" , "pneumonia_ab_count_3" , "pneumonia_ab_count_4")
renal=c("renal_ab_count_1"  ,    "renal_ab_count_2"   ,   "renal_ab_count_3"    ,  "renal_ab_count_4" )
sepsis=c("sepsis_ab_count_1"  ,   "sepsis_ab_count_2"   ,  "sepsis_ab_count_3"   ,  "sepsis_ab_count_4"  )
throat=c("throat_ab_count_1"  ,  "throat_ab_count_2"  ,   "throat_ab_count_3"  ,   "throat_ab_count_4"  )
others=c("asthma_ab_count_1"   ,  "asthma_ab_count_2"   ,  "asthma_ab_count_3"    , "asthma_ab_count_4" ,"cold_ab_count_1"    ,   "cold_ab_count_2"    ,   "cold_ab_count_3"    ,   "cold_ab_count_4",
        "cough_ab_count_1"  ,   "cough_ab_count_2"  ,    "cough_ab_count_3"  ,    "cough_ab_count_4","copd_ab_count_1"    ,   "copd_ab_count_2"  ,     "copd_ab_count_3"   ,    "copd_ab_count_4" ,
        "pneumonia_ab_count_1" , "pneumonia_ab_count_2" , "pneumonia_ab_count_3" , "pneumonia_ab_count_4","renal_ab_count_1"  ,    "renal_ab_count_2"   ,   "renal_ab_count_3"    ,  "renal_ab_count_4",
        "sepsis_ab_count_1"  ,   "sepsis_ab_count_2"   ,  "sepsis_ab_count_3"   ,  "sepsis_ab_count_4","throat_ab_count_1"  ,  "throat_ab_count_2"  ,   "throat_ab_count_3"  ,   "throat_ab_count_4" )


df$uti_ab_count=rowSums(df[uti])
df$lrti_ab_count=rowSums(df[lrti])
df$urti_ab_count=rowSums(df[urti])
df$sinusitis_ab_count=rowSums(df[sinusitis])
df$otmedia_ab_count=rowSums(df[otmedia])
df$ot_externa_ab_count=rowSums(df[ot_externa])
df$asthma_ab_count=rowSums(df[asthma])
df$cold_ab_count=rowSums(df[cold])
df$cough_ab_count=rowSums(df[cough])
df$copd_ab_count=rowSums(df[copd])
df$pneumonia_ab_count=rowSums(df[pneumonia])
df$renal_ab_count=rowSums(df[renal])
df$sepsis_ab_count=rowSums(df[sepsis])
df$throat_ab_count=rowSums(df[throat])
df$renal_ab_count=rowSums(df[renal])
df$others_ab_count=rowSums(df[others])

rm("uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat","others")


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=min(df$date)
last_mon= max(df$date)

df$date=as.Date(df$date)


# crude percent

detach(package:plyr)# need removed, or group_by doesn't work
df1=df%>% group_by(date)%>%
  summarise(
    total=sum(antibacterial_brit),
    uti=sum(uti_ab_count),
    lrti=sum(lrti_ab_count),
    urti=sum(urti_ab_count),
    sinusitis=sum(sinusitis_ab_count),
    otmedia=sum(otmedia_ab_count),
    ot_externa=sum(ot_externa_ab_count),
    asthma=sum(asthma_ab_count),
    cold=sum(cold_ab_count),
    cough=sum(cough_ab_count),
    copd=sum(copd_ab_count),
    pneumonia=sum(pneumonia_ab_count),
    renal=sum(renal_ab_count),
    sepsis=sum(sepsis_ab_count),
    throat=sum(throat_ab_count),
    others=sum(others_ab_count)
      )

df1$uncoded=df1$total-rowSums(df1[c("uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat")])
df1.1=df1%>%select(-c("others","total"))

df1.2=df1.1%>%gather(types,counts,"uncoded","uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat",-date)


#stackedbar <- 
plot=ggplot(df1.2, aes(x=date, y=counts, fill=types))+
  geom_bar(position="stack", stat="identity") +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype="dashed",color = "grey", size=0.5)+
  geom_vline(xintercept = as.Date("2020-11-01"), linetype="dashed",color = "grey", size=0.5)+
  geom_vline(xintercept = as.Date("2021-01-01"), linetype="dashed",color = "grey", size=0.5)+
  labs(
    title = "Propotion of prescriptions with indications",
    x = "Time", 
    y = "number of antibiotic prescriptions")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggsave(
  plot= plot,
  filename="ab_recoded_indication.jpeg", path=here::here("output"))






### data check -infection consultations###
names=c("uti","lrti","urti","sinusitis","otmedia","ot_externa","asthma","cold","cough","copd","pneumonia","renal","sepsis","throat")
temp <- vector("list")

for (i in names){
  
  df_check=df%>%select(paste0(i,"_date_1"),paste0(i,"_date_2"),paste0(i,"_date_3"),paste0(i,"_date_4"),paste0(i,"_counts"),"practice","date")
  df_check$count4times=4-rowSums(is.na(df_check))
  names(df_check)[5] <- "counts"
  
  df_check_gp=df_check%>%
    group_by(practice,date)%>%
    summarise(total_infection=sum(counts),
              included=sum(count4times))
  df_check_gp$rate=df_check_gp$included/df_check_gp$total_infection
  df_check_gp$infection=paste0(i)
  
  temp[[i]]=df_check_gp
 
}

df_check_gp <-plyr::ldply(temp, data.frame) 
write.csv(df_check_gp,here::here("output","check_infection_cover.csv"))

df_summary <- df_check_gp %>% group_by(date) %>%
  mutate(mean = mean(rate,na.rm=TRUE),
         lowquart= quantile(rate, na.rm=TRUE)[2],
         highquart= quantile(rate, na.rm=TRUE)[4],
         ninefive= quantile(rate, na.rm=TRUE, c(0.95)),
         five=quantile(rate, na.rm=TRUE, c(0.05)))

num_uniq_prac=length(unique(as.factor(df_summary$practice)))

plot <- ggplot(df_summary, aes(x=date))+
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
    title = "infection consultations",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", num_uniq_prac,"TPP Practices"),
    x = "Time",
    y = "% covered by this study"
  )+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")))+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")))

ggsave(
  plot= plot,
  filename="check_infection_cover.jpeg", path=here::here("output")) 

rm(df_check,df_check_gp,df_summary,temp,plot)

### data check -infection ab prescriptions ###

col_abcount=c("uti_ab_count", "lrti_ab_count", "urti_ab_count", "sinusitis_ab_count", "otmedia_ab_count", "ot_externa_ab_count", "asthma_ab_count", "cold_ab_count", "cough_ab_count", "copd_ab_count", "pneumonia_ab_count", "renal_ab_count", "sepsis_ab_count", "throat_ab_count", "renal_ab_count", "others_ab_count")
df_check=df%>%select(col_abcount,"practice","date","antibacterial_brit")
df_check$included=rowSums(df_check[col_abcount])

df_check_gp=df_check%>%
  group_by(practice,date)%>%
  summarise(included=sum(included),
            total=sum(antibacterial_brit))
df_check_gp$rate=df_check_gp$included/df_check_gp$total

write.csv(df_check_gp,here::here("output","check_infection_ab_cover.csv"))

df_summary <- df_check_gp %>% group_by(date) %>%
  mutate(mean = mean(rate,na.rm=TRUE),
         lowquart= quantile(rate, na.rm=TRUE)[2],
         highquart= quantile(rate, na.rm=TRUE)[4],
         ninefive= quantile(rate, na.rm=TRUE, c(0.95)),
         five=quantile(rate, na.rm=TRUE, c(0.05)))

num_uniq_prac=length(unique(as.factor(df_summary$practice)))

plot<- ggplot(df_summary, aes(x=date))+
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
    caption = paste("Data from approximately", num_uniq_prac,"TPP Practices",
                    ",coverage=extracted prescriptions/ total prescriotions"),
    x = "Time",
    y = "% covered by this study"
  )+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")))+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")))

ggsave(
  plot= plot,
  filename="check_infection_ab_cover.jpeg", path=here::here("output")) 

### data check ###