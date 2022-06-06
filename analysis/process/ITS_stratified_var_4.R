
##############################################################################
#####          This script is for preparing the variable for ITS         #####
##### The outcome variables includes broad spectrum & repeat prescribing #####
##############################################################################

library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

df <- readRDS("cleaned_indication_ab.rds")

### prepare var ### without Amoxicillin ###
broadtype <- c("Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-03-01")

###  Prepare the data frame for Interrupted time-series analysis  ###
###  Transfer df into numOutcome / numEligible  version
df <- df %>% filter (age>3)
df <- df %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                              age>=16 & age<=44 ~ "16-44",
                                              age>=45 & age<=64 ~ "45-64",
                                              age>=65 ~ "65+"))
df$cal_year <- year(df$date)
df$cal_mon <- month(df$date)
df$time <- as.numeric(df$cal_mon+(df$cal_year-2019)*12)
DF <- df

### Broad spectrum 

df.broad <- df %>% filter(type %in% broadtype ) 
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("time"))

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

write_csv(df.model, here::here("output", "mon_overall_all_prescription.csv"))
rm(df.all,df.broad,df.broad_total,df.model,df)

###  Interrupted time-series analysis  ###
###  UTI

df <- DF %>% filter (infection == "UTI")
df <- df[!is.na(df$type),]

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

write_csv(df.model, here::here("output", "mon_overall_uti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cold

df <- DF %>% filter (infection == "Cold")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)

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

write_csv(df.model, here::here("output", "mon_overall_cold.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cough

df <- DF %>% filter (infection == "Cough")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_cough.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  COPD

df <- DF %>% filter (infection == "COPD")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_copd.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sore throat

df <- DF %>% filter (infection == "Sore throat")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_throat.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  LRTI

df <- DF %>% filter (infection == "LRTI")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_lrti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  URTI

df <- DF %>% filter (infection == "URTI")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_urti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sinusitis

df <- DF %>% filter (infection == "Sinusitis")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_sinusitis.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis media

df <- DF %>% filter (infection == "Otitis media")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_ot_media.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis externa

df <- DF %>% filter (infection == "Otitis externa")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)
df.broad_total$numOutcome <- ifelse(df.broad_total$numOutcome<=10,round(df.broad_total$numOutcome),df.broad_total$numOutcome)
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

write_csv(df.model, here::here("output", "mon_overall_ot_externa.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)
rm(DF)


