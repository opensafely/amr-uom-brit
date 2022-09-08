#####################################################################################
#####            This script is for preparing the variable for ITS              #####
##### The outcome variables includes broad spectrum and group by infection type #####
#####################################################################################
library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))


df.19 <- read_rds("abtype_2019.rds") %>% select(date,type,infection)
df.20 <- read_rds("abtype_2020.rds") %>% select(date,type,infection)
df.21 <- read_rds("abtype_2021.rds") %>% select(date,type,infection)
df_raw <- bind_rows(df.19,df.20,df.21)
df_raw$date = as.Date(df_raw$date)

df_raw$infection=recode(df_raw$infection,
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
df_raw$infection[df_raw$infection == ""] <- NA
df_raw$indication <- ifelse(is.na(df_raw$infection),0,1)
df_raw <- df_raw %>% filter(!is.na(date))

### prepare var ### URL:https://www.opencodelists.org/codelist/opensafely/co-amoxiclav-cephalosporins-and-quinolones/0d299a50/ ###
broadtype <- c("Co-amoxiclav","Cefaclor","Cefadroxil","Cefixime","Cefotaxime","Ceftriaxone",
"Ceftazidime","Cefuroxime","Cefalexin","Cefradine","Ciprofloxacin","Levofloxacin",
"Moxifloxacin","Nalidixic acid","Norfloxacin","Ofloxacin")

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-03-01")

###  Prepare the data frame for Interrupted time-series analysis  ###
###  Transfer df into numOutcome / numEligible  version

df_raw$cal_year <- year(df_raw$date)
df_raw$cal_mon <- month(df_raw$date)

df_raw$time <- as.numeric(df_raw$cal_mon+(df_raw$cal_year-2019)*12)


###  Select coded prescription
df_raw <- df_raw %>% filter (indication == 1)
###  Interrupted time-series analysis  ###
###  UTI

df <- df_raw %>% filter (infection == "UTI")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_uti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cold

df <- df_raw %>% filter (infection == "Cold")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_cold.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cough

df <- df_raw %>% filter (infection == "Cough")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_cough.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  COPD

df <- df_raw %>% filter (infection == "COPD")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_copd.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sore throat

df <- df_raw %>% filter (infection == "Sore throat")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_throat.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  LRTI

df <- df_raw %>% filter (infection == "LRTI")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_lrti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  URTI

df <- df_raw %>% filter (infection == "URTI")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_urti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sinusitis

df <- df_raw %>% filter (infection == "Sinusitis")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_sinusitis.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis media

df <- df_raw %>% filter (infection == "Otitis media")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_ot_media.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis externa

df <- df_raw %>% filter (infection == "Otitis externa")

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model <- df.model %>%
  mutate(pre_covid = ifelse(monPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(monPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "mon_ot_externa.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)
rm(DF)

col_spec <-cols_only( broad_ab_count = col_number(),
                      antibiotic_count = col_number(),
                      date = col_date(format = "")
)
df <- read_csv("measure_broad-spectrum-ratio.csv",
               col_types = col_spec)

names(df) <- c("numOutcome","numEligible","monPlot")

write_csv(df, here::here("output", "mon_overall.csv"))
