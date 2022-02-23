library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

rds1 <- read_rds('recorded_ab_broad_2019.rds')
rds2 <- read_rds('recorded_ab_broad_2020.rds')
rds3 <- read_rds('recorded_ab_broad_2021.rds')
rds4 <- read_rds('recorded_ab_broad_2022.rds')

dat=dplyr::bind_rows(rds1,rds2,rds3,rds4)

last.date=max(dat$date)
dat=dat%>% dplyr::filter(date!=last.date)
first_mon <- (format(min(dat$date), "%m-%Y"))
last_mon <- (format(max(dat$date), "%m-%Y"))


dfrate <- dat%>% dplyr::group_by(date) %>% filter(broad_spectrum==1) %>% dplyr::summarise(count = n())
dftotal <- dat%>% dplyr::group_by(date) %>% dplyr::summarise(total = n())
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
  filename="broad_proportions_line.jpeg", path=here::here("output"),
)  

write_csv(dfprop, here::here("output", "broad_proportions.csv"))