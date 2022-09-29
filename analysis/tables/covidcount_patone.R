library("dplyr")
library("tidyverse")
library("lubridate")

setwd(here::here("output", "measures"))

csvFiles20 = list.files(pattern="input_sameday_ab_2020", full.names = FALSE)
temp <- vector("list", length(csvFiles20))
for (i in seq_along(csvFiles20)){
  # read in one-month data
  df <- read_csv(csvFiles20[i])
  temp[[i]] <- df}
df.20<-bind_rows(temp)
df_one_pat.20 <- df.20 %>% dplyr::group_by(patient_id) %>%
  sample_n(1)
df20<- table(df_one_pat.20$positive_test_event)

csvFiles21 = list.files(pattern="input_sameday_ab_2021", full.names = FALSE)
temp <- vector("list", length(csvFiles21))
for (i in seq_along(csvFiles21)){
  # read in one-month data
  df <- read_csv(csvFiles21[i])
  temp[[i]] <- df}
df.21<-bind_rows(temp)
df_one_pat.21 <- df.21 %>% dplyr::group_by(patient_id) %>%
  sample_n(1)
df21<- table(df_one_pat.21$positive_test_event)

csvFiles22 = list.files(pattern="input_sameday_ab_2022", full.names = FALSE)
temp <- vector("list", length(csvFiles22))
for (i in seq_along(csvFiles22)){
  # read in one-month data
  df <- read_csv(csvFiles22[i])
  temp[[i]] <- df}
df.22<-bind_rows(temp)
df_one_pat.22 <- df.22 %>% dplyr::group_by(patient_id) %>%
  sample_n(1)
df22<- table(df_one_pat.22$positive_test_event)
df <- as.data.frame(cbind(df20,df21,df22))

write_csv(df, here::here("output", "covid_count_patone.csv"))

