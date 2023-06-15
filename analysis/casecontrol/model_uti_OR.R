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

# Read the dataset
df <- readRDS(here::here("output", "processed", "model_uti.rds"))

# Preprocess the dataset
df$case=as.numeric(df$case) #1/0
df$set_id=as.factor(df$set_id) #pair id
df$charlsonGrp= relevel(as.factor(df$charlsonGrp), ref="zero")
df$patient_index_date <- as.Date(df$patient_index_date, format = "%Y%m%d")

df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                      patient_index_date >=as.Date("2020-03-26") & patient_index_date < as.Date("2021-03-08") ~ "2",
                                      patient_index_date >= as.Date("2021-03-08") ~ "3"))
df$covid=relevel(as.factor(df$covid), ref="1")

# Initialize an empty list
dfs <- list()

for (i in 1:6) {
    
  if(i==1){
    mod=clogit(case ~ ab_treatment + strata(set_id), df)
  }
  else if(i==2){
    mod=clogit(case ~ covid*ab_treatment + ab_treatment + strata(set_id), df)
  }
  else if(i==3){
    mod=clogit(case ~ ab_treatment + ckd_rrt + strata(set_id), df)
  }
  else if(i==4){
    mod=clogit(case ~ ckd_rrt*ab_treatment + ab_treatment + strata(set_id), df)
  }
  else if(i==5){
    mod=clogit(case ~ ab_treatment + charlsonGrp + strata(set_id), df)
  }
  else if(i==6){
    mod=clogit(case ~ ab_history_freq*ab_treatment + ab_treatment + strata(set_id), df)
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
write_csv(combined_df, here::here("output", "uti_model_result.csv"))
