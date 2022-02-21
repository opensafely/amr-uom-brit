library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

Files = list.files(pattern="recorded_ab_broad_", full.names = TRUE)
temp <- vector("list", length(Files))

for (i in seq_along(Files)){
  
  DF=read_rds(Files[i])
  
  #dat=rbindlist(DF)
  dat=bind_rows(DF)
  
  # filter incident
  ##dat=dat%>%filter(prevalent==0)
  
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

  rm(DF)
  temp[[i]] = dat
}

last.date=max(dat$date)
dat=dat%>% filter(date!=last.date)
first_mon <- (format(min(dat$date), "%m-%Y"))
last_mon <- (format(max(dat$date), "%m-%Y"))


dfrate <- dat%>% group_by(date) %>% filter(broad_spectrum==1) %>% dplyr::summarise(count = n())
dftotal <- dat%>% group_by(date) %>% dplyr::summarise(total = n())
dfprop <- merge(dfrate,dftotal,by='date')
dfprop$prop <- dfprop$count/dfprop$total

plot <- ggplot(dfprop, aes(x=date, y=prop))+
  geom_rect(xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_rect(xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_rect(xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_line()+
  theme(legend.position = "bottom",legend.title =element_blank())+
  scale_x_date(date_breaks = "1 month",date_labels =  "%m")+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.05))+
  labs(
    title = "Proportion of broad-spectrum antibiotics prescribed",  
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste('National lockdown in red area'), 
    x = "", 
    y = "broad-spectrum antibiotics prescribing %")
plot
## plot
ggsave(
  plot= plot,
  filename="broad_proportions_line_age.jpeg", path=here::here("output"),
)  