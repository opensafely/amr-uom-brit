# Load the libraries
library(here)
library(dplyr)
library(survival)
library(ggplot2)
library(tidyverse)
library(survminer)
library(lubridate)

data <- readRDS(here::here("output", "processed_data.rds"))

# 2. Print the number of patients with chronic respiratory disease
cat("Number of patients with chronic respiratory disease:", sum(data$has_chronic_respiratory_disease, na.rm = TRUE), "\n")

# 3. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 4. Print the number of patients with infection_indicator being TRUE
cat("Number of patients with infection record:", sum(data$infection_indicator, na.rm = TRUE), "\n")

# 5. Print the number of patients where covid_6weeks is FALSE
cat("Number of patients without covid-19 positive record in six weeks:", sum(!data$covid_6weeks, na.rm = TRUE), "\n")

# Remove patients with chronic respiratory disease
data <- data %>% filter(!has_chronic_respiratory_disease)

# Remove patients without infection_indicator
data <- data %>% filter(infection_indicator)

# Exclude patients with covid_6weeks being TRUE
data <- data %>% filter(!covid_6weeks)


# 6. Create the EVENT column
data <- data %>% 
  mutate(EVENT = ifelse(!is.na(emergency_admission_date), 1, 0))

# 7. Print the number of patients where EVENT is 1 and 0
event_table <- table(data$EVENT)
cat("Number of patients where EVENT is 0:", event_table["0"], "\n")
cat("Number of patients where EVENT is 1:", event_table["1"], "\n")

# Create the variables

# TtoAB
data <- data %>%
  mutate(TtoAB = ifelse(!is.na(ab_date_next), as.numeric(ab_date_next - patient_index_date), NA))

# TtoD
data <- data %>%
  mutate(TtoD = ifelse(!is.na(died_any_date), as.numeric(died_any_date - patient_index_date), NA))

# TtoAE
data <- data %>%
  mutate(TtoAE = ifelse(!is.na(emergency_admission_date), as.numeric(emergency_admission_date - patient_index_date), NA))

# TtoEND
data <- data %>%
  mutate(TtoEND = as.numeric(as.Date("2020-03-25") - patient_index_date))

# Create TEVENT column
data <- data %>%
  rowwise() %>%
  mutate(TEVENT = min(c(TtoAB, TtoD, TtoAE, TtoEND), na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(TEVENT = ifelse(TEVENT > 30, 30, TEVENT))

data1 <- data

print("data_1 processed!")


data <- readRDS(here::here("output", "processed_data_2.rds"))

# 2. Print the number of patients with chronic respiratory disease
cat("Number of patients with chronic respiratory disease:", sum(data$has_chronic_respiratory_disease, na.rm = TRUE), "\n")

# 3. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 4. Print the number of patients with infection_indicator being TRUE
cat("Number of patients with infection record:", sum(data$infection_indicator, na.rm = TRUE), "\n")

# 5. Print the number of patients where covid_6weeks is FALSE
cat("Number of patients without covid-19 positive record in six weeks:", sum(!data$covid_6weeks, na.rm = TRUE), "\n")

# Remove patients with chronic respiratory disease
data <- data %>% filter(!has_chronic_respiratory_disease)

# Remove patients without infection_indicator
data <- data %>% filter(infection_indicator)

# Exclude patients with covid_6weeks being TRUE
data <- data %>% filter(!covid_6weeks)


# 6. Create the EVENT column
data <- data %>% 
  mutate(EVENT = ifelse(!is.na(emergency_admission_date), 1, 0))

# 7. Print the number of patients where EVENT is 1 and 0
event_table <- table(data$EVENT)
cat("Number of patients where EVENT is 0:", event_table["0"], "\n")
cat("Number of patients where EVENT is 1:", event_table["1"], "\n")

# Create the variables

# TtoAB
data <- data %>%
  mutate(TtoAB = ifelse(!is.na(ab_date_next), as.numeric(ab_date_next - patient_index_date), NA))

# TtoD
data <- data %>%
  mutate(TtoD = ifelse(!is.na(died_any_date), as.numeric(died_any_date - patient_index_date), NA))

# TtoAE
data <- data %>%
  mutate(TtoAE = ifelse(!is.na(emergency_admission_date), as.numeric(emergency_admission_date - patient_index_date), NA))

# TtoEND
data <- data %>%
  mutate(TtoEND = as.numeric(as.Date("2021-03-08") - patient_index_date))

# Create TEVENT column
data <- data %>%
  rowwise() %>%
  mutate(TEVENT = min(c(TtoAB, TtoD, TtoAE, TtoEND), na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(TEVENT = ifelse(TEVENT > 30, 30, TEVENT))

data2 <- data

print("data_2 processed!")


data <- readRDS(here::here("output", "processed_data_3.rds"))

# 2. Print the number of patients with chronic respiratory disease
cat("Number of patients with chronic respiratory disease:", sum(data$has_chronic_respiratory_disease, na.rm = TRUE), "\n")

# 3. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 4. Print the number of patients with infection_indicator being TRUE
cat("Number of patients with infection record:", sum(data$infection_indicator, na.rm = TRUE), "\n")

# 5. Print the number of patients where covid_6weeks is FALSE
cat("Number of patients without covid-19 positive record in six weeks:", sum(!data$covid_6weeks, na.rm = TRUE), "\n")

# Remove patients with chronic respiratory disease
data <- data %>% filter(!has_chronic_respiratory_disease)

# Remove patients without infection_indicator
data <- data %>% filter(infection_indicator)

# Exclude patients with covid_6weeks being TRUE
data <- data %>% filter(!covid_6weeks)


# 6. Create the EVENT column
data <- data %>% 
  mutate(EVENT = ifelse(!is.na(emergency_admission_date), 1, 0))

# 7. Print the number of patients where EVENT is 1 and 0
event_table <- table(data$EVENT)
cat("Number of patients where EVENT is 0:", event_table["0"], "\n")
cat("Number of patients where EVENT is 1:", event_table["1"], "\n")

# Create the variables

# TtoAB
data <- data %>%
  mutate(TtoAB = ifelse(!is.na(ab_date_next), as.numeric(ab_date_next - patient_index_date), NA))

# TtoD
data <- data %>%
  mutate(TtoD = ifelse(!is.na(died_any_date), as.numeric(died_any_date - patient_index_date), NA))

# TtoAE
data <- data %>%
  mutate(TtoAE = ifelse(!is.na(emergency_admission_date), as.numeric(emergency_admission_date - patient_index_date), NA))

# TtoEND
data <- data %>%
  mutate(TtoEND = as.numeric(as.Date("2023-06-30") - patient_index_date))

# Create TEVENT column
data <- data %>%
  rowwise() %>%
  mutate(TEVENT = min(c(TtoAB, TtoD, TtoAE, TtoEND), na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(TEVENT = ifelse(TEVENT > 30, 30, TEVENT))

data3 <- data

print("data_3 processed!")

data <- bind_rows(data1, data2, data3) %>% mutate(year = year(patient_index_date))

# Define a vector of the column names
infection_columns <- c("has_uti", "has_urti", "has_lrti", "has_sinusitis", "has_ot_externa", "has_otmedia")

fit_list <- list()

for (col_name in infection_columns) {
  for (year_val in unique(data$year)) {
    # Filter data based on the current year and infection column
    infection_data <- data %>% filter(year == year_val & get(col_name) == TRUE)
  
    # Fit survival curve for this subset of data
    fit <- survfit(Surv(TEVENT, EVENT) ~ 1, data = infection_data)
    fit_list[[paste0(col_name, "_", year_val)]] <- fit
  }
}

for (col_name in infection_columns) {
  plot_title <- tools::toTitleCase(sub("^has_", "", col_name))
  fits <- fit_list[grep(col_name, names(fit_list))]
  
  Figure1 <- ggsurvplot(
    fits, 
    conf.int = TRUE,
    palette = "jco",
    legend = "right",
    xlab = "Time (days)",
    ylab = "Survival probability",
    title = paste("Kaplan-Meier Survival Curve with Confidence Interval for", plot_title),
    risk.table = TRUE
  )
  
  # Save the plot
  filename <- paste0("KM_overall_by_", plot_title, "_with_CI.jpeg")
  ggsave(Figure1, dpi = 700, filename = filename, path = here::here("output"))
}
