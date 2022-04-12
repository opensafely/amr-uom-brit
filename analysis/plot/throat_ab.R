library("tidyverse") 
library('dplyr')#conflict with plyr; load after plyr
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

DF=read_rds('ab_type_2019.rds')

#dat=rbindlist(DF)
dat=bind_rows(DF)
rm(DF)

# recode
dat$infection=recode(dat$infection,
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


dat$infection=ifelse(dat$infection=="","uncoded",dat$infection)

##Sore throat

df1 <- dat %>% filter(infection=='Sore throat')
rm(dat)

DF=read_rds('ab_type_2020.rds')

#dat=rbindlist(DF)
dat=bind_rows(DF)
rm(DF)

# recode
dat$infection=recode(dat$infection,
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


dat$infection=ifelse(dat$infection=="","uncoded",dat$infection)

##Sore throat

df2 <- dat %>% filter(infection=='Sore throat')
rm(dat)

DF=read_rds('ab_type_2021.rds')

#dat=rbindlist(DF)
dat=bind_rows(DF)
rm(DF)

# recode
dat$infection=recode(dat$infection,
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


dat$infection=ifelse(dat$infection=="","uncoded",dat$infection)

##Sore throat

df3 <- dat %>% filter(infection=='Sore throat')
rm(dat)

dat=read_rds('ab_type_2022.rds')

# recode
dat$infection=recode(dat$infection,
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


dat$infection=ifelse(dat$infection=="","uncoded",dat$infection)

##Sore throat

df4 <- dat %>% filter(infection=='Sore throat')
rm(dat)

df <- rbind(df1,df2,df3,df4)
rm(df1,df2,df3,df4)

df_throat <- df %>%
  count(type, name="n") %>%
  mutate(freq_rel=n / sum(n))

# df_throat$deviation <- 'NA'
# df_throat$deviation <- ifelse(df_throat$type != '', 1 , df$deviation)
# df_throat$deviation <- ifelse(df_throat$type == 'Phenoxymethylpenicillin', 0 , df$deviation)
# df_throat$deviation <- ifelse(df_throat$type == 'Clarithromycin', 0 , df$deviation)
# df_throat$deviation <- ifelse(df_throat$type == 'Erythromycin', 0 , df$deviation)


write_csv(df_throat, here::here("output", "ab_throat.csv"))