library("tidyverse") 
library('dplyr')
library('lubridate')


df <- read_csv(
  here::here("output", "input_ab_extraction_new.csv.gz"),  
  col_types = cols_only(
    ab_trim_nit = col_double(),
    ab_trim = col_double(),
    ab_nit = col_double(),
    patient_id = col_double()
  ),
  na = character()
)


df.trim <- df %>% summarise(
  trim = sum(ab_trim)
)

df.nit <- df %>% summarise(
  nit = sum(ab_nit)
)

df.t_n <- df %>% summarise(
  trim_nit = sum(ab_trim_nit)
)

df <- cbind(df.trim,df.nit,df.t_n)

df$trim_rate = (df$trim / (df$trim + df$nit)) *100
df$trim_rate_2 = (df$trim / df$trim_nit) *100

write_csv(df , here::here("output", "TPP_Trim_Nitro_frequency_new.csv"))