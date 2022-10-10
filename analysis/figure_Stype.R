library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")

setwd(here::here("output", "measures"))

col_spec_1 <-cols_only( antibiotic_count = col_number(),
                      date = col_date(format = "")
)

col_spec_2 <-cols_only( antibiotic_type = col_character(),
                      antibiotic_count = col_number(),
                      date = col_date(format = "")
)

lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")


df1 <- read_csv("measure_antibiotic_items.csv",
               col_types = col_spec_1)

df2 <- read_csv("measure_antibiotic_by_type.csv",
               col_types = col_spec_2)


df2 <- df2 %>% filter (antibiotic_type == "Amoxicillin")

names(df1) <- c("overall","date")

df <- merge(df2,df1,by = "date")
df$prop <- df$antibiotic_count/df$overall

p <- ggplot(df, aes(date)) +
  geom_rect(aes(xmin=lockdown_1_start, xmax=lockdown_1_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_2_start, xmax=lockdown_2_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_3_start, xmax=lockdown_3_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_line(aes(y = prop), colour = "#0F5DC9",size = 0.8) +
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  scale_y_continuous(limits = c(0, 0.4)) +
  labs(x = "", y = "") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60,hjust=1))



ggsave(p, width = 12, height = 6, dpi = 640,
  filename="figure_Stype.jpeg", path=here::here("output"),
)  