library("dplyr")
library("tidyverse")
library("lubridate")

#### 14Day ####

rm(list=ls())
setwd(here::here("output", "measures"))

col_spec <-cols_only(antibiotic_type = col_character(),
                     AB_given_14D_window = col_number(),
                     Positive_test_event = col_number(),
                     date = col_date(format = "")
)

df20 <- read_csv("measure_covid_window_top5_ab_by_type.csv",
                 col_types = col_spec) %>% filter(date >=as.Date("2020-03-01"))
df21 <- read_csv("measure_21_covid_window_top5_ab_by_type.csv",
                 col_types = col_spec)

df <- bind_rows(df20,df21)

df.frequency <- df %>% group_by(antibiotic_type) %>% summarise(
  n_count = sum(AB_given_14D_window)
)

all_count <- sum(df$AB_given_14D_window)

df.frequency$prop <- df.frequency$n_count/all_count

write_csv(df.frequency, here::here("output", "ab_type_table.csv"))


#### 2 Day ####
setwd(here::here("output", "measures"))

col_spec2 <-cols_only(antibiotic_type = col_character(),
                     AB_given_2D_window = col_number(),
                     Positive_test_event = col_number(),
                     date = col_date(format = "")
)

df20.2 <- read_csv("measure_covid_window_2D_top5_ab_by_type.csv",
                 col_types = col_spec2) %>% filter(date >=as.Date("2020-03-01"))
df21.2 <- read_csv("measure_21_covid_window_2D_top5_ab_by_type.csv",
                 col_types = col_spec2)

df2 <- bind_rows(df20.2,df21.2)

df.frequency2 <- df2 %>% group_by(antibiotic_type) %>% summarise(
  n_count = sum(AB_given_2D_window)
)

all_count <- sum(df2$AB_given_2D_window)

df.frequency2$prop <- df.frequency2$n_count/all_count

write_csv(df.frequency2, here::here("output", "ab_type_table_2D.csv"))
