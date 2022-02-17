# duplicated patient id can't extract cohort 
# split case and control


library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')


#### COVID death

# impoprt matched dataset
df <- read_csv(here::here("output", "matched_combined_hosp_icu_death.csv"))


case= df%>% filter(case==1)

control= df%>% filter(case==0)


write_csv(case, here::here("output", "matched_outcome_3_case.csv"))

write_csv(control, here::here("output", "matched_outcome_3_control.csv"))