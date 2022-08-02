library("tidyverse") 
library('dplyr')
library('lubridate')


df <- read_csv(
  here::here("output", "input_ab_extraction_condition.csv.gz"),  
  col_types = cols_only(
    antibacterial_brit = col_double(),
    antibacterial_brit_abtype = col_character(),
    patient_id = col_double()
  ),
  na = character()
)

df.all <- df %>% summarise(
    ab_count = sum(antibacterial_brit)
)

df.abtype <- df %>% group_by(antibacterial_brit_abtype) %>% summarise(
    type_count = sum(antibacterial_brit)
)

df.abtype $prop <- df.abtype$type_count*100/df.all$ab_count

write_csv(df.abtype , here::here("output", "TPP_Trim_Nitro_frequency_condition.csv"))


