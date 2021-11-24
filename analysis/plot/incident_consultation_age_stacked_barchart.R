##############
## Consultation rates for 6 common infection over time,
## stratified overall and by age categories. 
## Consultation for common infection will only include those with no prior records in 6 weeks of the same infection.
##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")



############ UTI ################
### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_UTI.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    uti_counts  = col_double(),
    population  = col_double(),
    incdt_uti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# 1.1 unifrom col name

df=df%>% rename(infection_counts=uti_counts, incdt_pt=incdt_uti_pt)

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



# stacked bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "UTI",
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="consult_age_stackedbar_UTI.png", path=here::here("output"),
)

rm(list=ls())


############ LRTI ################
### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_LRTI.csv"), ### !!  ####
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    lrti_counts  = col_double(), ### !!  ####
    population  = col_double(),
    incdt_lrti_pt = col_double(), ### !!  ####
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# 1.1 unifrom col name

df=df%>% rename(infection_counts=lrti_counts, incdt_pt=incdt_lrti_pt) ### !!  ####

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



# stacked bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "LRTI",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="consult_age_stackedbar_LRTI.png", path=here::here("output"), ### !!  ####
)

rm(list=ls())



############ URTI ################
### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_URTI.csv"), ### !!  ####
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    urti_counts  = col_double(), ### !!  ####
    population  = col_double(),
    incdt_urti_pt = col_double(), ### !!  ####
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# 1.1 unifrom col name

df=df%>% rename(infection_counts=urti_counts, incdt_pt=incdt_urti_pt) ### !!  ####

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



# stacked bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "URTI",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="consult_age_stackedbar_URTI.png", path=here::here("output"), ### !!  ####
)

rm(list=ls())



############ sinusitis ################
### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_sinusitis.csv"), ### !!  ####
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    sinusitis_counts  = col_double(), ### !!  ####
    population  = col_double(),
    incdt_sinusitis_pt = col_double(), ### !!  ####
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# 1.1 unifrom col name

df=df%>% rename(infection_counts=sinusitis_counts, incdt_pt=incdt_sinusitis_pt) ### !!  ####

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



# stacked bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "sinusitis",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="consult_age_stackedbar_sinusitis.png", path=here::here("output"), ### !!  ####
)

rm(list=ls())




########### ot_externa ################
### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_ot_externa.csv"), ### !!  ####
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    ot_externa_counts  = col_double(), ### !!  ####
    population  = col_double(),
    incdt_ot_externa_pt = col_double(), ### !!  ####
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# 1.1 unifrom col name

df=df%>% rename(infection_counts=ot_externa_counts, incdt_pt=incdt_ot_externa_pt) ### !!  ####

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



# stacked bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "ot_externa",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="consult_age_stackedbar_ot_externa.png", path=here::here("output"), ### !!  ####
)

rm(list=ls())



########### otmedia ################
### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_otmedia.csv"), ### !!  ####
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    otmedia_counts  = col_double(), ### !!  ####
    population  = col_double(),
    incdt_otmedia_pt = col_double(), ### !!  ####
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# 1.1 unifrom col name

df=df%>% rename(infection_counts=otmedia_counts, incdt_pt=incdt_otmedia_pt) ### !!  ####

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



# stacked bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "ot_externa",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="consult_age_stackedbar_otmedia.png", path=here::here("output"), ### !!  ####
)

rm(list=ls())




########### repeated UTI ################
### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_UTI.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    uti_counts  = col_double(),
    population  = col_double(),
    incdt_uti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# 1.1 unifrom col name

df=df%>% rename(infection_counts=uti_counts, incdt_pt=incdt_uti_pt)

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=1 (means repeated UTI case) , count consultation times
df$incdt_counts=ifelse(df$incdt_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



# stacked bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "repeated UTI",
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="consult_age_stackedbar_repeatedUTI.png", path=here::here("output"),
)

rm(list=ls())
