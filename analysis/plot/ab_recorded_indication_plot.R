

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")



# file list
Files = list.files(pattern="recorded_ab_indication_", full.names = TRUE)
temp <- vector("list", length(Files))

for (i in seq_along(Files)){
  
DF=read_rds(Files[i])

#dat=rbindlist(DF)
dat=bind_rows(DF)

# filter incident
dat=dat%>%filter(prevalent==0)

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
 
# patient number
dat$patient=length(unique(as.factor(dat$patient_id)))

# infection counts               
dat.sum=dat%>%group_by(date, infection)%>%
  summarise(count=n(),
            patient=mean(patient)) # equal in each row

rm(dat,DF)
temp[[i]] = dat.sum
}

# combine list->data.frame
dat=bind_rows(temp)

rm(temp,dat.sum,i,Files)

# remove last month data
last.date=max(dat$date)
dat=dat%>% filter(date != last.date)
first_mon=format(min(dat$date),"%m-%Y")
last_mon= format(max(dat$date),"%m-%Y")


# recode NA
dat$infection=dat$infection %>% replace_na("Uncoded")

# reorder
dat$infection <- factor(dat$infection, levels=c("LRTI","Otitis externa","Otitis media","Sinusitis","URTI","UTI","Other infection","Uncoded"))

# calculate rate= prescriptions/ number of infection patients
dat$value=dat$count/dat$patient

# plot
abtype_bar <- ggplot(dat,aes(x=date, y=value, fill=infection)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(color="white",position="fill", stat="identity")+
  labs(
    fill = "Infections",
    title = "Antibiotic prescriptions with infection records",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)




## # line graph-percent
lineplot<- ggplot(dat, aes(x=date, y=value,group=infection,color=infection))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    fill = "Infections",
    title = "Prescriptions with infection records",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "Grey shading represents national lockdown time. ",
    y = "number of prescriptions per 1000 infection patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")




ggsave(
  plot= abtype_bar,
  filename="ab_recorded_indication_bar.jpeg", path=here::here("output"),
)
ggsave(
  plot= lineplot,
  filename="ab_recorded_indication_line.jpeg", path=here::here("output"),
) 

write_csv(dat, here::here("output", "ab_recorded_indication.csv"))
