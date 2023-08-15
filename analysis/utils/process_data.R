## ###########################################################

##  This script:
## - Contains a general function that is used to process data that is extracted
##   for table 1

## linda.nab@thedatalab.com - 20220328
## ###########################################################

# Load libraries & functions ---
library(here)
library(dplyr)
# Function fct_case_when needed inside process_data
source(here("analysis", "utils", "fct_case_when.R"))

# Function ---
## Processes the extracted data in extract_data(): changes levels of factors in 
## data
## args:
## - data_extracted: a data.frame extracted by function extract_data() in 
##   ./analysis/utils/extract_data.R
## output:
## data.frame of data_extracted with factor columns with correct levels
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