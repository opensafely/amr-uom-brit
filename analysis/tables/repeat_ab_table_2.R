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
df <- df%>%filter(Date>=as.Date('2019-01-01'))

## Types of antibiotics prescribed for repeat courses 

df2 <- df %>% group_by(patient_id) %>% arrange(date,.by_group = TRUE)%>% 
  mutate(type2=lead(type))

### Appropriateness of antibiotic prescribing by indication

### Asthma

df1 <- df %>% filter(infection == "Asthma")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "asthma_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Asthma")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "asthma_ab_type.csv"))
rm(df2.1)
### Cold

df1 <- df %>% filter(infection == "Cold")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "cold_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Cold")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "cold_ab_type.csv"))
rm(df2.1)
### Cough

df1 <- df %>% filter(infection == "Cough")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "cough_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Cough")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "cough_ab_type.csv"))
rm(df2.1)
### COPD

df1 <- df %>% filter(infection == "COPD")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "copd_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "COPD")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "copd_ab_type.csv"))
rm(df2.1)
### Pneumonia

df1 <- df %>% filter(infection == "Pneumonia")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "pneumonia_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Pneumonia")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "pneumonia_ab_type.csv"))
rm(df2.1)
### Renal

df1 <- df %>% filter(infection == "Renal")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "renal_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Renal")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "renal_ab_type.csv"))
rm(df2.1)
### Sepsis

df1 <- df %>% filter(infection == "Sepsis")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "sepsis_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Sepsis")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "sepsis_ab_type.csv"))
rm(df2.1)
### UTI

df1 <- df %>% filter(infection == "UTI")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "uti_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "UTI")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "uti_ab_type.csv"))
rm(df2.1)
### LRTI

df1 <- df %>% filter(infection == "LRTI")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "lrti_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "LRTI")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "lrti_ab_type.csv"))
rm(df2.1)
### URTI

df1 <- df %>% filter(infection == "URTI")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "urti_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "URTI")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "urti_ab_type.csv"))
rm(df2.1)
### Sinusitis

df1 <- df %>% filter(infection == "Sinusitis")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "sinusitis_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Sinusitis")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "sinusitis_ab_type.csv"))
rm(df2.1)
### Otitis media

df1 <- df %>% filter(infection == "Otitis media")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "otmedia_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Otitis media")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "otmedia_ab_type.csv"))
rm(df2.1)
### Otitis externa

df1 <- df %>% filter(infection == "Otitis externa")
df1.1 <- df1 %>% group_by(incidental,type) %>% summarise(count=n())
df1.1 <- df1.1 %>% mutate(total_ab=sum(count))
df1.1$prop <- df1.1$count/df1.1$total_ab
### for counts > 100
df1.1 <- df1.1 %>% filter(count > 100)

write_csv(df1.1, here::here("output", "ot_externa_ab.csv"))
rm(df1,df1.1)
## Types of antibiotics prescribed for repeat courses 

df2.1 <- df2 %>% filter(infection == "Otitis externa")
df2.1 <- df2.1 %>% group_by(type,type2) %>% summarise(count=n())
df2.1$total_ab <- sum(df2.1$count)
df2.1$prop <- df2.1$count/df2.1$total_ab
### for counts > 100
df2.1 <- df2.1 %>% filter(count > 100)

write_csv(df2.1, here::here("output", "ot_externa_ab_type.csv"))