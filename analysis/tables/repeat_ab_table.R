library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

df1 <- readRDS('ab_type_pre.rds')
df2 <- readRDS('ab_type_2019.rds')
df3 <- readRDS('ab_type_2020.rds')
df4 <- readRDS('ab_type_2021.rds')
df5 <- readRDS('ab_type_2022.rds')
df2 <- bind_rows(df2)
df3 <- bind_rows(df3)
df4 <- bind_rows(df4)

DF <- rbind(df1,df2,df3,df4,df5)
rm(df1,df2,df3,df4,df5)

# recode
DF$infection=recode(DF$infection,
                     asthma ="Asthma",
                     cold="Cold",
                     cough="Cough",
                     copd="COPD",
                     pneumonia="Pneumonia",
                     renal="Renal",
                     sepsis="Sepsis",
                     throat="Sore throat",
                     uti = "UTI",
                     lrti = "LRTI",
                     urti = "URTI",
                     sinusits = "Sinusitis",
                     otmedia = "Otitis media",
                     ot_externa = "Otitis externa")
DF$infection[DF$infection == ""] <- NA  
DF$date <- as.Date(DF$date)
df <- DF
rm(DF)
##. Incidental common infection was defined as a record without any 
##  similar infection in the 90 days before, no antibiotic prescribing 
##  in the 30 days before or any other common infection in the 30 days before.

df <- df %>% group_by(patient_id,infection) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(date_int=as.numeric(date-lag(date)))
df$Same_infect=ifelse(is.na(df$date_int)|df$date_int>90,0,1)

### repeat use
df <- df %>% group_by(patient_id) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(date_int=as.numeric(date-lag(date)))
df$any_ab_before=ifelse(is.na(df$date_int)|df$date_int>30,0,1)
df <- df %>% group_by(patient_id) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(date_int=as.numeric(lead(date)-date))
df$any_ab_after=ifelse(is.na(df$date_int)|df$date_int>30,0,1)
df$repeat_ab <- ifelse(df$any_ab_before==1|df$any_ab_after==1,1,0)

### any infection
df <- df %>% group_by(patient_id) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(pre_infect=lag(infection))
df$Any_infect <- ifelse(is.na(df$pre_infect)==FALSE&df$any_ab_before==1,1,0)

### incidental infection
df$incidental <- ifelse(df$Same_infect==0&df$any_ab_before==0,1,0)


### table 1 incidental infection
df1 <- df%>%filter(Date>=as.Date('2019-01-01'))
df1.1 <- df1 %>% group_by(infection,repeat_ab) %>% summarise(count=n())
df1.1 <- df1.1 %>% group_by(infection) %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab

write_csv(df1.1, here::here("output", "blt_repeat_ab.csv"))

rm(df,df1.1)
### Appropriateness of antibiotic prescribing by indication
### sore throat Phenoxymethylpenicillin Clarithromycin Erythromycin

df_throat <- df1 %>% filter(infection == "Sore throat")
df_throat_tab <- df_throat %>% group_by(incidental,type) %>% summarise(count=n())
df_throat_tab <- df_throat_tab %>% mutate(total_ab=sum(count))
df_throat_tab$prop <- df_throat_tab$count/df_throat_tab$total_ab
### for counts > 100
df_throat_tab <- df_throat_tab %>% filter(count > 100)

df_throat_tab$deviation <- 1
df_throat_tab$deviation <- ifelse( df_throat_tab$type == "Phenoxymethylpenicillin",0, df_throat_tab$deviation)
df_throat_tab$deviation <- ifelse( df_throat_tab$type == "Clarithromycin",0, df_throat_tab$deviation)
df_throat_tab$deviation <- ifelse( df_throat_tab$type == "Erythromycin",0, df_throat_tab$deviation)
df_throat_tab <- df_throat_tab %>% arrange(desc(count))
write_csv(df_throat_tab, here::here("output", "throat_ab.csv"))
rm(df_throat,df_throat_tab)
## Types of antibiotics prescribed for repeat courses 

df1 <- df1 %>% group_by(patient_id) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(type2=lead(type))

df_throat_tpye <- df1 %>% filter(infection == "Sore throat")
df_throat_tpye <- df_throat_tpye %>% filter(repeat_ab == 1)
df_throat_tpye_tab <- df_throat_tpye %>% group_by(type,type2) %>% summarise(count=n())
df_throat_tpye_tab$total_ab <- sum(df_throat_tpye_tab$count)
df_throat_tpye_tab$prop <- df_throat_tpye_tab$count/df_throat_tpye_tab$total_ab
### for counts > 100
df_throat_tpye_tab <- df_throat_tpye_tab %>% filter(count > 100) %>% arrange(desc(count)) 

write_csv(df_throat_tpye_tab, here::here("output", "throat_ab_type.csv"))