# Load libraries & custom functions ---
library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)



# Set input and output directories
input_dir <- here::here("output")
output_dir <- here::here("output", "processed")

# Ensure output directory exists
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# List all input files
input_files <- c("input_control_uti_abvar.csv")

# Function to process data
process_data <- function(input_file) {
  # Read file
df <- read_csv(file.path(input_dir, input_file))

df$ab_frequency = case_when(
  df$ab_prescriptions == 0 ~ "0",
  df$ab_prescriptions == 1 ~ "1",
  df$ab_prescriptions >1 & df$ab_prescriptions <4 ~ "2-3",
  df$ab_prescriptions > 3 ~ ">3",)

df$ab_treatment = case_when(
  df$ab_prescriptions == 0 ~ "FALSE",
  df$ab_prescriptions > 0 ~ "TRUE")

df$ab_history_freq = case_when(
  df$ab_history == 0 ~ "0",
  df$ab_history == 1 ~ "1",
  df$ab_history >1 & df$ab_history <4 ~ "2-3",
  df$ab_history > 3 ~ ">3",)


df$cancer_comor<- ifelse(df$cancer_comor == 1L, 2L, 0L)
df$cardiovascular_comor <- ifelse(df$cardiovascular_comor == 1L, 1L, 0L)
df$chronic_obstructive_pulmonary_comor <- ifelse(df$chronic_obstructive_pulmonary_comor == 1L, 1L, 0)
df$heart_failure_comor <- ifelse(df$heart_failure_comor == 1L, 1L, 0L)
df$connective_tissue_comor <- ifelse(df$connective_tissue_comor == 1L, 1L, 0L)
df$dementia_comor <- ifelse(df$dementia_comor == 1L, 1L, 0L)
df$diabetes_comor <- ifelse(df$diabetes_comor == 1L, 1L, 0L)
df$diabetes_complications_comor <- ifelse(df$diabetes_complications_comor == 1L, 2L, 0L)
df$hemiplegia_comor <- ifelse(df$hemiplegia_comor == 1L, 2L, 0L)
df$hiv_comor <- ifelse(df$hiv_comor == 1L, 6L, 0L)
df$metastatic_cancer_comor <- ifelse(df$metastatic_cancer_comor == 1L, 6L, 0L)
df$mild_liver_comor <- ifelse(df$mild_liver_comor == 1L, 1L, 0L)
df$mod_severe_liver_comor <- ifelse(df$mod_severe_liver_comor == 1L, 3L, 0L)
df$mod_severe_renal_comor <- ifelse(df$mod_severe_renal_comor == 1L, 2L, 0L)
df$mi_comor <- ifelse(df$mi_comor == 1L, 1L, 0L)
df$peptic_ulcer_comor <- ifelse(df$peptic_ulcer_comor == 1L, 1L, 0L)
df$peripheral_vascular_comor <- ifelse(df$peripheral_vascular_comor == 1L, 1L, 0L)

## total charlson for each patient 
charlson=c("cancer_comor","cardiovascular_comor","chronic_obstructive_pulmonary_comor",
           "heart_failure_comor","connective_tissue_comor", "dementia_comor",
           "diabetes_comor","diabetes_complications_comor","hemiplegia_comor",
           "hiv_comor","metastatic_cancer_comor" ,"mild_liver_comor",
           "mod_severe_liver_comor", "mod_severe_renal_comor", "mi_comor",
           "peptic_ulcer_comor" , "peripheral_vascular_comor" )

df$charlson_score=rowSums(df[charlson])

## Charlson - as a catergorical group variable
df <- df %>%
  mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                 charlson_score >2 & charlson_score <=4 ~ 3,
                                 charlson_score >4 & charlson_score <=6 ~ 4,
                                 charlson_score >=7 ~ 5,
                                 charlson_score == 0 ~ 1))

df$charlsonGrp <- as.factor(df$charlsonGrp)
df$charlsonGrp <- factor(df$charlsonGrp, 
                                 labels = c("zero", "low", "medium", "high", "very high"))

  # Save final dataset
  saveRDS(df, file.path(output_dir, sub("\\.csv", ".rds", basename(input_file))))
}

# Apply function to each file
lapply(input_files, process_data)