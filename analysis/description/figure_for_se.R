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
broadtype_1 <- c("Amoxicillin","Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")

broadtype_2 <- c("Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")

broadtype_3 <- c("Co-amoxiclav","Cefaclor","Cefadroxil","Cefixime","Cefotaxime","Ceftriaxone","Ceftazidime"
               "Cefuroxime", "Cefalexin","Cefradine","Ciprofloxacin","Ofloxacin","Levofloxacin","Moxifloxacin")


### Broad spectrum 1

df.broad <- df %>% filter(type %in% broadtype_1 ) 
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("time"))

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
df.model$numOutcome <- plyr::round_any(df.model$numOutcome, 5)
df.model$numEligible <- plyr::round_any(df.model$numEligible, 5)


p_1 <- ggplot(df.model, aes(y=value, x=monPlot)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white")+
  labs(
    title = "Broad-spectrum percentage_1",
    caption = "National lockdown time in grey background. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")

ggsave(
  plot= p_1,
  filename="figure_broad_1.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_broad_1_table.csv"))
rm(df.broad_total,df.all,df.model,df.broad)


### Broad spectrum 2

df.broad <- df %>% filter(type %in% broadtype_2 ) 
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("time"))

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
df.model$numOutcome <- plyr::round_any(df.model$numOutcome, 5)
df.model$numEligible <- plyr::round_any(df.model$numEligible, 5)


p_1 <- ggplot(df.model, aes(y=value, x=monPlot)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white")+
  labs(
    title = "Broad-spectrum percentage_2",
    caption = "National lockdown time in grey background. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")

ggsave(
  plot= p_1,
  filename="figure_broad_2.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_broad_2_table.csv"))
rm(df.broad_total,df.all,df.model,df.broad)


### Broad spectrum 3

df.broad <- df %>% filter(type %in% broadtype_3 ) 
df.broad_total <- df.broad %>% group_by(time) %>% summarise(
  numOutcome = n(),
)

df.all <-  df %>% group_by(time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("time"))

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
df.model$numOutcome <- plyr::round_any(df.model$numOutcome, 5)
df.model$numEligible <- plyr::round_any(df.model$numEligible, 5)


p_1 <- ggplot(df.model, aes(y=value, x=monPlot)) + 
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_col(color="white")+
  labs(
    title = "Broad-spectrum percentage_3",
    caption = "National lockdown time in grey background. ",
    y = "Percentage",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")

ggsave(
  plot= p_1,
  filename="figure_broad_3.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_broad_3_table.csv"))
rm(df.broad_total,df.all,df.model,df.broad)