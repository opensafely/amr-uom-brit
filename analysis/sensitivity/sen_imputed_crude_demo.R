require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)
library(mice)

df_imp_long_ch <- read_csv (here::here ("output", "imputation_dataframe_ch.csv"))
df_imp_long_ch_mids<-as.mids(df_imp_long_ch)
df_imp_long_c <- read_csv (here::here ("output", "imputation_dataframe_c.csv"))
df_imp_long_c_mids<-as.mids(df_imp_long_c)
df_imp_long_h <- read_csv (here::here ("output", "imputation_dataframe_h.csv"))
df_imp_long_h_mids<-as.mids(df_imp_long_h)

calculate_ORs <- function(data_mids, variable) {
  data_mids$data$imd <-relevel(as.factor(data_mids$data$imd), ref="5")
  data_mids$data$smoking_status <-relevel(as.factor(data_mids$data$smoking_status), ref="Never")
  data_mids$data$bmi_adult <-relevel(as.factor(data_mids$data$bmi_adult), ref="Healthy range (18.5-24.9)")
  data_mids$data$ethnicity <-relevel(as.factor(data_mids$data$ethnicity), ref="White")
  data_mids$data$set_id <-as.factor(data_mids$data$set_id)

  model <- with(data_mids,
                clogit(case ~ get(variable) + strata(set_id)))
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
datasets <- list(ch = df_imp_long_ch_mids, 
                 c = df_imp_long_c_mids, 
                 h = df_imp_long_h_mids)

# Applying the function to each variable of interest
variables <- c("imd", "ethnicity", "bmi_adult", "smoking_status")

# Iterating over datasets and variables
for (data_name in names(datasets)) {
  for (var in variables) {
    result_df <- calculate_ORs(datasets[[data_name]], var)
    write_csv(result_df, here::here("output", paste0("imputed_crude_", data_name, "_", var, ".csv")))
  }
}