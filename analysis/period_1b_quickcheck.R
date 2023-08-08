library(dplyr)
library(readr)
library(lubridate)
library(here)


extract_data <- function(file_name) {
  ## read all data with default col_types 
  data_extracted <-
    read_csv(
      file_name,
      col_types = cols_only(
        patient_id = col_integer(),
        # dates
        patient_index_date = col_date(format = ""),
        emergency_admission_date = col_date(format = ""),
        died_any_date = col_date(format = ""),
        ab_date_next = col_date(format = ""),
        # covid binary indicator
        covid_6weeks = col_logical(),
        # infection indicator
        has_uti = col_logical(),
        has_urti = col_logical(),
        has_lrti = col_logical(),
        has_sinusitis = col_logical(),
        has_ot_externa = col_logical(),
        has_otmedia = col_logical(),
        has_chronic_respiratory_disease = col_logical(),
        # antibiotic related indicator
        ab_30d_next = col_logical(),
        ab_30d = col_logical()
      )
    )
  data_extracted
}

data <- extract_data(here::here("output", "input_period_1b.csv"))

# 1.Count the total number of rows in the dataset
cat("Total number of rows in the dataset:", nrow(data), "\n")

# 2. Count the number of antibiotic users in the dataset (assuming an antibiotic user is defined by a non-NA patient_index_date)
cat("Number of antibiotic users (non-NA patient_index_date):", sum(!is.na(data$patient_index_date)), "\n")

# 3. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 4. Print the number of patients with infection_indicator being TRUE
cat("Number of patients with infection record:", sum(data$infection_indicator, na.rm = TRUE), "\n")

# 5. Print the number of patients where covid_6weeks is FALSE
cat("Number of patients without covid-19 positive record in six weeks:", sum(!data$covid_6weeks, na.rm = TRUE), "\n")

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

# Print a frequency table of TEVENT
frequency_table <- table(data$TEVENT)
frequency_df <- as.data.frame(frequency_table)
write_csv(frequency_df, here::here("output", "period_1b_quickcheck.csv"))
