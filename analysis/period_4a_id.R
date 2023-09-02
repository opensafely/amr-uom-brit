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
        ab_date_2 = col_date(format = ""),
        ab_date_3 = col_date(format = ""),
        ab_date_4 = col_date(format = ""),
        ab_date_5 = col_date(format = ""),
        ab_date_6 = col_date(format = ""),
        ab_date_7 = col_date(format = ""),
        ab_date_8 = col_date(format = ""),
        ab_date_9 = col_date(format = ""),
        ab_date_10 = col_date(format = ""),
        ab_date_11 = col_date(format = ""),
        ab_date_12 = col_date(format = ""),
        ab_date_13 = col_date(format = ""),
        ab_date_14 = col_date(format = ""),
        ab_date_15 = col_date(format = ""),
        ab_date_16 = col_date(format = ""),
        ab_date_17 = col_date(format = ""),
        ab_date_18 = col_date(format = ""),
        ab_date_19 = col_date(format = ""),
        ab_date_20 = col_date(format = ""),
        ab_date_21 = col_date(format = ""),
        ab_date_22 = col_date(format = ""),
        ab_date_23 = col_date(format = ""),
        ab_date_24 = col_date(format = ""),
        # demographics
        age = col_integer(),
        sex = col_character(),
        region = col_character(),
        imd = col_number(),
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
        ab_30d_after = col_logical(),
        ab_30d = col_logical(),
        ab_after = col_logical()
      )
    )
  data_extracted
}

data <- extract_data(here::here("output", "input_period_4.csv"))

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

# 8. Create the columns TtoAB, TtoD, TtoAE, and TtoEND
data <- data %>%
  mutate(
    TtoAB = ifelse(!is.na(ab_date_2), ab_date_2 - patient_index_date, NA_real_),
    TtoD = ifelse(!is.na(died_any_date), died_any_date - patient_index_date, NA_real_),
    TtoAE = ifelse(!is.na(emergency_admission_date), emergency_admission_date - patient_index_date, NA_real_),
    TtoEND = as.Date("2023-06-30") - patient_index_date
  )

# 9. Create the TEVENT column
data <- data %>%
  rowwise() %>%
  mutate(
    TEVENT = min(c(TtoAB, TtoD, TtoAE, TtoEND), na.rm = TRUE)
  ) %>%
  ungroup()

data <- data %>%
  mutate(
    TEVENT = pmin(TEVENT, 30)
  )

head(data, n = 10)

# Count and print the specified criteria
cat("Number of patients with more than one antibiotic prescription:", sum(data$ab_after, na.rm = TRUE), "\n")

# Loop from date_2 to date_24
for(i in 2:24) {
  date_col <- paste0("ab_date_", i)
  cat(sprintf("Number of patients with %s:", date_col), sum(!is.na(data[[date_col]])), "\n")
}

# Selecting the desired columns
df_subset <- data %>%
  select(patient_id, patient_index_date)

# Save the subset dataframe to a CSV file
write_csv(df_subset, here::here("output", "period_4a_id.csv"))
