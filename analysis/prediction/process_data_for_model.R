

## Load libraries & custom functions

library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)
library(reshape2)
library(ggplot2)
library(survival)
library(rms)
## Load data

data <- readRDS(here::here("output", "processed_data.rds"))

## Process Data
fct_case_when <- function(...) {
  # uses dplyr::case_when but converts the output to a factor,
  # with factors ordered as they appear in the case_when's  ... argument
  args <- as.list(match.call())
  levels <- sapply(args[-1], function(f) f[[3]])  # extract RHS of formula
  levels <- levels[!is.na(levels)]
  factor(dplyr::case_when(...), levels=levels)
}


process_data <- function(data_extracted) {
  data_processed <-
    data_extracted %>%
    mutate(
      sex = fct_case_when(sex == "F" ~ "Female",
                          sex == "M" ~ "Male",
                          TRUE ~ NA_character_),
      # no missings should occur as only of
      # individuals with a female/male sex, data is extracted
      bmi = fct_case_when(
        bmi == "Underweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
        bmi == "Healthy range (18.5-24.9)" ~ "Healthy range (18.5-24.9 kg/m2)",
        bmi == "Overweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
        bmi == "Obese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
        bmi == "Obese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
        bmi == "Obese III (40+)" ~ "Obese III (40+ kg/m2)",
        TRUE ~ NA_character_
      ),
      
      ethnicity = fct_case_when(
        ethnicity == "1" ~ "White",
        ethnicity == "2" ~ "Mixed",
        ethnicity == "3" ~ "South Asian",
        ethnicity == "4" ~ "Black",
        ethnicity == "5" ~ "Other",
        ethnicity == "0" ~ "Unknown",
        TRUE ~ NA_character_ # no missings in real data expected 
        # (all mapped into 0) but dummy data will have missings (data is joined
        # and patient ids are not necessarily the same in both cohorts)
      ),
      
      smoking_status_comb = fct_case_when(
        smoking_status_comb == "N + M" ~ "Never and unknown",
        smoking_status_comb == "E" ~ "Former",
        smoking_status_comb == "S" ~ "Current",
        TRUE ~ NA_character_
      ),
      
      imd = fct_case_when(
        imd == "5" ~ "5 (least deprived)",
        imd == "4" ~ "4",
        imd == "3" ~ "3",
        imd == "2" ~ "2",
        imd == "1" ~ "1 (most deprived)",
        imd == "0" ~ NA_character_
      ),
      
      region = fct_case_when(
        region == "North East" ~ "North East",
        region == "North West" ~ "North West",
        region == "Yorkshire and The Humber" ~ "Yorkshire and the Humber",
        region == "East Midlands" ~ "East Midlands",
        region == "West Midlands" ~ "West Midlands",
        region == "East" ~ "East of England",
        region == "London" ~ "London",
        region == "South East" ~ "South East",
        region == "South West" ~ "South West",
        TRUE ~ NA_character_
      ))
  data_processed
}

data <- process_data(data)

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

# Relevel variables
data$region <- relevel(data$region, ref = "East of England")
data$imd <- relevel(data$imd, ref = "5 (least deprived)")
data$ethnicity <- relevel(data$ethnicity, ref = "White")
data$bmi <- relevel(data$bmi, ref = "Healthy range (18.5-24.9 kg/m2)")
data$bmi[is.na(data$bmi)] <- "Healthy range (18.5-24.9 kg/m2)"
data$smoking_status_comb <- relevel(data$smoking_status_comb, ref = "Never and unknown")
data$charlsonGrp <- relevel(data$charlsonGrp, ref = "zero")
data$imd <- factor(data$imd, levels = c(levels(data$imd), "Unknown"))
data$imd[is.na(data$imd)] <- "Unknown"
data$region <- factor(data$region, levels = c(levels(data$region), "Unknown"))
data$region[is.na(data$region)] <- "Unknown"
data <- data %>% filter(!is.na(sex))

# Reclassify total_ab_3yr
data$ab_3yr <- cut(data$total_ab_3yr, breaks = c(-Inf, 0, 1, 3, Inf), labels = c("0", "1", "2-3", "4+"), right = TRUE, include.lowest = TRUE)

data_output <- data %>% dplyr::select(EVENT,TEVENT,age,sex,region,imd,ethnicity,bmi,smoking_status_comb,charlsonGrp,ab_3yr,ab_30d,has_uti,has_urti,has_lrti,has_sinusitis,has_ot_externa,has_otmedia)

library(dplyr)

# Specify the columns of interest
columns_of_interest <- c("EVENT", "TEVENT", "age", "sex", "region", "imd", "ethnicity", "bmi", "smoking_status_comb", "charlsonGrp", "ab_3yr", "ab_30d")

# Calculate the number of missing values for the specified columns
missing_data_count <- data_output %>%
  select(all_of(columns_of_interest)) %>%
  summarise(across(everything(), ~sum(is.na(.))))

# Save to CSV
write_csv(missing_data_count, here::here("output", "missing_data_count.csv"))


saveRDS(data_output, here::here("output", "data_for_cox_model.rds"))
