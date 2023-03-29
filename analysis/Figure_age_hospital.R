
### This script calculate the rate of Community-acquired sepsis per 1000 person by age ###

library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("here")
library("ggsci")


rm(list=ls())
setwd(here::here("output", "measures"))

col_spec1 <-cols_only(date = col_date(format = ""),
                      population = col_number(),
                      age = col_integer())

df <- read_csv("measure_person_age.csv",
                 col_types = col_spec1)

ave_population_1 <- df %>% filter(date<as.Date("2020-04-01"))
ave_population_1 <- ave_population_1 %>% group_by(age) %>% summarise(count = mean(population))
ave_population_1$count<-round(ave_population_1$count,0)

ave_population_2 <- df %>% filter(date>=as.Date("2020-04-01") & date<as.Date("2021-04-01"))
ave_population_2 <- ave_population_2 %>% group_by(age) %>% summarise(count = mean(population))
ave_population_2$count<-round(ave_population_2$count,0)

ave_population_3 <- df %>% filter(date>=as.Date("2021-04-01") & date<as.Date("2022-07-01"))
ave_population_3 <- ave_population_3 %>% group_by(age) %>% summarise(count = mean(population))
ave_population_3$count<-round(ave_population_3$count,0)

setwd(here::here("output","processed"))
df <- readRDS("input_model_h.rds")
df <- df %>% filter(case==1)
df1 <- df %>% filter (covid == 1)
df2 <- df %>% filter (covid == 2)
df3 <- df %>% filter (covid == 3)

case_1 <- df1 %>% group_by(age) %>% summarise(case = n())
case_1$case <- plyr::round_any(case_1$case, 5)
case_2 <- df2 %>% group_by(age) %>% summarise(case = n())
case_2$case <- plyr::round_any(case_2$case, 5)
case_3 <- df3 %>% group_by(age) %>% summarise(case = n())
case_3$case <- plyr::round_any(case_3$case, 5)

plot1<-merge(case_1,ave_population_1,by="age")
plot2<-merge(case_2,ave_population_2,by="age")
plot3<-merge(case_3,ave_population_3,by="age")
plot1$rate <- plot1$case*1000/plot1$count
plot1$rate <- round(plot1$rate,1)
plot2$rate <- plot2$case*1000/plot2$count
plot2$rate <- round(plot2$rate,1)
plot3$rate <- plot3$case*1000/plot3$count
plot3$rate <- round(plot3$rate,1)

plot1 <- ggplot(plot1, aes(x = age, y = rate)) +
  geom_bar(stat = "identity", width = 1, color = "black", fill = "#EFC000FF") +
  labs(title = "",
       x = "Age",
       y = "Incident rate per 1000 people") +
  scale_x_continuous(breaks = seq(0, 100, by = 5))+
  scale_y_continuous(breaks = seq(0, max(plot1$rate, na.rm = TRUE), by = 0.5)) + 
  theme_minimal()

plot2 <- ggplot(plot2, aes(x = age, y = rate)) +
  geom_bar(stat = "identity", width = 1, color = "black", fill = "#EFC000FF") +
  labs(title = "",
       x = "Age",
       y = "Incident rate per 1000 people") +
  scale_x_continuous(breaks = seq(0, 100, by = 5))+
  scale_y_continuous(breaks = seq(0, max(plot2$rate, na.rm = TRUE), by = 0.1)) + 
  theme_minimal()


plot3 <- ggplot(plot3, aes(x = age, y = rate)) +
  geom_bar(stat = "identity", width = 1, color = "black", fill = "#EFC000FF") +
  labs(title = "",
       x = "Age",
       y = "Incident rate per 1000 people") +
  scale_x_continuous(breaks = seq(0, 100, by = 5))+
  scale_y_continuous(breaks = seq(0, max(plot3$rate, na.rm = TRUE), by = 0.5)) + 
  theme_minimal()


ggsave(plot1, width = 8, height = 4, dpi = 320,
       filename="figure_age_hos_1.jpeg", path=here::here("output"),
)  
ggsave(plot2, width = 8, height = 4, dpi = 320,
       filename="figure_age_hos_2.jpeg", path=here::here("output"),
)  
ggsave(plot3, width = 8, height = 4, dpi = 320,
       filename="figure_age_hos_3.jpeg", path=here::here("output"),
)  