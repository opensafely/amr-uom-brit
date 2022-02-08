


##############
## percentage of consultations which were prescribed antibiotics
##############

### import patient-level data to summarize antibiotics counts ###
library("data.table")
library("dplyr")
library('here')
library("tidyverse")


### 01. read csv -measures by 6 infection
## 1.1 UTI
df <- read_csv(
  here::here("output", "measures", "measure_infection_Rx_percent_UTI.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 
                 uti_ab_flag_1  = col_double(),
                 uti_pt = col_double(),
                 hx_indications = col_double(),
                 hx_antibiotics= col_double(),
                 age_cat = col_character(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)


df[is.na(df)] <- 0 # replace NA ->0


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# summarise table
df1=df%>%group_by(date,age_cat,hx_indications,hx_antibiotics)%>%
  summarise(percent=mean(value))%>%
  mutate(infection="UTI")

rm(df,first_mon,last_mon,last.date)


## 1.2 URTI
df <- read_csv(
  here::here("output", "measures", "measure_infection_Rx_percent_URTI.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 
                 urti_ab_flag_1  = col_double(),
                 urti_pt = col_double(),
                 hx_indications = col_double(),
                 hx_antibiotics= col_double(),
                 age_cat = col_character(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)


df[is.na(df)] <- 0 # replace NA ->0


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# summarise table
df2=df%>%group_by(date,age_cat,hx_indications,hx_antibiotics)%>%
  summarise(percent=mean(value))%>%
  mutate(infection="URTI")

rm(df,first_mon,last_mon,last.date)



## 1.3 LRTI
df <- read_csv(
  here::here("output", "measures", "measure_infection_Rx_percent_LRTI.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 
                 lrti_ab_flag_1  = col_double(),
                 lrti_pt = col_double(),
                 hx_indications = col_double(),
                 hx_antibiotics= col_double(),
                 age_cat = col_character(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)


df[is.na(df)] <- 0 # replace NA ->0


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# summarise table
df3=df%>%group_by(date,age_cat,hx_indications,hx_antibiotics)%>%
  summarise(percent=mean(value))%>%
  mutate(infection="LRTI")

rm(df,first_mon,last_mon,last.date)



# 1.4 sinusitis
df <- read_csv(
  here::here("output", "measures", "measure_infection_Rx_percent_sinusitis.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 
                 sinusitis_ab_flag_1  = col_double(),
                 sinusitis_pt = col_double(),
                 hx_indications = col_double(),
                 hx_antibiotics= col_double(),
                 age_cat = col_character(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)


df[is.na(df)] <- 0 # replace NA ->0


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

#msummarise table
df4=df%>%group_by(date,age_cat,hx_indications,hx_antibiotics)%>%
  summarise(percent=mean(value))%>%
  mutate(infection="sinusitis")

rm(df,first_mon,last_mon,last.date)



# 1.5 ot_externa
df <- read_csv(
  here::here("output", "measures", "measure_infection_Rx_percent_ot_externa.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 
                 ot_externa_ab_flag_1  = col_double(),
                 ot_externa_pt = col_double(),
                 hx_indications = col_double(),
                 hx_antibiotics= col_double(),
                 age_cat = col_character(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)


df[is.na(df)] <- 0 # replace NA ->0


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# summarise table
df5=df%>%group_by(date,age_cat,hx_indications,hx_antibiotics)%>%
  summarise(percent=mean(value))%>%
  mutate(infection="otitis externa")

rm(df,first_mon,last_mon,last.date)




# 1.6 otmedia
df <- read_csv(
  here::here("output", "measures", "measure_infection_Rx_percent_otmedia.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 practice = col_integer(),
                 
                 # Outcomes
                 
                 otmedia_ab_flag_1  = col_double(),
                 otmedia_pt = col_double(),
                 hx_indications = col_double(),
                 hx_antibiotics= col_double(),
                 age_cat = col_character(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)


df[is.na(df)] <- 0 # replace NA ->0


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# summarise table
df6=df%>%group_by(date,age_cat,hx_indications,hx_antibiotics)%>%
  summarise(percent=mean(value))%>%
  mutate(infection="otitis media")

rm(df,last.date)


### 02. combine df

df=rbind(df1,df2,df3,df4,df5,df6)
rm(df1,df2,df3,df4,df5,df6)


### 03. plots

## 3.1 prevalent case
df.p=df%>%group_by(date,age_cat,infection)%>%
  summarise(percent=mean(percent))

write.csv(df.p,here::here("output","prescribed_infection_prevalent.csv"))


df.p$age_cat <- factor(df.p$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))
df.p$infection<-factor(df.p$infection, levels=c("UTI", "URTI", "LRTI","otitis externa", "otitis media", "sinusitis"))

df.p$month=format(df.p$date,"%m")
df.p$year=format(df.p$date,"%Y")

lineplot.p1<- ggplot(df.p, aes(x=month, y=percent,group=year,color=year))+
  facet_grid(rows = vars(age_cat), cols = vars(infection))+
  geom_line()+
  scale_y_continuous(labels = scales::percent)+
  scale_x_discrete(breaks=c("01","03","05","07","09","11"))+
  theme(axis.text.x = element_text(angle = 90,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Percentage of infection records with antibiotic prescribing- prevalent ",
    subtitle = paste(first_mon,"-",last_mon),
   caption = "Estimated from patients' first infection record in each month and same day prescribing",
    x = "", 
    y = "")

lineplot.p2<- ggplot(df.p, aes(x=date, y=percent,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "2 month",date_labels =  "%Y-%m")+
  scale_y_continuous(labels = scales::percent)+
  facet_grid(rows = vars(infection))+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Percentage of infection records with antibiotic prescribing- prevalent ",
    subtitle = paste(first_mon,"-",last_mon),
  caption = "Estimated from patients' first infection record in each month and same day prescribing; 
  National lockdown time in grey background. ",
    x = "", 
    y = "")



## 3.2 incident case
df.i=df%>%group_by(date,age_cat,infection)%>%
  filter(hx_indications==0&hx_antibiotics==0)%>%
  summarise(percent=mean(percent))

write.csv(df.i,here::here("output","prescribed_infection_incident.csv"))


df.i$age_cat <- factor(df.i$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))
df.i$infection<-factor(df.i$infection, levels=c("UTI", "URTI", "LRTI","otitis externa", "otitis media", "sinusitis"))

df.i$month=format(df.i$date,"%m")
df.i$year=format(df.i$date,"%Y")

lineplot.i1<- ggplot(df.i, aes(x=month, y=percent,group=year,color=year))+
  facet_grid(rows = vars(age_cat), cols = vars(infection))+
  geom_line()+
  scale_y_continuous(labels = scales::percent)+
  scale_x_discrete(breaks=c("01","03","05","07","09","11"))+
  theme(axis.text.x = element_text(angle = 90,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Percentage of infection records with antibiotic prescribing- incident",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Estimated from patients' first infection record in each month and same day prescribing",
    x = "", 
    y = "")

lineplot.i2<- ggplot(df.i, aes(x=date, y=percent,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "2 month",date_labels =  "%Y-%m")+
  scale_y_continuous(labels = scales::percent)+
  facet_grid(rows = vars(infection))+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Percentage of infection records with antibiotic prescribing- incident ",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Estimated from patients' first infection record in each month and same day prescribing; 
    National lockdown time in grey background. ",
    x = "", 
    y = "")



## 3.3 overall
df$type=ifelse(df$hx_antibiotics==0&df$hx_indications==0,"incident","prevalent")
df.all=df%>%group_by(date, infection,type)%>%
  summarise(percent=mean(percent))

df.all$infection<-factor(df.all$infection, levels=c("UTI", "URTI", "LRTI","otitis externa", "otitis media", "sinusitis"))

lineplot.all<- ggplot(df.all, aes(x=date, y=percent,group=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "2 month",date_labels =  "%Y-%m")+
  scale_y_continuous(labels = scales::percent)+
  facet_grid(rows = vars(infection))+
  geom_line(aes(color=type))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
      legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Percentage of infection records with antibiotic prescribing ",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Estimated from patients' first infection record in each month and same day prescribing; 
    National lockdown time in grey background. ",
    x = "", 
    y = "")
lineplot.all




ggsave(
  plot= lineplot.p1,
  filename="infection_ab_precent_p1.jpeg", path=here::here("output"))

ggsave(
  plot= lineplot.p2,
  filename="infection_ab_precent_p2.jpeg", path=here::here("output"))

ggsave(
  plot= lineplot.i1,
  filename="infection_ab_precent_i1.jpeg", path=here::here("output"))

ggsave(
  plot= lineplot.i2,
  filename="infection_ab_precent_i2.jpeg", path=here::here("output"))

ggsave(
  plot= lineplot.all,
  filename="infection_ab_precent_all.jpeg", path=here::here("output"))
