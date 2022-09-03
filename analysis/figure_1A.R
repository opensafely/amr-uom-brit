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

# Function factory for secondary axis transforms
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

sec <- with(df, train_sec(c(0, max(antibiotic_count)),
                                 c(0, max(value))))

p <- ggplot(df, aes(date)) +
  geom_rect(aes(xmin=lockdown_1_start, xmax=lockdown_1_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_2_start, xmax=lockdown_2_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_3_start, xmax=lockdown_3_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_line(aes(y = antibiotic_count), colour = "#0F5DC9",size = 0.8) +
  geom_line(aes(y = sec$fwd(value)), colour = "#BA6A16") +
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  scale_y_continuous(sec.axis = sec_axis(~sec$rev(.), name = "broad-spectrum antibiotic rate"))+
  labs(x = "Date", y = "antibiotic items") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60,hjust=1))



ggsave(p, width = 12, height = 6, dpi = 640,
  filename="figure_1A.jpeg", path=here::here("output"),
)  