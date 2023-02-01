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

col_spec1 <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

### case cohort

df1.1<- read_csv(here::here("output", "matched_cases_191.csv"), col_types = col_spec)
df2.1<- read_csv(here::here("output", "matched_cases_192.csv"), col_types = col_spec)
df1.2<- read_csv(here::here("output", "matched_cases_201.csv"), col_types = col_spec)
df2.2<- read_csv(here::here("output", "matched_cases_202.csv"), col_types = col_spec)
df1.3<- read_csv(here::here("output", "matched_cases_211.csv"), col_types = col_spec)
df2.3<- read_csv(here::here("output", "matched_cases_212.csv"), col_types = col_spec)
df3.1<- read_csv(here::here("output", "matched_cases_221.csv"), col_types = col_spec)
case<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)

df1.1<- read_csv(here::here("output", "matched_matches_191.csv"), col_types = col_spec1)
df2.1<- read_csv(here::here("output", "matched_matches_192.csv"), col_types = col_spec1)
df1.2<- read_csv(here::here("output", "matched_matches_201.csv"), col_types = col_spec1)
df2.2<- read_csv(here::here("output", "matched_matches_202.csv"), col_types = col_spec1)
df1.3<- read_csv(here::here("output", "matched_matches_211.csv"), col_types = col_spec1)
df2.3<- read_csv(here::here("output", "matched_matches_212.csv"), col_types = col_spec1)
df3.1<- read_csv(here::here("output", "matched_matches_221.csv"), col_types = col_spec1)

control<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)
control <- control[,-6]
case_date <-select(case,set_id,patient_index_date,sepsis_type)
control <- merge(control,case_date,by = "set_id")
df <- bind_rows(case,control)
df <- df %>% filter( case == 0)
df <- select(df,patient_id,patient_index_date)
df191 <- df %>% filter (patient_index_date < as.Date("2019-07-01") & patient_index_date >= as.Date("2019-01-01"))
df192 <- df %>% filter (patient_index_date < as.Date("2020-01-01") & patient_index_date >= as.Date("2019-07-01"))
df201 <- df %>% filter (patient_index_date < as.Date("2020-07-01") & patient_index_date >= as.Date("2020-01-01"))
df202 <- df %>% filter (patient_index_date < as.Date("2021-01-01") & patient_index_date >= as.Date("2020-07-01"))
df211 <- df %>% filter (patient_index_date < as.Date("2021-07-01") & patient_index_date >= as.Date("2021-01-01"))
df212 <- df %>% filter (patient_index_date < as.Date("2022-01-01") & patient_index_date >= as.Date("2021-07-01"))
df221 <- df %>% filter (patient_index_date < as.Date("2022-07-01") & patient_index_date >= as.Date("2022-01-01"))

write_csv(df191, here::here("output", "control_id_191.csv"))
write_csv(df192, here::here("output", "control_id_192.csv"))
write_csv(df201, here::here("output", "control_id_201.csv"))
write_csv(df202, here::here("output", "control_id_202.csv"))
write_csv(df211, here::here("output", "control_id_211.csv"))
write_csv(df212, here::here("output", "control_id_212.csv"))
write_csv(df221, here::here("output", "control_id_221.csv"))

