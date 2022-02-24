

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")



# read in files
df19=read_rds("recorded_ab_broad_2019.rds")
df20=read_rds("recorded_ab_broad_2020.rds")
df21=read_rds("recorded_ab_broad_2021.rds")
df22=read_rds("recorded_ab_broad_2022.rds")
dat=bind_rows(df19,df20,df21,df22)
rm(df19,df20,df21,df22)

# remove last month data
last.date=max(dat$date)
dat=dat%>% filter(date != last.date)
first_mon=format(min(dat$date),"%m-%Y")
last_mon= format(max(dat$date),"%m-%Y")

# define variables
dat$prevalent=as.factor(dat$prevalent)
dat$infection=as.character(dat$infection)

# recode
dat$infection=recode(dat$infection,
                     asthma ="Other infection",
                     cold="Other infection",
                     cough="Other infection",
                     copd="Other infection",
                     pneumonia="Other infection",
                     renal="Other infection",
                     sepsis="Other infection",
                     throat="Other infection",
                     uti = "UTI",
                     lrti = "LRTI",
                     urti = "URTI",
                     sinusits = "Sinusitis",
                     otmedia = "Otitis media",
                     ot_externa = "Otitis externa")


# recode empty value
dat$infection=ifelse(dat$infection=="","Uncoded",dat$infection)

# reorder
dat$infection <- factor(dat$infection, levels=c("LRTI","Otitis externa","Otitis media","Sinusitis","URTI","UTI","Other infection","Uncoded"))

# patient number
#dat=dat%>%dplyr::group_by(date)%>%mutate(patient=length(unique(patient_id)))

# select prevalent
dat=dat%>%filter(prevalent==1)

# summarise ab counts for infection
dat=dat%>%group_by(date,infection)%>%summarise(count=n())
# total antibiotics count per month
dat=dat%>%group_by(date)%>%mutate(total=sum(count))
# percentage
dat$value=dat$count/dat$total

# # plot
# abtype_bar <- ggplot(dat,aes(x=date, y=value, color=infection)) + 
#   annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   geom_col()+
#   labs(
#     fill = "Infections",
#     title = "Prevalent antibiotic prescriptions with infection records",
#     #subtitle = paste(first_mon,"-",last_mon),
#     caption = "Grey shading represents national lockdown time. ",
#     y = "Percentage",
#     x=""
#   )+
#   theme(axis.text.x=element_text(angle=60,hjust=1))+
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
#   scale_y_continuous(labels = scales::percent)+
#   scale_color_manual(values = c("red","darkorchid1","goldenrod2","green","forestgreen","darkblue","deepskyblue","azure4"))

# abtype_bar


## # line graph-percent
lineplot<- ggplot(dat, aes(x=date, y=value,group=infection,color=infection))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  geom_point(aes(shape=infection))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Infections",
    title = "Prevalent antibiotic prescriptions with infection records",
    #  subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)+
  scale_shape_manual(values = c(rep(1:8))) +
  scale_color_manual(values = c("red","darkorchid1","goldenrod2","green","forestgreen","darkblue","deepskyblue","azure4"))

lineplot

ggsave(
  plot= abtype_bar,
  filename="ab_recorded_prevalent_bar.jpeg", path=here::here("output"),
)
ggsave(
  plot= lineplot,
  filename="ab_recorded_prevalent_line.jpeg", path=here::here("output"),
) 

write_csv(dat, here::here("output", "ab_recorded_prevalent.csv"))
