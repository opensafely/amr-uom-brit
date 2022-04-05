

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")


# file list
Files = list.files(pattern="recorded_ab_covid_20", full.names = FALSE)
temp <- vector("list", length(Files))

for (i in seq_along(Files)){
  
  DF=read_rds(Files[i])
  
  #dat=rbindlist(DF)
  dat=bind_rows(DF)
  rm(DF)
  
  
  # filter incident
  dat=dat%>%filter(prevalent==1)%>%select(patient_id,date,infection)# covid infection
  
  
  # summarise ab counts for covid infection
  dat=dat%>%group_by(date,infection)%>%summarise(count=n())
  # total antibiotics count per month
  dat=dat%>%group_by(date)%>%mutate(total=sum(count))
  # percentage
  dat$value=dat$count/dat$total
  
  temp[[i]] = dat
  rm(dat)
}

# combine list->data.frame
dat=bind_rows(temp)

rm(temp,dat.sum,i,Files)

# remove last month data
last.date=max(dat$date)
dat=dat%>% filter(date != last.date)
first_mon=format(min(dat$date),"%m-%Y")
last_mon= format(max(dat$date),"%m-%Y")


# # plot
abtype_bar <- ggplot(dat,aes(x=date, y=value, fill=infection)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white")+
  labs(
    fill = "Covid",
    title = "Incident antibiotic prescriptions with Covid code recorded",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)+
  scale_fill_manual(values = c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))


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
    title = "Incident antibiotic prescriptions with Covid code recorded",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)+
  scale_shape_manual(values = c(rep(1:8))) +
  scale_color_manual(values =  c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))



ggsave(
  plot= abtype_bar,
  filename="ab_recorded_covid_prevalent_bar.jpeg", path=here::here("output"),
)
ggsave(
  plot= lineplot,
  filename="ab_recorded_covid_prevalent_line.jpeg", path=here::here("output"),
) 

write_csv(dat, here::here("output", "ab_recorded_covid_prevalent.csv"))




