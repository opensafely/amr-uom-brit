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

  # Preprocess the dataset
  df$case=as.numeric(df$case) #1/0
  df$set_id=as.factor(df$set_id) #pair id
  df$ethnicity= relevel(as.factor(df$ethnicity), ref="White")
  df$region= relevel(as.factor(df$region), ref="East of England")
  df$bmi= relevel(as.factor(df$bmi), ref="Healthy range (18.5-24.9 kg/m2)")
  df$imd= relevel(as.factor(df$imd), ref="5 (least deprived)")
  df$smoking_status_comb= relevel(as.factor(df$smoking_status_comb), ref="Never and unknown")
  df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                        patient_index_date >=as.Date("2020-03-26") & patient_index_date < as.Date("2021-03-08") ~ "2",
                                        patient_index_date >= as.Date("2021-03-08") ~ "3"))
  df$covid=relevel(as.factor(df$covid), ref="1")

  df <- df %>% mutate(ab_history_count = case_when(ab_history == 0 ~ "0",
                                                  ab_history == 1 ~ "1",
                                                  ab_history > 1 & ab_history <3 ~ "2-3",
                                                  ab_history >= 3 ~ "3+"))

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
  # Define your medications
  meds <- c("Rx_Nitrofurantoin", "Rx_Trimethoprim", "Rx_Amoxicillin", "Rx_Co_amoxiclav")
  other_meds <- setdiff(medications, meds) # Other medications

  # Define the total count of TRUE medications
  df$total_true <- rowSums(df[, medications])

  # Define the total count of TRUE for other medications
  df$other_true <- rowSums(df[, other_meds])

  # Define medication variable
  df <- df %>% mutate(
    medication = case_when(
      Rx_Nitrofurantoin == TRUE & total_true == 1 ~ "Nitrofurantoin",
      Rx_Trimethoprim == TRUE & total_true == 1 ~ "Trimethoprim",
      Rx_Amoxicillin == TRUE & total_true == 1 ~ "Amoxicillin",
      Rx_Co_amoxiclav == TRUE & total_true == 1 ~ "Co_amoxiclav",
      other_true == 1 & total_true == 1 ~ "Others",
      total_true > 1 ~ "Multiple",
      total_true == 0 ~ "None",
      TRUE ~ NA_character_
    )
  )

  # Convert medication to factor, with "None" as the reference level
  df$medication <- relevel(factor(df$medication), ref = "None")

  # Calculate the frequency of each medication level by case
  medication_freq <- df %>% group_by(medication, case) %>% summarise(freq = n())

  # Pivot the data to have case values as columns
  medication_freq_pivot <- medication_freq %>% pivot_wider(names_from = case, values_from = freq)

  # Replace NA values with 0
  medication_freq_pivot[is.na(medication_freq_pivot)] <- 0

  # Write the frequency table to a CSV file
  write_csv(medication_freq_pivot, here::here("output", paste0(condition,"_ab_medication_freq.csv")))


  # Initialize an empty list
  dfs <- list()

  for (i in 1:5) {
      
    if(i==1){
      mod=clogit(case ~ medication + strata(set_id), df)
    }
    else if(i==2){
      mod=clogit(case ~ covid*medication + medication + covid + strata(set_id), df)
    }
    else if(i==3){
      mod=clogit(case ~ medication + ethnicity + region + bmi + imd + smoking_status_comb + strata(set_id), df)
    }
    else if(i==4){
      mod=clogit(case ~ medication + ethnicity + region + bmi + imd + smoking_status_comb + ckd_rrt + strata(set_id), df)
    }
    else if(i==5){
      mod=clogit(case ~ medication + ethnicity + region + bmi + imd + smoking_status_comb + charlsonGrp + strata(set_id), df)
    }


    sum.mod=summary(mod)
    result=data.frame(sum.mod$conf.int)
    DF=result[,-2]
    names(DF)[1]="OR"
    names(DF)[2]="CI_L"
    names(DF)[3]="CI_U"
    setDT(DF, keep.rownames = TRUE)[]
    names(DF)[1]="type"

    # Define the model number
    Model <- paste0("Model ", i)
    
    DF$model_num <- i
    DF$Model <- Model
    
    # Add DF to the list
    dfs[[i]] <- DF
  }

  # Combine all data frames
  combined_df <- bind_rows(dfs)

  # Combine OR, CI_L, CI_U into one column
  combined_df$`OR (95% CI)` <- ifelse(is.na(combined_df$OR), "",
                                       sprintf("%.2f (%.2f to %.2f)",
                                               combined_df$OR, combined_df$CI_L, combined_df$CI_U))
  combined_df <- combined_df %>% select(type, Model, `OR (95% CI)`)

  # Write the combined data frame to a CSV file
  write_csv(combined_df, here::here("output", paste0(condition,"_ab_type_OR.csv")))
}


main("uti")
