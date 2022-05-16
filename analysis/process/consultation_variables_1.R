# this script is data preparation for consultation model

library("ggplot2")
library("data.table")
library("dplyr")
library("tidyverse")

setwd(here::here("output", "measures"))
### Import data

#### 1.  extracted variables from "basic_record_20_"

df19 = read_rds(here::here("output","measures","basic_record_2019.rds"))
df19=df19%>% dplyr::select(practice,region)

df20 = read_rds(here::here("output","measures","basic_record_2020.rds"))
df20=df20%>% dplyr::select(practice,region)

df21 = read_rds(here::here("output","measures","basic_record_2021.rds"))
df21=df21%>% dplyr::select(practice,region)

region=rbind(df19,df20,df21)
region=region%>%distinct(practice, .keep_all = TRUE)

rm(df19,df20,df21) 



#### 2.1 read measures for all indications
df <- read_csv(here::here("output","measures","measure_indication_counts.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 indication_counts  = col_double(),
                 population  = col_double(),
                 hx_indications = col_double(),
                 age_cat = col_character(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=indication_counts, hx_pt=hx_indications)

df[is.na(df)] <- 0 # replace NA ->0

#### 03. add variables

# add region variables
df=merge(df,region, by= "practice")


# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# sort age
df$age_cat <- factor(df$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

saveRDS(df,"consult_indications.rds")

rm(df)


#### 2.1 read measures for uti
df <- read_csv(here::here("output","measures","measure_infection_consult_UTI.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 uti_counts  = col_double(),
                 population  = col_double(),
                 hx_uti_pt = col_double(),
                 age_cat = col_character(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=uti_counts, hx_pt=hx_uti_pt)

df[is.na(df)] <- 0 # replace NA ->0

#### 03. add variables

# add region variables
df=merge(df,region, by= "practice")


# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# sort age
df$age_cat <- factor(df$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

saveRDS(df,"consult_UTI.rds")

rm(df)







#### 2.2 read measures for lrti
df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_LRTI.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    lrti_counts  = col_double(), 
    population  = col_double(),
    hx_lrti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=lrti_counts, hx_pt=hx_lrti_pt)

df[is.na(df)] <- 0 # replace NA ->0
#### 03. add variables

# add region variables
df=merge(df,region, by= "practice")


# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# sort age
df$age_cat <- factor(df$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

saveRDS(df,"consult_LRTI.rds")

rm(df)






#### 2.3 read measures for urti
df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_URTI.csv"), 
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    #Outcomes
    urti_counts  = col_double(), 
    population  = col_double(),
    hx_urti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=urti_counts, hx_pt=hx_urti_pt)

df[is.na(df)] <- 0 # replace NA ->0

#### 03. add variables

# add region variables
df=merge(df,region, by= "practice")


# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# sort age
df$age_cat <- factor(df$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

saveRDS(df,"consult_URTI.rds")

rm(df)




#### 2.4 read measures for sinusitis 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_sinusitis.csv"), 
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    sinusitis_counts  = col_double(), 
    population  = col_double(),
    hx_sinusitis_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=sinusitis_counts, hx_pt=hx_sinusitis_pt)

df[is.na(df)] <- 0 # replace NA ->0

#### 03. add variables

# add region variables
df=merge(df,region, by= "practice")


# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# sort age
df$age_cat <- factor(df$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

saveRDS(df,"consult_sinusitis.rds")

rm(df)






#### 2.5 read measures for otmedia

df <- read_csv(here::here("output","measures","measure_infection_consult_otmedia.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 otmedia_counts  = col_double(),
                 population  = col_double(),
                 hx_otmedia_pt = col_double(),
                 age_cat = col_character(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=otmedia_counts, hx_pt=hx_otmedia_pt)

df[is.na(df)] <- 0 # replace NA ->0

#### 03. add variables

# add region variables
df=merge(df,region, by= "practice")


# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# sort age
df$age_cat <- factor(df$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

saveRDS(df,"consult_otmedia.rds")

rm(df)





#### 2.6 read measures for ot_externa

df <- read_csv(here::here("output","measures","measure_infection_consult_ot_externa.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 ot_externa_counts  = col_double(),
                 population  = col_double(),
                 hx_ot_externa_pt = col_double(),
                 age_cat = col_character(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=ot_externa_counts, hx_pt=hx_ot_externa_pt)

df[is.na(df)] <- 0 # replace NA ->0

#### 03. add variables

# add region variables
df=merge(df,region, by= "practice")


# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# sort age
df$age_cat <- factor(df$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

saveRDS(df,"consult_ot_externa.rds")

rm(df)