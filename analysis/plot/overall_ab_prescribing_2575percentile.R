
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
  here::here("output", "measures", "measure_antibiotics_overall.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    antibacterial_prescriptions  = col_double(),
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

# mean list size per practice 
dfls <- df %>% group_by(practice) %>%
  mutate(listsize_ave = round(mean(population),digits = 0))

df_gprate <- dfls %>% group_by(practice, cal_mon, cal_year) %>%
  mutate(ab_rate_1000 = value*1000) 

df_mean <- df_gprate %>% group_by(cal_mon, cal_year) %>%
  mutate(meanABrate = mean(ab_rate_1000,na.rm=TRUE),
         lowquart= quantile(ab_rate_1000, na.rm=TRUE)[2],
         highquart= quantile(ab_rate_1000, na.rm=TRUE)[4]),
         ninefive= quantile(ab_rate_1000, na.rm=TRUE, c(0.95)),
         five=quantile(ab_rate_1000, na.rm=TRUE, c(0.05)))

  
plot_percentile <- ggplot(df_mean, aes(x=date))+
  geom_line(aes(y=meanABrate),color="steelblue")+
  geom_point(aes(y=meanABrate),color="steelblue")+
  geom_line(aes(y=lowquart), color="darkred", linetype=3)+
  geom_point(aes(y=lowquart), color="darkred", linetype=3)+
  geom_line(aes(y=highquart), color="darkred", linetype=3)+
  geom_point(aes(y=highquart), color="darkred", linetype=3)+
  geom_line(aes(y=ninefive), color="black", linetype=3)+
  geom_point(aes(y=ninefive), color="black", linetype=3)+
  geom_line(aes(y=five), color="black", linetype=3)+
  geom_point(aes(y=five), color="black", linetype=3)+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  labs(x=NULL, y="Antibiotic Prescribing Rate per 1000 registered patients")+
  geom_vline(xintercept = as.numeric(as.Date("2019-12-31")), linetype=4)+
  geom_vline(xintercept = as.numeric(as.Date("2020-12-31")), linetype=4)

plot_percentile 

ggsave(
  plot= plot_percentile,
  filename="overall_25th_75th_percentile.png", path=here::here("output"),
)
