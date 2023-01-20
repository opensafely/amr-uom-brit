library("dplyr")
library("tidyverse")
library("lubridate")
library("ggsci")


rm(list=ls())
setwd(here::here("output"))


col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        sepsis_type = col_integer(),       
                        patient_id = col_number()
)


lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")

df <- read_csv("case_ch.csv",
                col_types = col_spec)

df$cal_year <- year(df$patient_index_date)
df$cal_mon <- month(df$patient_index_date)
df$cal_day <- 1
df$monPlot <- as.Date(with(df,paste(cal_year,cal_mon,cal_day,sep="-")),"%Y-%m-%d")

### sepsis count by age

df <- df %>% mutate(age_cat = case_when(age < 25 ~ "<25",
                                        age >= 25 & age < 65 ~ "25-64",
                                        age >= 65 ~ ">64"))

df.plot <- df %>% group_by(monPlot,age_cat) %>% summarise(value = length(patient_id))
df.plot$value <- plyr::round_any(df.plot$value, 5)

figure_age_strata <- ggplot(df.plot, aes(x = as.Date("2019-01-01"), y = value, group = factor(age_cat), col = factor(age_cat), fill = factor(age_cat))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = monPlot, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "Cases of spesis hospital admission", title = "", colour = "Age", fill = "Age") +
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


### by sex
df$sex <- recode(df$sex,
       "F" = "Female", 
       "M"= "Male")

df.plot <- df %>% group_by(monPlot,sex) %>% summarise(value = length(patient_id))
df.plot$value <- plyr::round_any(df.plot$value, 5)

figure_sex_strata <- ggplot(df.plot, aes(x = as.Date("2019-01-01"), y = value, group = factor(sex), col = factor(sex), fill = factor(sex))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = monPlot, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "Cases of spesis hospital admission", title = "", colour = "Sex", fill = "Sex") +
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


###  by IMD
df$imd <- recode(df$imd,
       "5" = "5(least deprived)", 
       "4" = "4",
       "3" = "3",
       "2" = "2",
       "1" = "1(most deprived)")
df.plot <- df %>% group_by(monPlot,imd) %>% summarise(value = length(patient_id))
df.plot$value <- plyr::round_any(df.plot$value, 5)

figure_imd_strata <- ggplot(df.plot, aes(x = as.Date("2019-01-01"), y = value, group = factor(imd), col = factor(imd), fill = factor(imd))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = monPlot, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "Cases of spesis hospital admission", title = "", colour = "IMD", fill = "IMD") +
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
figure_imd_strata

ggsave(figure_age_strata, width = 8, height = 4, dpi = 640,
       filename="figure_2.1.jpeg", path=here::here("output"),
)  
ggsave(figure_sex_strata, width = 8, height = 4, dpi = 640,
       filename="figure_2.2.jpeg", path=here::here("output"),
)  
ggsave(figure_imd_strata, width = 8, height = 4, dpi = 640,
       filename="figure_2.3.jpeg", path=here::here("output"),
)  

write_csv(df.plot, here::here("output", "figure_2.3_table.csv"))
