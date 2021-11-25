##############
## Consultation rates for 6 common infection over time,
## stratified overall and by age categories. 
## Consultation for common infection will only include those with no prior records in 6 weeks of the same infection.
##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("cowplot")



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
df$date <- as.Date(df$date)
# 1.1 unifrom col name

df=df%>% rename(infection_counts=uti_counts, incdt_pt=incdt_uti_pt)

### 2. summarise table

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))



# bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

bar1 <- ggplot(df_plot, aes(x=date, y=rate))+
  scale_x_date(date_labels = "%b %Y")+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = as.Date("2021-01-01"),ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-11-01"),ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-03-01"),ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  facet_grid(rows = vars(age_cat))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(
    title = "UTI",
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")



ggsave(
  plot=bar1,
  filename="consult_age_UTI.png", path=here::here("output"),
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
df$date <- as.Date(df$date)
# 1.1 unifrom col name

df=df%>% rename(infection_counts=lrti_counts, incdt_pt=incdt_lrti_pt) ### !!  ####

### 2. summarise table

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))



# bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

bar2 <- ggplot(df_plot, aes(x=date, y=rate))+
  scale_x_date(date_labels = "%b %Y")+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = as.Date("2021-01-01"),ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-11-01"),ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-03-01"),ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  facet_grid(rows = vars(age_cat))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(
    title = "LRTI",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")



ggsave(
  plot= bar2,
  filename="consult_age_LRTI.png", path=here::here("output"), ### !!  ####
)

rm(list=ls())



########### URTI ################
## 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_URTI.csv"), ### !!  ####
  col_types = cols_only(
    
   # Identifier
    practice = col_integer(),
    
    #Outcomes
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
df$date <- as.Date(df$date)
#1.1 unifrom col name

df=df%>% rename(infection_counts=urti_counts, incdt_pt=incdt_urti_pt) ### !!  ####

## 2. summarise table

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


## 3. plot

df_plot=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))



# bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

bar3 <- ggplot(df_plot, aes(x=date, y=rate))+
  scale_x_date(date_labels = "%b %Y")+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = as.Date("2021-01-01"),ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-11-01"),ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-03-01"),ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  facet_grid(rows = vars(age_cat))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(
    title = "URTI",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")


ggsave(
  plot= bar3,
  filename="consult_age_URTI.png", path=here::here("output"), ### !!  ####
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
df$date <- as.Date(df$date)
# 1.1 unifrom col name

df=df%>% rename(infection_counts=sinusitis_counts, incdt_pt=incdt_sinusitis_pt) ### !!  ####

### 2. summarise table

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))



#  bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

bar4 <- ggplot(df_plot, aes(x=date, y=rate))+
  scale_x_date(date_labels = "%b %Y")+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = as.Date("2021-01-01"),ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-11-01"),ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-03-01"),ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  facet_grid(rows = vars(age_cat))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(
    title = "sinusitis",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")



ggsave(
  plot= bar4,
  filename="consult_age_sinusitis.png", path=here::here("output"), ### !!  ####
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
df$date <- as.Date(df$date)
# 1.1 unifrom col name

df=df%>% rename(infection_counts=ot_externa_counts, incdt_pt=incdt_ot_externa_pt) ### !!  ####

### 2. summarise table

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))



#  bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

bar5 <- ggplot(df_plot, aes(x=date, y=rate))+
  scale_x_date(date_labels = "%b %Y")+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = as.Date("2021-01-01"),ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-11-01"),ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-03-01"),ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  facet_grid(rows = vars(age_cat))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(
    title = "ot_externa",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")



ggsave(
  plot= bar5,
  filename="consult_age_ot_externa.png", path=here::here("output"), ### !!  ####
)

rm(list=ls())



########## otmedia ################
## 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_consult_otmedia.csv"), ### !!  ####
  col_types = cols_only(
    
    #Identifier
    practice = col_integer(),
    
    #Outcomes
    otmedia_counts  = col_double(), ### !!  ####
    population  = col_double(),
    incdt_otmedia_pt = col_double(), ### !!  ####
    age_cat = col_character(),
    value = col_double(),
    
    #Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

# 1.1 unifrom col name
df=df%>% rename(infection_counts=otmedia_counts, incdt_pt=incdt_otmedia_pt) ### !!  ####

## 2. summarise table

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_pt==0,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


## 3. plot

df_plot=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))



#bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

bar6 <- ggplot(df_plot, aes(x=date, y=rate))+
  scale_x_date(date_labels = "%b %Y")+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = as.Date("2021-01-01"),ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-11-01"),ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-03-01"),ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  facet_grid(rows = vars(age_cat))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(
    title = "ot_externa",   ### !!  ####
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")



ggsave(
  plot= bar6,
  filename="consult_age_otmedia.png", path=here::here("output"), ### !!  ####
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
df$date <- as.Date(df$date)
# 1.1 unifrom col name

df=df%>% rename(infection_counts=uti_counts, incdt_pt=incdt_uti_pt)

### 2. summarise table

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=1 (means repeated UTI case) , count consultation times
df$incdt_counts=ifelse(df$incdt_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))



# bar chart
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

bar7 <- ggplot(df_plot, aes(x=date, y=rate))+
  scale_x_date(date_labels = "%b %Y")+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = as.Date("2021-01-01"),ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-11-01"),ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = as.Date("2020-03-01"),ymin = -Inf, ymax = Inf,fill="grey60")+
  geom_col()+
  facet_grid(rows = vars(age_cat))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(
    title = "repeated UTI",
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")



ggsave(
  plot= bar7,
  filename="consult_age_repeatedUTI.png", path=here::here("output"),
)

rm(list=ls())
