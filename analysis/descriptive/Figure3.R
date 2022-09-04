### This script is for preparing the variables for repeat antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output", "measures"))

df <- readRDS("cohort_1.rds")
### filter cohort 2 ###
df <- df %>% filter(!is.na(infection))

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-03-01")

###  Prepare the data frame for Interrupted time-series analysis  ###
###  Transfer df into numOutcome / numEligible  version
df$cal_year <- year(df$date)
df$cal_mon <- month(df$date)
df$time <- as.numeric(df$cal_mon+(df$cal_year-2019)*12)


### repeat by incident/prevalent (Yes/No)

df.repeat <- df %>% filter(repeat_ab == 1) 
df.repeat_total <- df.repeat %>% group_by(time,incidental) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time,incidental) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.repeat_total,df.all,by=c("time","incidental"))

df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1)
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")

df.model <- df.model %>% mutate(value = numOutcome/numEligible)

df.model$value <- round(df.model$value,digits = 3)
df.model$value <- df.model$value*100
df.model$numOutcome <- plyr::round_any(df.model$numOutcome, 5)
df.model$numEligible <- plyr::round_any(df.model$numEligible, 5)


bkg_colour <- "white"
figure_incident_strata <- ggplot(df.model, aes(x = as.Date("2019-01-01"), y = value, group = factor(incidental), col = factor(incidental), fill = factor(incidental))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y", breaks = "1 year") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of repeat prescription", title = "", colour = "incidental", fill = "incidental") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) 

figure_incident_strata

ggsave(
  plot= figure_incident_strata,
  filename="cohort_2_incident_strata.jpeg", path=here::here("output"),
)  

df.model$value <- df.model$numOutcome/df.model$numEligible

write_csv(df.model, here::here("output", "cohort_2_incident_strata_table.csv"))
rm(df.broad_total,df.all,df.model)

