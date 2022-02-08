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




### 1. import data 
##1.1 UTI
df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_UTI.csv"),
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

df=df%>% rename(infection_counts=uti_counts, incdt_pt=incdt_uti_pt)

df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")
TPPnumber=length(unique(df$practice))

# select incident pt and count consultations
# incdt_pt==0 means has no consultation in prior 6 weeks
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


# add variables
df_1=df_sum_gp_age%>%
  #group_by(date,age_cat)%>%
  #summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="UTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)


###1.2 LRTI
#import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_LRTI.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    lrti_counts  = col_double(), 
    population  = col_double(),
    incdt_lrti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)
df=df%>% rename(infection_counts=lrti_counts, incdt_pt=incdt_lrti_pt) 
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


# add variables

df_2=df_sum_gp_age%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="LRTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)



### 1.3 URTI
#import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_URTI.csv"), 
  col_types = cols_only(
    
   # Identifier
    practice = col_integer(),
    
    #Outcomes
    urti_counts  = col_double(), 
    population  = col_double(),
    incdt_urti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
   # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)
df=df%>% rename(infection_counts=urti_counts, incdt_pt=incdt_urti_pt) 
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


# add variables
df_3=df_sum_gp_age%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="URTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)




###1.4 sinusitis 
#import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_sinusitis.csv"), 
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    sinusitis_counts  = col_double(), 
    population  = col_double(),
    incdt_sinusitis_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)
df=df%>% rename(infection_counts=sinusitis_counts, incdt_pt=incdt_sinusitis_pt) 
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


# add variables

df_4=df_sum_gp_age%>%
  group_by(date,age_cat)%>%
  summarise(rate=mean(rate))%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="sinusitis")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)





### 1.5 ot_externa 
# import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_ot_externa.csv"), 
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    ot_externa_counts  = col_double(), 
    population  = col_double(),
    incdt_ot_externa_pt = col_double(), 
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=ot_externa_counts, incdt_pt=incdt_ot_externa_pt) 

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


# add variables

df_5=df_sum_gp_age%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="otitis externa")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)




### 1.6 otmedia 
# import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_otmedia.csv"), 
  col_types = cols_only(
    
    #Identifier
    practice = col_integer(),
    
    #Outcomes
    otmedia_counts  = col_double(), 
    population  = col_double(),
    incdt_otmedia_pt = col_double(), 
    age_cat = col_character(),
    value = col_double(),
    
    #Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=otmedia_counts, incdt_pt=incdt_otmedia_pt) 

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

# add variables
df_6=df_sum_gp_age%>%
  mutate(year=format(date,"%Y"),
        month=format(date,"%m"),
         indic="otitis media")
rm(df,df_sum_gp_age,last.date)



### 2. combined dataframe

df=rbind(df_1,df_2,df_3,df_4,df_5,df_6)


### 3. plots

## 3.1 consultation rate by age group

#summarise table
df_plot=df%>%
group_by(date,age_cat,indic)%>%
summarise(rate=mean(rate))

write.csv(df_plot,here::here("output","consultation_rate.csv"))


# line graph- by age group and divided by year
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))
df_plot$year=format(df_plot$date,"%Y")
df_plot$month=format(df_plot$date,"%m")

lineplot_1<- ggplot(df_plot, aes(x=month, y=rate,group=year,color=year))+
  facet_grid(rows = vars(age_cat), cols = vars(indic))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  scale_x_discrete(breaks =c("01","03","05","07","09","11"))+
  #scale_y_continuous(n.breaks = 20)+
  labs(
    title = "Consultation rate per 1,000 registered patients",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices"),
    x = "", 
    y = "")

lineplot_2<- ggplot(df_plot, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  facet_grid(rows = vars(indic))+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
    legend.position = "bottom",legend.title =element_blank())+
   labs(
    title = "Consultation rate per 1,000 registered patients",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices; National lockdown in grey background"),
    x = "", 
    y = "")

  ggsave(
  plot= lineplot_1,
  filename="consult_age_1.jpeg", path=here::here("output"))

  ggsave(
  plot= lineplot_2,
  filename="consult_age_2.jpeg", path=here::here("output"))


## 3.2 consultation rate by percentile 

#summarise table
df_gprate=df%>%
group_by(date,practice)%>%
summarise(ab_rate_1000=mean(rate))

write.csv(df_gprate,here::here("output","consultation_GP_rate.csv"))


df_gprate$cal_year=format(df_gprate$date,"%Y")
df_gprate$cal_mon=format(df_gprate$date,"%m")


num_uniq_prac <- as.numeric(dim(table((df_gprate$practice))))

df_mean <- df_gprate %>% group_by(cal_mon, cal_year) %>%
  mutate(meanABrate = mean(ab_rate_1000,na.rm=TRUE),
         lowquart= quantile(ab_rate_1000, na.rm=TRUE)[2],
         highquart= quantile(ab_rate_1000, na.rm=TRUE)[4],
         ninefive= quantile(ab_rate_1000, na.rm=TRUE, c(0.95)),
         five=quantile(ab_rate_1000, na.rm=TRUE, c(0.05)))

  
plot_percentile <- ggplot(df_mean, aes(x=date))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(y=meanABrate),color="steelblue")+
  geom_point(aes(y=meanABrate),color="steelblue")+
  geom_line(aes(y=lowquart), color="darkred", linetype=3)+
  geom_point(aes(y=lowquart), color="darkred", linetype=3)+
  geom_line(aes(y=highquart), color="darkred", linetype=3)+
  geom_point(aes(y=highquart), color="darkred", linetype=3)+
  geom_line(aes(y=ninefive), color="black", linetype=3)+
  geom_point(aes(y=ninefive), color="black", linetype=3)+
  geom_line(aes(y=five), color="black", linetype=3)+
  geom_point(aes(y=five), color="black", linetype=3)+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 20)+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  labs(
    title = "Consultation rate per 1000 registered patients",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", num_uniq_prac,"TPP Practices; 
    National lockdown in grey background"),
    x = "",
    y = "")+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")))+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")))

plot_percentile 

ggsave(
  plot= plot_percentile,
  filename="consult_all.jpeg", path=here::here("output"),
)

