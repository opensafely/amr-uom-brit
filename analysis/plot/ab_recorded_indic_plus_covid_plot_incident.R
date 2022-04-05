

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")

# ab for covid
df1=read_csv("ab_recorded_covid_incident.csv")
df1=df1%>%filter(infection=="1")
df1$infection="Covid"

# ab for indications
df2=read_csv("ab_recorded_incident.csv")

#merge
dat=rbind(df1,df2)

# remove last month data
last.date=as.Date("2022-02-01")
dat=dat%>% filter(date < last.date)
first_mon=format(min(dat$date),"%m-%Y")
last_mon= format(max(dat$date),"%m-%Y")


# 
dat=dat%>%group_by(date)%>%mutate(total=sum(count))
dat$value=dat$count/dat$total

# reorder
dat$infection <- factor(dat$infection, levels=c("Covid","LRTI","Otitis_externa","Otitis_media","Sinusitis","URTI","UTI","Other_infection","Uncoded"))


# # plot
abtype_bar <- ggplot(dat,aes(x=date, y=value, fill=infection)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white")+
  labs(
    fill = "Covid",
    title = "Incident antibiotic prescriptions with an infection code recorded",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)+
  scale_fill_manual(values = c("black","red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))


## # line graph-percent
lineplot<- ggplot(dat, aes(x=date, y=value,group=infection,color=infection))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  geom_point(aes(shape=infection))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Covid",
    title = "Incident antibiotic prescriptions with an infection code recorded",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)+
  scale_shape_manual(values = c(rep(1:9))) +
  scale_color_manual(values =  c("black","red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4","orange"))



ggsave(
  plot= abtype_bar,
  filename="ab_recorded_covid_indication_incident_bar.jpeg", path=here::here("output"),
)
ggsave(
  plot= lineplot,
  filename="ab_recorded_covid_indication_incident_line.jpeg", path=here::here("output"),
) 

write_csv(dat, here::here("output", "ab_recorded_covid_indication_incident.csv"))




