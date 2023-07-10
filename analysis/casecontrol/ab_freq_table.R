# Load the necessary libraries
library(readr)
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)

main <- function(condition) {
  # Read the dataset
  df <- readRDS(here::here("output", "processed", paste0("model_", condition, "_ab.rds")))
  df$case=as.numeric(df$case) #1/0

  medications <- c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", 
                  "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", 
                  "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", 
                  "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", 
                  "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", 
                  "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", 
                  "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", 
                  "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", 
                  "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", 
                  "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", 
                  "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", 
                  "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", 
                  "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", 
                  "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")

  # Convert medication values to TRUE/FALSE
  df <- df %>% 
    mutate_at(vars(all_of(medications)), ~ if_else(. > 0, TRUE, FALSE))

  for(case in c(0, 1)) {
    # Generate the frequency table only for TRUE medication values and specific case
    freq_table <- df %>% 
      filter(case == case) %>%
      gather(medication, value, all_of(medications)) %>%
      filter(value == TRUE) %>% 
      group_by(medication) %>%  
      summarise(count = round(n() / 5) * 5) %>%  # round to nearest 5
      mutate(percentage = round(count / sum(count) * 100, 3)) %>% # round to 3 decimal places
      arrange(desc(percentage)) # arrange in descending order of percentage

    # Remove "Rx_" prefix from medication names
    freq_table$medication <- str_replace_all(freq_table$medication, "Rx_", "")

    # Define file name based on case
    if(case == 0) {
      file_name <- paste0("control_",condition,"_medication_freq_table.csv")
    } else {
      file_name <- paste0("case_",condition,"_medication_freq_table.csv")
    }

    # Save the frequency table
    write_csv(freq_table, here::here("output", file_name))
  }
}

main("uti")
main("urti")
main("lrti")
