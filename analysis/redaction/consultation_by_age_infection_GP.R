##############
## Consultation rates for 6 common infection over time,
## stratified by infections. 
## prevalent= with same infection in 90 days
##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
#library("cowplot")


dir.create(here::here("output", "redacted"))

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


## incident
df0=df%>% mutate(infection_counts=
                    ifelse(df$hx_pt==0,df$infection_counts,0))
## prevalent
df1=df%>% mutate(infection_counts=
                    ifelse(df$hx_pt==1,df$infection_counts,0))


# aggregate: infection counts, list size per GP per month
df0.1=df0%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="UTI")

# aggregate: infection counts, list size per GP per month
df1.1=df1%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="UTI")
         
rm(df,df0,df1,first_mon,last_mon,last.date)


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

## incident
df0=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==0,df$infection_counts,0))
## prevalent
df1=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==1,df$infection_counts,0))


# aggregate: infection counts, list size per GP per month
df0.2=df0%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="LRTI")

# aggregate: infection counts, list size per GP per month
df1.2=df1%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="LRTI")

rm(df,df0,df1,first_mon,last_mon,last.date)


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

## incident
df0=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==0,df$infection_counts,0))
## prevalent
df1=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==1,df$infection_counts,0))


# aggregate: infection counts, list size per GP per month
df0.3=df0%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="URTI")

# aggregate: infection counts, list size per GP per month
df1.3=df1%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="URTI")

rm(df,df0,df1,first_mon,last_mon,last.date)



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

## incident
df0=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==0,df$infection_counts,0))
## prevalent
df1=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==1,df$infection_counts,0))


# aggregate: infection counts, list size per GP per month
df0.4=df0%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="sinusitis")

# aggregate: infection counts, list size per GP per month
df1.4=df1%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="sinusitis")

rm(df,df0,df1,first_mon,last_mon,last.date)



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

## incident
df0=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==0,df$infection_counts,0))
## prevalent
df1=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==1,df$infection_counts,0))


# aggregate: infection counts, list size per GP per month
df0.5=df0%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="otitis externa")

# aggregate: infection counts, list size per GP per month
df1.5=df1%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="otitis externa")

rm(df,df0,df1,first_mon,last_mon,last.date)



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

## incident
df0=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==0,df$infection_counts,0))
## prevalent
df1=df%>% mutate(infection_counts=
                   ifelse(df$hx_pt==1,df$infection_counts,0))


# aggregate: infection counts, list size per GP per month
df0.6=df0%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="otitis media")

# aggregate: infection counts, list size per GP per month
df1.6=df1%>%
  group_by(date,practice)%>% 
  summarise(total.population=sum(population),
            counts=sum(infection_counts),
            date=unique(date))%>%
  mutate(indic="otitis media")

rm(df,df0,df1,last.date)




### 2. combined dataframe

df0=rbind(df0.1,df0.2,df0.3,df0.4,df0.5,df0.6)
df1=rbind(df1.1,df1.2,df1.3,df1.4,df1.5,df1.6)
rm(df0.1,df0.2,df0.3,df0.4,df0.5,df0.6,df1.1,df1.2,df1.3,df1.4,df1.5,df1.6)

df0$rate=df0$counts/df0$total.population
df1$rate=df1$counts/df1$total.population



### tables

df0$prevalent=0
df1$prevalent=1
df=rbind(df0,df1)

breaks <- c(as.Date("2019-01-01"),as.Date("2019-12-31"),# 1=pre-covid, 2=exclusion
            as.Date("2020-04-01"), as.Date("2021-12-31"),# 3= covid time
            max(df$date)) # NA exclusion

df=df%>%mutate(covid=cut(date,breaks,labels = 1:4))

df=df%>% filter(covid==1 | covid==3)
df$covid= recode(df$covid, '1'="0", '3'="1") # precovid=0, covid=1
df$covid <- factor(df$covid, levels=c("0","1"))

# month for adjust seasonality
df$month=format(df$date,"%m")
df=df%>% mutate(season= case_when( month=="03"|month=="04"|month=="05" ~ "spring",
                                   month=="06"|month=="07"|month=="08" ~ "summer",
                                   month=="09"|month=="10"|month=="11" ~ "autumn",
                                   month=="12"|month=="01"|month=="02" ~ "winter"))

# remove low counts
df0.sum <- df %>% filter(prevalent==0)%>%
  group_by(covid,season,indic)%>%
  mutate(  
            lowquart= quantile(rate, na.rm=TRUE)[2],
            median= quantile(rate, na.rm=TRUE)[3],
            highquart= quantile(rate, na.rm=TRUE)[4],
            lowquart.counts= quantile(counts, na.rm=TRUE)[2],
            median.counts= quantile(counts, na.rm=TRUE)[3],
            highquart.counts= quantile(counts, na.rm=TRUE)[4])

df1.sum <- df %>% filter(prevalent==1)%>%
  group_by(covid,season,indic)%>%
  mutate(  
           lowquart= quantile(rate, na.rm=TRUE)[2],
           median= quantile(rate, na.rm=TRUE)[3],
           highquart= quantile(rate, na.rm=TRUE)[4],
           lowquart.counts= quantile(counts, na.rm=TRUE)[2],
           median.counts= quantile(counts, na.rm=TRUE)[3],
           highquart.counts= quantile(counts, na.rm=TRUE)[4])



# #remove counts<=5

# df0.sum$redacted_25th.counts=ifelse(df0.sum$lowquart.counts<=5,NA,df0.sum$lowquart.counts)
# df1.sum$redacted_25th.counts=ifelse(df1.sum$lowquart.counts<=5,NA,df1.sum$lowquart.counts)
# df0.sum$redacted_rate_25th=ifelse(df0.sum$lowquart.counts<=5,NA,df0.sum$lowquart)
# df1.sum$redacted_rate_25th=ifelse(df1.sum$lowquart.counts<=5,NA,df1.sum$lowquart)

# df0.sum$redacted_75th.counts=ifelse(df0.sum$highquart.counts<=5,NA,df0.sum$highquart.counts)
# df1.sum$redacted_75th.counts=ifelse(df1.sum$highquart.counts<=5,NA,df1.sum$highquart.counts)
# df0.sum$redacted_rate_75th=ifelse(df0.sum$highquart.counts<=5,NA,df0.sum$highquart)
# df1.sum$redacted_rate_75th=ifelse(df1.sum$highquart.counts<=5,NA,df1.sum$highquart)


# df0.sum$redacted_50th.counts=ifelse(df0.sum$median.counts<=5,NA,df0.sum$median.counts)
# df1.sum$redacted_50th.counts=ifelse(df1.sum$median.counts<=5,NA,df1.sum$median.counts)
# df0.sum$redacted_rate_50th=ifelse(df0.sum$median.counts<=5,NA,df0.sum$median)
# df1.sum$redacted_rate_50th=ifelse(df1.sum$median.counts<=5,NA,df1.sum$median)

# summarise tables
df0.table=df0.sum%>%
  group_by(covid,season,indic)%>%
  summarise(rate_25th= mean(lowquart),
            median=mean(median),
            rate_75th= mean(highquart),
            gp.counts=sum(length(unique(practice))))


df1.table=df1.sum%>%
  group_by(covid,season,indic)%>%
  summarise(rate_25th= mean(lowquart),
            median=mean(median),
            rate_75th= mean(highquart),
            gp.counts=sum(length(unique(practice))))


write.csv(df1.table,here::here("output","redacted","consultation_GP_rate_prevalent.csv"))
write.csv(df0.table,here::here("output","redacted","consultation_GP_rate_incident.csv"))

rm(df1.table,df0.table,df1.sum,df0.sum,df)


### 4. plots

#summarise table
df0.sum <- df0 %>% group_by(date,indic) %>%
  summarise(
            total.counts=sum(counts),
            gp.counts=sum(length(unique(practice))),
            lowquart= quantile(rate, na.rm=TRUE)[2],
            median= quantile(rate, na.rm=TRUE)[3],
            highquart= quantile(rate, na.rm=TRUE)[4],
            lowquart.counts= quantile(counts, na.rm=TRUE)[2],
            median.counts= quantile(counts, na.rm=TRUE)[3],
            highquart.counts= quantile(counts, na.rm=TRUE)[4])

df1.sum <- df1 %>% group_by(date,indic) %>%
  summarise(
            total.counts=sum(counts),
            gp.counts=sum(length(unique(practice))),
            lowquart= quantile(rate, na.rm=TRUE)[2],
            median= quantile(rate, na.rm=TRUE)[3],
            highquart= quantile(rate, na.rm=TRUE)[4],
            lowquart.counts= quantile(counts, na.rm=TRUE)[2],
            median.counts= quantile(counts, na.rm=TRUE)[3],
            highquart.counts= quantile(counts, na.rm=TRUE)[4])
  

# #remove counts<=5
# df0.sum$redacted_50th.counts=ifelse(df0.sum$median.counts<=5,NA,df0.sum$median.counts)
# df1.sum$redacted_50th.counts=ifelse(df1.sum$median.counts<=5,NA,df1.sum$median.counts)
# df0.sum$redacted_rate_50th=ifelse(df0.sum$median.counts<=5,NA,df0.sum$median)
# df1.sum$redacted_rate_50th=ifelse(df1.sum$median.counts<=5,NA,df1.sum$median)

# df0.sum$redacted_25th.counts=ifelse(df0.sum$lowquart.counts<=5,NA,df0.sum$lowquart.counts)
# df1.sum$redacted_25th.counts=ifelse(df1.sum$lowquart.counts<=5,NA,df1.sum$lowquart.counts)
# df0.sum$redacted_rate_25th=ifelse(df0.sum$lowquart.counts<=5,NA,df0.sum$lowquart)
# df1.sum$redacted_rate_25th=ifelse(df1.sum$lowquart.counts<=5,NA,df1.sum$lowquart)

# df0.sum$redacted_75th.counts=ifelse(df0.sum$highquart.counts<=5,NA,df0.sum$highquart.counts)
# df1.sum$redacted_75th.counts=ifelse(df1.sum$highquart.counts<=5,NA,df1.sum$highquart.counts)
# df0.sum$redacted_rate_75th=ifelse(df0.sum$highquart.counts<=5,NA,df0.sum$highquart)
# df1.sum$redacted_rate_75th=ifelse(df1.sum$highquart.counts<=5,NA,df1.sum$highquart)


df=rbind(df0.sum,df1.sum)


write.csv(df,here::here("output","redacted","consultation_rate_GP_check.csv"))
rm(df,df0,df1)




# # plot missing value line
# gap50=df0.sum %>% filter(!is.na(redacted_rate_50th))
# gap25=df0.sum %>% filter(!is.na(redacted_rate_25th))
# gap75=df0.sum %>% filter(!is.na(redacted_rate_75th))

# incident
plot_0 <- ggplot(df0.sum, aes(x=date))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  # geom_line(data =gap50, aes(y=redacted_rate_50th), color="black",linetype="dashed") +
  # geom_line(data =gap25, aes(y=redacted_rate_25th), color="darkred",linetype="dashed") +
  # geom_line(data =gap75, aes(y=redacted_rate_75th), color="darkred",linetype="dashed") +
  geom_line(aes(y=lowquart),color="black",linetype="dashed")+
  geom_line(aes(y=median), color="black")+
  geom_line(aes(y=highquart), color="black",linetype="dashed")+
  facet_grid(rows = vars(indic))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  labs(
    title = "Consultation rate of incident patients for 6 common infections",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time. 
                    Black lines represent median and dashed lines represent 25th and 75th percentile. "),
    x = "",
    y = "consultation rate per practice")+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")),color="grey70")+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")),color="grey70")

ggsave(
  plot= plot_0,
  filename="consult_all_incident.jpeg", path=here::here("output","redacted"))

rm(gap50,gap25,gap75)

#df1.sum$redacted_rate_25th=as.numeric(df1.sum$redacted_rate_25th)#for dummy data
# gap50=df1.sum %>% filter(!is.na(redacted_rate_50th))
# gap25=df1.sum %>% filter(!is.na(redacted_rate_25th))
# gap75=df1.sum %>% filter(!is.na(redacted_rate_75th))

# prevalent
plot_1 <- ggplot(df1.sum, aes(x=date))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  # geom_line(data =gap50, aes(y=redacted_rate_50th), color="black",linetype="dashed") +
  # geom_line(data =gap25, aes(y=redacted_rate_25th), color="darkred",linetype="dashed") +
  # geom_line(data =gap75, aes(y=redacted_rate_75th), color="darkred",linetype="dashed") +
  geom_line(aes(y=lowquart),color="black",linetype="dashed")+
  geom_line(aes(y=median), color="black")+
  geom_line(aes(y=highquart), color="black",linetype="dashed")+
  facet_grid(rows = vars(indic))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  labs(
    title = "Consultation rate of prevalent patients for 6 common infections",
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", TPPnumber,"TPP Practices 
                    Grey shading represents national lockdown time. 
                    Black lines represent median and dashed lines represent 25th and 75th percentile.  "),
    x = "",
    y = "consultation rate per practice")+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")),color="grey70")+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")),color="grey70")

ggsave(
  plot= plot_1,
  filename="consult_all_prevalent.jpeg", path=here::here("output","redacted"))





#   ## combine incident& prevelent 
#   df=rbind(df1,df0)   
#   df=df %>% group_by(indic,date,practice) %>%
#   summarise(counts=sum(infection_counts),
#   total.population=mean(total.population))

#   # rate of each GP 
#   df$rate=df$counts/df$total.population*1000

#   df.sum <- df %>% group_by(date,indic) %>%
#   summarise(
#             total.counts=sum(counts),
#             lowquart= quantile(rate, na.rm=TRUE)[2],
#             median= quantile(rate, na.rm=TRUE)[3],
#             highquart= quantile(rate, na.rm=TRUE)[4],
#             lowquart.counts= quantile(counts, na.rm=TRUE)[2],
#             median.counts= quantile(counts, na.rm=TRUE)[3],
# #             highquart.counts= quantile(counts, na.rm=TRUE)[4])
  

# #remove counts<=5
# df.sum$redacted_50th.counts=ifelse(df.sum$median.counts<=5,NA,df.sum$median.counts)
# df.sum$redacted_rate_50th=ifelse(df.sum$median.counts<=5,NA,df.sum$median)

# df.sum$redacted_25th.counts=ifelse(df.sum$lowquart.counts<=5,NA,df.sum$lowquart.counts)
# df.sum$redacted_rate_25th=ifelse(df.sum$lowquart.counts<=5,NA,df.sum$lowquart)

# df.sum$redacted_75th.counts=ifelse(df.sum$highquart.counts<=5,NA,df.sum$highquart.counts)
# df.sum$redacted_rate_75th=ifelse(df.sum$highquart.counts<=5,NA,df.sum$highquart)


# write.csv(df,here::here("output","redacted","consultation_rate_GP_check.csv"))
# rm(df,df0,df1)


