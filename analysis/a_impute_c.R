### This script is for sensitivity analysis -- complete case analysis ###

## Import libraries---

require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)
library(mice)


df <- readRDS("output/processed/input_model_c.rds")
df$smoking_status[df$smoking_status == "Missing"] <- NA
df$bmi_adult[df$bmi_adult == "Missing"] <- NA
df$ethnicity[df$ethnicity == "Unknown"] <- NA

df$imd= relevel(as.factor(df$imd), ref="5")

df <- df %>% select(case, imd ,ethnicity ,bmi_adult ,smoking_status ,hypertension ,chronic_respiratory_disease,
             asthma ,chronic_cardiac_disease ,diabetes_controlled ,cancer ,haem_cancer ,chronic_liver_disease,
             stroke ,dementia ,other_neuro ,organ_kidney_transplant ,asplenia ,ra_sle_psoriasis ,immunosuppression,
             learning_disability ,sev_mental_ill ,alcohol_problems ,care_home_type_ba ,ckd_rrt ,ab_frequency, set_id)

set.seed(123) # Setting a seed for reproducibility

## Select 1% of the data randomly
df_sampled <- df 

## Function to calculate and print the number of missing values in each column
print_missing_values <- function(df){
  missing_values <- sapply(df, function(x) sum(is.na(x)))
  print(missing_values)
}

## Print the number of missing values before imputation in the sampled data
cat("Number of missing values before imputation in the sampled data:\n")
print_missing_values(df_sampled)

## Perform mice imputation on sampled data
imp_sampled <- mice(df_sampled, maxit=0, seed = 123)
predM_sampled <- imp_sampled$predictorMatrix
meth_sampled <- imp_sampled$method


predM_sampled[, c("set_id")] <- 0

imp2_sampled <- mice(df_sampled, maxit = 5, seed = 123,
                     predictorMatrix = predM_sampled, 
                     method = meth_sampled, print = TRUE)

df_imp_long_sampled <- mice::complete(imp2_sampled, action="long", include = TRUE)            

## Print the number of missing values after imputation in the sampled data
cat("Number of missing values after imputation in the sampled data:\n")
print_missing_values(df_imp_long_sampled)

write.csv(df_imp_long_sampled, here::here("output", "imputation_dataframe_c.csv"))

