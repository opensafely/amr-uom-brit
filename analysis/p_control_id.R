# Load necessary packages
library(tidyverse)
library(lubridate)
library(here)

# Set seed for reproducibility
set.seed(1234)

# Read in dataset
df <- read_csv(here::here("output", "input_p_control_2.csv"))

# Generate sequence of dates
date_seq <- seq.Date(from = as.Date("2019-01-01"), to = as.Date("2023-03-31"), by = "day")

# Generate random patient_index_dates that cover all months within the defined time period
df$patient_index_date <- sample(date_seq, nrow(df), replace = TRUE)

# Format patient_index_date to match your format
df$patient_index_date <- as.Date(df$patient_index_date, format = "%Y%m%d")

# Select only patient_id and patient_index_date
df <- df %>% select(patient_id, patient_index_date)

# Write to new csv
write_csv(df, here::here("output", "p_control_id.csv"))
