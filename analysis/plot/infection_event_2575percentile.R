
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a plot to show overall antibiotics prescribing rate by month
# By practice, by month, per 1000 patient
# mean 25th and 75th percentile
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

# impoprt data
df <- read_csv(
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

df <- df %>% filter(practice >0)

df$date <- as.Date(df$date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)

# mean list size per practice (average of same GP in various months)
dfls <- df %>% group_by(practice) %>%
  mutate(listsize_ave = round(mean(population),digits = 0))

# calculate= (uti events)*1000/ population  --per GP per month--
df_gprate <- dfls %>% group_by(practice, cal_mon, cal_year) %>%
  mutate(ab_rate_1000 = value*1000) 

df_mean <- df_gprate %>% group_by(cal_mon, cal_year) %>%
  mutate(meanABrate = mean(ab_rate_1000),
         lowquart= quantile(ab_rate_1000)[2],
         highquart= quantile(ab_rate_1000)[4])

  
plot_percentile <- ggplot(df_mean, aes(x=date))+
  geom_line(aes(y=meanABrate),color="steelblue")+
  geom_point(aes(y=meanABrate),color="steelblue")+
  geom_line(aes(y=lowquart), color="darkred")+
  geom_point(aes(y=lowquart), color="darkred")+
  geom_line(aes(y=highquart), color="darkred")+
  geom_point(aes(y=highquart), color="darkred")+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  labs(x=NULL, y="UTI Events Rate per 1000 registered patients")+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")), linetype=4)+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")), linetype=4)

plot_percentile 

ggsave(
  plot= plot_percentile,
  filename="uti_event_25th_75th_percentile.png", path=here::here("output"),
)
