#### This script is for calculating mortality rate and draw the table ####

require('tidyverse')
require("gtsummary")
library(car)
library(data.table)
library(gridExtra)
library(purrr)
library(dplyr)
library(survival)
library(rms)

df <- readRDS("output/processed/input_model_c_h.rds")
df <- df %>% filter(case==1)
df$agegroup = case_when(
  df$age < 18 ~ "<18",
  df$age >= 18 & df$age < 40 ~ "18-39",
  df$age >= 40 & df$age < 50 ~ "40-49",
  df$age >= 50 & df$age < 60 ~ "50-59",
  df$age >= 60 & df$age < 70 ~ "60-69",
  df$age >= 70 & df$age < 80 ~ "70-79",
  df$age >= 80 ~ "80+")

###Age###

df$agegroup= relevel(as.factor(df$agegroup), ref="50-59")

###Age###
mod <- glm(died_any_30d~agegroup + agegroup*covid + covid + sex + strata(region),family="binomial",data = df)
summary(mod)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result1 <- result

###Sex###
mod <- glm(died_any_30d~rcs(age, 4) + sex + sex*covid + covid + strata(region),family="binomial",data = df)
summary(mod)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result2 <- result

### Region ###
mod <- glm(died_any_30d~rcs(age, 4) + sex + region + region*covid + covid,family="binomial",data = df)
summary(mod)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result3 <- result

### IMD ###
mod <- glm(died_any_30d~ imd + + imd*covid + covid + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
summary(mod)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result4 <- result

### Other ###
mod <- glm(died_any_30d~ ethnicity+ ethnicity*covid + covid + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
summary(mod)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result5 <- result


mod <- glm(died_any_30d~ bmi_adult+ bmi_adult*covid + covid + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
summary(mod)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result6 <- result


mod <- glm(died_any_30d~ smoking_status+ smoking_status*covid + covid + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
summary(mod)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result7 <- result

result_a <- bind_rows(result1,result2,result3,result4,result5,result6,result7)
setDT(result_a, keep.rownames = TRUE)
write_csv(result_a, here::here("output", "combined_mortality_part1.csv"))
#############
# List of predictors to be tested
predictors <- c("hypertension", "chronic_respiratory_disease", "asthma",
                "chronic_cardiac_disease", "diabetes_controlled", "cancer",
                "haem_cancer", "chronic_liver_disease", "stroke",
                "dementia", "other_neuro", "organ_kidney_transplant", 
                "asplenia", "ra_sle_psoriasis", "immunosuppression",
                "learning_disability", "sev_mental_ill", "alcohol_problems",
                "care_home_type_ba", "ckd_rrt", "ab_frequency", "ab_type_num")

# Initialize an empty data frame to store all results
all_results <- data.frame()

# Loop over each predictor, fit model, and store results
for(predictor in predictors) {
  
  # Build formula string for glm
  formula_str <- paste("died_any_30d ~", predictor, "+", predictor, "*covid + covid + rcs(age, 4) + sex + strata(region)")
  
  # Fit model
  mod <- glm(as.formula(formula_str), family = "binomial", data = df)
  
  # Extract and format results
  result <- data.frame(exp(cbind(OR = coef(mod), confint(mod))))
  result$Predictor <- predictor
  
  # Bind this result to the main result data frame
  all_results <- bind_rows(all_results, result)
}
setDT(all_results, keep.rownames = TRUE)

# Save combined results to CSV
write_csv(all_results, here::here("output", "combined_mortality_part2.csv"))