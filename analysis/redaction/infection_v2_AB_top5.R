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

## filter case with ab
df=df%>%filter(!is.na(abtype))

##select prevalent cases
# calculate ab types
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%mutate(total=n())
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 3 ab
DF.top10.1=df.1%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.1$type=ifelse(df.1$abtype %in% DF.top10.1$abtype | is.na(df.1$abtype), df.1$abtype, "Others")

# recode NA -> no recorded antibiotics
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.1=df.1%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
##df.1$percentage=df.1$count/df.1$total

##select incident cases
# calculate ab types
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%mutate(total=n())
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 5 ab
DF.top10.0=df.0%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.0$type=ifelse(df.0$abtype %in% DF.top10.0$abtype | is.na(df.0$abtype), df.0$abtype, "Others")

# recode NA -> no recorded antibiotics
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.0=df.0%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.0$percentage=df.0$count/df.0$total


## csv check for plot
rm(DF.top10.0,DF.top10.1,df)
df.1$prevalent=as.factor(1)
df.0$prevalent=as.factor(0)
df=rbind(df.0,df.1)

# redacted
df$raw_count=df$count
df$raw_total=df$total
df$count=ifelse(df$count<=6,6, df$count)
df=df%>%group_by(date,prevalent)%>%mutate(total=sum(count))
df$percentage=df$count/df$total


write_csv(df, here::here("output","redacted_v2", "AB_uti_check_top5.csv"))

df.1=df%>%filter(prevalent==1)
df.0=df%>%filter(prevalent==0)

### line graph
# prevalent
lineplot.1.uti<- ggplot(df.1, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("UTI")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))        

#ggsave(
 # plot= lineplot.1,
 # filename="prevalent_AB_uti_top5.jpeg", path=here::here("output","redacted_v2")) 

# incident
lineplot.0.uti<- ggplot(df.0, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("UTI")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))      

#ggsave(
 # plot= lineplot.0,
 # filename="incident_AB_uti_top5.jpeg", path=here::here("output","redacted_v2")) 



#lineplot=ggarrange(lineplot.0, lineplot.1, 
#                   labels = c("A", "B"),
 #                  nrow = 2)

#lineplot=annotate_figure(lineplot,
#                         top = text_grob(" ", face = "bold", size = 14),
#                         bottom = text_grob("A= incident cases; B= prevalent cases.
#                                    Grey shading represents national lockdown time.", 
#                                             hjust = 1, x = 1, size = 10),
#                         fig.lab =paste0("Top 5 antibiotic prescriptions issued - UTI       ",
#                                         first_mon," - ",last_mon),
#                         left = text_grob("", rot = 90),
#)

#ggsave(
#  plot= lineplot,
#  filename="AB_uti_top5.jpeg", path=here::here("output","redacted_v2")) 

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
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.1=df%>%
  group_by(covid,season,prevalent,type)%>%
  summarise(count=sum(count))%>%
  mutate(indic="uti")

df.table.1=df.table.1%>%
  group_by(covid,season,prevalent)%>%
  mutate(total=sum(count), percentage=count/total)

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

## filter case with ab
df=df%>%filter(!is.na(abtype))

##select prevalent cases
# calculate ab types
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%mutate(total=n())
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 5 ab
DF.top10.1=df.1%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.1$type=ifelse(df.1$abtype %in% DF.top10.1$abtype | is.na(df.1$abtype), df.1$abtype, "Others")

# recode NA -> no recorded antibiotics
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.1=df.1%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
##df.1$percentage=df.1$count/df.1$total

##select incident cases
# calculate ab types
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%mutate(total=n())
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 3 ab
DF.top10.0=df.0%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.0$type=ifelse(df.0$abtype %in% DF.top10.0$abtype | is.na(df.0$abtype), df.0$abtype, "Others")

# recode NA -> no recorded antibiotics
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.0=df.0%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.0$percentage=df.0$count/df.0$total


## csv check for plot
rm(DF.top10.0,DF.top10.1,df)
df.1$prevalent=as.factor(1)
df.0$prevalent=as.factor(0)
df=rbind(df.0,df.1)

# redacted
df$raw_count=df$count
df$raw_total=df$total
df$count=ifelse(df$count<=6,6, df$count)
df=df%>%group_by(date,prevalent)%>%mutate(total=sum(count))
df$percentage=df$count/df$total

write_csv(df, here::here("output","redacted_v2", "AB_lrti_check_top5.csv"))


df.1=df%>%filter(prevalent==1)
df.0=df%>%filter(prevalent==0)

### line graph
# prevalent
lineplot.1.lrti<- ggplot(df.1, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("LRTI")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))   

#ggsave(
#  plot= lineplot.1,
 # filename="prevalent_AB_lrti_top5.jpeg", path=here::here("output","redacted_v2")) 


# incident
lineplot.0.lrti<- ggplot(df.0, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("LRTI")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))   
#ggsave(
#  plot= lineplot.0,
 # filename="incident_AB_lrti_top5.jpeg", path=here::here("output","redacted_v2")) 





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
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.2=df%>%
  group_by(covid,season,prevalent,type)%>%
  summarise(count=sum(count))%>%
  mutate(indic="lrti")

df.table.2=df.table.2%>%
  group_by(covid,season,prevalent)%>%
  mutate(total=sum(count), percentage=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)




###########URTI

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

## filter case with ab
df=df%>%filter(!is.na(abtype))

##select prevalent cases
# calculate ab types
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%mutate(total=n())
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 3 ab
DF.top10.1=df.1%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.1$type=ifelse(df.1$abtype %in% DF.top10.1$abtype | is.na(df.1$abtype), df.1$abtype, "Others")

# recode NA -> no recorded antibiotics
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.1=df.1%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.1$percentage=df.1$count/df.1$total

##select incident cases
# calculate ab types
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%mutate(total=n())
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 5 ab
DF.top10.0=df.0%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.0$type=ifelse(df.0$abtype %in% DF.top10.0$abtype | is.na(df.0$abtype), df.0$abtype, "Others")

# recode NA -> no recorded antibiotics
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.0=df.0%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.0$percentage=df.0$count/df.0$total


## csv check for plot
rm(DF.top10.0,DF.top10.1,df)
df.1$prevalent=as.factor(1)
df.0$prevalent=as.factor(0)
df=rbind(df.0,df.1)
# redacted
df$raw_count=df$count
df$raw_total=df$total
df$count=ifelse(df$count<=6,6, df$count)
df=df%>%group_by(date,prevalent)%>%mutate(total=sum(count))
df$percentage=df$count/df$total

write_csv(df, here::here("output","redacted_v2", "AB_urti_check_top5.csv"))



df.1=df%>%filter(prevalent==1)
df.0=df%>%filter(prevalent==0)
### line graph
# prevalent
lineplot.1.urti<- ggplot(df.1, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("URTI")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))       

#ggsave(
 # plot= lineplot.1,
 # filename="prevalent_AB_urti_top5.jpeg", path=here::here("output","redacted_v2")) 


# incident
lineplot.0.urti<- ggplot(df.0, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("URTI")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))   
#ggsave(
 # plot= lineplot.0,
 # filename="incident_AB_urti_top5.jpeg", path=here::here("output","redacted_v2")) 



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
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.3=df%>%
  group_by(covid,season,prevalent,type)%>%
  summarise(count=sum(count))%>%
  mutate(indic="urti")

df.table.3=df.table.3%>%
  group_by(covid,season,prevalent)%>%
  mutate(total=sum(count), percentage=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)



######### Sinusitis

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

## filter case with ab
df=df%>%filter(!is.na(abtype))

##select prevalent cases
# calculate ab types
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%mutate(total=n())
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 5 ab
DF.top10.1=df.1%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.1$type=ifelse(df.1$abtype %in% DF.top10.1$abtype | is.na(df.1$abtype), df.1$abtype, "Others")

# recode NA -> no recorded antibiotics
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.1=df.1%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.1$percentage=df.1$count/df.1$total

##select incident cases
# calculate ab types
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%mutate(total=n())
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 3 ab
DF.top10.0=df.0%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.0$type=ifelse(df.0$abtype %in% DF.top10.0$abtype | is.na(df.0$abtype), df.0$abtype, "Others")

# recode NA -> no recorded antibiotics
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.0=df.0%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.0$percentage=df.0$count/df.0$total



## csv check for plot
rm(DF.top10.0,DF.top10.1,df)
df.1$prevalent=as.factor(1)
df.0$prevalent=as.factor(0)
df=rbind(df.0,df.1)

# redacted
df$raw_count=df$count
df$raw_total=df$total
df$count=ifelse(df$count<=6,6, df$count)
df=df%>%group_by(date,prevalent)%>%mutate(total=sum(count))
df$percentage=df$count/df$total

write_csv(df, here::here("output","redacted_v2", "AB_sinusitis_check_top5.csv"))


df.1=df%>%filter(prevalent==1)
df.0=df%>%filter(prevalent==0)

### line graph
# prevalent
lineplot.1.sin<- ggplot(df.1, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("Sinusitis")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))   

#ggsave(
 # plot= lineplot.1,
 # filename="prevalent_AB_sinusitis_top5.jpeg", path=here::here("output","redacted_v2")) 


# incident
lineplot.0.sin<- ggplot(df.0, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("Sinusitis")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))        

#ggsave(
#  plot= lineplot.0,
#  filename="incident_AB_sinusitis_top5.jpeg", path=here::here("output","redacted_v2")) 




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
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.4=df%>%
  group_by(covid,season,prevalent,type)%>%
  summarise(count=sum(count))%>%
  mutate(indic="sinusitis")

df.table.4=df.table.4%>%
  group_by(covid,season,prevalent)%>%
  mutate(total=sum(count), percentage=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)




####### otitis externa



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

## filter case with ab
df=df%>%filter(!is.na(abtype))

##select prevalent cases
# calculate ab types
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%mutate(total=n())
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 5 ab
DF.top10.1=df.1%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.1$type=ifelse(df.1$abtype %in% DF.top10.1$abtype | is.na(df.1$abtype), df.1$abtype, "Others")

# recode NA -> no recorded antibiotics
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.1=df.1%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.1$percentage=df.1$count/df.1$total

##select incident cases
# calculate ab types
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%mutate(total=n())
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 3 ab
DF.top10.0=df.0%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.0$type=ifelse(df.0$abtype %in% DF.top10.0$abtype | is.na(df.0$abtype), df.0$abtype, "Others")

# recode NA -> no recorded antibiotics
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.0=df.0%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.0$percentage=df.0$count/df.0$total



## csv check for plot
rm(DF.top10.0,DF.top10.1,df)
df.1$prevalent=as.factor(1)
df.0$prevalent=as.factor(0)
df=rbind(df.0,df.1)

# redacted
df$raw_count=df$count
df$raw_total=df$total
df$count=ifelse(df$count<=6,6, df$count)
df=df%>%group_by(date,prevalent)%>%mutate(total=sum(count))
df$percentage=df$count/df$total

write_csv(df, here::here("output","redacted_v2", "AB_ot_externa_check_top5.csv"))

df.1=df%>%filter(prevalent==1)
df.0=df%>%filter(prevalent==0)
### line graph
# prevalent
lineplot.1.oe<- ggplot(df.1, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("Otitis externa")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))     

#ggsave(
 # plot= lineplot.1,
 # filename="prevalent_AB_ot_externa_top5.jpeg", path=here::here("output","redacted_v2")) 



# incident
lineplot.0.oe<- ggplot(df.0, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("Otitis externa")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))   

#ggsave(
 # plot= lineplot.0,
 # filename="incident_AB_ot_externa_top5.jpeg", path=here::here("output","redacted_v2")) 



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
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.5=df%>%
  group_by(covid,season,prevalent,type)%>%
  summarise(count=sum(count))%>%
  mutate(indic="ot_externa")

df.table.5=df.table.5%>%
  group_by(covid,season,prevalent)%>%
  mutate(total=sum(count), percentage=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)


########## otitis media

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

## filter case with ab
df=df%>%filter(!is.na(abtype))

##select prevalent cases
# calculate ab types
df.1=df%>%filter(prevalent==1)%>%group_by(date)%>%mutate(total=n())
df.1=df.1%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 3 ab
DF.top10.1=df.1%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.1$type=ifelse(df.1$abtype %in% DF.top10.1$abtype | is.na(df.1$abtype), df.1$abtype, "Others")

# recode NA -> no recorded antibiotics
df.1$type=ifelse(is.na(df.1$type),"No_antibiotics", df.1$type)
df.1$type <- factor(df.1$type, levels=c(DF.top10.1$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.1=df.1%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.1$percentage=df.1$count/df.1$total

##select incident cases
# calculate ab types
df.0=df%>%filter(prevalent==0)%>%group_by(date)%>%mutate(total=n())
df.0=df.0%>%group_by(date,abtype)%>%summarise(count=n(),total=mean(total))


# top 5 ab
DF.top10.0=df.0%>%
  group_by(abtype)%>%
  summarise(count=sum(count))%>% 
  arrange(desc(count))%>%
  slice(1:5)

# sort ab type
# recode other types
df.0$type=ifelse(df.0$abtype %in% DF.top10.0$abtype | is.na(df.0$abtype), df.0$abtype, "Others")

# recode NA -> no recorded antibiotics
df.0$type=ifelse(is.na(df.0$type),"No_antibiotics", df.0$type)
df.0$type <- factor(df.0$type, levels=c(DF.top10.0$abtype,"Others","No_antibiotics"))# reorder


# consultation with AB 
df.0=df.0%>%group_by(date,type)%>%summarise(count=sum(count),total=mean(total))
#df.0$percentage=df.0$count/df.0$total



## csv check for plot
rm(DF.top10.0,DF.top10.1,df)
df.1$prevalent=as.factor(1)
df.0$prevalent=as.factor(0)
df=rbind(df.0,df.1)

# redacted
df$raw_count=df$count
df$raw_total=df$total
df$count=ifelse(df$count<=6,6, df$count)
df=df%>%group_by(date,prevalent)%>%mutate(total=sum(count))
df$percentage=df$count/df$total

write_csv(df, here::here("output","redacted_v2", "AB_otmedia_check_top5.csv"))


df.1=df%>%filter(prevalent==1)
df.0=df%>%filter(prevalent==0)
### line graph
# prevalent
lineplot.1.om<- ggplot(df.1, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("Otitis media")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))     

#ggsave(
#  plot= lineplot.1,
 # filename="prevalent_AB_otmedia_top5.jpeg", path=here::here("output","redacted_v2")) 


# incident
lineplot.0.om<- ggplot(df.0, aes(x=date, y=percentage, group=type,color=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=type))+
  geom_point(aes(shape=type),size=0.5)+
  theme(legend.position = "right",legend.title =element_blank())+
  scale_shape_manual(values = c(rep(1:11))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","blue","green4","goldenrod2","blue3","green3","forestgreen","dodgerblue","black"))+
  labs(
    y = "" ,
    x="")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "2 month")+
  scale_y_continuous(labels = scales::percent)+
  ggtitle("Otitis media")+
  theme(text = element_text(size = 8))+
  theme(plot.title = element_text(size = 7))   

#ggsave(
 # plot= lineplot.0,
 # filename="incident_AB_otmedia_top5.jpeg", path=here::here("output","redacted_v2")) 




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
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))
df.table.6=df%>%
  group_by(covid,season,prevalent,type)%>%
  summarise(count=sum(count))%>%
  mutate(indic="otmedia")

df.table.6=df.table.6%>%
  group_by(covid,season,prevalent)%>%
  mutate(total=sum(count), percentage=count/total)

rm(df,df.0,df.1,lineplot,lineplot.0,lineplot.1)


#### combine table
df.table=rbind(df.table.1,df.table.2,df.table.3,df.table.4,df.table.5,df.table.6)
write_csv(df.table, here::here("output","redacted_v2", "AB_top5.csv"))


lineplot.0=ggarrange(lineplot.0.urti, lineplot.0.lrti,lineplot.0.oe,lineplot.0.om,lineplot.0.uti,lineplot.0.sin,
                  nrow = 3, ncol=2)


lineplot.1=ggarrange(lineplot.1.urti, lineplot.1.lrti,lineplot.1.oe,lineplot.1.om,lineplot.1.uti,lineplot.1.sin,
                     nrow = 3, ncol=2)


ggsave(
 plot= lineplot.0,
filename="incident_AB_top5.jpeg", path=here::here("output","redacted_v2")) 
ggsave(
  plot= lineplot.1,
  filename="prevalent_AB_top5.jpeg", path=here::here("output","redacted_v2")) 
