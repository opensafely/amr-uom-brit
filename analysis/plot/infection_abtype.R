##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")


########### UTI
df=readRDS("abtype_uti.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# list size per month
df=df%>%group_by(date)%>%
  mutate(patient=sum(length(unique(df$patient_id))))
  

# abtype counts
df=df%>%group_by(date,abtype,prevalent)%>%
  summarise(count=n(),
            patient=mean(patient))


# calculate rate
df$value=df$count/df$patient

### select most common ab###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)


 # sort ab type
         
        # recode other types
         df$type=ifelse(df$abtype %in% DF.top10$abtype | is.na(df$abtype), df$abtype, "Others")
         
         # recode NA -> no recorded antibiotics
         df$type=ifelse( is.na(df$type),"No Antibiotics", df$type)
         
         df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others","No Antibiotics"))# reorder
         
         # summarise data
         df.plot=df%>%group_by(type,date,prevalent)%>%
           summarise(
             value2=sum(value)
           )


## # line graph-rate
lineplot<- ggplot(df.plot, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  facet_grid(rows = vars(prevalent))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed for UTI patinets",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time.
    0 means incident infection; 1 means prevalent infection.",
    y = "Number of prescriptions per 1000 UTI patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

ggsave(
  plot= lineplot,
  filename="abtype_uti.jpeg", path=here::here("output"),
) 

write_csv(df, here::here("output", "abtype_uti.csv"))




########### LRTI
df=readRDS("abtype_lrti.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# list size per month
df=df%>%group_by(date)%>%
  mutate(patient=sum(length(unique(df$patient_id))))
  

# abtype counts
df=df%>%group_by(date,abtype,prevalent)%>%
  summarise(count=n(),
            patient=mean(patient))


# calculate rate
df$value=df$count/df$patient

### select most common ab###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)


 # sort ab type
         
        # recode other types
         df$type=ifelse(df$abtype %in% DF.top10$abtype | is.na(df$abtype), df$abtype, "Others")
         
         # recode NA -> no recorded antibiotics
         df$type=ifelse( is.na(df$type),"No Antibiotics", df$type)
         
         df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others","No Antibiotics"))# reorder
         
         # summarise data
         df.plot=df%>%group_by(type,date,prevalent)%>%
           summarise(
             value2=sum(value)
           )


## # line graph-rate
lineplot<- ggplot(df.plot, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  facet_grid(rows = vars(prevalent))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed for LRTI patinets",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time.
    0 means incident infection; 1 means prevalent infection.",
    y = "Number of prescriptions per 1000 LRTI patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

ggsave(
  plot= lineplot,
  filename="abtype_lrti.jpeg", path=here::here("output"),
) 

write_csv(df, here::here("output", "abtype_lrti.csv"))



########### URTI



df=readRDS("abtype_urti.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# list size per month
df=df%>%group_by(date)%>%
  mutate(patient=sum(length(unique(df$patient_id))))
  

# abtype counts
df=df%>%group_by(date,abtype,prevalent)%>%
  summarise(count=n(),
            patient=mean(patient))


# calculate rate
df$value=df$count/df$patient

### select most common ab###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)


 # sort ab type
         
        # recode other types
         df$type=ifelse(df$abtype %in% DF.top10$abtype | is.na(df$abtype), df$abtype, "Others")
         
         # recode NA -> no recorded antibiotics
         df$type=ifelse( is.na(df$type),"No Antibiotics", df$type)
         
         df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others","No Antibiotics"))# reorder
         
         # summarise data
         df.plot=df%>%group_by(type,date,prevalent)%>%
           summarise(
             value2=sum(value)
           )


## # line graph-rate
lineplot<- ggplot(df.plot, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  facet_grid(rows = vars(prevalent))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed for URTI patinets",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time.
    0 means incident infection; 1 means prevalent infection.",
    y = "Number of prescriptions per 1000 URTI patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

ggsave(
  plot= lineplot,
  filename="abtype_urti.jpeg", path=here::here("output"),
) 

write_csv(df, here::here("output", "abtype_urti.csv"))



########### sinusitis


df=readRDS("abtype_sinusitis.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# list size per month
df=df%>%group_by(date)%>%
  mutate(patient=sum(length(unique(df$patient_id))))
  

# abtype counts
df=df%>%group_by(date,abtype,prevalent)%>%
  summarise(count=n(),
            patient=mean(patient))


# calculate rate
df$value=df$count/df$patient

### select most common ab###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)


 # sort ab type
         
        # recode other types
         df$type=ifelse(df$abtype %in% DF.top10$abtype | is.na(df$abtype), df$abtype, "Others")
         
         # recode NA -> no recorded antibiotics
         df$type=ifelse( is.na(df$type),"No Antibiotics", df$type)
         
         df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others","No Antibiotics"))# reorder
         
         # summarise data
         df.plot=df%>%group_by(type,date,prevalent)%>%
           summarise(
             value2=sum(value)
           )


## # line graph-rate
lineplot<- ggplot(df.plot, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  facet_grid(rows = vars(prevalent))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed for Sinusitis patinets",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time.
    0 means incident infection; 1 means prevalent infection.",
    y = "Number of prescriptions per 1000 Sinusitis patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

ggsave(
  plot= lineplot,
  filename="abtype_sinusitis.jpeg", path=here::here("output"),
) 

write_csv(df, here::here("output", "abtype_sinusitis.csv"))





########### ot_externa


df=readRDS("abtype_ot_externa.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# list size per month
df=df%>%group_by(date)%>%
  mutate(patient=sum(length(unique(df$patient_id))))
  

# abtype counts
df=df%>%group_by(date,abtype,prevalent)%>%
  summarise(count=n(),
            patient=mean(patient))


# calculate rate
df$value=df$count/df$patient

### select most common ab###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)


 # sort ab type
         
        # recode other types
         df$type=ifelse(df$abtype %in% DF.top10$abtype | is.na(df$abtype), df$abtype, "Others")
         
         # recode NA -> no recorded antibiotics
         df$type=ifelse( is.na(df$type),"No Antibiotics", df$type)
         
         df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others","No Antibiotics"))# reorder
         
         # summarise data
         df.plot=df%>%group_by(type,date,prevalent)%>%
           summarise(
             value2=sum(value)
           )


## # line graph-rate
lineplot<- ggplot(df.plot, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  facet_grid(rows = vars(prevalent))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed for Otitis externa patinets",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time.
    0 means incident infection; 1 means prevalent infection.",
    y = "Number of prescriptions per 1000 Otitis externa patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

ggsave(
  plot= lineplot,
  filename="abtype_ot_externa.jpeg", path=here::here("output"),
) 

write_csv(df, here::here("output", "abtype_ot_externa.csv"))







########### otmedia


df=readRDS("abtype_otmedia.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# list size per month
df=df%>%group_by(date)%>%
  mutate(patient=sum(length(unique(df$patient_id))))
  

# abtype counts
df=df%>%group_by(date,abtype,prevalent)%>%
  summarise(count=n(),
            patient=mean(patient))


# calculate rate
df$value=df$count/df$patient

### select most common ab###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)


 # sort ab type
         
        # recode other types
         df$type=ifelse(df$abtype %in% DF.top10$abtype | is.na(df$abtype), df$abtype, "Others")
         
         # recode NA -> no recorded antibiotics
         df$type=ifelse( is.na(df$type),"No Antibiotics", df$type)
         
         df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others","No Antibiotics"))# reorder
         
         # summarise data
         df.plot=df%>%group_by(type,date,prevalent)%>%
           summarise(
             value2=sum(value)
           )


## # line graph-rate
lineplot<- ggplot(df.plot, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  facet_grid(rows = vars(prevalent))+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed for Otitis media patinets",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time.
    0 means incident infection; 1 means prevalent infection.",
    y = "Number of prescriptions per 1000 Otitis media patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

ggsave(
  plot= lineplot,
  filename="abtype_otmedia.jpeg", path=here::here("output"),
) 

write_csv(df, here::here("output", "abtype_otmedia.csv"))





