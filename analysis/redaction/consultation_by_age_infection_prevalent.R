##############
## Consultation rates for 6 common infection over time,
## stratified by age categories. 
## prevalent= with same infection in 90 days
##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
#library("cowplot")

dir.create(here::here("output", "redacted"))


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
    hx_uti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=uti_counts, hx_pt=hx_uti_pt)

df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")
TPPnumber=length(unique(df$practice))

# select prevalent pt and count consultations
# hx_pt==1 means has same infection consultation in 90 days
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# summarize prevalent counts & total population
df_1=df%>%
  group_by(date,age_cat)%>% 
  summarise(counts=sum(hx_counts), 
            population=sum(population))%>%
  mutate(indic="UTI")

rm(df,first_mon,last_mon,last.date)


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

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select prevalent pt and count consultations
# hx_pt==1 means has same infection consultation in 90 days
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# summarize prevalent counts & total population
df_2=df%>%
  group_by(date,age_cat)%>% 
  summarise(counts=sum(hx_counts), 
            population=sum(population))%>%
  mutate(indic="LRTI")

rm(df,first_mon,last_mon,last.date)



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

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select prevalent pt and count consultations
# hx_pt==1 means has same infection consultation in 90 days
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# summarize prevalent counts & total population
df_3=df%>%
  group_by(date,age_cat)%>% 
  summarise(counts=sum(hx_counts), 
            population=sum(population))%>%
  mutate(indic="URTI")

rm(df,first_mon,last_mon,last.date)



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

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select prevalent pt and count consultations
# hx_pt==1 means has same infection consultation in 90 days
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# summarize prevalent counts & total population
df_4=df%>%
  group_by(date,age_cat)%>% 
  summarise(counts=sum(hx_counts), 
            population=sum(population))%>%
  mutate(indic="sinusitis")

rm(df,first_mon,last_mon,last.date)





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
    hx_ot_externa_pt = col_double(), 
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=ot_externa_counts, hx_pt=hx_ot_externa_pt) 

df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select prevalent pt and count consultations
# hx_pt==1 means has same infection consultation in 90 days
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# summarize prevalent counts & total population
df_5=df%>%
  group_by(date,age_cat)%>% 
  summarise(counts=sum(hx_counts), 
            population=sum(population))%>%
  mutate(indic="otitis externa")

rm(df,first_mon,last_mon,last.date)




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
    hx_otmedia_pt = col_double(), 
    age_cat = col_character(),
    value = col_double(),
    
    #Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=otmedia_counts, hx_pt=hx_otmedia_pt) 

df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select prevalent pt and count consultations
# hx_pt==1 means has same infection consultation in 90 days
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# summarize prevalent counts & total population
df_6=df%>%
  group_by(date,age_cat)%>% 
  summarise(counts=sum(hx_counts), 
            population=sum(population))%>%
  mutate(indic="otitis media")

rm(df,last.date)






### 2. combined dataframe

df=rbind(df_1,df_2,df_3,df_4,df_5,df_6)
rm(df_1,df_2,df_3,df_4,df_5,df_6)
df=df%>%filter(age_cat != "0") # remove 0 group

df=df%>%group_by(date,indic)%>%mutate(total.pop=sum(population))

#remove counts<5
df$counts2=ifelse(df$counts<=5, NA , df$counts)
df$rate=df$counts2/df$total.pop*1000
df_plot=df
write.csv(df,here::here("output","redacted","consultation_rate_prevalent_check.csv"))







### 3.table
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

df=df%>%group_by(covid,season)%>%summarise(rate=mean(counts)/mean(total.pop)*1000)
write.csv(df,here::here("output","redacted","consultation_rate_prevalent.csv"))


### 4. plots

# # line graph- by age group and divided by year
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

# UTI
df_plot.1=df_plot%>%filter(indic=="UTI")

# plot missing value line
gaps=df_plot.1 %>% filter(!is.na(rate))

lineplot_1<- ggplot(df_plot.1, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  geom_line(data =gaps, linetype = "dashed",aes(color=age_cat)) +
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- UTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time.
                    
                    "),
    x = "", 
    y = "Number of consultations per 1000 patients")


ggsave(
  plot= lineplot_1,
  filename="consult_age_prevalent_UTI.jpeg", path=here::here("output","redacted"))

rm(df_plot.1,lineplot_1,gaps)



# URTI
df_plot.2=df_plot%>%filter(indic=="URTI")
# plot missing value line
gaps=df_plot.2%>% filter(!is.na(rate))

lineplot_2<- ggplot(df_plot.2, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  geom_line(data =gaps, linetype = "dashed",aes(color=age_cat)) +
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- URTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time.
                    
                    "),
    x = "", 
    y = "Number of consultations per 1000 patients")


ggsave(
  plot= lineplot_2,
  filename="consult_age_prevalent_URTI.jpeg", path=here::here("output","redacted"))


rm(df_plot.2,lineplot_2,gaps)


#LRTI
df_plot.3=df_plot%>%filter(indic=="LRTI")

# plot missing value line
gaps=df_plot.3 %>% filter(!is.na(rate))

lineplot_3<- ggplot(df_plot.3, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  geom_line(data =gaps, linetype = "dashed",aes(color=age_cat)) +
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- LRTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time.
                    
                    "),
    x = "", 
    y = "Number of consultations per 1000 patients")


ggsave(
  plot= lineplot_3,
  filename="consult_age_prevalent_LRTI.jpeg", path=here::here("output","redacted"))


rm(df_plot.3,lineplot_3,gaps)


# sinusitis
df_plot.4=df_plot%>%filter(indic=="sinusitis")

# plot missing value line
gaps=df_plot.4 %>% filter(!is.na(rate))

lineplot_4<- ggplot(df_plot.4, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  geom_line(data =gaps, linetype = "dashed",aes(color=age_cat)) +
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- Otitis externa",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time.
                    
                    "),
    x = "", 
    y = "Number of consultations per 1000 patients")


ggsave(
  plot= lineplot_4,
  filename="consult_age_prevalent_sinusitis.jpeg", path=here::here("output","redacted"))


rm(df_plot.4,lineplot_4,gaps)


# otmedia
df_plot.5=df_plot%>%filter(indic=="otitis media")

# plot missing value line
gaps=df_plot.5 %>% filter(!is.na(rate))

lineplot_5<- ggplot(df_plot.5, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  geom_line(data =gaps, linetype = "dashed",aes(color=age_cat)) +
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- Otitis media",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time.
                    
                    "),
    x = "", 
    y = "Number of consultations per 1000 patients")

ggsave(
  plot= lineplot_5,
  filename="consult_age_prevalent_otmedia.jpeg", path=here::here("output","redacted"))

rm(df_plot.5,lineplot_5,gaps)




# ot externa
df_plot.6=df_plot%>%filter(indic=="otitis externa")

# plot missing value line
gaps=df_plot.6 %>% filter(!is.na(rate))

lineplot_6<- ggplot(df_plot.6, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  geom_line(data =gaps, linetype = "dashed",aes(color=age_cat)) +
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- Otitis externa",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time.
                    
                    "),
    x = "", 
    y = "Number of consultations per 1000 patients")

ggsave(
  plot= lineplot_6,
  filename="consult_age_prevalent_ot_externa.jpeg", path=here::here("output","redacted"))


