# Load necessary packages
library(tidyverse)
library(lubridate)
library(here)


# Read in dataset
data <- read_csv(here::here("output", "input_flowchart.csv"))

# Function to print frequency table
print_freq_table <- function(data, column_name) {
  freq_table <- table(data[[column_name]])
  cat(paste("Frequency Table for", column_name, ":\n"))
  print(freq_table)
  cat("\n")
  return(data)
}

# Process data and print frequency tables

# For has_follow_up
data %>% 
  print_freq_table("has_follow_up") %>%
  
  # Filter out rows where has_follow_up = 0
  filter(has_follow_up != 0) %>%
  
  # For age: print frequency table and then filter out ages not in [18, 110]
  mutate(age_group = ifelse(age >= 18 & age <= 110, "18-110", "Other")) %>%
  print_freq_table("age_group") %>%
  filter(age_group == "18-110") %>%
  
  # For sex: print frequency table and then filter out sex "I" or "U"
  print_freq_table("sex") %>%
  filter(!(sex %in% c("I", "U"))) %>%
  
  # For stp: print frequency table
  print_freq_table("stp") %>%
  
  # For index_of_multiple_deprivation
  print_freq_table("index_of_multiple_deprivation")

# Calculate and print row count
row_count <- nrow(data)
cat("Number of rows in the original dataset:", row_count)

row_count_df <- tibble(Row_Count = row_count)
# Write to new csv
write_csv(row_count_df, here::here("output", "flowchart_count.csv"))