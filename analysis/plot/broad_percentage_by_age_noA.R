library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output", "measures"))

df1 <- readRDS('ab_type_pre.rds')
df2 <- readRDS('ab_type_2019.rds')
df3 <- readRDS('ab_type_2020.rds')
df4 <- readRDS('ab_type_2021.rds')
df5 <- readRDS('ab_type_2022.rds')
df2 <- bind_rows(df2)
df3 <- bind_rows(df3)
df4 <- bind_rows(df4)

df <- rbind(df1,df2,df3,df4,df5)
rm(df1,df2,df3,df4,df5)

broadtype <- c("Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")


df <- df %>% select(patient_id,age,Date,type) %>%
  mutate(age_cat= case_when(age>=0&age<=4 ~ "0-4",
                                               age>=5&age<=14 ~ "5-14",
                                               age>=15&age<=24 ~ "15-24",
                                               age>=25&age<=34 ~ "25-34",
                                               age>=35&age<=44 ~ "35-44",
                                               age>=45&age<=54 ~ "45-54",
                                               age>=55&age<=64 ~ "55-64",
                                               age>=65&age<=74 ~ "65-74",
                                               age>=75 ~ "75+"))
df$age_cat <- as.factor(df$age_cat)

df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(Date,age_cat) %>% summarise(
  broad_number = n()
)

first_mon=format(min(df.broad_total$Date),"%m-%Y")
last_mon= format(max(df.broad_total$Date),"%m-%Y")


plot.broad_number<- ggplot(df.broad_total, aes(x=Date, y=broad_number ,group=age_cat,color=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=age_cat))+
  geom_point(aes(shape=age_cat))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "Age",
    title = "Broad- Spectrum total number by age_cat",
    subtitle = paste(first_mon,"-",last_mon),
    y = "",
    x=""
  )+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_shape_manual(values = c(rep(1:9))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen"))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")
plot.broad_number

ggsave(
  plot= plot.broad_number,
  filename="broad_prescriptions_by_age_noA.jpeg", path=here::here("output"),
)  

rm(plot.broad_number,df.broad)

df.all <-  df %>% group_by(Date,age_cat) %>% summarise(
  ab_number = n()
)
df.prop <- merge(df.broad_total,df.all,by=c("Date","age_cat"))
df.prop$prop <- df.prop$broad_number/df.prop$ab_number


plot.broad_prop<- ggplot(df.prop, aes(x=Date, y=prop ,group=age_cat,color=age_cat))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=age_cat))+
  geom_point(aes(shape=age_cat))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "Age",
    title = "Proportion of broad-spectrum antibiotics prescribed by age_cat",
    subtitle = paste(first_mon,"-",last_mon),
    y = "",
    x=""
  )+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.005))+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_shape_manual(values = c(rep(1:9))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen"))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")
plot.broad_prop

ggsave(
  plot= plot.broad_prop,
  filename="broad_proportion_by_age_noA.jpeg", path=here::here("output"),
)  