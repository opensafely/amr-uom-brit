##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")
library("ggpubr")

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

# variable types
df$prevalent=as.factor(df$prevalent)
df$date=as.Date(df$date)
df$abtype=as.character(df$abtype)


# select prevalent cases
df.1=df%>%filter(prevalent==1)%>%group_by(date,abtype)%>%summarise(count=n(),patient=mean(patient))
df.1$value=df.1$count/df.1$patient*1000

#top 10 ab
DF.top10.1=df.1%>%
  group_by(abtype)%>%
  summarise(value2=mean(value))%>% # RX: average per month
  arrange(desc(value2))%>%
  slice(1:10)

# sort ab type
# recode other types
df.1$type=ifelse(df.1$abtype %in% DF.top10.1$abtype | is.na(df.1$abtype), df.1$abtype, "Others")

# recode NA -> no recorded antibiotics
df.1$type=ifelse(is.na(df.1$type),"No Antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No Antibiotics"))# reorder

# summarise data
df.plot.1=df.1%>%group_by(type,date)%>%
  summarise(
    value2=sum(value)
  )


# select incident cases
df.0=df%>%filter(prevalent==0)%>%group_by(date,abtype)%>%summarise(count=n(),patient=mean(patient))
df.0$value=df.0$count/df.0$patient*1000

#top 10 ab
DF.top10.0=df.0%>%
  group_by(abtype)%>%
  summarise(value2=mean(value))%>% # RX: average per month
  arrange(desc(value2))%>%
  slice(1:10)

# sort ab type
# recode other types
df.0$type=ifelse(df.0$abtype %in% DF.top10.0$abtype | is.na(df.0$abtype), df.0$abtype, "Others")

# recode NA -> no recorded antibiotics
df.0$type=ifelse(is.na(df.0$type),"No Antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No Antibiotics"))# reorder


# summarise data
df.plot.0=df.0%>%group_by(type,date)%>%
  summarise(
    value2=sum(value)
  )

df.1$prevalent=as.factor(1)
df.0$prevalent=as.factor(0)
df=rbind(df.0,df.1)

## # line graph-rate
# prevalent
lineplot.1<- ggplot(df.plot.1, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type))+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:12))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen","dodgerblue","deepskyblue","azure4"))+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

# incident
lineplot.0<- ggplot(df.plot.0, aes(x=date, y=value2,group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type))+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:12))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen","dodgerblue","deepskyblue","azure4"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 10)

lineplot=ggarrange(lineplot.0, lineplot.1, 
          labels = c("A", "B"),
          nrow = 2)

annotate_figure(lineplot,
                top = text_grob("Top 10 Antibiotic Types Prescribed for UTI patients", face = "bold", size = 18),
                bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                   hjust = 1, x = 1, size = 10),
                left = text_grob("Number of prescriptions per 1000 UTI patients", rot = 90),
)


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
    title = "Top 10 Antibiotic Types Prescribed for LRTI patients",
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
    title = "Top 10 Antibiotic Types Prescribed for URTI patients",
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
    title = "Top 10 Antibiotic Types Prescribed for Sinusitis patients",
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
    title = "Top 10 Antibiotic Types Prescribed for Otitis externa patients",
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
    title = "Top 10 Antibiotic Types Prescribed for Otitis media patients",
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





