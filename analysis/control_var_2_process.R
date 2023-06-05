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
utils_dir <- here("analysis", "utils")
source(paste0(utils_dir, "/process_data_2.R")) # function extract_data()

# Initialize variables for different types of data
types <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")

# Directory where input files are located
input_dir <- here::here("output")

# Create output directory if it doesn't exist
output_dir <- here::here("output", "processed")
fs::dir_create(output_dir)

col_name = c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")


# Loop over all types
for (type in types) {
    # Initialize a list to hold data from each file of the same type
    data_list <- list()
    
    # Loop over files from 1 to 9
    for (i in 1:9) {
        # Generate input file name
        input_file <- paste0("input_control_", i, "_", type, "_var_2.csv")
        
        # Generate full path of input file
        input_file_path <- file.path(input_dir, input_file)
                
        # Process data_extracted by using correct levels for each column of type factor
        data_processed <- process_data_2(input_file_path, col_name)
        
        # Append data_processed to data_list
        data_list[[i]] <- data_processed
    }
    
    # Combine all data from the same type
    data_combined <- do.call(rbind, data_list)
    
    # Determine output file name
    output_file_name <- paste0("input_control_", type, "_var_2.rds")
    
    # Save output
    saveRDS(object = data_combined,
            file = file.path(output_dir, output_file_name),
            compress = TRUE)
}
