## ###########################################################

##  This script:
##  - Imports data extracted from the cohort extractor (wave1, wave2, wave3)
##  - Formats column types and levels of factors in data
##  - Saves processed data in ./output/processed/input_wave*.rds

## linda.nab@thedatalab.com - 2022024
## ###########################################################

# Load libraries & custom functions ---
library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)

types <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")
input_files <- lapply(1:9, function(i) {
  paste0("input_control_", i, "_", types, "_var_2.csv")
})
input_files <- unlist(input_files)

process_data <- function(input_files, output_file) {
  # Define column names
  col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")

  # Check if all input files exist
  if (all(file.exists(here::here("output",input_files)))) {
    # Read all files
    df_list <- lapply(input_files, function(input_file) {
      df <- read_csv(here::here("output",input_file))
      
      # Data processing...
        # Data processing
    df[col] <- df[col] %>% mutate_all(~replace(., is.na(.), 0)) 
    df$total_ab_6w <- rowSums(df[col])
    df$ab_6w <- ifelse(df$total_ab_6w > 0, 1, 0)
    df[col] <- ifelse(df[col] > 0, 1, 0)
    df$ab_types_6w <- rowSums(df[col] > 0)
    df <- df[!names(df) %in% col]
    df$ab_types_6w <- ifelse(is.na(df$ab_types_6w), 0, df$ab_types_6w) 

    df$ab_frequency = case_when(
    df$ab_prescriptions == 0 ~ "0",
    df$ab_prescriptions == 1 ~ "1",
    df$ab_prescriptions >1 & df$ab_prescriptions <4 ~ "2-3",
    df$ab_prescriptions > 3 ~ ">3",)

    df$ab_type_num = case_when(
    df$ab_types_6w == 0 ~ "0",
    df$ab_types_6w == 1 ~ "1",
    df$ab_types_6w >1 & df$ab_types_6w <4 ~ "2-3",
    df$ab_types_6w > 3 ~ ">3",)
    #... rest of your data processing steps...
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
        
    df
    })
    
    # Combine all data frames into one
    df_combined <- bind_rows(df_list)

    # Save final dataset
    saveRDS(df_combined, output_file)
  } else {
    stop(paste("Some input files do not exist:", input_files[!file.exists(here::here("output",input_files))]))
  }
}

types <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")
for (type in types) {
  input_files_type <- grep(type, input_files, value = TRUE)
  output_file <- paste0("output/processed/input_control_", type, "_var_2.rds")
  process_data(input_files_type, output_file)
}
