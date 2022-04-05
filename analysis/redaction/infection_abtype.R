##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")
library("ggpubr")

dir.create(here::here("output", "redacted"))

rm(list=ls())
setwd(here::here("output", "measures"))
setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")


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
  mutate(patient=sum(length(unique(patient_id)))) # error fix: df$patinet_id

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
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder

# summarise data
df.plot.1=df.1%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.1$redacted_counts=ifelse(df.plot.1$counts<=5, NA , df.plot.1$counts)
df.plot.1$redacted_rate=df.plot.1$redacted_counts/df.plot.1$patient*1000
rm(DF.top10.1)


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
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# summarise data
df.plot.0=df.0%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.0$redacted_counts=ifelse(df.plot.0$counts<=5, NA , df.plot.0$counts)
df.plot.0$redacted_rate=df.plot.0$redacted_counts/df.plot.0$patient*1000
rm(DF.top10.0)

rm(df.0,df.1,df)
df.plot.1$prevalent=as.factor(1)
df.plot.0$prevalent=as.factor(0)
df=rbind(df.plot.1,df.plot.0)
write_csv(df, here::here("output","redacted", "abtype_uti_check.csv"))


### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))


df.table=df%>%
  group_by(covid,type)%>%
  summarise(ave.rate=mean(value2))%>%
  arrange(desc(ave.rate))%>%
  slice(1:10)%>%
  mutate(indic="uti")

write_csv(df, here::here("output","redacted", "abtype_uti.csv"))


### plots
df.plot.1$redacted_rate=as.numeric(df.plot.1$redacted_rate)
## # line graph-rate
# prevalent
lineplot.1<- ggplot(df.plot.1, aes(x=date, y=redacted_rate,group=type,color=type))+
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

df.plot.0$redacted_rate=as.numeric(df.plot.0$redacted_rate)
# incident
lineplot.0<- ggplot(df.plot.0, aes(x=date, y=redacted_rate,group=type,color=type))+
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

lineplot=annotate_figure(lineplot,
                top = text_grob(" ", face = "bold", size = 14),
                bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                   hjust = 1, x = 1, size = 10),
                 fig.lab =paste0("Top 10 antibiotic types prescribed for UTI patients       ",
                                         first_mon," - ",last_mon),
                left = text_grob("counts per 1000 UTI patients", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="abtype_uti.jpeg", path=here::here("output","redacted")) 

rm(list=ls())







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
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder

# summarise data
df.plot.1=df.1%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.1$redacted_counts=ifelse(df.plot.1$counts<=5, NA , df.plot.1$counts)
df.plot.1$redacted_rate=df.plot.1$redacted_counts/df.plot.1$patient*1000
rm(DF.top10.1)


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
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# summarise data
df.plot.0=df.0%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.0$redacted_counts=ifelse(df.plot.0$counts<=5, NA , df.plot.0$counts)
df.plot.0$redacted_rate=df.plot.0$redacted_counts/df.plot.0$patient*1000
rm(DF.top10.0)

rm(df.0,df.1,df)
df.plot.1$prevalent=as.factor(1)
df.plot.0$prevalent=as.factor(0)
df=rbind(df.plot.1,df.plot.0)
write_csv(df, here::here("output","redacted", "abtype_lrti_check.csv"))


### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))


df.table=df%>%
  group_by(covid,type)%>%
  summarise(ave.rate=mean(value2))%>%
  arrange(desc(ave.rate))%>%
  slice(1:10)%>%
  mutate(indic="lrti")

write_csv(df, here::here("output","redacted", "abtype_lrti.csv"))


### plots
df.plot.1$redacted_rate=as.numeric(df.plot.1$redacted_rate)
## # line graph-rate
# prevalent
lineplot.1<- ggplot(df.plot.1, aes(x=date, y=redacted_rate,group=type,color=type))+
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

df.plot.0$redacted_rate=as.numeric(df.plot.0$redacted_rate)
# incident
lineplot.0<- ggplot(df.plot.0, aes(x=date, y=redacted_rate,group=type,color=type))+
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

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Top 10 antibiotic types prescribed for LRTI patients       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("counts per 1000 LRTI patients", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="abtype_lrti.jpeg", path=here::here("output","redacted")) 

rm(list=ls())




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
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder

# summarise data
df.plot.1=df.1%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.1$redacted_counts=ifelse(df.plot.1$counts<=5, NA , df.plot.1$counts)
df.plot.1$redacted_rate=df.plot.1$redacted_counts/df.plot.1$patient*1000
rm(DF.top10.1)


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
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# summarise data
df.plot.0=df.0%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.0$redacted_counts=ifelse(df.plot.0$counts<=5, NA , df.plot.0$counts)
df.plot.0$redacted_rate=df.plot.0$redacted_counts/df.plot.0$patient*1000
rm(DF.top10.0)

rm(df.0,df.1,df)
df.plot.1$prevalent=as.factor(1)
df.plot.0$prevalent=as.factor(0)
df=rbind(df.plot.1,df.plot.0)
write_csv(df, here::here("output","redacted", "abtype_urti_check.csv"))


### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))


df.table=df%>%
  group_by(covid,type)%>%
  summarise(ave.rate=mean(value2))%>%
  arrange(desc(ave.rate))%>%
  slice(1:10)%>%
  mutate(indic="urti")

write_csv(df, here::here("output","redacted", "abtype_urti.csv"))


### plots
df.plot.1$redacted_rate=as.numeric(df.plot.1$redacted_rate)
## # line graph-rate
# prevalent
lineplot.1<- ggplot(df.plot.1, aes(x=date, y=redacted_rate,group=type,color=type))+
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

df.plot.0$redacted_rate=as.numeric(df.plot.0$redacted_rate)
# incident
lineplot.0<- ggplot(df.plot.0, aes(x=date, y=redacted_rate,group=type,color=type))+
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

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Top 10 antibiotic types prescribed for URTI patients       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("counts per 1000 URTI patients", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="abtype_urti.jpeg", path=here::here("output","redacted")) 

rm(list=ls())


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
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder

# summarise data
df.plot.1=df.1%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.1$redacted_counts=ifelse(df.plot.1$counts<=5, NA , df.plot.1$counts)
df.plot.1$redacted_rate=df.plot.1$redacted_counts/df.plot.1$patient*1000
rm(DF.top10.1)


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
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# summarise data
df.plot.0=df.0%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.0$redacted_counts=ifelse(df.plot.0$counts<=5, NA , df.plot.0$counts)
df.plot.0$redacted_rate=df.plot.0$redacted_counts/df.plot.0$patient*1000
rm(DF.top10.0)

rm(df.0,df.1,df)
df.plot.1$prevalent=as.factor(1)
df.plot.0$prevalent=as.factor(0)
df=rbind(df.plot.1,df.plot.0)
write_csv(df, here::here("output","redacted", "abtype_sinusitis_check.csv"))


### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))


df.table=df%>%
  group_by(covid,type)%>%
  summarise(ave.rate=mean(value2))%>%
  arrange(desc(ave.rate))%>%
  slice(1:10)%>%
  mutate(indic="sinusitis")

write_csv(df, here::here("output","redacted", "abtype_sinusitis.csv"))


### plots
df.plot.1$redacted_rate=as.numeric(df.plot.1$redacted_rate)
## # line graph-rate
# prevalent
lineplot.1<- ggplot(df.plot.1, aes(x=date, y=redacted_rate,group=type,color=type))+
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

df.plot.0$redacted_rate=as.numeric(df.plot.0$redacted_rate)
# incident
lineplot.0<- ggplot(df.plot.0, aes(x=date, y=redacted_rate,group=type,color=type))+
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

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Top 10 antibiotic types prescribed for sinusitis patients       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("counts per 1000 sinusitis patients", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="abtype_sinusitis.jpeg", path=here::here("output","redacted")) 

rm(list=ls())



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
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder

# summarise data
df.plot.1=df.1%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.1$redacted_counts=ifelse(df.plot.1$counts<=5, NA , df.plot.1$counts)
df.plot.1$redacted_rate=df.plot.1$redacted_counts/df.plot.1$patient*1000
rm(DF.top10.1)


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
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# summarise data
df.plot.0=df.0%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.0$redacted_counts=ifelse(df.plot.0$counts<=5, NA , df.plot.0$counts)
df.plot.0$redacted_rate=df.plot.0$redacted_counts/df.plot.0$patient*1000
rm(DF.top10.0)

rm(df.0,df.1,df)
df.plot.1$prevalent=as.factor(1)
df.plot.0$prevalent=as.factor(0)
df=rbind(df.plot.1,df.plot.0)
write_csv(df, here::here("output","redacted", "abtype_ot_externa_check.csv"))


### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))


df.table=df%>%
  group_by(covid,type)%>%
  summarise(ave.rate=mean(value2))%>%
  arrange(desc(ave.rate))%>%
  slice(1:10)%>%
  mutate(indic="ot_externa")

write_csv(df, here::here("output","redacted", "abtype_ot_externa.csv"))


### plots
df.plot.1$redacted_rate=as.numeric(df.plot.1$redacted_rate)
## # line graph-rate
# prevalent
lineplot.1<- ggplot(df.plot.1, aes(x=date, y=redacted_rate,group=type,color=type))+
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

df.plot.0$redacted_rate=as.numeric(df.plot.0$redacted_rate)
# incident
lineplot.0<- ggplot(df.plot.0, aes(x=date, y=redacted_rate,group=type,color=type))+
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

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Top 10 antibiotic types prescribed for otitis externa patients       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("counts per 1000 otitis externa patients", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="abtype_ot_externa.jpeg", path=here::here("output","redacted")) 

rm(list=ls())



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
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder

# summarise data
df.plot.1=df.1%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.1$redacted_counts=ifelse(df.plot.1$counts<=5, NA , df.plot.1$counts)
df.plot.1$redacted_rate=df.plot.1$redacted_counts/df.plot.1$patient*1000
rm(DF.top10.1)


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
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# summarise data
df.plot.0=df.0%>%group_by(date,type)%>%
  summarise(
    value2=sum(value),
    counts=sum(count),
    patient=mean(patient)
    
  )

#remove counts<5
df.plot.0$redacted_counts=ifelse(df.plot.0$counts<=5, NA , df.plot.0$counts)
df.plot.0$redacted_rate=df.plot.0$redacted_counts/df.plot.0$patient*1000
rm(DF.top10.0)

rm(df.0,df.1,df)
df.plot.1$prevalent=as.factor(1)
df.plot.0$prevalent=as.factor(0)
df=rbind(df.plot.1,df.plot.0)
write_csv(df, here::here("output","redacted", "abtype_otmedia_check.csv"))


### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))


df.table=df%>%
  group_by(covid,type)%>%
  summarise(ave.rate=mean(value2))%>%
  arrange(desc(ave.rate))%>%
  slice(1:10)%>%
  mutate(indic="otmedia")

write_csv(df, here::here("output","redacted", "abtype_otmedia.csv"))


### plots
df.plot.1$redacted_rate=as.numeric(df.plot.1$redacted_rate)
## # line graph-rate
# prevalent
lineplot.1<- ggplot(df.plot.1, aes(x=date, y=redacted_rate,group=type,color=type))+
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

df.plot.0$redacted_rate=as.numeric(df.plot.0$redacted_rate)
# incident
lineplot.0<- ggplot(df.plot.0, aes(x=date, y=redacted_rate,group=type,color=type))+
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

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Top 10 antibiotic types prescribed for otitis media patients       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("counts per 1000 otitis media patients", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="abtype_otmedia.jpeg", path=here::here("output","redacted")) 

rm(list=ls())




