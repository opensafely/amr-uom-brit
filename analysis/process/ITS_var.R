#### this scirpt transfers the data to a prepared verson for ITS model

###  load library  ###
library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')
###  import data  ###

rm(list=ls())
setwd(here::here("output", "measures"))

df2 <- readRDS('ab_type_2019.rds')
df3 <- readRDS('ab_type_2020.rds')
df4 <- readRDS('ab_type_2021.rds')
df5 <- readRDS('ab_type_2022.rds')
df2 <- bind_rows(df2)
df3 <- bind_rows(df3)
df4 <- bind_rows(df4)

DF <- rbind(df2,df3,df4,df5)
rm(df2,df3,df4,df5)

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
DF$type[DF$type == ""] <- NA  
###  Interrupted time-series analysis  ###
###  UTI

df <- DF %>% filter (infection == "UTI")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

broadtype <- c("Amoxicillin","Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

write_csv(df.model, here::here("output", "df.model.csv"))

