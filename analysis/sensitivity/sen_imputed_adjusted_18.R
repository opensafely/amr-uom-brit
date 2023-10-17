require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)
library(mice)

df_imp_long_ch <- read_csv (here::here ("output", "imputation_dataframe_18_ch.csv"))
df_imp_long_ch_mids<-as.mids(df_imp_long_ch)
df_imp_long_c <- read_csv (here::here ("output", "imputation_dataframe_18_c.csv"))
df_imp_long_c_mids<-as.mids(df_imp_long_c)
df_imp_long_h <- read_csv (here::here ("output", "imputation_dataframe_18_h.csv"))
df_imp_long_h_mids<-as.mids(df_imp_long_h)

calculate_ORs <- function(data_mids) {
  data_mids$data$diabetes_controlled <-relevel(as.factor(data_mids$data$diabetes_controlled), ref="No diabetes")
  data_mids$data$organ_kidney_transplant <-relevel(as.factor(data_mids$data$organ_kidney_transplant), ref="No transplant")
  data_mids$data$ckd_rrt <-relevel(as.factor(data_mids$data$ckd_rrt), ref="No CKD or RRT")
  data_mids$data$ab_frequency <-relevel(as.factor(data_mids$data$ab_frequency), ref="0")
  data_mids$data$set_id <-as.factor(data_mids$data$set_id)

  model <- with(data_mids,
                clogit(case ~  hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + strata(set_id)))
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


# Iterating over datasets
for (data_name in names(datasets)) {
  result_df <- calculate_ORs(datasets[[data_name]])
  write_csv(result_df, here::here("output", paste0("imputed_adjusted_18_", data_name, ".csv")))
}