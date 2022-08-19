library("tidyverse") 
library('dplyr')
library('lubridate')


df <- read_csv(
  here::here("output", "input_antibiotic_Brit_2020.csv.gz"),  
  col_types = cols_only(
    ab_Brit = col_double(),
    ab_Brit_abtype = col_character(),
    patient_id = col_double()
  ),
  na = character()
)

df.all <- df %>% summarise(
    ab_count = sum(ab_Brit)
)

df.abtype <- df %>% group_by(ab_Brit_abtype) %>% summarise(
    type_count = sum(ab_Brit)
)

df.abtype$prop <- df.abtype$type_count*100/df.all$ab_count

write_csv(df.abtype , here::here("output", "TPP_ab_Brit_2020_frequency.csv"))
write_csv(df.all  , here::here("output", "TPP_ab_Brit_2020_count.csv"))

