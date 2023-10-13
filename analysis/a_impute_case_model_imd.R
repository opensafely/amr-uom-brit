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


df <- readRDS("output/processed/input_model_c_h.rds")
df$smoking_status[df$smoking_status == "Missing"] <- NA
df$bmi_adult[df$bmi_adult == "Missing"] <- NA
df$ethnicity[df$ethnicity == "Unknown"] <- NA

df$imd= relevel(as.factor(df$imd), ref="5")

df <- df %>% select(case, imd ,ethnicity ,bmi_adult ,smoking_status ,hypertension ,chronic_respiratory_disease,
             asthma ,chronic_cardiac_disease ,diabetes_controlled ,cancer ,haem_cancer ,chronic_liver_disease,
             stroke ,dementia ,other_neuro ,organ_kidney_transplant ,asplenia ,ra_sle_psoriasis ,immunosuppression,
             learning_disability ,sev_mental_ill ,alcohol_problems ,care_home_type_ba ,ckd_rrt ,ab_frequency, set_id)

df$case <- as.factor(df$case)
# We run the mice code with 0 iterations 

imp <- mice(df, maxit=0, seed = 123)

predM <- imp$predictorMatrix
meth <- imp$method
head(predM)

imp2 <- mice(df, maxit = 5, seed = 123,
             predictorMatrix = predM, 
             method = meth, print =  TRUE)

df_imp_long <- mice::complete(imp2, action="long", include = TRUE)            


## Function to calculate and print the number of missing values in each column
print_missing_values <- function(df){
  missing_values <- sapply(df, function(x) sum(is.na(x)))
  print(missing_values)
}

## Print the number of missing values before imputation
cat("Number of missing values before imputation:\n")
print_missing_values(df)

## Print the number of missing values after imputation
cat("Number of missing values after imputation:\n")
print_missing_values(df_imp_long)

write.csv (df_imp_long, here::here ("output", "imputation_dataframe.csv"))


