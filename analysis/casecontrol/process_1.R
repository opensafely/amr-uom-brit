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
df2 <- df %>% filter(patient_index_date > as.Date("2019-06-30") & patient_index_date <= as.Date("2019-12-31"))
df3 <- df %>% filter(patient_index_date > as.Date("2019-12-31") & patient_index_date <= as.Date("2020-06-30"))
df4 <- df %>% filter(patient_index_date > as.Date("2020-06-30") & patient_index_date <= as.Date("2020-12-31"))
df5 <- df %>% filter(patient_index_date > as.Date("2020-12-31") & patient_index_date <= as.Date("2021-06-30"))
df6 <- df %>% filter(patient_index_date > as.Date("2021-06-30") & patient_index_date <= as.Date("2021-12-31"))
df7 <- df %>% filter(patient_index_date > as.Date("2021-12-31") & patient_index_date <= as.Date("2022-06-30"))
df8 <- df %>% filter(patient_index_date > as.Date("2022-06-30") & patient_index_date <= as.Date("2022-12-31"))
df9 <- df %>% filter(patient_index_date > as.Date("2022-12-31") & patient_index_date <= as.Date("2023-03-31"))

df_list <- list(df1, df2, df3, df4, df5, df6, df7, df8, df9)

record_vars <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

for (i in 1:length(df_list)) {
  for (var in record_vars) {
    filtered_df <- df_list[[i]] %>% 
      filter(!!sym(paste0(var, "_record")) == 1) %>%
      select(patient_id, patient_index_date, age, sex)
    write_csv(filtered_df, here::here("output", paste0("case_", i, "_", var, ".csv")))
  }
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

dfcontrol2 <- read_csv("input_control_2.csv",
                      col_types = col_spec1)

# Loop over the variables
for (var in record_vars) {
  filtered_df <- dfcontrol2 %>%
    filter(!!sym(paste0(var, "_record")) == 1) %>%
    select(patient_id, patient_index_date,age,sex)
  write_csv(filtered_df, here::here("output", paste0("control_2_", var, ".csv")))
}

# The new column specifications
col_spec12 <- cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        uti_record = col_number(),
                        lrti_record = col_number(),
                        urti_record = col_number(),
                        sinusitis_record = col_number(),
                        ot_externa_record = col_number(),
                        ot_media_record = col_number(),
                        pneumonia_record = col_number(),
                        covid_6weeks = col_number(),
                        patient_id = col_number())

# Loop over control_3 to control_9
for (i in 3:9) {
  dfcontrol <- read_csv(paste0("input_control_", i, ".csv"), col_types = col_spec12)
  
  for (var in record_vars) {
    filtered_df <- dfcontrol %>%
      filter(covid_6weeks == 0) %>%
      filter(!!sym(paste0(var, "_record")) == 1) %>%
      select(patient_id, patient_index_date, age, sex)
    write_csv(filtered_df, here::here("output", paste0("control_", i, "_", var, ".csv")))
  }
}

