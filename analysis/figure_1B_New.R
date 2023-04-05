library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")

setwd(here::here("output", "measures"))

col_spec <-cols_only( broad_ab_count = col_number(),
                      antibiotic_count = col_number(),
                      value = col_number(),
                      date = col_date(format = "")
)

lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")


df <- read_csv("measure_broad-spectrum-ratio.csv",
               col_types = col_spec)
df$value <- round(df$value*100,1)

p <- ggplot(df, aes(date)) +
  geom_rect(aes(xmin=lockdown_1_start, xmax=lockdown_1_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_2_start, xmax=lockdown_2_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_3_start, xmax=lockdown_3_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_line(aes(y = df$value), colour = "#BA6A16") +
  scale_x_date(date_labels = "%Y %b", breaks = seq(as.Date("2019-01-01"), as.Date("2022-01-01"), by = "3 months")) +
  ylim(0, max(df$value)) +
  labs(x = "", y = "") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60,hjust=1))

ggsave(p, width = 10, height = 6, dpi = 640,
  filename="figure_1B_New.jpeg", path=here::here("output"))
