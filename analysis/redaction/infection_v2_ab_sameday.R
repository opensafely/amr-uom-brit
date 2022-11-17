##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")
library("ggpubr")

dir.create(here::here("output", "redacted_v2"))

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


# variable types
df$prevalent=as.factor(df$prevalent)
df$date=as.Date(df$date)
df$abtype=as.character(df$abtype)

##select prevalent cases
# list size per month: total consultations
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.1=df.1%>%filter(is.na(abtype))

# calculate  no ab
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.1$percentage=df.1$count/df.1$total

  
##select incident cases
# list size per month: total consultations
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.0=df.0%>%filter(is.na(abtype))

# calculate  no ab
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.0$percentage=df.0$count/df.0$total




## csv check for plot
rm(df)
df.0$prevalent=as.factor(0)
df.1$prevalent=as.factor(1)
DF_1=rbind(df.0,df.1)
DF_1$infection="UTI"



########### LRTI


df=readRDS("abtype_lrti.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# variable types
df$prevalent=as.factor(df$prevalent)
df$date=as.Date(df$date)
df$abtype=as.character(df$abtype)

##select prevalent cases
# list size per month: total consultations
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.1=df.1%>%filter(is.na(abtype))

# calculate  no ab
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.1$percentage=df.1$count/df.1$total


##select incident cases
# list size per month: total consultations
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.0=df.0%>%filter(is.na(abtype))

# calculate  no ab
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.0$percentage=df.0$count/df.0$total




## csv check for plot
rm(df)
df.0$prevalent=as.factor(0)
df.1$prevalent=as.factor(1)
DF_2=rbind(df.0,df.1)
DF_2$infection="LRTI"




########### URTI



df=readRDS("abtype_urti.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# variable types
df$prevalent=as.factor(df$prevalent)
df$date=as.Date(df$date)
df$abtype=as.character(df$abtype)

##select prevalent cases
# list size per month: total consultations
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.1=df.1%>%filter(is.na(abtype))

# calculate  no ab
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.1$percentage=df.1$count/df.1$total


##select incident cases
# list size per month: total consultations
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.0=df.0%>%filter(is.na(abtype))

# calculate  no ab
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.0$percentage=df.0$count/df.0$total




## csv check for plot
rm(df)
df.0$prevalent=as.factor(0)
df.1$prevalent=as.factor(1)
DF_3=rbind(df.0,df.1)
DF_3$infection="URTI"





########### sinusitis


df=readRDS("abtype_sinusitis.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# variable types
df$prevalent=as.factor(df$prevalent)
df$date=as.Date(df$date)
df$abtype=as.character(df$abtype)

##select prevalent cases
# list size per month: total consultations
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.1=df.1%>%filter(is.na(abtype))

# calculate  no ab
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.1$percentage=df.1$count/df.1$total


##select incident cases
# list size per month: total consultations
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.0=df.0%>%filter(is.na(abtype))

# calculate  no ab
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.0$percentage=df.0$count/df.0$total




## csv check for plot
rm(df)
df.0$prevalent=as.factor(0)
df.1$prevalent=as.factor(1)
DF_4=rbind(df.0,df.1)
DF_4$infection="sinusitis"




########### ot_externa


df=readRDS("abtype_ot_externa.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# variable types
df$prevalent=as.factor(df$prevalent)
df$date=as.Date(df$date)
df$abtype=as.character(df$abtype)

##select prevalent cases
# list size per month: total consultations
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.1=df.1%>%filter(is.na(abtype))

# calculate  no ab
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.1$percentage=df.1$count/df.1$total


##select incident cases
# list size per month: total consultations
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.0=df.0%>%filter(is.na(abtype))

# calculate  no ab
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.0$percentage=df.0$count/df.0$total




## csv check for plot
rm(df)
df.0$prevalent=as.factor(0)
df.1$prevalent=as.factor(1)
DF_5=rbind(df.0,df.1)
DF_5$infection="otitis externa"



########### otmedia

df=readRDS("abtype_otmedia.rds")
df=bind_rows(df)


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


# variable types
df$prevalent=as.factor(df$prevalent)
df$date=as.Date(df$date)
df$abtype=as.character(df$abtype)


##select prevalent cases
# list size per month: total consultations
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.1=df.1%>%filter(is.na(abtype))

# calculate  no ab
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.1$percentage=df.1$count/df.1$total


##select incident cases
# list size per month: total consultations
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%
  mutate(total=n())

## filter case without ab
df.0=df.0%>%filter(is.na(abtype))

# calculate  no ab
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))

df.0$percentage=df.0$count/df.0$total




## csv check for plot
rm(df)
df.0$prevalent=as.factor(0)
df.1$prevalent=as.factor(1)
DF_6=rbind(df.0,df.1)
DF_6$infection="otitis media"




# merge 6 infections
DF=rbind(DF_1,DF_2,DF_3,DF_4,DF_5,DF_6)
rm(DF_1,DF_2,DF_3,DF_4,DF_5,DF_6,df.0,df.1)

DF$percentage_sameday=1-DF$percentage # patients with ab

DF0=DF%>% filter(prevalent==0)
DF1=DF%>% filter(prevalent==1)

# incident
lineplot.0<- ggplot(DF0, aes(x=date, y=percentage_sameday, group=infection,color=infection))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=infection))+
  geom_point(aes(shape=infection))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:6))) +
  scale_color_manual(values = c("coral2","darkred","goldenrod2","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="",
    title = "")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "3 month")+
  scale_y_continuous(labels = scales::percent)

lineplot.0

# prevalent
lineplot.1<- ggplot(DF1, aes(x=date, y=percentage_sameday, group=infection,color=infection))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=infection))+
  geom_point(aes(shape=infection))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:6))) +
  scale_color_manual(values = c("coral2","darkred","goldenrod2","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="",
    title = "")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "3 month")+
  scale_y_continuous(labels = scales::percent)

lineplot.1

ggsave(
  plot= lineplot.0,
  filename="incident_sameday.jpeg", path=here::here("output","redacted_v2")) 
ggsave(
  plot= lineplot.1,
  filename="prevalent_sameday.jpeg", path=here::here("output","redacted_v2")) 

write_csv(DF, here::here("output","redacted_v2", "sameday_AB_check.csv"))

