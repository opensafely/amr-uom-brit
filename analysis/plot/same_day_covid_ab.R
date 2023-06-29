library("dplyr")
library("tidyverse")
library('lubridate')
library("finalfit")

setwd(here::here("output", "measures"))

col_spec <-cols_only( value = col_number(),
                      date = col_date(format = "")
)

df.sgss <- read_csv("measure_samedayab_sgss.csv",
               col_types = col_spec)
df.gp <- read_csv("measure_samedayab_gp.csv",
               col_types = col_spec)


### Sgss same day ab
df.sgss <- df.sgss %>% filter(date >=as.Date("2020-03-01"))
df.gp  <- df.gp  %>% filter(date >=as.Date("2020-03-01"))
df.sgss <- df.sgss %>% filter(date <=as.Date("2021-12-31"))
df.gp  <- df.gp  %>% filter(date <=as.Date("2021-12-31"))

first_mon=format(min(df.sgss$date),"%m-%Y")
last_mon= format(max(df.sgss$date),"%m-%Y")



plot <-ggplot(data = df.sgss, aes(x = date, y = value*100))+
  geom_line(color = "coral2", size = 0.5)+ 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  labs(
    title = "Same day Covid diagnosis and antibiotics prescription-sgss",
    subtitle = paste(first_mon,"-",last_mon),
    x = "",
    y = "Same day antibiotics prescribing %")+
    theme(axis.text.x=element_text(angle=60,hjust=1))+
    scale_x_date(date_labels = "%m-%Y", breaks = seq(as.Date("2019-01-01"), as.Date("2021-12-01"), by = "3 months"))

plot

ggsave(
  plot= plot,
  filename="same_day_ab_prop_line_sgss.jpeg", path=here::here("output"),
)  

### Gp same day ab

first_mon=format(min(df.gp$date),"%m-%Y")
last_mon= format(max(df.gp$date),"%m-%Y")

plot <-ggplot(data = df.gp, aes(x = date, y = value*100))+
  geom_line(color = "coral2", size = 0.5)+ 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  labs(
    title = "",
    subtitle = paste(first_mon,"-",last_mon),
    x = "",
    y = "Same day antibiotics prescribing %")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", breaks = seq(as.Date("2019-01-01"), as.Date("2021-12-01"), by = "3 months"))

plot

ggsave(
  plot= plot,
  filename="same_day_ab_prop_line_gp.jpeg", path=here::here("output"),
)  
