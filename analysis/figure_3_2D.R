library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")

rm(list=ls())
setwd(here::here("output", "measures"))

col_spec1 <-cols_only(AB_given_2D_window = col_number(),
                       Positive_test_event = col_number(),
                       value = col_number(),
                       date = col_date(format = "")
)

col_spec2 <-cols_only(Broad_given_2D_window = col_number(),
                       date = col_date(format = "")
)



lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")




df1.20 <- read_csv("measure_covid_window_2D_window_ab.csv",
               col_types = col_spec1) %>% filter(date >=as.Date("2020-03-01"))
df1.21 <- read_csv("measure_21_covid_window_2D_window_ab.csv",
               col_types = col_spec1)
df1 <- bind_rows(df1.20,df1.21)

df2.20 <- read_csv("measure_covid_window_2D_window_broad.csv",
               col_types = col_spec2) %>% filter(date >=as.Date("2020-03-01"))
df2.21 <- read_csv("measure_21_covid_window_2D_window_broad.csv",
               col_types = col_spec2)
df2 <- bind_rows(df2.20,df2.21)


df <- left_join(df1,df2,by = "date")
df$ab_rate <- round(df$value,digits = 3)
df$broad_rate <- round(df$Broad_given_2D_window/df$AB_given_2D_window,digits = 3)
df$Broad_given_2D_window <- plyr::round_any(df$Broad_given_2D_window, 5)
df$AB_given_2D_window <- plyr::round_any(df$AB_given_2D_window, 5)


train_sec <- function(primary, secondary, na.rm = TRUE) {
  # Thanks Henry Holm for including the na.rm argument!
  from <- range(secondary, na.rm = na.rm)
  to   <- range(primary, na.rm = na.rm)
  # Forward transform for the data
  forward <- function(x) {
    rescale(x, from = from, to = to)
  }
  # Reverse transform for the secondary axis
  reverse <- function(x) {
    rescale(x, from = to, to = from)
  }
  list(fwd = forward, rev = reverse)
}

sec <- with(df, train_sec(c(0, max(ab_rate)),
                          c(0, max(broad_rate))))



p <- ggplot(df, aes(x=date, y=sec$fwd(broad_rate))) +
  geom_rect(aes(xmin=lockdown_1_start, xmax=lockdown_1_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_2_start, xmax=lockdown_2_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_3_start, xmax=lockdown_3_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_line(aes(y = ab_rate), colour = "#0F5DC9",size = 0.8) +
  geom_line(aes(y = sec$fwd(broad_rate)), colour = "#BA6A16") +
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  scale_y_continuous(sec.axis = sec_axis(~sec$rev(.), name = "broad-spectrum rate"))+
  labs(x = "", y = "antibiotic prescribed in 2-day window tested positive for SARS-Cov-2") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60,hjust=1))
p


ggsave(p, width = 12, height = 6, dpi = 640,
                   filename="figure_3_2D.jpeg", path=here::here("output"),
            )  
write_csv(df, here::here("output", "figure_3_2D_table.csv"))
