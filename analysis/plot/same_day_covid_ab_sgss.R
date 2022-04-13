library("dplyr")
library('here')
library("tidyverse")
library("ggplot2")
library('lubridate')

df <- read_csv(
  here::here("output", "input_sameday_ab.csv.gz"),
  col_types = cols_only(
    age = col_number(),
    age_cat = col_factor(),
    sex = col_factor(),
    practice = col_number(),#
    first_positive_test_date = col_date(format = ""),
    sgss_ab_prescribed = col_integer(),
    second_positive_test_date = col_date(format = ""),
    sgss_ab_prescribed_2 = col_integer(),
    patient_id = col_number())
)

df$covid_positive_1=ifelse(is.na(df$first_positive_test_date),0,1)
df1 <- df %>% filter(covid_positive_1 == 1)
df1$date <- as.Date(df1$first_positive_test_date,format= "%m-%Y")

df1$cal_mon <- month(df1$date)
df1$cal_year <- year(df1$date)

plot1 <- df1 %>% group_by(cal_mon,cal_year) %>%
  summarise(total_count = sum(covid_positive_1),
            ab_count = sum(sgss_ab_prescribed))
plot1 <- plot1 %>% mutate(prop = ab_count/total_count)
plot1$cal_day <- 1


plot1$Date <- as.Date(paste(plot1$cal_year, plot1$cal_mon,plot1$cal_day, sep="-"), "%Y-%m-%d")
first_mon=format(min(plot1$Date),"%m-%Y")
last_mon= format(max(plot1$Date),"%m-%Y")



plot <-ggplot(data = plot1, aes(x = Date, y = prop))+
  geom_line(color = "#E7B800", size = 1)+ 
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 0.05, by = 0.005))+
  labs(
    title = "Same day Covid diagnosis and antibiotics prescription",
    subtitle = paste(first_mon,"-",last_mon),
    x = "Time",
    y = "Same day antibiotics prescribing %")

plot

ggsave(
  plot= plot,
  filename="same_day_ab_prop_line_sgss.jpeg", path=here::here("output"),
)  