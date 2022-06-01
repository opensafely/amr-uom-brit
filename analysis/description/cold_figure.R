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

DF <- readRDS("cleaned_indication_ab.rds")

# recode
DF$date <- as.Date(DF$date)
DF <- DF %>% filter(date <= as.Date("2021-12-31"))
DF <- DF %>% filter(age > 3)
setwd(here::here("output"))
df2.1 <- read_csv("prepared_var_2019.csv") %>% select(-c(age,sex))
df2.2 <- read_csv("prepared_var_2020.csv") %>% select(-c(age,sex))
df2.3 <- read_csv("prepared_var_2021.csv") %>% select(-c(age,sex))
df2 <- rbind(df2.1,df2.2,df2.3)
df <- merge(DF,df2,by=c("patient_id"))
rm(DF,df2)

df$ethnicity_6 <- as.factor(df$ethnicity_6)
df$imd <- as.factor(df$imd)
df$region <- as.factor(df$region)
df$charlsonGrp <- as.factor(df$charlsonGrp)
df$ab12b4 <- as.factor(df$ab12b4)
df <- df %>% dplyr::select(patient_id,incidental,infection,type,repeat_ab,age,sex,ethnicity_6,region,charlsonGrp,imd,ab12b4,date)
df <- df %>% filter (df$sex=="M"|df$sex=="F")
df <- df %>% mutate(age_group = case_when(age>3 & age<=15 ~ "<16",
                                          age>=16 & age<=44 ~ "16-44",
                                          age>=45 & age<=64 ~ "45-64",
                                          age>=65 ~ "65+"))


### cold : repeat/percentage

### prepare var ### without Amoxicillin ###

df <- df %>% filter (incidental == 1)
df <- df %>% filter (infection == "Cold")

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-03-01")

###  Transfer df into numOutcome / numEligible  version
df$cal_year <- year(df$date)
df$cal_mon <- month(df$date)
df$time <- as.numeric(df$cal_mon+(df$cal_year-2019)*12)
DF <- df

### repeat overall

df.repeat <- df %>% filter(repeat_ab == 1) 
df.repeat_total <- df.repeat %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.repeat_total,df.all,by=c("time"))

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

bkg_colour <- "white"
figure_cold <- ggplot(df.model, aes(x = as.Date("2019-01-01"), y = value, group = factor(infection), col = factor(infection), fill = factor(infection))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  geom_line(aes(x = monPlot, y = value), lwd = 1.2)+ 
  scale_x_date(date_labels = "%Y", breaks = "1 year") +
  geom_vline(xintercept = c(start_covid, 
                            covid_adjustment_period_from), col = 1, lwd = 1)+
  labs(x = "Date", y = "% of repeat prescription", title = "", colour = "indication", fill = "indication") +
  theme_classic()  +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) 

figure_cold

ggsave(
  plot= figure_cold,
  filename="figure_cold_repeat.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_cold_repeat_table.csv"))
rm(df.broad_total,df.all,df.model)

