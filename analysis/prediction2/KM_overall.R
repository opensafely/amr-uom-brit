# Load the libraries
library(here)
library(dplyr)
library(survival)
library(ggplot2)
library(tidyverse)
library(survminer)
library(lubridate)
library(ggsci)

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

# Loop through each infection column
for (col_name in infection_columns) {
  # Filter data for the current infection column
  data_infection <- data %>% filter(!!sym(col_name))
  
  # Fit survival curves for each year within the filtered data
  surv_fit <- survfit(Surv(TEVENT, EVENT) ~ year, data = data_infection)
  
  # Plot the survival curves using ggsurvplot
  Figure_infection <- ggsurvplot(
    surv_fit,
    conf.int = TRUE,
    palette = "jco",
    legend.title = "Year",
    legend.labs = c("2019", "2020", "2021", "2022", "2023"),
    xlab = "Time (days)",
    ylab = "Survival probability",
    title = paste("Survival Curves for", col_name, "Patients by Year"),
     # Add p-value and tervals
    pval = TRUE,
     # Add risk table
    risk.table = TRUE,
    tables.height = 0.2,
    tables.theme = theme_cleantable(),
  )
  Figure_infection <- Figure_infection$plot+
  # Customize the confidence interval and y-axis range
  scale_y_continuous(limits = c(0.90, 1)) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white")
  ) + scale_color_jco()
  
  # Save the plot using ggsave with the plot argument
  filename <- paste0(col_name, "_survival_plot_by_year.jpeg")
  ggsave(filename = here::here("output", filename), plot = Figure_infection, dpi = 700)
}
