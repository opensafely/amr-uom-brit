# Load the necessary libraries
library(readr)
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)

# Define the list of infections
infections <- c("uti", "lrti", "urti")

# Define date_gap labels
date_gap_labels <- c("0-2 days", "3-4 days", "5-6 days", "7-8 days", "9-10 days", "11-12 days", "13-14 days", "15-16 days", "17-18 days", "19-20 days", "21-22 days", "23-24 days", "25-26 days", "27-28 days", "29-30 days")

# Iterate over each infection in the list
for (infection in infections) {
  
  # Load data for the current infection
  case_infection <- readRDS(here::here("output", "processed", paste0("case_withdate_",infection,".rds")))
  control_infection <- readRDS(here::here("output", "processed",paste0("control_withdate_",infection,".rds")))
  
  df <- rbind(case_infection, control_infection)

  # Convert date columns to Date type
  df$patient_index_date <- as.Date(df$patient_index_date)
  df$infection_date <- as.Date(df$infection_date)
  
  # Calculate date_gap in days
  df$date_gap <- df$patient_index_date - df$infection_date

# Define date_gap labels
date_gap_labels <- c("0-2 days", "3-4 days", "5-6 days", "7-8 days", "9-10 days", "11-12 days", "13-14 days", "15-16 days", "17-18 days", "19-20 days", "21-22 days", "23-24 days", "25-26 days", "27-28 days", "29-30 days")

# Define date_gap breaks
date_gap_breaks <- c(0, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31)

# Classify date_gap
df$date_gap <- cut(as.numeric(df$date_gap), 
                   breaks = date_gap_breaks, 
                   labels = date_gap_labels, 
                   include.lowest = TRUE, 
                   right = FALSE)

# Replace NA in date_gap with "0-2 days"
df$date_gap <- replace_na(df$date_gap, "0-2 days")


  df$ab_treatment <- df %>% mutate() 
  df$ab_treatment<-  case_when(
    df$ab_frequency == "0" ~ "FALSE",
    df$ab_frequency == "1" ~ "TRUE",
    df$ab_frequency == "2-3" ~ "TRUE",
    df$ab_frequency == ">3" ~ "TRUE")
  
  df$case=as.numeric(df$case) #1/0
  df$set_id=as.factor(df$set_id)#pair id
  df$charlsonGrp= relevel(as.factor(df$charlsonGrp), ref="zero")
  df$patient_index_date <- as.Date(df$patient_index_date, format = "%Y%m%d")

  # Create exposure column
  df$exposure <- ifelse(df$ab_treatment == "TRUE", paste0("ab ", df$date_gap), paste0("non-ab ", df$date_gap))

  df$exposure= relevel(as.factor(df$exposure), ref="non-ab 0-2 days")
  # List to store data frame

  # Generate frequency table
  frequency_table <- df %>%
    group_by(exposure, case) %>%
    summarise(count = n(), .groups = "drop")

  # Write the frequency table to a CSV file
  write.csv(frequency_table, file = here::here("output", paste0("table2_",infection,".csv")))
}
