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

col_spec4 <-cols_only( value = col_number(),
                       imd = col_character(),
                       date = col_date(format = "")
)

col_spec5 <-cols_only( value = col_number(),
                       ethnicity = col_character(),
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


df.plot$value <- round(df.plot$value,digits = 3)
df.plot$braod_count <- plyr::round_any(df.plot$braod_count, 5)
df.plot$ab_count <- plyr::round_any(df.plot$ab_count, 5)


figure_age_strata <- ggplot(df.plot, aes(x = as.Date("2019-01-01"), y = value, group = factor(age_cat), col = factor(age_cat), fill = factor(age_cat))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  ylim(0, max(df.plot$value)) +
  labs(x = "", y = "", title = "", colour = "Age", fill = "Age") +
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

df2$value <- round(df2$value,digits = 3)

figure_sex_strata <- ggplot(df2, aes(x = as.Date("2019-01-01"), y = value, group = factor(sex), col = factor(sex), fill = factor(sex))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  ylim(0, max(df2$value)) +
  labs(x = "", y = "", title = "", colour = "Sex", fill = "Sex") +
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
df3$value <- round(df3$value,digits = 3)

figure_region_strata <- ggplot(df3, aes(x = as.Date("2019-01-01"), y = value, group = factor(region), col = factor(region), fill = factor(region))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  ylim(0, max(df3$value)) +
  labs(x = "", y = "", title = "", colour = "Region", fill = "Region") +
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

### broad-spectrum rate by IMD

df5 <- read_csv("measure_broad-spectrum-ratio_imd.csv",
                col_types = col_spec4)
df5$imd <- recode(df5$imd,
       "0" = "NA", 
       "1"= "IMD 1 (most deprived)",
       "2"= "IMD 2",
       "3"= "IMD 3",
       "4"= "IMD 4",
       "5"= "IMD 5 (least deprived)")
df5 <- df5 %>% filter(!imd=="NA")
df5$value <- round(df5$value,digits = 3)

figure_imd_strata <- ggplot(df5, aes(x = as.Date("2019-01-01"), y = value, group = factor(imd), col = factor(imd), fill = factor(imd))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  ylim(0, max(df5$value)) +
  labs(x = "", y = "", title = "", colour = "IMD quintiles", fill = "IMD quintiles") +
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

### broad-spectrum rate by ethnicity

df4 <- read_csv("measure_broad-spectrum-ratio_ethnicity.csv",
                col_types = col_spec5)
df4$ethnicity <- recode(df4$ethnicity,
       "0" = "Unknown", 
       "1"= "White",
       "2"= "Mixed",
       "3"= "South Asian",
       "4"= "Black",
       "5"= "Other")
df4 <- df4 %>% filter(!ethnicity=="Unknown")
df4$value <- round(df4$value,digits = 3)

figure_ethnicity_strata <- ggplot(df4, aes(x = as.Date("2019-01-01"), y = value, group = factor(ethnicity), col = factor(ethnicity), fill = factor(ethnicity))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = date, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  ylim(0, max(df4$value)) +
  labs(x = "", y = "", title = "", colour = "Ethnicity", fill = "Ethnicity") +
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
figure_ethnicity_strata















ggsave(figure_age_strata, width = 10, height = 6, dpi = 640,
       filename="figure_2.1.jpeg", path=here::here("output"),
)  

write_csv(df.plot, here::here("output", "figure_2.1_table.csv"))

ggsave(figure_sex_strata, width = 10, height = 6, dpi = 640,
       filename="figure_2.2.jpeg", path=here::here("output"),
)  
ggsave(figure_region_strata, width = 10, height = 6, dpi = 640,
       filename="figure_2.3.jpeg", path=here::here("output"),
)  
ggsave(figure_ethnicity_strata, width = 10, height = 6, dpi = 640,
       filename="figure_2.4.jpeg", path=here::here("output"),
)  

ggsave(figure_imd_strata, width = 10, height = 6, dpi = 640,
       filename="figure_2.5.jpeg", path=here::here("output"),
)  