##############
## combine UTI infection event rate & prescribing rate by UTI infection
##############


### import patient-level data to summarize antibiotics counts ###
library("data.table")
library("dplyr")
library('here')
library("tidyverse")

setwd(here::here("output", "measures"))

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

# combine list of data.table/data.frame
df_input <- rbindlist(temp)
# remove temopary list
rm(temp,csvFiles,i)

# select valid practice number
df_input <- df_input %>% filter(practice >0)

# sum up total number of uti antibiotics within each patient in one month & extract year-month for group data
df_input=df_input%>%
  mutate(
  ab_counts_all= uti_ab_count_1 + uti_ab_count_2 + uti_ab_count_3 + uti_ab_count_4) %>%
  mutate(date=format(as.Date(uti_date_1) , "%Y-%m"))

# remove date=NA (no antibiotics prescribed date)
df_input <- df_input %>% filter(!is.na(df_input$date))

# -----UTI
## summarize patient-level data to paractice-level
df_ab=df_input%>%  
  group_by(date, practice) %>%
  summarize(ab_counts=sum(ab_counts_all)) %>%
  select(date, practice, ab_counts)



### import practice-level data for infection event measure ###

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


### merge two dataframe with "practice" & "date(year-month)" ###
df_infection$date=format(as.Date(df_infection$date) , "%Y-%m")
df=merge(df_infection, df_ab, by.x = c('practice','date'))
