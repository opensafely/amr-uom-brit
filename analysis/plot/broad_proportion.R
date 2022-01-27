## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

# impoprt data

df <- read_csv(
  here::here("output", "measures", "measure_broad_narrow_prescribing.csv"),
  col_types = cols_only(
    broad_prescriptions_check  = col_double(),
    practice  = col_double(),
    age_cat = col_character(),
    population = col_double(),
    # Date
    date = col_date(format="%Y-%m-%d")
  ),
  na = character()
)



# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))

df$date <- as.Date(df$date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)
df$broad_prescriptions_check <- as.factor(df$broad_prescriptions_check)


df_ab <- df%>% group_by(date,practice,age_cat)%>%
  mutate(total_ab_population=population[broad_prescriptions_check==1]+population[broad_prescriptions_check==0])


df_ab <- df_ab%>%filter(broad_prescriptions_check==1)

num_uniq_prac <- as.numeric(dim(table((df_ab$practice))))

df_plot <- df_ab%>%group_by(date,age_cat)%>%
  summarise(broad_population=sum(population,na.rm = TRUE),
            ab_population=sum(total_ab_population,na.rm = TRUE))%>%
  mutate(year=format(date,"%Y"))

df_plot$rate <- df_plot$broad_population/df_plot$ab_population

df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))


plot1 <- ggplot(df_plot, aes(x=date, y=rate))+
  geom_rect(xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-12"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_rect(xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_rect(xmin = as.Date("2020-03-23"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_line(aes(color=year))+
  facet_grid(rows = vars(age_cat))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  scale_x_date(date_breaks = "1 month",date_labels =  "%m")+
  scale_y_continuous(labels = scales::percent)+
  labs(
    title = "Proportion of broad-spectrum antibiotics prescribed by age group",  
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", num_uniq_prac,"TPP Practices",';National lockdown in red area'), 
    x = "", 
    y = "broad-spectrum antibiotics prescribing %")
plot1


df_plot_2 <- df_plot%>%group_by(date)%>%summarise(broad_population=sum(broad_population,na.rm = TRUE),
                                                  ab_population=sum(ab_population,na.rm = TRUE))%>%
  mutate(year=format(date,"%Y"))
df_plot_2$rate<- df_plot_2$broad_population/df_plot_2$ab_population

plot2 <- ggplot(df_plot_2, aes(x=date, y=rate))+
  geom_rect(xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-12"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_rect(xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_rect(xmin = as.Date("2020-03-23"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
  geom_line(aes(color=year))+
  theme(legend.position = "bottom",legend.title =element_blank())+
  scale_x_date(date_breaks = "1 month",date_labels =  "%m")+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.005))+
  labs(
    title = "Proportion of broad-spectrum antibiotics prescribed",  
    subtitle = paste(first_mon,"-",last_mon),
    caption = paste("Data from approximately", num_uniq_prac,"TPP Practices",';National lockdown in red area'), 
    x = "", 
    y = "broad-spectrum antibiotics prescribing %")
plot2

## table 
write_csv(df_plot, here::here("output", "broad_prescriptions_proportion.csv"))

## plot
ggsave(
  plot= plot1,
  filename="broad_proportions_line_age.jpeg", path=here::here("output"),
)  

ggsave(
  plot= plot2,
  filename="broad_proportions_line.jpeg", path=here::here("output"),
)  