

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")


# # file list
# Files = list.files(pattern="ab_type_20", full.names = FALSE)
# temp <- vector("list", length(Files))

# for (i in seq_along(Files)){
  
#   DF=read_rds(Files[i])
  
#   #dat=rbindlist(DF)
#   dat=bind_rows(DF)
#   rm(DF)
  
  
#   # filter incident
#   dat=dat%>%filter(type=="Trimethoprim"|type=="Nitrofurantoin")
  
  
#   # summarise ab counts
#   dat=dat%>%group_by(date,type)%>%summarise(count=n())

  
#   #round ~5
#   dat$count=round(dat$count/5)*5
  
#   # percentage
#   dat=dat%>%group_by(date)%>%mutate(total=sum(count))
  
#   temp[[i]] = dat
#   rm(dat)
# }

# # combine list->data.frame
# dat=bind_rows(temp)

# rm(temp,dat.sum,i,Files)

# # group by month
# dat$cal_YM=format(dat$date,"%Y-%m")
# dat=dat%>%group_by(cal_YM,type)%>%summarise(count=sum(count),total=sum(total))

# # remove last month data
# last.date=max(dat$cal_YM)
# dat=dat%>% filter(cal_YM != last.date)


# dat$value=dat$count/dat$total

# dat=dat%>%arrange(cal_YM)
date= seq(as.Date("2019-01-01"), as.Date("2022-06-01"), "month")
Files = list.files(pattern="measure_ratio_", full.names = FALSE)
temp <- vector("list", length(Files))

 for (i in seq_along(Files)){

   DF=read_csv(Files[i])
   DF$date=date[i]
   temp[[i]] = DF
 }

   dat=bind_rows(temp)
   
   ## # line graph-percent
   lineplot<- ggplot(dat, aes(x=date,y=Trimethoprim/(Trimethoprim+Nitrofurantoin)))+
     annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
     annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
     annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
     geom_line()+
     theme(legend.position = "bottom",legend.title =element_blank())+
     labs(
       title = "Trimethoprim/(Trimethoprim+Nitrofurantoin)",
       caption = "Grey shading represents national lockdown time. ",
       y = "ratio",
       x=""
     )+
     theme(axis.text.x=element_text(angle=60,hjust=1))


## # line graph-percent
lineplot2<- ggplot(dat, aes(x=date))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(y=Nitrofurantoin))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Nitrofurantoin",
    caption = "Grey shading represents national lockdown time. ",
    y = "items",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))
#  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")
#  scale_y_continuous(labels = scales::percent)+
 # scale_shape_manual(values = c(rep(1:8))) +
  #scale_color_manual(values =  c("red","goldenrod2","green3","forestgreen","deepskyblue","darkorchid1","darkblue","azure4"))
## # line graph-percent
lineplot3<- ggplot(dat, aes(x=date))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(y=Trimethoprim))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Trimethoprim",
    caption = "Grey shading represents national lockdown time. ",
    y = "items",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))


ggsave(
  plot= lineplot,
  filename="uti_ab_ratio_check_line.jpeg", path=here::here("output"),
)



ggsave(
  plot= lineplot2,
  filename="uti_ab_ratio_check_line2.jpeg", path=here::here("output"),
) 



ggsave(
  plot= lineplot3,
  filename="uti_ab_ratio_check_line3.jpeg", path=here::here("output"),
) 
write_csv(dat, here::here("output", "uti_ab_ratio_check.csv"))




