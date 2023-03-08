### This script calculate the rate of sepsis per 1000 person per IMD ###

library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")


rm(list=ls())
df <- readRDS("output/processed/input_model_c_h.rds")
df <- df %>% filter(case==1)

lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")

df$cal_year <- year(df$patient_index_date)
df$cal_mon <- month(df$patient_index_date)
df$cal_day <- 1
df$monPlot <- as.Date(with(df,paste(cal_year,cal_mon,cal_day,sep="-")),"%Y-%m-%d")
df <- df %>% filter(monPlot < as.Date("2022-07-01"))


### IMD ###
df.plot <- df %>% group_by(monPlot,imd) %>% summarise(count = length(patient_id))
df.plot$count <- plyr::round_any(df.plot$count, 5)

df_died <- df %>% filter(died_any_30d == 1) 
df_imd_died <- df_died %>% group_by(monPlot,imd) %>% summarise(died_count= n())

df.plot <- merge(df.plot,df_imd_died,by =c("monPlot","imd"))
df.plot$value <- df.plot$died_count /df.plot$count
df.plot$value <- round(df.plot$value,digits = 3)

df.plot$imd <- recode(df.plot$imd,
       "1" = "1(most deprived)", 
       "2" = "2",
       "3" = "3",
       "4" = "4",
       "5" = "5(least deprived)")


figure_imd_strata <- ggplot(df.plot, aes(x = as.Date("2019-01-01"), y = value, group = factor(imd), col = factor(imd), fill = factor(imd))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = monPlot, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "30-day mortality", title = "", colour = "IMD", fill = "IMD") +
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


ggsave(figure_imd_strata, width = 8, height = 4, dpi = 640,
       filename="mortality_trend.jpeg", path=here::here("output"),
)  
write_csv(df.plot, here::here("output", "figure_mortality_trend.csv"))
