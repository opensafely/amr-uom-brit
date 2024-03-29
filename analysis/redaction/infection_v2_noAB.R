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
#setwd("/Users/user/Documents/GitHub/amr-uom-brit/output/measures")


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
df=rbind(df.0,df.1)
write_csv(df, here::here("output","redacted_v2", "noAB_uti_check.csv"))


### line graph
# prevalent

lineplot.1<- ggplot(df.1, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
   labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

# incident
lineplot.0<- ggplot(df.0, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

lineplot=ggarrange(lineplot.0, lineplot.1, 
          labels = c("A", "B"),
          nrow = 2)

lineplot=annotate_figure(lineplot,
                top = text_grob(" ", face = "bold", size = 14),
                bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                   hjust = 1, x = 1, size = 10),
                 fig.lab =paste0("Consultations without coded antibiotic prescriptions - UTI       ",
                                         first_mon," - ",last_mon),
                left = text_grob("", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="noAB_uti.jpeg", path=here::here("output","redacted_v2")) 

### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# define seasons
# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.1=df%>%
  group_by(covid,season,prevalent)%>%
  summarise(count=sum(count), total=sum(total))%>%
  mutate(indic="uti",percent=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)




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
df=rbind(df.0,df.1)
write_csv(df, here::here("output","redacted_v2", "noAB_lrti_check.csv"))


### line graph
# prevalent

lineplot.1<- ggplot(df.1, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)
  
# incident

lineplot.0<- ggplot(df.0, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

lineplot=ggarrange(lineplot.0, lineplot.1, 
                   labels = c("A", "B"),
                   nrow = 2)

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Consultations without coded antibiotic prescriptions - LRTI       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="noAB_lrti.jpeg", path=here::here("output","redacted_v2")) 

### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# define seasons
# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.2=df%>%
  group_by(covid,season,prevalent)%>%
  summarise(count=sum(count), total=sum(total))%>%
  mutate(indic="lrti",percent=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)


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
df=rbind(df.0,df.1)
write_csv(df, here::here("output","redacted_v2", "noAB_urti_check.csv"))


### line graph
# prevalent

lineplot.1<- ggplot(df.1, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

# incident

lineplot.0<- ggplot(df.0, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

lineplot=ggarrange(lineplot.0, lineplot.1, 
                   labels = c("A", "B"),
                   nrow = 2)

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Consultations without coded antibiotic prescriptions - URTI       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="noAB_urti.jpeg", path=here::here("output","redacted_v2")) 

### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# define seasons
# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.3=df%>%
  group_by(covid,season,prevalent)%>%
  summarise(count=sum(count), total=sum(total))%>%
  mutate(indic="urti",percent=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)



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
df=rbind(df.0,df.1)
write_csv(df, here::here("output","redacted_v2", "noAB_sinusitis_check.csv"))


### line graph
# prevalent

lineplot.1<- ggplot(df.1, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

# incident

lineplot.0<- ggplot(df.0, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

lineplot=ggarrange(lineplot.0, lineplot.1, 
                   labels = c("A", "B"),
                   nrow = 2)

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Consultations without coded antibiotic prescriptions - sinusitis       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="noAB_sinusitis.jpeg", path=here::here("output","redacted_v2")) 

### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# define seasons
# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.4=df%>%
  group_by(covid,season,prevalent)%>%
  summarise(count=sum(count), total=sum(total))%>%
  mutate(indic="sinusitis",percent=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)


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
df=rbind(df.0,df.1)
write_csv(df, here::here("output","redacted_v2", "noAB_ot_externa_check.csv"))


### line graph
# prevalent

lineplot.1<- ggplot(df.1, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

# incident

lineplot.0<- ggplot(df.0, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

lineplot=ggarrange(lineplot.0, lineplot.1, 
                   labels = c("A", "B"),
                   nrow = 2)

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Consultations without coded antibiotic prescriptions - otitis externa       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="noAB_ot_externa.jpeg", path=here::here("output","redacted_v2")) 

### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# define seasons
# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.5=df%>%
  group_by(covid,season,prevalent)%>%
  summarise(count=sum(count), total=sum(total))%>%
  mutate(indic="ot_externa",percent=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)




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
df=rbind(df.0,df.1)
write_csv(df, here::here("output","redacted_v2", "noAB_otmedia_check.csv"))


### line graph
# prevalent
lineplot.1<- ggplot(df.1, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

# incident

lineplot.0<- ggplot(df.0, aes(x=date, y=percentage))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line()+
  labs(
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)

lineplot=ggarrange(lineplot.0, lineplot.1, 
                   labels = c("A", "B"),
                   nrow = 2)

lineplot=annotate_figure(lineplot,
                         top = text_grob(" ", face = "bold", size = 14),
                         bottom = text_grob("A= incident cases; B= prevalent cases.
                                   Grey shading represents national lockdown time.", 
                                            hjust = 1, x = 1, size = 10),
                         fig.lab =paste0("Consultations without coded antibiotic prescriptions - otitis media       ",
                                         first_mon," - ",last_mon),
                         left = text_grob("", rot = 90),
)


ggsave(
  plot= lineplot,
  filename="noAB_otmedia.jpeg", path=here::here("output","redacted_v2")) 

### tables
# define covid date
breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# define seasons
# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.6=df%>%
  group_by(covid,season,prevalent)%>%
  summarise(count=sum(count), total=sum(total))%>%
  mutate(indic="otmedia",percent=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)



#### combine table
df.table=rbind(df.table.1,df.table.2,df.table.3,df.table.4,df.table.5,df.table.6)
write_csv(df.table, here::here("output","redacted_v2", "noAB.csv"))







