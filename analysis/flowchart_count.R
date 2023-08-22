# Load necessary packages
library(tidyverse)
library(lubridate)
library(here)


# Read in dataset
data <- read_csv(here::here("output", "input_flowchart.csv"))

# Frequency tables for the specified columns

# For has_follow_up
has_follow_up_freq <- table(data$has_follow_up)
cat("Frequency Table for has_follow_up:\n")
print(has_follow_up_freq)
cat("\n")

# For age
age_freq <- table(data$age)
cat("Frequency Table for age:\n")
print(age_freq)
cat("\n")

# For sex
sex_freq <- table(data$sex)
cat("Frequency Table for sex:\n")
print(sex_freq)
cat("\n")

# For stp
stp_freq <- table(data$stp)
cat("Frequency Table for stp:\n")
print(stp_freq)
cat("\n")

# For index_of_multiple_deprivation
index_of_multiple_deprivation_freq <- table(data$index_of_multiple_deprivation)
cat("Frequency Table for index_of_multiple_deprivation:\n")
print(index_of_multiple_deprivation_freq)

# Calculate and print row count
row_count <- nrow(data)
cat("Number of rows in the dataset:", row_count)

row_count <- as.data.frame(row_count)
# Write to new csv
write_csv(row_count, here::here("output", "flowchart_count.csv"))
