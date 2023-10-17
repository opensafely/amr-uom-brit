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

# Convert the data to mids object
data_mids <- as.mids(df_imp_long_c)


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
  data_mids$data$covid= as.factor(data_mids$data$covid)
  data_mids$data <- data_mids$data %>% filter(covid == '1')

  model <- with(data_mids,
                clogit(case ~ ethnicty + rcs(age, 4) + sex + strata(region)))
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
  
  print(results)

  write_csv(results, here::here("output", "imputed_adjusted_mortality_community_ethnicity.csv"))


