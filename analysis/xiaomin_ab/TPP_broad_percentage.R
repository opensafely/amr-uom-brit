library("tidyverse") 
library('dplyr')
library('lubridate')

df1 <- read_csv(
  here::here("output", "measures", "measure_broad_op_proportion.csv"),  
  col_types = cols_only(
    practice = col_integer(),
    # Outcomes
    broad_spect_op  = col_double(),
    antibacterial_brit = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

df1 <- df1 %>% filter (date <= as.Date("2021-12-31"))


plot1 <- df1 %>% group_by(date) %>% summarise(
  b_count = sum(broad_spect_op, na.rm = TRUE),
  ab_count = sum(antibacterial_brit, na.rm = TRUE)
)

plot1 <- plot1 %>% mutate(prop = b_count/ab_count)
plot1$cal_mon <- month(plot1$date)
plot1$cal_year <- year(plot1$date)
plot1$year <- as.factor(plot1$cal_year)
plot1$mon <- as.factor(plot1$cal_mon)


p_1 <- ggplot(plot1, aes(y=prop, x=date)) + 
  geom_line(color = "coral2", size = 0.5)+ 
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 0.15, by = 0.0025))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  labs(
    title = "Broad-spectrum",
    caption = "National lockdown time in grey background. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")

p_1


ggsave(
  plot= p_1,
  filename="TPP_broad_percentage.jpeg", path=here::here("output"),
)


