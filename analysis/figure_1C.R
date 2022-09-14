library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")

rm(list=ls())
setwd(here::here("output", "measures"))

col_spec <-cols_only(  broad_ab_binary = col_number(),
                       AB_given_14D_window = col_number(),
                       Tested_for_covid_event = col_number(),
                       value = col_number(),
                       date = col_date(format = "")
)


lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")




df <- read_csv("measure_14D_window_ab.csv",
               col_types = col_spec)



df.allab <- df %>%
  group_by(date)%>%
  summarise(AB_given_14D_window=sum(AB_given_14D_window,na.rm=TRUE),
            Tested_for_covid_event=sum(Tested_for_covid_event,na.rm=TRUE)) %>%
  mutate(value = round(AB_given_14D_window/Tested_for_covid_event,digits = 3))

df.broad <- df %>% filter(broad_ab_binary == 1) 
df.broad <- df.broad[,-1]
df.allab $ type <- "all antibiotics"
df.broad $ type <- "broad-spectrum"

df <- bind_rows(df.allab,df.broad)

p <- ggplot(df, aes(x=date, y=value, group = type, color = type))+
  annotate(geom = "rect", xmin=lockdown_1_start, xmax=lockdown_1_end,ymin = -Inf, ymax = Inf,fill="#DEC0A0", alpha=0.5)+
  annotate(geom = "rect", xmin=lockdown_2_start, xmax=lockdown_2_end,ymin = -Inf, ymax = Inf,fill="#DEC0A0", alpha=0.5)+
  annotate(geom = "rect", xmin=lockdown_3_start, xmax=lockdown_3_end,ymin = -Inf, ymax = Inf,fill="#DEC0A0", alpha=0.5)+
  geom_line(aes(y = value), lwd = 0.8)+ scale_color_manual(values=c("#0F5DC9", "#BA6A16"))+
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  labs(x = "", y = "antibiotic prescribed in 14-day window tested positive for SARS-Cov-2") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60,hjust=1))
            
p
            
ggsave(p, width = 12, height = 6, dpi = 640,
                   filename="figure_1C.jpeg", path=here::here("output"),
            )  