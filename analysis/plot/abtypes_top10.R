##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")

#install.packages("pals")
#library(pals)


rm(list=ls())

######## UTI 
df1 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_UTI_1.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 uti_abtype1  = col_character(),
                 
                 # Outcomes
                 uti_ab_count_1   = col_double(),
                 population  = col_double(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)

df2 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_UTI_2.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  uti_abtype2  = col_character(),
                  
                  # Outcomes
                  uti_ab_count_2   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)

df3 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_UTI_3.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  uti_abtype3  = col_character(),
                  
                  # Outcomes
                  uti_ab_count_3   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df4 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_UTI_4.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  uti_abtype4  = col_character(),
                  
                  # Outcomes
                  uti_ab_count_4  = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df1=df1%>%dplyr::rename(abtype=uti_abtype1,ab_count=uti_ab_count_1)
df2=df2%>%dplyr::rename(abtype=uti_abtype2,ab_count=uti_ab_count_2)
df3=df3%>%dplyr::rename(abtype=uti_abtype3,ab_count=uti_ab_count_3)
df4=df4%>%dplyr::rename(abtype=uti_abtype4,ab_count=uti_ab_count_4)
df=rbind(df1,df3,df3,df4)
rm(df1,df2,df3,df4)

# count polulation numbers
Patients=sum(df$population)

df=df%>%dplyr::group_by(date,abtype)%>%
  dplyr::summarise(value=sum(value),
            count=sum(ab_count))
  

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))

#df <- mutate_all(df, list(~na_if(.,"")))
#df <- na.omit(df)

# df$date <- as.Date(df$date)
# df$cal_mon <- month(df$date)
# df$cal_year <- year(df$date)

df <- filter(df, abtype != "")
df$value2 <- df$value*1000
df$abtype  <- as.character(df$abtype)



######barchart1. rate per 1000 pt#####
### select most common ab (rate)###
DF.top10=df%>%
  dplyr::group_by(abtype)%>%
  dplyr::summarise(value=mean(value))%>% # RX: average per month
  dplyr::arrange(desc(value))%>%
  slice(1:10)

df$type=ifelse(df$abtype %in% DF.top10$abtype, df$abtype, "Others")
df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others"))# reorder

# summarise data
df.plot=df%>%dplyr::group_by(type,date)%>%
  dplyr::summarise(
    value2=sum(value2)
  )
  

#df$date=format(df$date,"%Y-%m")

abtype_bar <- ggplot(df.plot, aes(y=value2, x=date)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white",aes(fill=type,group=-value2))+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - UTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "National lockdown time in grey background. ",
    y = "Number of prescriptions per 1000 registered patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 20)


#####barchart2. total consumption- counts ####
# summarise data
df.plot2=df%>%dplyr::group_by(type,date)%>%
  dplyr::summarise(
    count=sum(count)
  )

bar_propotion <- 
  ggplot(df.plot2, aes(x=date, y=count, fill=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(color="white",position="fill", stat="identity")+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - UTI",
    subtitle = paste(first_mon,"-",last_mon),
    #caption = "TPP Practices",
    y = "percent",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)






ggsave(
  plot= abtype_bar,
  filename="abtype_UTI.jpeg", path=here::here("output"),
)
ggsave(
  plot= bar_propotion,
  filename="abtype_percent_UTI.jpeg", path=here::here("output"),
) 



## ungroup for table
df.1 <- ungroup(df)
df.1$type="UTI"
df.1<- dplyr::select(df.1, date, abtype, value2,count,type)


rm(df_plot,DF.top10,df)





######## URTI 
df1 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_URTI_1.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 urti_abtype1  = col_character(),
                 
                 # Outcomes
                 urti_ab_count_1   = col_double(),
                 population  = col_double(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)

df2 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_URTI_2.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  urti_abtype2  = col_character(),
                  
                  # Outcomes
                  urti_ab_count_2   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)

df3 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_URTI_3.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  urti_abtype3  = col_character(),
                  
                  # Outcomes
                  urti_ab_count_3   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df4 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_URTI_4.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  urti_abtype4  = col_character(),
                  
                  # Outcomes
                  urti_ab_count_4  = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df1=df1%>%rename(abtype=urti_abtype1,ab_count=urti_ab_count_1)
df2=df2%>%rename(abtype=urti_abtype2,ab_count=urti_ab_count_2)
df3=df3%>%rename(abtype=urti_abtype3,ab_count=urti_ab_count_3)
df4=df4%>%rename(abtype=urti_abtype4,ab_count=urti_ab_count_4)
df=rbind(df1,df3,df3,df4)
rm(df1,df2,df3,df4)

# count polulation numbers
Patients=sum(df$population)

df=df%>%group_by(date,abtype)%>%
  summarise(value=sum(value),
            count=sum(ab_count))
  

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


#df <- mutate_all(df, list(~na_if(.,"")))
#df <- na.omit(df)


df <- filter(df, abtype != "")
df$value2 <- df$value*1000
df$abtype  <- as.character(df$abtype)




######barchart1. rate per 1000 pt#####
### select most common ab (rate)###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)

df$type=ifelse(df$abtype %in% DF.top10$abtype, df$abtype, "Others")
df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others"))# reorder

# summarise data
df.plot=df%>%group_by(type,date)%>%
  summarise(
    value2=sum(value2)
  )
  

#df$date=format(df$date,"%Y-%m")

abtype_bar <- ggplot(df.plot, aes(y=value2, x=date)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white",aes(fill=type,group=-value2))+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - URTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "National lockdown time in grey background. ",
    y = "Number of prescriptions per 1000 registered patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 20)


#####barchart2. total consumption- counts ####
# summarise data
df.plot2=df%>%group_by(type,date)%>%
  summarise(
    count=sum(count)
  )

bar_propotion <- 
  ggplot(df.plot2, aes(x=date, y=count, fill=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(color="white",position="fill", stat="identity")+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - URTI",
    subtitle = paste(first_mon,"-",last_mon),
    #caption = "TPP Practices",
    y = "percent",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)


ggsave(
  plot= abtype_bar,
  filename="abtype_URTI.jpeg", path=here::here("output"),
)
ggsave(
  plot= bar_propotion,
  filename="abtype_percent_URTI.jpeg", path=here::here("output"),
) 




## ungroup for table
df.2 <- ungroup(df)
df.2$type="URTI"
df.2<- select(df.1, date, abtype, value2,count,type)
rm(df_plot,DF.top10,df)



######## LRTI 
df1 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_LRTI_1.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 lrti_abtype1  = col_character(),
                 
                 # Outcomes
                 lrti_ab_count_1   = col_double(),
                 population  = col_double(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)

df2 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_LRTI_2.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  lrti_abtype2  = col_character(),
                  
                  # Outcomes
                  lrti_ab_count_2   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)

df3 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_LRTI_3.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  lrti_abtype3  = col_character(),
                  
                  # Outcomes
                  lrti_ab_count_3   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df4 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_LRTI_4.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  lrti_abtype4  = col_character(),
                  
                  # Outcomes
                  lrti_ab_count_4  = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df1=df1%>%rename(abtype=lrti_abtype1,ab_count=lrti_ab_count_1)
df2=df2%>%rename(abtype=lrti_abtype2,ab_count=lrti_ab_count_2)
df3=df3%>%rename(abtype=lrti_abtype3,ab_count=lrti_ab_count_3)
df4=df4%>%rename(abtype=lrti_abtype4,ab_count=lrti_ab_count_4)
df=rbind(df1,df3,df3,df4)
rm(df1,df2,df3,df4)

# count polulation numbers
Patients=sum(df$population)

df=df%>%group_by(date,abtype)%>%
  summarise(value=sum(value),
            count=sum(ab_count))
  

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


#df <- mutate_all(df, list(~na_if(.,"")))
#df <- na.omit(df)

df$date <- as.Date(df$date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)

df <- filter(df, abtype != "")
df$value2 <- df$value*1000
df$abtype  <- as.character(df$abtype)


######barchart1. rate per 1000 pt#####
### select most common ab (rate)###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)

df$type=ifelse(df$abtype %in% DF.top10$abtype, df$abtype, "Others")
df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others"))# reorder

# summarise data
df.plot=df%>%group_by(type,date)%>%
  summarise(
    value2=sum(value2)
  )
  

#df$date=format(df$date,"%Y-%m")

abtype_bar <- ggplot(df.plot, aes(y=value2, x=date)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white",aes(fill=type,group=-value2))+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - LRTI",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "National lockdown time in grey background. ",
    y = "Number of prescriptions per 1000 registered patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 20)


#####barchart2. total consumption- counts ####
# summarise data
df.plot2=df%>%group_by(type,date)%>%
  summarise(
    count=sum(count)
  )

bar_propotion <- 
  ggplot(df.plot2, aes(x=date, y=count, fill=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(color="white",position="fill", stat="identity")+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - LRTI",
    subtitle = paste(first_mon,"-",last_mon),
    #caption = "TPP Practices",
    y = "percent",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)



ggsave(
  plot= abtype_bar,
  filename="abtype_LRTI.jpeg", path=here::here("output"),
)
ggsave(
  plot= bar_propotion,
  filename="abtype_percent_LRTI.jpeg", path=here::here("output"),
) 


## ungroup for table
df.3 <- ungroup(df)
df.3$type="LRTI"
df.3<- select(df.1, date, abtype, value2,count,type)


rm(df_plot,DF.top10,df)




######## sinusitis
df1 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_sinusitis_1.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 sinusitis_abtype1  = col_character(),
                 
                 # Outcomes
                 sinusitis_ab_count_1   = col_double(),
                 population  = col_double(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)

df2 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_sinusitis_2.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  sinusitis_abtype2  = col_character(),
                  
                  # Outcomes
                  sinusitis_ab_count_2   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)

df3 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_sinusitis_3.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  sinusitis_abtype3  = col_character(),
                  
                  # Outcomes
                  sinusitis_ab_count_3   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df4 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_sinusitis_4.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  sinusitis_abtype4  = col_character(),
                  
                  # Outcomes
                  sinusitis_ab_count_4  = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df1=df1%>%rename(abtype=sinusitis_abtype1,ab_count=sinusitis_ab_count_1)
df2=df2%>%rename(abtype=sinusitis_abtype2,ab_count=sinusitis_ab_count_2)
df3=df3%>%rename(abtype=sinusitis_abtype3,ab_count=sinusitis_ab_count_3)
df4=df4%>%rename(abtype=sinusitis_abtype4,ab_count=sinusitis_ab_count_4)
df=rbind(df1,df3,df3,df4)
rm(df1,df2,df3,df4)

# count polulation numbers
Patients=sum(df$population)

df=df%>%group_by(date,abtype)%>%
  summarise(value=sum(value),
            count=sum(ab_count))
  

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))

#df <- mutate_all(df, list(~na_if(.,"")))
#df <- na.omit(df)

df$date <- as.Date(df$date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)

df <- filter(df, abtype != "")
df$value2 <- df$value*1000
df$abtype  <- as.character(df$abtype)


######barchart1. rate per 1000 pt#####
### select most common ab (rate)###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)

df$type=ifelse(df$abtype %in% DF.top10$abtype, df$abtype, "Others")
df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others"))# reorder

# summarise data
df.plot=df%>%group_by(type,date)%>%
  summarise(
    value2=sum(value2)
  )
  

#df$date=format(df$date,"%Y-%m")

abtype_bar <- ggplot(df.plot, aes(y=value2, x=date)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white",aes(fill=type,group=-value2))+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - Sinusitis",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "National lockdown time in grey background. ",
    y = "Number of prescriptions per 1000 registered patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 20)


#####barchart2. total consumption- counts ####
# summarise data
df.plot2=df%>%group_by(type,date)%>%
  summarise(
    count=sum(count)
  )

bar_propotion <- 
  ggplot(df.plot2, aes(x=date, y=count, fill=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(color="white",position="fill", stat="identity")+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - Sinusitis",
    subtitle = paste(first_mon,"-",last_mon),
   # caption = "TPP Practices",
    y = "percent",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)



ggsave(
  plot= abtype_bar,
  filename="abtype_sinusitis.jpeg", path=here::here("output"),
)
ggsave(
  plot= bar_propotion,
  filename="abtype_percent_sinusitis.jpeg", path=here::here("output"),
) 




## ungroup for table
df.4 <- ungroup(df)
df.4$type="sinusitis"
df.4<- select(df.1, date, abtype, value2,count,type)

rm(df_plot,DF.top10,df)




######## ot_externa
df1 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_ot_externa_1.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 ot_externa_abtype1  = col_character(),
                 
                 # Outcomes
                 ot_externa_ab_count_1   = col_double(),
                 population  = col_double(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)

df2 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_ot_externa_2.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  ot_externa_abtype2  = col_character(),
                  
                  # Outcomes
                  ot_externa_ab_count_2   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)

df3 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_ot_externa_3.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  ot_externa_abtype3  = col_character(),
                  
                  # Outcomes
                  ot_externa_ab_count_3   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df4 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_ot_externa_4.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  ot_externa_abtype4  = col_character(),
                  
                  # Outcomes
                  ot_externa_ab_count_4  = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df1=df1%>%rename(abtype=ot_externa_abtype1,ab_count=ot_externa_ab_count_1)
df2=df2%>%rename(abtype=ot_externa_abtype2,ab_count=ot_externa_ab_count_2)
df3=df3%>%rename(abtype=ot_externa_abtype3,ab_count=ot_externa_ab_count_3)
df4=df4%>%rename(abtype=ot_externa_abtype4,ab_count=ot_externa_ab_count_4)
df=rbind(df1,df3,df3,df4)
rm(df1,df2,df3,df4)

# count polulation numbers
Patients=sum(df$population)

df=df%>%group_by(date,abtype)%>%
  summarise(value=sum(value),
            count=sum(ab_count))
  

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


#df <- mutate_all(df, list(~na_if(.,"")))
#df <- na.omit(df)

df$date <- as.Date(df$date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)

df <- filter(df, abtype != "")
df$value2 <- df$value*1000
df$abtype  <- as.character(df$abtype)



######barchart1. rate per 1000 pt#####
### select most common ab (rate)###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)

df$type=ifelse(df$abtype %in% DF.top10$abtype, df$abtype, "Others")
df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others"))# reorder

# summarise data
df.plot=df%>%group_by(type,date)%>%
  summarise(
    value2=sum(value2)
  )
  

#df$date=format(df$date,"%Y-%m")

abtype_bar <- ggplot(df.plot, aes(y=value2, x=date)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white",aes(fill=type,group=-value2))+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - Otitis externa",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "National lockdown time in grey background. ",
    y = "Number of prescriptions per 1000 registered patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 20)

#####barchart2. total consumption- counts ####
# summarise data
df.plot2=df%>%group_by(type,date)%>%
  summarise(
    count=sum(count)
  )

bar_propotion <- 
  ggplot(df.plot2, aes(x=date, y=count, fill=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(color="white",position="fill", stat="identity")+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - Otitis externa",
    subtitle = paste(first_mon,"-",last_mon),
    #caption = "TPP Practices",
    y = "percent",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)



ggsave(
  plot= abtype_bar,
  filename="abtype_ot_externa.jpeg", path=here::here("output"),
)
ggsave(
  plot= bar_propotion,
  filename="abtype_percent_ot_externa.jpeg", path=here::here("output"),
) 



## ungroup for table
df.5 <- ungroup(df)
df.5$type="ot_externa"
df.5<- select(df.1, date, abtype, value2,count,type)


rm(df_plot,DF.top10,df)






######## otmedia
df1 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_otmedia_1.csv"),
               col_types = cols_only(
                 
                 # Identifier
                 otmedia_abtype1  = col_character(),
                 
                 # Outcomes
                 otmedia_ab_count_1   = col_double(),
                 population  = col_double(),
                 value = col_double(),
                 
                 # Date
                 date = col_date(format="%Y-%m-%d")
                 
               ),
               na = character()
)

df2 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_otmedia_2.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  otmedia_abtype2  = col_character(),
                  
                  # Outcomes
                  otmedia_ab_count_2   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)

df3 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_otmedia_3.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  otmedia_abtype3  = col_character(),
                  
                  # Outcomes
                  otmedia_ab_count_3   = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df4 <- read_csv(
    here::here("output", "measures", "measure_infection_abtype_otmedia_4.csv"),
                col_types = cols_only(
                  
                  # Identifier
                  otmedia_abtype4  = col_character(),
                  
                  # Outcomes
                  otmedia_ab_count_4  = col_double(),
                  population  = col_double(),
                  value = col_double(),
                  
                  # Date
                  date = col_date(format="%Y-%m-%d")
                  
                ),
                na = character()
)


df1=df1%>%rename(abtype=otmedia_abtype1,ab_count=otmedia_ab_count_1)
df2=df2%>%rename(abtype=otmedia_abtype2,ab_count=otmedia_ab_count_2)
df3=df3%>%rename(abtype=otmedia_abtype3,ab_count=otmedia_ab_count_3)
df4=df4%>%rename(abtype=otmedia_abtype4,ab_count=otmedia_ab_count_4)
df=rbind(df1,df3,df3,df4)
rm(df1,df2,df3,df4)

# count polulation numbers
Patients=sum(df$population)

df=df%>%group_by(date,abtype)%>%
  summarise(value=sum(value),
            count=sum(ab_count))
  

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))

#df <- mutate_all(df, list(~na_if(.,"")))
#df <- na.omit(df)

df$date <- as.Date(df$date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)

df <- filter(df, abtype != "")
df$value2 <- df$value*1000
df$abtype  <- as.character(df$abtype)


######barchart1. rate per 1000 pt#####
### select most common ab (rate)###
DF.top10=df%>%
  group_by(abtype)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)

df$type=ifelse(df$abtype %in% DF.top10$abtype, df$abtype, "Others")
df$type <- factor(df$type, levels=c(DF.top10$abtype,"Others"))# reorder

# summarise data
df.plot=df%>%group_by(type,date)%>%
  summarise(
    value2=sum(value2)
  )
  

#df$date=format(df$date,"%Y-%m")

abtype_bar <- ggplot(df.plot, aes(y=value2, x=date)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white",aes(fill=type,group=-value2))+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - Otitis media",
    subtitle = paste(first_mon,"-",last_mon),
    caption = "National lockdown time in grey background. ",
    y = "Number of prescriptions per 1000 registered patients",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(n.breaks = 20)


#####barchart2. total consumption- counts ####
# summarise data
df.plot2=df%>%group_by(type,date)%>%
  summarise(
    count=sum(count)
  )

bar_propotion <- 
  ggplot(df.plot2, aes(x=date, y=count, fill=type))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_bar(color="white",position="fill", stat="identity")+
  labs(
    fill = "Antibiotic type",
    title = "Top 10 Antibiotic Types Prescribed - Otitis media",
    subtitle = paste(first_mon,"-",last_mon),
    #caption = "TPP Practices",
    y = "percent",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  scale_y_continuous(labels = scales::percent)


ggsave(
  plot= abtype_bar,
  filename="abtype_otmedia.jpeg", path=here::here("output"),
)
ggsave(
  plot= bar_propotion,
  filename="abtype_percent_otmedia.jpeg", path=here::here("output"),
) 

## ungroup for table
df.6 <- ungroup(df)
df.6$type="otmedia"
df.6<- select(df.1, date, abtype, value2,count,type)


rm(df_plot,DF.top10,df)


## combine table
ugp_df10=rbind(df.1,df.2,df.3,df.4,df.5,df.6)
write_csv(ugp_df10, here::here("output", "abtype_top10_by_infection.csv"))
