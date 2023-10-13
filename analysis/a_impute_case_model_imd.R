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


df <- readRDS("output/processed/input_model_c_h.rds")
df$smoking_status[df$smoking_status == "Missing"] <- NA
df$bmi_adult[df$bmi_adult == "Missing"] <- NA
df$ethnicity[df$ethnicity == "Unknown"] <- NA

df$imd= relevel(as.factor(df$imd), ref="5")

## Perform multiple imputations to handle missing data
imputed_data <- mice(df, m=5, method='pmm', seed=500)

## Now, perform analysis on each imputed dataset
for(i in 1:5){
  data <- complete(imputed_data, i)
  
  ## You can now perform your analysis on each completed dataset 
  ## (I'll show the crude model by variables as an example)
  mod=clogit(case ~ imd + strata(set_id), data)
  sum.mod=summary(mod)
  result=data.frame(sum.mod$conf.int)
  DF=result[,-2]
  names(DF)[1]="OR"
  names(DF)[2]="CI_L"
  names(DF)[3]="CI_U"
  setDT(DF, keep.rownames = TRUE)[]
  
  ## Save the output in a CSV file
  write_csv(DF, here::here(sprintf("output/analysis_result_set_%d.csv", i)))
}



