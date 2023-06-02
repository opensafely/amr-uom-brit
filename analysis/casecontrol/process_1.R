library("dplyr")
library("tidyverse")
library("lubridate")
library("ggsci")


rm(list=ls())
setwd(here::here("output"))

col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        covid_6weeks = col_number(),
                        uti_record = col_number(),
                        lrti_record = col_number(),
                        urti_record = col_number(),
                        sinusitis_record = col_number(),
                        ot_externa_record = col_number(),
                        ot_media_record = col_number(),
                        pneumonia_record = col_number(),
                        has_outcome_1yr = col_number(),    
                        patient_id = col_number()
)


df <- read_csv("input_case.csv",
                col_types = col_spec)

df <- df %>% filter(has_outcome_1yr==0)

df1 <- df %>% filter(patient_index_date <= as.Date("2019-06-30"))


record_vars <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

for (var in record_vars) {
  filtered_df <- df1 %>% 
    filter(!!sym(paste0(var, "_record")) == 1) %>%
    select(patient_id, patient_index_date,age,sex)
  write_csv(filtered_df, here::here("output", paste0("case_1_", var, ".csv")))
}


col_spec1 <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        uti_record = col_number(),
                        lrti_record = col_number(),
                        urti_record = col_number(),
                        sinusitis_record = col_number(),
                        ot_externa_record = col_number(),
                        ot_media_record = col_number(),
                        pneumonia_record = col_number(),
                        patient_id = col_number()
)


dfcontrol1 <- read_csv("input_control_1.csv",
                col_types = col_spec1)

for (var in record_vars) {
  filtered_df <- dfcontrol1 %>%
    filter(!!sym(paste0(var, "_record")) == 1) %>%
    select(patient_id, patient_index_date,age,sex)
  write_csv(filtered_df, here::here("output", paste0("control_1_", var, ".csv")))
}
