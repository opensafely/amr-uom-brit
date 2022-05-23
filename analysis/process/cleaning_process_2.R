library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

DF <- readRDS("cleaned_ab_infection.rds")

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
DF$type[DF$type ==""] <- NA
DF$date <- as.Date(DF$date)
df <- DF
rm(DF)
##  Incidental common infection was defined as a record without any 
##  similar infection in the 90 days before, no any other common 
##  infection in the 30 days before.

### same infection (no similar infection 90 days before)
df <- df %>% group_by(patient_id,infection) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(date_int=as.numeric(date-lag(date)))
df$Same_infect=ifelse(is.na(df$date_int)|df$date_int>90,0,1)

### same day ab

df$ab_flag <- ifelse(is.na(df$type),0,1)
df$infect_flag <- ifelse(is.na(df$infection),0,1)
df$sameday_ab <- ifelse(df$ab_flag==1 & df$infect_flag==1,1,0)

### repeat use & Antibiotics used in past 12 months 

df_ab <- df %>% filter(ab_flag==1) %>% group_by(patient_id) %>% 
  arrange(date,.by_group = TRUE)%>% 
  mutate(date_int=as.numeric(date-lag(date)))
df_ab$any_ab_before=ifelse(is.na(df_ab$date_int)|df_ab$date_int>30,0,1)

df_ab <- df_ab %>% group_by(patient_id) %>% 
  arrange(date,.by_group = TRUE)%>% 
  mutate(date_2int = date_int + lag(date_int)) %>%
  mutate(date_3int = date_int + lag(date_2int)) %>%
  mutate(date_4int = date_int + lag(date_3int)) %>%
  mutate(date_5int = date_int + lag(date_4int)) 


df_ab_0 <- df_ab %>% filter(any_ab_before==0) %>%
  mutate(ab12b4 = case_when(date_int <=365  ~ 1,
                            date_int > 365|is.na(date_int) ~ 0))

df_ab_1 <- df_ab %>% filter(any_ab_before==1) %>% 
  mutate(ab12b4 = case_when(date_2int <= 30 & date_3int <= 30 & date_4int <= 30 & date_5int > 30 & date_5int <= 365  ~ 1,
                            date_2int <= 30 & date_3int <= 30 & date_4int > 30 & date_4int <= 365 ~ 1,
                            date_2int <= 30 & date_3int > 30 & date_3int <= 365 ~ 1,
                            date_2int > 30 & date_2int <= 365 ~ 1,
                            date_2int <= 30 & date_3int <= 30 & date_4int <= 30 & date_5int > 365| is.na(date_5int)  ~ 0,
                            date_2int <= 30 & date_3int <= 30 & date_4int > 365 | is.na(date_4int)~ 0,
                            date_2int <= 30 & date_3int > 365 | is.na(date_3int) ~ 0,
                            date_2int > 365 | is.na(date_2int) ~ 0))


df_ab <- rbind(df_ab_0,df_ab_1)
rm(df_ab_0,df_ab_1)

df_ab <- df_ab %>% group_by(patient_id) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(date_int=as.numeric(lead(date)-date))
df_ab$any_ab_after=ifelse(is.na(df_ab$date_int)|df_ab$date_int>30,0,1)
df_ab$repeat_ab <- ifelse(df_ab$any_ab_before==1|df_ab$any_ab_after==1,1,0)
## Types of antibiotics prescribed for repeat courses 
df_ab <- df_ab %>% group_by(patient_id) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(type2=lead(type))
### any infection
### The any group included records of a common infection that were recorded at 
### least 30 days apart (in order to minimise double counting of the same infection.)
df_infect <- df %>% group_by(patient_id,infect_flag) %>%
  arrange(date,.by_group = TRUE)%>% 
  mutate(date_int=as.numeric(date-lag(date)))

df_infect$any_infect <- ifelse(df_infect$date_int>=30|is.na(df_infect$date_int),0,1)
df_infect$any_infect <- ifelse(df_infect$infect_flag==0,0,df_infect$any_infect)
df_infect_ab <- df_infect %>% filter(ab_flag==1)
### incidental infection
df_infect_ab <- df_infect_ab[,-7]
df_ab <- df_ab[,-7]
df1 <- left_join(df_infect_ab,df_ab)
rm(df_ab,df_infect,df,df_infect_ab)
df1 <- df1 %>% filter(ab_flag==1) 

df1$incidental <- ifelse(df1$Same_infect==0&df1$any_infect==0,1,0)
df1 <- df1%>%filter(date>=as.Date('2019-01-01'))
df1 <- df1%>%filter(date<=as.Date('2021-12-31'))
df1 <- dplyr::select(df1,patient_id, date, infection, type, age, sex, Same_infect, 
                       ab_flag, infect_flag, sameday_ab, any_infect, 
                        ab12b4, repeat_ab, type2, incidental)
saveRDS(df1, "cleaned_indication_ab.rds")