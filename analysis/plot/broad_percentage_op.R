library("tidyverse") 
library('dplyr')
library('lubridate')

df1 <- read_csv(
  here::here("output", "measures", "measure_broad_op_proportion.csv"),  
  col_types = cols_only(
    practice = col_integer(),
    # Outcomes
    broad_spectrum_op  = col_double(),
    antibacterial_brit = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

# remove last month data
last.date=max(df1$date)
df1=df1%>% filter(date != last.date)
first_mon=format(min(df1$date),"%m-%Y")
last_mon= format(max(df1$date),"%m-%Y")


plot1 <- df1 %>% group_by(date) %>% summarise(
  b_count = sum(broad_spectrum_op, na.rm = TRUE),
  ab_count = sum(antibacterial_brit, na.rm = TRUE)
)

plot1 <- plot1 %>% mutate(prop = b_count/ab_count)
plot1$cal_mon <- month(plot1$date)
plot1$cal_year <- year(plot1$date)
plot1$year <- as.factor(plot1$cal_year)
plot1$mon <- as.factor(plot1$cal_mon)

p <- ggplot(plot1, aes(x=mon, y=prop, group=year)) +
  geom_line(aes(color=year))+
  geom_point(aes(color=year))+
  scale_color_brewer(palette="Paired")+
  theme_minimal()+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.001))+
  labs(
    title = "Proportion of broad-spectrum antibiotics prescribed",
    subtitle = paste(first_mon,"-",last_mon),
    x = "Month",
    y = "broad-spectrum antibiotics prescribing %")
p

ggsave(
  plot= p,
  filename="broad_percentage_op.jpeg", path=here::here("output"),
)


