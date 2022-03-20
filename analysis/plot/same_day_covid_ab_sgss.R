library("dplyr")
library('here')
library("tidyverse")
library("ggplot2")
library('lubridate')



df <- read_csv(
  here::here("output", "measures", "measure_Same_day_pos_ab_sgss.csv"),  
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    Covid_test_result_sgss  = col_double(),
    population  = col_double(),
    sgss_ab_prescribed = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)


df$date <- as.Date(df$date,format="%Y-%m-%d")
df[is.na(df)] <- 0 


# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)
first_mon=format(min(df$date),"%m-%Y")
last_mon= format(max(df$date),"%m-%Y")



## remove negative Covid cohorts
df <- df%>% filter(Covid_test_result_sgss==1)
df$year <- as.factor(df$cal_year)
df$mon <- as.factor(df$cal_mon)

plot <- ggplot(df, aes(x=mon, y=value, group=year)) +
  geom_line(aes(color=year))+
  geom_point(aes(color=year))+
  scale_color_brewer(palette="Paired")+
  theme_minimal()+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.05))+
  labs(
    title = "Same day Covid diagnosis and antibiotics prescription-sgss",
    subtitle = paste(first_mon,"-",last_mon),
    x = "Month",
    y = "Same day antibiotics prescribing %")

plot

ggsave(
  plot= plot,
  filename="same_day_ab_prop_line_sgss.jpeg", path=here::here("output"),
)  