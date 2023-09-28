## Load libraries & custom functions
library(here)
library(dplyr)
library(readr)

# Load data
data1 <- readRDS(here::here("output", "processed_data.rds"))
data2 <- readRDS(here::here("output", "processed_data_2.rds"))
data3 <- readRDS(here::here("output", "processed_data_3.rds"))
data4 <- readRDS(here::here("output", "processed_data_4.rds"))

# Combine data
data <- bind_rows(data1, data2, data3, data4)

# Randomly pick one row of each same patient_id
data <- data %>% group_by(patient_id) %>% sample_n(1) %>% ungroup()
print(paste("Number of patients after first sampling:", n_distinct(data$patient_id)))

# Remove rows with chronic respiratory disease and sample again
data <- data %>% filter(!has_chronic_respiratory_disease) %>% group_by(patient_id) %>% sample_n(1) %>% ungroup()
print(paste("Number of patients after removing chronic respiratory disease:", n_distinct(data$patient_id)))
# Exclude patients with covid_6weeks being TRUE and sample again
data <- data %>% filter(!covid_6weeks) %>% group_by(patient_id) %>% sample_n(1) %>% ungroup()
print(paste("Number of patients after excluding covid_6weeks:", n_distinct(data$patient_id)))
# Create the infection_indicator column and filter rows without infection_indicator, then sample again
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia) %>%
  filter(infection_indicator) %>% group_by(patient_id) %>% sample_n(1) %>% ungroup()
print(paste("Number of patients with infection indicator:", n_distinct(data$patient_id)))

# Write the final data to CSV
write_csv(data, here::here("output", "final_processed_data.csv"))