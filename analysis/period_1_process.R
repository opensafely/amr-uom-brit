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

data <- extract_data(here::here("output", "input_period_1.csv"))


# 2. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 3. Print the number of patients with infection_indicator being TRUE
print(sum(data$infection_indicator, na.rm = TRUE))

# 4. Filter out those with infection_indicator being FALSE
data <- filter(data, infection_indicator)

# 5. Print the number of patients where covid_6weeks is FALSE
print(sum(!data$covid_6weeks, na.rm = TRUE))

# 6. Remove the patients where covid_6weeks is TRUE
data <- filter(data, !covid_6weeks)

# 7. Create the EVENT column
data <- data %>% 
  mutate(EVENT = ifelse(!is.na(emergency_admission_date), 1, 0))

# 8. Print the number of patients where EVENT is 1 and 0
print(table(data$EVENT))


# 9. Create the columns TtoAB, TtoD, TtoAE, and TtoEND
data <- data %>%
  mutate(
    TtoAB = ifelse(!is.na(ab_date_2), ab_date_2 - patient_index_date, NA_real_),
    TtoD = ifelse(!is.na(died_any_date), died_any_date - patient_index_date, NA_real_),
    TtoAE = ifelse(!is.na(emergency_admission_date), emergency_admission_date - patient_index_date, NA_real_),
    TtoEND = as.Date("2020-03-25") - patient_index_date
  )

# 10. Create the TEVENT column
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

# Continue from the previous code

# Count and print the specified criteria
cat("Number of ab_after TRUE:", sum(data$ab_after, na.rm = TRUE), "\n")
cat("Number of non-NA ab_date_2:", sum(!is.na(data$ab_date_2)), "\n")
cat("Number of non-NA ab_date_3:", sum(!is.na(data$ab_date_3)), "\n")
cat("Number of non-NA ab_date_4:", sum(!is.na(data$ab_date_4)), "\n")
cat("Number of non-NA ab_date_5:", sum(!is.na(data$ab_date_5)), "\n")

# Selecting the desired columns
df_subset <- data %>%
  select(patient_id, patient_index_date, TEVENT, EVENT, has_chronic_respiratory_disease, has_uti, 
         has_urti, has_lrti, has_sinusitis, has_ot_externa, has_otmedia)

# Save the subset dataframe to a CSV file
write_csv(df_subset, here::here("output", "period_1a.csv"))