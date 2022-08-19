library("tidyverse") 
library('dplyr')
library('lubridate')


df <- read_csv(
  here::here("output", "input_antibiotic_OS_2022.csv.gz"),  
  col_types = cols_only(
    ab_OS = col_double(),
    patient_id = col_double()
  ),
  na = character()
)

df.all <- df %>% summarise(
    ab_count = sum(ab_OS)
)


write_csv(df.all  , here::here("output", "TPP_ab_OS_2022_count.csv"))

