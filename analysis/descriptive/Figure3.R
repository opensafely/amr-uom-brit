### This script is for preparing the variables for repeat antibiotics model ###
library("dplyr")
library("tidyverse")
library("lubridate")
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")

rm(list=ls())
setwd(here::here("output"))

df <- readRDS("cohort1.rds")

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-03-01")

###  Prepare the data frame for the figure  ###
###  Transfer df into numOutcome / numEligible  version
df$cal_year <- year(df$date)
df$cal_mon <- month(df$date)
df$time <- as.numeric(df$cal_mon+(df$cal_year-2019)*12)


### repeat by age

df.repeat <- df %>% filter(ab_repeat == 1) 
df.repeat_total <- df.repeat %>% group_by(time,age_group) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time,age_group) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.repeat_total,df.all,by=c("time","age_group"))

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
figure_age_strata <- ggplot(df.model, aes(x = as.Date("2019-01-01"), y = value, group = factor(age_group), col = factor(age_group), fill = factor(age_group))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of repeat prescription", title = "", colour = "Age", fill = "Age") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) +
  theme(axis.text.x=element_text(angle=60,hjust=1))

figure_age_strata

ggsave(
  plot= figure_age_strata,width = 12, height = 6, dpi = 640,
  filename="Figure3_age.jpeg", path=here::here("output"),
)  

df.model$value <- df.model$numOutcome/df.model$numEligible

write_csv(df.model, here::here("output", "Figure3_age_table.csv"))
rm(df.broad_total,df.all,df.model)

### repeat by sex

df.repeat <- df %>% filter(ab_repeat == 1) 
df.repeat_total <- df.repeat %>% group_by(time,sex) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time,sex) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.repeat_total,df.all,by=c("time","sex"))

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
figure_sex_strata <- ggplot(df.model, aes(x = as.Date("2019-01-01"), y = value, group = factor(sex), col = factor(sex), fill = factor(sex))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of repeat prescription", title = "", colour = "Gender", fill = "Gender") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) +
  theme(axis.text.x=element_text(angle=60,hjust=1))

figure_sex_strata

ggsave(
  plot= figure_sex_strata,width = 12, height = 6, dpi = 640,
  filename="Figure3_sex.jpeg", path=here::here("output"),
)  

df.model$value <- df.model$numOutcome/df.model$numEligible

write_csv(df.model, here::here("output", "Figure3_sex_table.csv"))
rm(df.broad_total,df.all,df.model)
### Repeat by region

df.repeat <- df %>% filter(ab_repeat == 1) 
df.repeat_total <- df.repeat %>% group_by(time,region) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time,region) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.repeat_total,df.all,by=c("time","region"))

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
df.model_remove_na <- df.model %>% filter(!is.na(region))

df.model$value <- round(df.model$value,digits = 3)
df.model$value <- df.model$value*100
df.model$numOutcome <- plyr::round_any(df.model$numOutcome, 5)
df.model$numEligible <- plyr::round_any(df.model$numEligible, 5)


bkg_colour <- "white"
figure_region_strata <- ggplot(df.model_remove_na, aes(x = as.Date("2019-01-01"), y = value, group = factor(region), col = factor(region), fill = factor(region))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of repeat prescription", title = "", colour = "Region", fill = "Region") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) +
  theme(axis.text.x=element_text(angle=60,hjust=1))

figure_region_strata

ggsave(
  plot= figure_region_strata,width = 12, height = 6, dpi = 640,
  filename="Figure3_region.jpeg", path=here::here("output"),
)  

df.model$value <- df.model$numOutcome/df.model$numEligible

write_csv(df.model, here::here("output", "Figure3_region_table.csv"))
