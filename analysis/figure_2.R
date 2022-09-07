library("dplyr")
library("tidyverse")
library("lubridate")
library("ggsci")


rm(list=ls())
setwd(here::here("output", "measures"))


col_spec1 <-cols_only( broad_ab_count = col_number(),
                       antibiotic_count = col_number(),
                       age_cat = col_character(),
                       date = col_date(format = "")
)

col_spec2 <-cols_only( value = col_number(),
                       sex = col_character(),
                       date = col_date(format = "")
)

col_spec3 <-cols_only( value = col_number(),
                       region = col_character(),
                       date = col_date(format = "")
)

lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")

### broad-spectrum rate by age

df1 <- read_csv("measure_broad-spectrum-ratio_age.csv",
                col_types = col_spec1)
df1$age_cat <- recode(df1$age_cat,
       "0-4" = "<25", 
       "5-14"= "<25",
       "15-24" = "<25",
       "25-34"= "25-64",
       "35-44"= "25-64",
       "45-54" = "25-64",
       "55-64"= "25-64",
       "65-74"= ">64",
       "75+" = ">64")
df.plot <- df1 %>% group_by(date,age_cat) %>% summarise(braod_count = sum(broad_ab_count),
                                                        ab_count = sum(antibiotic_count))%>%
  mutate(value = braod_count/ab_count)

df.plot <- df.plot %>% filter(!age_cat == 0)

figure_age_strata <- ggplot(df.plot, aes(x = as.Date("2019-01-01"), y = value, group = factor(age_cat), col = factor(age_cat), fill = factor(age_cat))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "rate of broad-sepctrum antibiotic", title = "", colour = "Age", fill = "Age") +
  theme_bw() +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) +
  theme(axis.text.x=element_text(angle=60,hjust=1))+ scale_color_aaas()+ scale_fill_aaas()
figure_age_strata


### broad-spectrum rate by sex

df2 <- read_csv("measure_broad-spectrum-ratio_sex.csv",
                col_types = col_spec2)
df2$sex <- recode(df2$sex,
       "F" = "Female", 
       "M"= "Male")

figure_sex_strata <- ggplot(df2, aes(x = as.Date("2019-01-01"), y = value, group = factor(sex), col = factor(sex), fill = factor(sex))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "rate of broad-sepctrum antibiotic", title = "", colour = "Sex", fill = "Sex") +
  theme_bw() +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) +
  theme(axis.text.x=element_text(angle=60,hjust=1))+ scale_color_aaas()+ scale_fill_aaas()
figure_sex_strata


### broad-spectrum rate by region

df3 <- read_csv("measure_broad-spectrum-ratio_region.csv",
                col_types = col_spec3)

df3 <- df3 %>% filter(!is.na(region))

figure_region_strata <- ggplot(df3, aes(x = as.Date("2019-01-01"), y = value, group = factor(region), col = factor(region), fill = factor(region))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "rate of broad-sepctrum antibiotic", title = "", colour = "Region", fill = "Region") +
  theme_bw() +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) +
  theme(axis.text.x=element_text(angle=60,hjust=1))+ scale_color_aaas()+ scale_fill_aaas()
figure_region_strata

ggsave(figure_age_strata, width = 12, height = 6, dpi = 640,
       filename="figure_2.1.jpeg", path=here::here("output"),
)  
ggsave(figure_sex_strata, width = 12, height = 6, dpi = 640,
       filename="figure_2.2.jpeg", path=here::here("output"),
)  
ggsave(figure_region_strata, width = 12, height = 6, dpi = 640,
       filename="figure_2.3.jpeg", path=here::here("output"),
)  