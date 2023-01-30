library("dplyr")
library("tidyverse")
library("lubridate")

# import data
col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        sepsis_type = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

df1.1<- read_csv(here::here("output", "matched_cases_191.csv"), col_types = col_spec)
df2.1<- read_csv(here::here("output", "matched_cases_192.csv"), col_types = col_spec)
df1.2<- read_csv(here::here("output", "matched_cases_201.csv"), col_types = col_spec)
df2.2<- read_csv(here::here("output", "matched_cases_202.csv"), col_types = col_spec)
df1.3<- read_csv(here::here("output", "matched_cases_211.csv"), col_types = col_spec)
df2.3<- read_csv(here::here("output", "matched_cases_212.csv"), col_types = col_spec)
df3.1<- read_csv(here::here("output", "matched_cases_221.csv"), col_types = col_spec)
case<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)

case_id <- select(case,patient_index_date,patient_id)

write_csv(case_id, here::here("output", "case_id.csv"))