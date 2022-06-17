

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")


# file list
Files = list.files(pattern="recorded_ab_broad_20", full.names = FALSE)
temp <- vector("list", length(Files))

for (i in seq_along(Files)){
  
  DF=read_rds(Files[i])
  
  #dat=rbindlist(DF)
  dat=bind_rows(DF)
  rm(DF)
  
  
  # filter incident
  dat=dat%>%filter(prevalent==0)%>%select(patient_id,date,infection)
  
  # recode empty value
  dat$infection=ifelse(dat$infection=="","uncoded",dat$infection)
  dat$infection=dat$infection %>% replace_na("uncoded")
  
  # recode
  dat$infection=recode(dat$infection,
                       asthma ="Other_infection",
                       cold="Other_infection",
                       cough="Other_infection",
                       copd="Other_infection",
                       pneumonia="Other_infection",
                       renal="Other_infection",
                       sepsis="Other_infection",
                       throat="Other_infection",
                       uti = "UTI",
                       lrti = "LRTI",
                       urti = "URTI",
                       sinusits = "Sinusitis",
                       otmedia = "Otitis_media",
                       ot_externa = "Otitis_externa",
                       uncoded = "Uncoded")
  
  # recode empty value
  dat$infection=ifelse(dat$infection=="","uncoded",dat$infection)
  
  #remove uti
 # dat=dat%>%filter(infection != "UTI") # remove UTI for analysis
  
  
  # summarise ab counts for infection
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

# reorder
dat$infection <- factor(dat$infection, levels=c("Covid","LRTI","Otitis_externa","Otitis_media","Sinusitis","URTI","UTI","Other_infection","Uncoded"))
#dat$infection <- factor(dat$infection, levels=c("Covid","LRTI","Otitis_externa","Otitis_media","Sinusitis","URTI","Other_infection","Uncoded"))


# # plot
abtype_bar <- ggplot(dat,aes(x=date, y=value, fill=infection)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white")+
  labs(
    fill = "Infections",
    title = "Incident antibiotic prescriptions with an infection code recorded",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)+
  scale_fill_manual(values = c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))

# # plot
abtype_bar_2 <- ggplot(dat,aes(x=date, y=count, fill=infection)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(position="stack", stat="identity")+
  labs(
    fill = "Infections",
    title = "Incident antibiotic prescriptions with an infection code recorded",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "counts",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  #scale_y_continuous(labels = scales::percent)+
  scale_fill_manual(values = c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))


## # line graph-percent
lineplot<- ggplot(dat, aes(x=date, y=count,group=infection,color=infection))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  geom_point(aes(shape=infection))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Infections",
    title = "Incident antibiotic prescriptions with an infection code recorded",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "counts",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
#  scale_y_continuous(labels = scales::percent)+
  scale_shape_manual(values = c(rep(1:8))) +
  scale_color_manual(values =  c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))



ggsave(
  plot= abtype_bar,
  filename="ab_recorded_incident_bar.jpeg", path=here::here("output"),
)

ggsave(
  plot= abtype_bar_2,
  filename="ab_recorded_incident_bar_2.jpeg", path=here::here("output"),
)

ggsave(
  plot= lineplot,
  filename="ab_recorded_incident_line.jpeg", path=here::here("output"),
) 

write_csv(dat, here::here("output", "ab_recorded_incident.csv"))





###### ver.2
# # read in files
# df19=read_rds("recorded_ab_broad_2019.rds")
# df20=read_rds("recorded_ab_broad_2020.rds")
# df21=read_rds("recorded_ab_broad_2021.rds")
# df22=read_rds("recorded_ab_broad_2022.rds")
# dat=bind_rows(df19,df20,df21,df22)
# rm(df19,df20,df21,df22)

# # remove last month data
# last.date=max(dat$date)
# dat=dat%>% filter(date != last.date)
# first_mon=format(min(dat$date),"%m-%Y")
# last_mon= format(max(dat$date),"%m-%Y")

# # define variables
# dat$prevalent=as.factor(dat$prevalent)
# dat$infection=as.character(dat$infection)

# # recode
# dat$infection=recode(dat$infection,
#                      asthma ="others",
#                      cold="others",
#                      cough="others",
#                      copd="others",
#                      pneumonia="others",
#                      renal="others",
#                      sepsis="others",
#                      throat="others")
                  


# # recode empty value
# dat$infection=ifelse(dat$infection=="","uncoded",dat$infection)


# # patient number
# #dat=dat%>%dplyr::group_by(date)%>%mutate(patient=length(unique(patient_id)))

# # select prevalent
# dat=dat%>%filter(prevalent==0)

# # summarise ab counts for infection
# dat=dat%>%group_by(date,infection)%>%summarise(count=n())
# # total antibiotics count per month
# dat=dat%>%group_by(date)%>%mutate(total=sum(count))
# # percentage
# dat$value=dat$count/dat$total


# # recode
# dat$infection=recode(dat$infection,
#                      others = "Other infections",
#                      uti = "UTI",
#                      lrti = "LRTI",
#                      urti = "URTI",
#                      sinusits = "Sinusitis",
#                      otmedia = "Otitis media",
#                      ot_externa = "Otitis externa",
#                      uncoded = "Uncoded")
# # reorder
# dat$infection <- factor(dat$infection, levels=c("LRTI","Otitis externa","Otitis media","Sinusitis","URTI","UTI","Other infections","Uncoded"))




# # # plot
# abtype_bar <- ggplot(dat,aes(x=date, y=value, fill=infection)) + 
#   annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   geom_col(color="white")+
#   labs(
#     fill = "Infections",
#     title = "Incident antibiotic prescriptions with an infection code recorded",
#     #subtitle = paste(first_mon,"-",last_mon),
#     caption = "Grey shading represents national lockdown time. ",
#     y = "Percentage",
#     x=""
#   )+
#   theme(axis.text.x=element_text(angle=60,hjust=1))+
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
#   scale_y_continuous(labels = scales::percent)+
#   scale_fill_manual(values = c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))


# ## # line graph-percent
# lineplot<- ggplot(dat, aes(x=date, y=value,group=infection,color=infection))+
#   annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   geom_line()+
#   geom_point(aes(shape=infection))+
#   theme(legend.position = "bottom",legend.title =element_blank())+
#   labs(
#     fill = "Infections",
#     title = "Incident antibiotic prescriptions with an infection code recorded",
#     #  subtitle = paste(first_mon,"-",last_mon),
#     caption = "Grey shading represents national lockdown time. ",
#     y = "Percentage",
#     x=""
#   )+
#   theme(axis.text.x=element_text(angle=60,hjust=1))+
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
#   scale_y_continuous(labels = scales::percent)+
#   scale_shape_manual(values = c(rep(1:8))) +
#   scale_color_manual(values =  c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))



# ggsave(
#   plot= abtype_bar,
#   filename="ab_recorded_incident_bar.jpeg", path=here::here("output"),
# )
# ggsave(
#   plot= lineplot,
#   filename="ab_recorded_incident_line.jpeg", path=here::here("output"),
# ) 

# write_csv(dat, here::here("output", "ab_recorded_incident.csv"))


#### ver.1

# # file list
# Files = list.files(pattern="recorded_ab_broad_20", full.names = TRUE)
# temp <- vector("list", length(Files))

# for (i in seq_along(Files)){
  
# DF=read_rds(Files[i])

# #dat=rbindlist(DF)
# dat=bind_rows(DF)

# # filter incident
# dat=dat%>%filter(prevalent==0)%>%select(patient_id,date,infection)

# # # recorde date into year-month
# # dat$date=format(dat$date,"%Y-%m")
# # dat$date=as.Date(paste0(dat$date,"-01"))

# # recode
# dat$infection=recode(dat$infection,
#                  asthma ="Other infection",
#                  cold="Other infection",
#                  cough="Other infection",
#                  copd="Other infection",
#                  pneumonia="Other infection",
#                  renal="Other infection",
#                  sepsis="Other infection",
#                  throat="Other infection",
#                  uti = "UTI",
#                  lrti = "LRTI",
#                  urti = "URTI",
#                  sinusits = "Sinusitis",
#                  otmedia = "Otitis media",
#                  ot_externa = "Otitis externa")
 
# # patient number
# dat$patient=length(unique(as.factor(dat$patient_id)))

# # infection counts               
# dat.sum=dat%>%group_by(date, infection)%>%
#   summarise(count=n(),
#             patient=mean(patient)) # equal in each row

# rm(dat,DF)
# temp[[i]] = dat.sum
# }

# # combine list->data.frame
# dat=bind_rows(temp)

# rm(temp,dat.sum,i,Files)

# # remove last month data
# last.date=max(dat$date)
# dat=dat%>% filter(date != last.date)
# first_mon=format(min(dat$date),"%m-%Y")
# last_mon= format(max(dat$date),"%m-%Y")


# # recode NA
# dat$infection=dat$infection %>% replace_na("Uncoded")

# # reorder
# dat$infection <- factor(dat$infection, levels=c("LRTI","Otitis externa","Otitis media","Sinusitis","URTI","UTI","Other infection","Uncoded"))

# # calculate rate= prescriptions/ number of patients
# dat$value=dat$count/dat$patient

# # plot
# abtype_bar <- ggplot(dat,aes(x=date, y=value, fill=infection)) + 
#   annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   geom_bar(color="white",position="fill", stat="identity")+
#   labs(
#     fill = "Infections",
#     title = "Incident antibiotic prescriptions with infection records",
#     #subtitle = paste(first_mon,"-",last_mon),
#     caption = "Grey shading represents national lockdown time. ",
#     y = "Percentage",
#     x=""
#   )+
#   theme(axis.text.x=element_text(angle=60,hjust=1))+
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
#   scale_y_continuous(labels = scales::percent)



# ## # line graph-percent
# lineplot<- ggplot(dat, aes(x=date, y=value,group=infection,color=infection))+
#   annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   geom_line()+
#   theme(legend.position = "bottom",legend.title =element_blank())+
#   labs(
#     fill = "Infections",
#     title = "Incident antibiotic prescriptions with infection records",
#   #  subtitle = paste(first_mon,"-",last_mon),
#     caption = "Grey shading represents national lockdown time. ",
#     y = "Percentage",
#     x=""
#   )+
#   theme(axis.text.x=element_text(angle=60,hjust=1))+
#   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
#   scale_y_continuous(labels = scales::percent)



# ggsave(
#   plot= abtype_bar,
#   filename="ab_recorded_incident_bar.jpeg", path=here::here("output"),
# )
# ggsave(
#   plot= lineplot,
#   filename="ab_recorded_incident_line.jpeg", path=here::here("output"),
# ) 

# write_csv(dat, here::here("output", "ab_recorded_incident.csv"))


