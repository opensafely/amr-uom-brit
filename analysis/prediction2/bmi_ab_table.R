################################################################################
# Part 1: LRTI model development process                                        #
################################################################################

library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)
library(reshape2)
library(ggplot2)
library(survival)
library(rms)
library(MASS)
library(Hmisc)

## Load data

input_data <- readRDS(here::here("output", "data_for_cox_model_all.rds"))

# Calculate frequency and percentages
frequency_and_percent <- input_data %>%
  count(bmi, ab_3yr) %>%
  group_by(ab_3yr) %>%
  mutate(percentage = n / sum(n) * 100)

# Print the table with frequencies and percentages
print(frequency_and_percent)

library(tidyr)

contingency_table_percentage <- frequency_and_percent %>%
  spread(key = ab_3yr, value = percentage, fill = 0) 

print(contingency_table_percentage)

write_csv(contingency_table_percentage, here::here("output", "bmi_and_ab_3yr.csv"))