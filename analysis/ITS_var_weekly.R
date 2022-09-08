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

start_covid = as.Date("2020-03-31")
covid_adjustment_period_from = as.Date("2020-03-10")


###  Prepare the data frame for Interrupted time-series analysis  ###
###  Transfer df into numOutcome / numEligible  version

df_raw$cal_year <- year(df_raw$date)
df_raw$time <- as.numeric(ceiling((df_raw$date-as.Date("2018-12-31"))/7))

###  Select coded prescription
df_raw <- df_raw %>% filter (indication == 1)
###  Interrupted time-series analysis  ###
###  UTI

df <- df_raw %>% filter (infection == "UTI")

df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_uti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cold

df <- df_raw %>% filter (infection == "Cold")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_cold.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Cough

df <- df_raw %>% filter (infection == "Cough")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_cough.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)


###  COPD

df <- df_raw %>% filter (infection == "COPD")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_copd.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sore throat

df <- df_raw %>% filter (infection == "Sore throat")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_throat.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  LRTI

df <- df_raw %>% filter (infection == "LRTI")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_lrti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  URTI

df <- df_raw %>% filter (infection == "URTI")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_urti.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Sinusitis

df <- df_raw %>% filter (infection == "Sinusitis")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_sinusitis.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis media

df <- df_raw %>% filter (infection == "Otitis media")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_ot_media.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)

###  Otitis externa

df <- df_raw %>% filter (infection == "Otitis externa")
df.broad <- df %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by="time")

df.model <- df.model %>% mutate(weekPlot = ((time-1)*7) + as.Date("2019-01-01")) %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>%
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))


write_csv(df.model, here::here("output", "week_ot_externa.csv"))
rm(df,df.all,df.broad,df.broad_total,df.model)



col_spec <-cols_only( broad_ab_count = col_number(),
                      antibiotic_count = col_number(),
                      date = col_date(format = "")
)
df <- read_csv("measure_weekly_broad-spectrum-ratio.csv",
               col_types = col_spec)

names(df) <- c("numOutcome","numEligible","weekPlot")

df.model <- df %>%
  mutate(months = as.numeric(format.Date(weekPlot, "%m"))) %>%
  mutate(year = as.numeric(format.Date(weekPlot, "%Y"))-2018) %>% 
  mutate(pre_covid = ifelse(weekPlot < covid_adjustment_period_from , 1, 0),
         during_covid = ifelse(weekPlot >= start_covid , 1, 0)) %>%
  mutate(covid = ifelse(pre_covid == 1 , 0,
                        ifelse (during_covid == 1, 1,
                                NA)))

df.model$time <- as.numeric(ceiling((df.model$weekPlot-as.Date("2018-12-31"))/7))

write_csv(df.model, here::here("output", "week_all.csv"))
