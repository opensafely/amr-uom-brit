##############
## Consultation rates for 6 common infection over time,
## stratified by age categories. 
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

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select incident pt and count consultations
## incdt_pt==0 means has no consultation in prior 6 weeks
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


df_1=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="UTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)


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
# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

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

df_2=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="LRTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)



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
# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

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

df_3=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="URTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)




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
# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

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

df_4=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="sinusitis")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)





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
# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

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

df_5=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="otitis externa")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)




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
# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

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
df_6=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="otitis media")
rm(df,df_sum_gp_age,last.date)



##### 4. combined plots

df_plot=rbind(df_1,df_2,df_3,df_4,df_5,df_6)
write.csv(df_plot,here::here("output","consultation_rate.csv"))

# line graph- by age group and divided by year
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

lineplot<- ggplot(df_plot, aes(x=month, y=rate,group=year,color=year))+
  facet_grid(rows = vars(age_cat), cols = vars(indic))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  scale_x_discrete(breaks =c("01","04","07","10"))+
  #theme(axis.text.x = element_blank())+
  labs(
    title = "consultation rate per 1,000 registered patients",
    x = "month", 
    y = "rate",
    caption = paste0("Data from TPP Practices, ",paste(first_mon,"-",last_mon)))

ggsave(
  plot= lineplot,
  filename="consult_age_all.jpg", path=here::here("output"))