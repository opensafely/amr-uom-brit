### This script is for preparing the variables for broad spectrum antibiotics model ###
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

### prepare var ### without Amoxicillin ###
broadtype <- c("Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-03-01")

###  Prepare the data frame for Interrupted time-series analysis  ###
###  Transfer df into numOutcome / numEligible  version
df$cal_year <- year(df$date)
df$cal_mon <- month(df$date)
df$time <- as.numeric(df$cal_mon+(df$cal_year-2019)*12)
DF <- df

### Broad spectrum by age

df.broad <- df %>% filter(type %in% broadtype ) 
df.broad_total <- df.broad %>% group_by(time,age_group) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time,age_group) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("time","age_group"))

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

df.model$numOutcome <- round(df.model$numOutcome, digits = -1)
df.model$numEligible <- round(df.model$numEligible, digits = -1)

bkg_colour <- "white"
figure_age_strata <- ggplot(df.model, aes(x = as.Date("2019-01-01"), y = value, group = factor(age_group), col = factor(age_group), fill = factor(age_group))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y", breaks = "1 year") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of broad-sepctrum prescription", title = "", colour = "Age", fill = "Age") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) 

figure_age_strata

ggsave(
  plot= figure_age_strata,
  filename="figure_age_strata.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_age_strata_table.csv"))
rm(df.broad_total,df.all,df.model)

### Broad spectrum by sex

df.broad_total <- df.broad %>% group_by(time,sex) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time,sex) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("time","sex"))

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

df.model$numOutcome <- round(df.model$numOutcome, digits = -1)
df.model$numEligible <- round(df.model$numEligible, digits = -1)

bkg_colour <- "white"
figure_sex_strata <- ggplot(df.model, aes(x = as.Date("2019-01-01"), y = value, group = factor(sex), col = factor(sex), fill = factor(sex))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y", breaks = "1 year") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of broad-sepctrum prescription", title = "", colour = "Gender", fill = "Gender") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) 

figure_sex_strata

ggsave(
  plot= figure_sex_strata,
  filename="figure_sex_strata.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_sex_strata_table.csv"))
rm(df.broad_total,df.all,df.model)
### Broad spectrum by region

df.broad_total <- df.broad %>% group_by(time,region) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time,region) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("time","region"))

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

df.model$numOutcome <- round(df.model$numOutcome, digits = -1)
df.model$numEligible <- round(df.model$numEligible, digits = -1)

bkg_colour <- "white"
figure_region_strata <- ggplot(df.model_remove_na, aes(x = as.Date("2019-01-01"), y = value, group = factor(region), col = factor(region), fill = factor(region))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y", breaks = "1 year") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of broad-sepctrum prescription", title = "", colour = "Region", fill = "Region") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) 

figure_region_strata

ggsave(
  plot= figure_region_strata,
  filename="figure_region_strata.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_region_strata_table.csv"))

