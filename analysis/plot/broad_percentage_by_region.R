library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())

df <- read_csv(
    here::here("output", "input_withab_cohort.csv.gz"),  
               col_types = cols_only(
                 age = col_integer(),
                 sex = col_character(),
                 practice = col_integer(),
                 region = col_factor(),
                 imd = col_integer(),
                 ethnicity = col_factor(),
                 patient_id = col_integer()
               ),
               na = character())

df.r <- df %>% select(patient_id,region)
rm(df)

setwd(here::here("output", "measures"))

df1 <- readRDS('ab_type_2019.rds')
df2 <- readRDS('ab_type_2020.rds')
df3 <- readRDS('ab_type_2021.rds')
df1 <- bind_rows(df1)
df2 <- bind_rows(df2)
df3 <- bind_rows(df3)
DF <- rbind(df1,df2,df3)
rm(df1,df2,df3)

df <- merge(DF,df.r, by='patient_id')
rm(DF,df.r)

broadtype <- c("Amoxicillin","Ampicillin","Co-amoxiclav","Moxifloxacin","Cefaclor","Cefadroxil",
               "Cefuroxime", "Cefalexin","Cefazolin","Cefixime","Cefotaxime","Cefoxitin","Cefradine",
               "Cefpirome","Ceftazidime","Ceftriaxone", "Cefprozil","Ciprofloxacin","Co-fluampicil",
               "Doripenem","Ertapenem", "Cilastatin","Cefamandole","Levofloxacin" , 
               "Meropenem" ,"Nalidixic acid","Norfloxacin", "Ofloxacin","Cefpodoxime","Cefepime")


df.broad <- df %>% filter(type %in% broadtype )
df.broad_total <- df.broad %>% group_by(Date,region) %>% summarise(
  broad_number = n()
)

first_mon=format(min(df.broad_total$Date),"%m-%Y")
last_mon= format(max(df.broad_total$Date),"%m-%Y")



plot.broad_number<- ggplot(df.broad_total, aes(x=Date, y=broad_number ,group=region,color=region))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=region))+
  geom_point(aes(shape=region))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "Region",
    title = "Broad- Spectrum total number by region",
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
  filename="broad_prescriptions_by_region.jpeg", path=here::here("output"),
)  

rm(plot.broad_number,df.broad)

df.all <-  df %>% group_by(Date,region) %>% summarise(
  ab_number = n()
)
df.prop <- merge(df.broad_total,df.all,by=c("Date","region"))
df.prop$prop <- df.prop$broad_number/df.prop$ab_number


plot.broad_prop<- ggplot(df.prop, aes(x=Date, y=prop ,group=region,color=region))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=region))+
  geom_point(aes(shape=region))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "Region",
    title = "Proportion of broad-spectrum antibiotics prescribed by region",
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
  filename="broad_proportion_by_region.jpeg", path=here::here("output"),
)  