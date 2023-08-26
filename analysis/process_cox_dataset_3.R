library(dplyr)
library(readr)
library(lubridate)
library(here)
library(purrr)
library(tidyverse)
library(stringr)


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
        # demographics
        age = col_integer(),
        sex = col_character(),
        region = col_character(),
        imd = col_number(),
        bmi = col_character(),
        ethnicity = col_number(),
        smoking_status_comb = col_character(),
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
        # cci
        cancer_comor = col_logical(),
        cardiovascular_comor = col_logical(),
        chronic_obstructive_pulmonary_comor = col_logical(),
        heart_failure_comor = col_logical(),
        connective_tissue_comor = col_logical(),
        dementia_comor = col_logical(),
        diabetes_comor = col_logical(),
        diabetes_complications_comor = col_logical(),
        hemiplegia_comor = col_logical(),
        hiv_comor = col_logical(),
        metastatic_cancer_comor = col_logical(),
        mild_liver_comor = col_logical(),
        mod_severe_liver_comor = col_logical(),
        mod_severe_renal_comor = col_logical(),
        mi_comor = col_logical(),
        peptic_ulcer_comor = col_logical(),
        peripheral_vascular_comor = col_logical(),
        # antibiotic related indicator
        ab_30d_next = col_logical(),
        ab_30d = col_logical()
      )
    )
  data_extracted <- data_extracted %>%
    mutate(
      cancer_comor = ifelse(cancer_comor == 1L, 2L, 0L),
      cardiovascular_comor = ifelse(cardiovascular_comor == 1L, 1L, 0L),
      chronic_obstructive_pulmonary_comor = ifelse(chronic_obstructive_pulmonary_comor == 1L, 1L, 0),
      heart_failure_comor = ifelse(heart_failure_comor == 1L, 1L, 0L),
      connective_tissue_comor = ifelse(connective_tissue_comor == 1L, 1L, 0L),
      dementia_comor = ifelse(dementia_comor == 1L, 1L, 0L),
      diabetes_comor = ifelse(diabetes_comor == 1L, 1L, 0L),
      diabetes_complications_comor = ifelse(diabetes_complications_comor == 1L, 2L, 0L),
      hemiplegia_comor = ifelse(hemiplegia_comor == 1L, 2L, 0L),
      hiv_comor = ifelse(hiv_comor == 1L, 6L, 0L),
      metastatic_cancer_comor = ifelse(metastatic_cancer_comor == 1L, 6L, 0L),
      mild_liver_comor = ifelse(mild_liver_comor == 1L, 1L, 0L),
      mod_severe_liver_comor = ifelse(mod_severe_liver_comor == 1L, 3L, 0L),
      mod_severe_renal_comor = ifelse(mod_severe_renal_comor == 1L, 2L, 0L),
      mi_comor = ifelse(mi_comor == 1L, 1L, 0L),
      peptic_ulcer_comor = ifelse(peptic_ulcer_comor == 1L, 1L, 0L),
      peripheral_vascular_comor = ifelse(peripheral_vascular_comor == 1L, 1L, 0L),
      charlson_score = rowSums(
        select(
          .,
          cancer_comor, cardiovascular_comor, chronic_obstructive_pulmonary_comor,
          heart_failure_comor, connective_tissue_comor, dementia_comor,
          diabetes_comor, diabetes_complications_comor, hemiplegia_comor,
          hiv_comor, metastatic_cancer_comor, mild_liver_comor,
          mod_severe_liver_comor, mod_severe_renal_comor, mi_comor,
          peptic_ulcer_comor, peripheral_vascular_comor
        )
      ),
      charlsonGrp = case_when(
        charlson_score > 0 & charlson_score <= 2 ~ "low",
        charlson_score > 2 & charlson_score <= 4 ~ "medium",
        charlson_score > 4 & charlson_score <= 6 ~ "high",
        charlson_score >= 7 ~ "very high",
        charlson_score == 0 ~ "zero"
      )
    ) %>%
    mutate(charlsonGrp = as.factor(charlsonGrp)) %>%
    select(-cancer_comor, -cardiovascular_comor, -chronic_obstructive_pulmonary_comor,
           -heart_failure_comor, -connective_tissue_comor, -dementia_comor,
           -diabetes_comor, -diabetes_complications_comor, -hemiplegia_comor,
           -hiv_comor, -metastatic_cancer_comor, -mild_liver_comor,
           -mod_severe_liver_comor, -mod_severe_renal_comor, -mi_comor,
           -peptic_ulcer_comor, -peripheral_vascular_comor)
  
  return(data_extracted)
}

process_data <- function(input_file, data) {
  col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")
  df <- read.csv(input_file) %>%
    mutate_at(all_of(col), ~replace(., is.na(.), 0)) %>%
    mutate(total_ab_3yr = rowSums(select(., all_of(col))),
           ab_3yr = as.integer(total_ab_3yr > 0),
           across(all_of(col), ~as.integer(. > 0)),
           ab_types_3yr = rowSums(select(., all_of(col)) > 0),
           ab_types_3yr = if_else(is.na(ab_types_3yr), 0, ab_types_3yr)) %>%
    select(patient_id, total_ab_3yr, ab_types_3yr)
  
  dt <- left_join(data, df, by = "patient_id")
  
  saveRDS(dt, "processed_data.rds")
  
  return(dt)
}


# Vector of file names
file_names <- paste0(here::here("output", "input_period_3"), letters[1:20], ".csv")

# Process and combine all files
combined_data <- purrr::map_dfr(file_names, function(file) {
  data <- extract_data(file)
  processed_data <- process_data(file, data)
  return(processed_data)
})

# Save the combined dataset
saveRDS(combined_data, here::here("output", "processed_data_3.rds"))
