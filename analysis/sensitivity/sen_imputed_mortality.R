require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)
library(mice)
library(purrr)
library(dplyr)
library(rms)

# Read the CSV file
df_imp_long_c <- read_csv(here::here("output", "imputation_mortality_c.csv"))
df_imp_long_c_period1 <- df_imp_long_c %% filter (covid==1)
df_imp_long_c_period2 <- df_imp_long_c %% filter (covid==2)
df_imp_long_c_period3 <- df_imp_long_c %% filter (covid==3)

# Convert the data to mids object
df_imp_long_c_period1_mids <- as.mids(df_imp_long_c_period1)
df_imp_long_c_period2_mids <- as.mids(df_imp_long_c_period2)
df_imp_long_c_period3_mids <- as.mids(df_imp_long_c_period3)

# Function to calculate Odds Ratios
calculate_ORs <- function(data_mids, variable) {
  # Relevel factors
  data_mids$data$imd <-relevel(as.factor(data_mids$data$imd), ref="5")
  data_mids$data$smoking_status <-relevel(as.factor(data_mids$data$smoking_status), ref="Never")
  data_mids$data$bmi_adult <-relevel(as.factor(data_mids$data$bmi_adult), ref="Healthy range (18.5-24.9)")
  data_mids$data$ethnicity <-relevel(as.factor(data_mids$data$ethnicity), ref="White")
  data_mids$data$diabetes_controlled <-relevel(as.factor(data_mids$data$diabetes_controlled), ref="No diabetes")
  data_mids$data$organ_kidney_transplant <-relevel(as.factor(data_mids$data$organ_kidney_transplant), ref="No transplant")
  data_mids$data$ckd_rrt <-relevel(as.factor(data_mids$data$ckd_rrt), ref="No CKD or RRT")
  data_mids$data$ab_frequency <-relevel(as.factor(data_mids$data$ab_frequency), ref="0")
  data_mids$data$agegroup = case_when(
  data_mids$data$age < 18 ~ "<18",
  data_mids$data$age >= 18 & data_mids$data$age < 40 ~ "18-39",
  data_mids$data$age >= 40 & data_mids$data$age < 50 ~ "40-49",
  data_mids$data$age >= 50 & data_mids$data$age < 60 ~ "50-59",
  data_mids$data$age >= 60 & data_mids$data$age < 70 ~ "60-69",
  data_mids$data$age >= 70 & data_mids$data$age < 80 ~ "70-79",
  data_mids$data$age >= 80 ~ "80+")
  data_mids$data$agegroup= relevel(as.factor(data_mids$data$agegroup), ref="50-59")
  model <- with(data_mids,
                clogit(case ~ get(variable) + rcs(age, 4) + sex + strata(region)))
  model <- summary(pool(model)) 
  
  # Extracting coefficients and other details from the model
  coefs <- model$estimate
  std_errors <- model$std.error
  var_names <- model$term
  
  # Calculating Odds Ratios and 95% CI
  ORs <- exp(coefs)
  lower_95 <- exp(coefs - 1.96 * std_errors)
  upper_95 <- exp(coefs + 1.96 * std_errors)
  
  # Creating a data frame with results
  results <- data.frame(Variable = var_names,
                        Odds_Ratios = ORs,
                        Lower_95_CI = lower_95,
                        Upper_95_CI = upper_95)
  
  return(results)
}


# List of datasets
datasets <- list(period1 = df_imp_long_c_period1_mids, 
                 period2 = df_imp_long_c_period2_mids, 
                 period3 = df_imp_long_c_period3_mids)

# Applying the function to each variable of interest
variables <- c("ethnicity", "smoking_status", "hypertension", 
               "chronic_respiratory_disease", "asthma", "chronic_cardiac_disease", 
               "diabetes_controlled", "cancer", "haem_cancer", "chronic_liver_disease", 
               "stroke", "dementia", "other_neuro", "organ_kidney_transplant", "asplenia", 
               "ra_sle_psoriasis", "immunosuppression", "learning_disability", 
               "sev_mental_ill", "alcohol_problems", "care_home_type_ba", "ckd_rrt", 
               "ab_frequency")

# Iterating over datasets and variables
for (data_name in names(datasets)) {
  for (var in variables) {
    result_df <- calculate_ORs(datasets[[data_name]], var)
    write_csv(result_df, here::here("output", paste0("imputed_adjusted_mortality_community_", data_name, "_", var, ".csv")))
  }
}


