# Load libraries
library("dplyr")
library("tidyverse")
library("lubridate")
library("here")

# Function to define column specifications and load the datasets
load_dataset <- function(file_path) {
  col_spec <- cols_only(
    patient_index_date = col_date(format = ""),
    age = col_number(),
    sex = col_character(),
    set_id = col_number(),
    case = col_number(),
    patient_id = col_number()
  )

  df <- read_csv(here(file_path), col_types = col_spec)
  return(df)
}

# Function to load and prepare the second and third dataset
load_prepared_df <- function(file_path, selected_vars) {
  df <- readRDS(here(file_path)) %>% select(one_of(selected_vars))
  return(df)
}

# Function to merge datasets
merge_data <- function(df.1, df.2, df.3) {
  merged_data <- df.1 %>%
    left_join(df.2, by = c("patient_id", "patient_index_date")) %>%
    left_join(df.3, by = c("patient_id", "patient_index_date"))
  
  return(merged_data)
}

# Main function
main <- function(condition) {
  df_cases <- load_dataset(paste0("output/matched_cases_", condition, ".csv"))
  df_matches <- load_dataset(paste0("output/matched_matches_", condition, ".csv"))

  df_ab_vars <- c("patient_index_date", "patient_id","ab_history", "charlson_score", "charlsonGrp","Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
  df_oth_vars <- c("patient_index_date", "patient_id", "region", "imd", "ethnicity", "bmi", "smoking_status_comb", "ckd_rrt")

  df_cases_ab <- load_prepared_df(paste0("output/processed/input_case_", condition, "_abvar.rds"), df_ab_vars)
  df_cases_oth <- load_prepared_df(paste0("output/processed/input_case_", condition, "_othvar.rds"), df_oth_vars)

  df_matches_ab <- load_prepared_df(paste0("output/processed/input_control_", condition, "_abvar.rds"), df_ab_vars)
  df_matches_oth <- load_prepared_df(paste0("output/processed/input_control_", condition, "_othvar.rds"), df_oth_vars)

  df_cases <- merge_data(df_cases, df_cases_ab, df_cases_oth)
  df_matches <- merge_data(df_matches, df_matches_ab, df_matches_oth)

  # Combine datasets using rbind
  merged_data <- rbind(df_cases, df_matches)

  # Save the merged data to a new RDS file using saveRDS
  saveRDS(merged_data, here("output", "processed", paste0("model_", condition, "_ab.rds")))
}

# Call the main function for each condition
main("uti")
main("urti")
main("lrti")
