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

### prepare var ###
broadtype <- c("Amoxicillin","Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-01-01")

###  Interrupted time-series analysis  ###
###  UTI

df <- DF %>% filter (infection == "UTI")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_uti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

### Asthma

df <- DF %>% filter (infection == "Asthma")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_asthma.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cold

df <- DF %>% filter (infection == "Cold")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_cold.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cough

df <- DF %>% filter (infection == "Cough")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_cough.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  COPD

df <- DF %>% filter (infection == "COPD")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_copd.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Pneumonia

df <- DF %>% filter (infection == "Pneumonia")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_pneumonia.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Renal

df <- DF %>% filter (infection == "Renal")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_renal.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sepsis

df <- DF %>% filter (infection == "Sepsis")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_sepsis.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sore throat

df <- DF %>% filter (infection == "Sore throat")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_throat.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  LRTI

df <- DF %>% filter (infection == "LRTI")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_lrti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  URTI

df <- DF %>% filter (infection == "URTI")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_urti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sinusitis

df <- DF %>% filter (infection == "Sinusitis")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_sinusitis.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis media

df <- DF %>% filter (infection == "Otitis media")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_ot_media.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis externa

df <- DF %>% filter (infection == "Otitis externa")
df <- df[!is.na(df$type),]

###  Transfer df into numOutcome / numEligible  version

df$cal_year <- year(df$date)
df$time <- as.numeric(ceiling((df$date-as.Date("2018-12-31"))/7))

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n()
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n()
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = (time*7) + as.Date("2018-12-31")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

write_csv(df.model, here::here("output", "df.model_ot_externa.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)



