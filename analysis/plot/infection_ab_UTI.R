##############
## UTI:
## event rate & prescribing rate (per 1000 patients)
## By practice, by month, per 1000 patient
##############



library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("cowplot")

setwd(here::here("output", "measures"))

### 1. read data  ###
### 1.1 import patient-level data(study definition input.csv) to summarize antibiotics counts

############ loop reaaing multiple CSV files ################
# read flie list from input.csv
csvFiles = list.files(pattern="input_", full.names = TRUE)
temp <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles))
  temp[[i]] <- read_csv(csvFiles[i],
    
    col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    uti_ab_count_1  = col_double(),
    uti_ab_count_2  = col_double(),
    uti_ab_count_3  = col_double(),
    uti_ab_count_4  = col_double(),
    uti_counts  = col_double(),
    
    
    # Date
    uti_date_1 = col_date(format="%Y-%m-%d"),
    uti_date_2 = col_date(format="%Y-%m-%d"),
    uti_date_3 = col_date(format="%Y-%m-%d"),
    uti_date_4 = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

# combine list -> data.table/data.frame
df_input <- rbindlist(temp)
rm(temp,csvFiles,i)# remove temopary list
############ loop reaaing multiple CSV files ################

# sum up total number of uti antibiotics within each patient in one month & extract year-month for grouping data
df_input=df_input%>%
  mutate(
  ab_counts_all= uti_ab_count_1 + uti_ab_count_2 + uti_ab_count_3 + uti_ab_count_4) %>%
  mutate(date=format(as.Date(uti_date_1) , "%Y-%m"))

# remove date=NA (no antibiotics prescribed date)
df_input= df_input %>% filter(!is.na(df_input$date))

# summarize patient-level data to paractice-level (by date, by practice)
df_ab=df_input%>%  
  group_by(date, practice) %>%
  summarize(ab_counts=sum(ab_counts_all)) %>%
  select(date, practice, ab_counts)


### 1.2 import practice-level data(measure.csv) for infection event 
df_infection <- read_csv(
  here::here("output", "measures", "measure_UTI_event.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    uti_counts  = col_double(),
    population  = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

### 1.3 import practice-level data(measure.csv) for number of infection patient 
df_pt <- read_csv(
  here::here("output", "measures", "measure_UTI_patient.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes: value=uti patients/population
    value = col_double(),
    uti_pt= col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)


### 2. merge dataframe ###
# key variable: "practice" & "date(year-month)"

# 2.1 combine 1.2df_infection (event)& 1.3df_patient (pt number)
df_infection$date=format(as.Date(df_infection$date) , "%Y-%m")
df_infection=df_infection%>%
  rename(inf.rate=value)

df_pt$date=format(as.Date(df_pt$date) , "%Y-%m")
df_pt=df_pt%>%
  rename(pt.rate=value)

df=merge(df_infection, df_pt, by = c('practice','date'))

# 2.2 combine 1.1df_ab(prescriptions) & above df(1.2+1.3)
df_all=merge(df, df_ab, by.x = c('practice','date') )
df_all=df_all%>%
  mutate(ab.rate=ab_counts*1000 /population, #prescribing rate (per 1000 registered patients)
         pt.rate=pt.rate*1000, # measure value(infection patient)*1000
         inf.rate=inf.rate*1000) # measure value(infection event)*1000



#check row number- suppose to be equal- but how to print that result???? -
nrow(df_infection)
nrow(df_pt)
nrow(df_ab)
nrow(df)


### 3. plot  ###
### 3.1 line chart- UTI prescribing rate (mean, Q1,median,Q3) 

df_sum=df_all%>%
  group_by(date)%>%
  summarise(m.ab=mean(ab.rate),
            sd.ab=sd(ab.rate),
            min.ab=min(ab.rate),
            max.ab=max(ab.rate),
            q1=quantile(ab.rate,0.25),
            q2=quantile(ab.rate,0.5),
            q3=quantile(ab.rate,0.75))

plot_ab <- ggplot(df_sum, aes(x = date, y =m.ab, group=1))+  # one-line
  geom_ribbon(aes(ymin=q1, ymax=q3), fill="grey80")+
  geom_line(aes(y =q2), col="grey70") +
  geom_line()+
  geom_point()+
  labs(
    title = "UTI prescribing rate(per 1,000 patients)",
    caption = "black line: mean, grey line:median, grey area:Q1-Q3",
    x = "",
    y = "UTI prescriptions")+
  scale_x_discrete(labels = NULL) 


### 3.2 bar chart- UTI event rate & patient infection rate
df_sum2=df_all%>%
  group_by(date)%>%
  summarise(inf=mean(inf.rate),
         pt=mean(pt.rate))

plot_infection <- ggplot(df_sum2, aes(x = date, y =inf))+
  geom_bar(stat="identity",fill="grey70")+
  geom_bar(aes(y =pt), stat="identity",fill="grey60")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "UTI events rate(per 1,000 patients)",
    caption = "dark grey:person counts, light grey:event counts",
    x = "Time", 
    y = "UTI patients & events")


### 3.3 combine two charts
plot_com=plot_grid(
  plot_ab, plot_infection, labels = "auto", ncol = 1)

ggsave(
  plot= plot_com,
  filename="UTI.png", path=here::here("output"),
)