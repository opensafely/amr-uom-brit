##############
## Consultation rates for 6 common infection over time,
## stratified by age categories. 
## prevalent= with same infection in 90 days
##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
#library("cowplot")




### 1. import data 
##1.1 UTI
df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_UTI.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    uti_counts  = col_double(),
    population  = col_double(),
    hx_uti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=uti_counts, hx_pt=hx_uti_pt)

df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")
TPPnumber=length(unique(df$practice))

# select prevalent pt and count consultations
# hx_pt==1 means has same infection consultation in 90 days
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize prevalent number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(hx_counts), # count consultation number in each age_cat; hx=1(sum counts), hx=0(count=0)
            population=mean(population)) # patient number per GP
 
# "rate per 1,000 registered patients"
df_1=df_sum_gp_age%>%mutate(rate=pt_counts/population*1000,
                           indic="UTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)


###1.2 LRTI
#import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_LRTI.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    lrti_counts  = col_double(), 
    population  = col_double(),
    hx_lrti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)
df=df%>% rename(infection_counts=lrti_counts, hx_pt=hx_lrti_pt) 
df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select incdt=1 , count prevalent patient number
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(hx_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            population=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
# "rate per 1,000 registered patients"
df_2=df_sum_gp_age%>%mutate(rate=pt_counts/population*1000,
                           indic="LRTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)



### 1.3 URTI
#import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_URTI.csv"), 
  col_types = cols_only(
    
   # Identifier
    practice = col_integer(),
    
    #Outcomes
    urti_counts  = col_double(), 
    population  = col_double(),
    hx_urti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
   # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)
df=df%>% rename(infection_counts=urti_counts, hx_pt=hx_urti_pt) 
df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select incdt=1 , count prevalent patient number
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize prevalent consultation number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(hx_counts), 
            population=mean(population)) 
 
# "rate per 1,000 registered patients"
df_3=df_sum_gp_age%>%mutate(rate=pt_counts/population*1000,
                           indic="URTI")
rm(df,df_sum_gp_age,first_mon,last_mon,last.date)




###1.4 sinusitis 
#import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_sinusitis.csv"), 
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    sinusitis_counts  = col_double(), 
    population  = col_double(),
    hx_sinusitis_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)
df=df%>% rename(infection_counts=sinusitis_counts, hx_pt=hx_sinusitis_pt) 
df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select incdt=1, count prevalent patient number
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(hx_counts), 
            population=mean(population)) 
 
# "rate per 1,000 registered patients"
df_4=df_sum_gp_age%>%mutate(rate=pt_counts/population*1000,
                           indic="sinusitis")


rm(df,df_sum_gp_age,first_mon,last_mon,last.date)





### 1.5 ot_externa 
# import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_ot_externa.csv"), 
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    ot_externa_counts  = col_double(), 
    population  = col_double(),
    hx_ot_externa_pt = col_double(), 
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=ot_externa_counts, hx_pt=hx_ot_externa_pt) 

df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select incdt=1 , count prevalent patient number
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(hx_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            population=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_5=df_sum_gp_age%>%mutate(rate=pt_counts/population*1000,
                           indic="otitis externa")

rm(df,df_sum_gp_age,first_mon,last_mon,last.date)




### 1.6 otmedia 
# import data 

df <- read_csv(
  here::here("output", "measures", "measure_infection_consult_otmedia.csv"), 
  col_types = cols_only(
    
    #Identifier
    practice = col_integer(),
    
    #Outcomes
    otmedia_counts  = col_double(), 
    population  = col_double(),
    hx_otmedia_pt = col_double(), 
    age_cat = col_character(),
    value = col_double(),
    
    #Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)
df$date <- as.Date(df$date)

df=df%>% rename(infection_counts=otmedia_counts, hx_pt=hx_otmedia_pt) 

df[is.na(df)] <- 0 # replace NA ->0

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")

# select incdt=1 , count prevalent patient number
df$hx_counts=ifelse(df$hx_pt==1,df$infection_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(date,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(date,practice,age_cat)%>% 
  summarise(pt_counts=sum(hx_counts), 
            population=mean(population)) 
 
# "rate per 1,000 registered patients"
df_6=df_sum_gp_age%>%mutate(rate=pt_counts/population*1000,
                           indic="otitis media")

rm(df,df_sum_gp_age,last.date)



### 2. combined dataframe

df=rbind(df_1,df_2,df_3,df_4,df_5,df_6)


### 3. plots

## 3.1 consultation rate by age group

#summarise table
df_plot=df%>%
group_by(date,age_cat,indic)%>%
summarise(rate=mean(rate))

write.csv(df_plot,here::here("output","consultation_rate_prevalent.csv"))


# # line graph- by age group and divided by year
df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))

# df_plot=df_plot%>%mutate(age_cat_5= case_when(age_cat=="0-4"| age_cat=="5-14" ~ "0-14",
#                                               age_cat=="15-24"| age_cat=="25-34" ~ "15-34",
#                                               age_cat=="35-44"| age_cat=="45-54" ~ "35-54",
#                                               age_cat=="55-64"| age_cat=="65-74" ~ "55-74",
#                                               age_cat=="75+" ~ "75+"))

# df_plot2=df_plot%>%group_by(date,indic, age_cat_5)%>%summarise(rate=sum(rate))

# lineplot_2<- ggplot(df_plot2, aes(x=date, y=rate,group=age_cat_5))+
#   annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
#   scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
#   #scale_y_continuous(n.breaks = 20)+
#   facet_grid(rows  = vars(indic))+
#   geom_line(aes(color=age_cat_5))+
#   theme(axis.text.x = element_text(angle = 60,hjust=1),
#         legend.position = "bottom",legend.title =element_blank())+
#   labs(
#     title = "Consultation rate of prevalent patients for 6 common infections",
#     subtitle = paste(first_mon,"-",last_mon),
#     caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
#     x = "", 
#     y = "Number of consultations per 1000 patients")


df_plot.1=df_plot%>%filter(indic=="UTI")
lineplot_1<- ggplot(df_plot.1, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- UTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
    x = "", 
    y = "Number of consultations per 1000 patients")

  ggsave(
  plot= lineplot_1,
  filename="consult_age_prevalent_UTI.jpeg", path=here::here("output"))

  rm(df_plot.1,lineplot_1)

  df_plot.2=df_plot%>%filter(indic=="URTI")
lineplot_2<- ggplot(df_plot.2, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- URTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
    x = "", 
    y = "Number of consultations per 1000 patients")

  ggsave(
  plot= lineplot_2,
  filename="consult_age_prevalent_URTI.jpeg", path=here::here("output"))


  rm(df_plot.2,lineplot_2)

  df_plot.3=df_plot%>%filter(indic=="LRTI")
lineplot_3<- ggplot(df_plot.3, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- LRTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
    x = "", 
    y = "Number of consultations per 1000 patients")

  ggsave(
  plot= lineplot_3,
  filename="consult_age_prevalent_LRTI.jpeg", path=here::here("output"))


  rm(df_plot.3,lineplot_3)

  df_plot.4=df_plot%>%filter(indic=="sinusitis")
lineplot_4<- ggplot(df_plot.4, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- Sinusitis",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
    x = "", 
    y = "Number of consultations per 1000 patients")

  ggsave(
  plot= lineplot_4,
  filename="consult_age_prevalent_sinusitis.jpeg", path=here::here("output"))


 rm(df_plot.4,lineplot_4)



  df_plot.5=df_plot%>%filter(indic=="otitis media")
lineplot_5<- ggplot(df_plot.5, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- Otitis media",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
    x = "", 
    y = "Number of consultations per 1000 patients")

  ggsave(
  plot= lineplot_5,
  filename="consult_age_prevalent_otmedia.jpeg", path=here::here("output"))

   rm(df_plot.5,lineplot_5)




  df_plot.6=df_plot%>%filter(indic=="otitis externa")
lineplot_6<- ggplot(df_plot.6, aes(x=date, y=rate,group=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  scale_x_date(date_breaks = "1 month",date_labels =  "%Y-%m")+
  #scale_y_continuous(n.breaks = 20)+
  geom_line(aes(color=age_cat))+
  theme(axis.text.x = element_text(angle = 60,hjust=1),
        legend.position = "bottom",legend.title =element_blank())+
  labs(
    title = "Consultation rate of prevalent patients- Otitis externa",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
    x = "", 
    y = "Number of consultations per 1000 patients")

  ggsave(
  plot= lineplot_6,
  filename="consult_age_prevalent_ot_externa.jpeg", path=here::here("output"))


## 3.2 overall consultation rate percentile including percentiles

# #summarise table
# df_gprate=df%>%
# group_by(date,practice)%>%
# summarise(ab_rate_1000=mean(rate))


# # df_gprate$cal_year=format(df_gprate$date,"%Y")
# # df_gprate$cal_mon=format(df_gprate$date,"%m")


# # num_uniq_prac <- as.numeric(dim(table((df_gprate$practice))))

# # df_mean <- df_gprate %>% group_by(cal_mon, cal_year) %>%
# #   mutate(meanABrate = mean(ab_rate_1000,na.rm=TRUE),
# #          lowquart= quantile(ab_rate_1000, na.rm=TRUE)[2],
# #          highquart= quantile(ab_rate_1000, na.rm=TRUE)[4],
# #          ninefive= quantile(ab_rate_1000, na.rm=TRUE, c(0.95)),
# #          five=quantile(ab_rate_1000, na.rm=TRUE, c(0.05)))

  
# # plot_percentile <- ggplot(df_mean, aes(x=date))+
# #   annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
# #   annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
# #   annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
# #   geom_line(aes(y=meanABrate),color="steelblue")+
# #   geom_point(aes(y=meanABrate),color="steelblue")+
# #   geom_line(aes(y=lowquart), color="darkred", linetype=3)+
# #   geom_point(aes(y=lowquart), color="darkred", linetype=3)+
# #   geom_line(aes(y=highquart), color="darkred", linetype=3)+
# #   geom_point(aes(y=highquart), color="darkred", linetype=3)+
# #   geom_line(aes(y=ninefive), color="black", linetype=3)+
# #   geom_point(aes(y=ninefive), color="black", linetype=3)+
# #   geom_line(aes(y=five), color="black", linetype=3)+
# #   geom_point(aes(y=five), color="black", linetype=3)+
# #   scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
# #   scale_y_continuous(n.breaks = 20)+
# #   theme(axis.text.x=element_text(angle=60,hjust=1))+
# #   labs(
# #     title = "Consultation rate of prevalent patients for 6 common infections",
# #     subtitle = paste(first_mon,"-",last_mon),
# #     caption = paste("Data from approximately", TPPnumber,"TPP Practices; Grey shading represents national lockdown time."),
# #     x = "",
# #     y = "Number of consultations per 1000 patients")+
# #   geom_vline(xintercept = as.numeric(as.Date("2019-12-31")))+
# #   geom_vline(xintercept = as.numeric(as.Date("2020-12-31")))

#summarise table
df_gprate_infec=df%>%
  group_by(date,practice,indic)%>%
  summarise(ab_rate_1000=sum(pt_counts)/mean(population)*1000) #total consultations/ population *1000

num_uniq_prac <- as.numeric(dim(table((df_gprate_infec$practice))))

df_mean <- df_gprate_infec %>% group_by(date) %>%
  mutate(meanABrate = mean(ab_rate_1000,na.rm=TRUE),
         lowquart= quantile(ab_rate_1000, na.rm=TRUE)[2],
         highquart= quantile(ab_rate_1000, na.rm=TRUE)[4])
       #  ninefive= quantile(ab_rate_1000, na.rm=TRUE, c(0.95)),
      #   five=quantile(ab_rate_1000, na.rm=TRUE, c(0.05)))

write.csv(df_mean,here::here("output","consultation_GP_rate_prevalent.csv"))

plot_percentile_by_infection <- ggplot(df_mean, aes(x=date))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(y=meanABrate),color="black")+
 # geom_point(aes(y=meanABrate),color="steelblue")+
  geom_line(aes(y=lowquart), color="darkred", linetype= "dotted")+
#  geom_point(aes(y=lowquart), color="darkred", linetype=3)+
  geom_line(aes(y=highquart), color="darkred", linetype= "dotted")+
 # geom_point(aes(y=highquart), color="darkred", linetype=3)+
  #geom_line(aes(y=ninefive), color="black", linetype=3)+
  #geom_point(aes(y=ninefive), color="black", linetype=3)+
#  geom_line(aes(y=five), color="black", linetype=3)+
 # geom_point(aes(y=five), color="black", linetype=3)+
  facet_grid(rows = vars(indic))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
 # scale_y_continuous(n.breaks = 20)+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  labs(
    title = "Consultation rate of prevalent patients for 6 common infections",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time. 
                    Black lines represent mean rate and dotted lines represent 25th and 75th percentile rate. "),
    x = "",
    y = "Number of consultations per 1000 patients")+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")),color="grey70")+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")),color="grey70")

ggsave(
  plot= plot_percentile_by_infection,
  filename="consult_all_prevalent.jpeg", path=here::here("output"),
)



