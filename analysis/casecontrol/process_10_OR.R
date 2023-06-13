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

# Define the list of infections
infections <- c("uti", "lrti", "urti")

# Define date_gap labels
date_gap_labels <- c("0-2 days", "3-4 days", "5-6 days", "7-8 days", "9-10 days", "11-12 days", "13-14 days", "15-16 days", "17-18 days", "19-20 days", "21-22 days", "23-24 days", "25-26 days", "27-28 days", "29-30 days")

# Iterate over each infection in the list
for (infection in infections) {
  
  # Load data for the current infection
  case_infection <- readRDS(here::here("output", "processed", paste0("case_withdate_",infection,".rds")))
  control_infection <- readRDS(here::here("output", "processed",paste0("control_withdate_",infection,".rds")))
  
  df <- rbind(case_infection, control_infection)

  # Convert date columns to Date type
  df$patient_index_date <- as.Date(df$patient_index_date)
  df$infection_date <- as.Date(df$infection_date)
  
  # Calculate date_gap in days
  df$date_gap <- df$patient_index_date - df$infection_date

  # Classify date_gap
  df$date_gap <- cut(as.numeric(df$date_gap), breaks=seq(from = -Inf, to = Inf, by = 2), labels=date_gap_labels, include.lowest = TRUE)

  # Replace NA in date_gap with "0-2 days"
  df$date_gap <- replace_na(df$date_gap, "0-2 days")

  df$ab_treatment <- df %>% mutate() 
  df$ab_treatment<-  case_when(
    df$ab_frequency == "0" ~ "FALSE",
    df$ab_frequency == "1" ~ "TRUE",
    df$ab_frequency == "2-3" ~ "TRUE",
    df$ab_frequency == ">3" ~ "TRUE")
  
  df$case=as.numeric(df$case) #1/0
  df$set_id=as.factor(df$set_id)#pair id
  df$charlsonGrp= relevel(as.factor(df$charlsonGrp), ref="zero")
  df$patient_index_date <- as.Date(df$patient_index_date, format = "%Y%m%d")

  # Create exposure column
  df$exposure <- ifelse(df$ab_treatment == "TRUE", paste0("ab ", df$date_gap), paste0("non-ab ", df$date_gap))

  # List to store data frames
  dfs <- list()
  
  for (i in 1:4) {
    
    if(i==1){
      mod=clogit(case ~ exposure + strata(set_id), df)
    }
    else if(i==2){
      mod=clogit(case ~ exposure + ckd_rrt + strata(set_id), df)
    }
    else if(i==3){
      mod=clogit(case ~ ckd_rrt*exposure + exposure + strata(set_id), df)
    }
    else if(i==4){
      mod=clogit(case ~ exposure + charlsonGrp + strata(set_id), df)
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
    
    # Add the infection type, model number, and Model to the DF
    DF$infection <- infection
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
  write_csv(combined_df, here::here("output", paste0(infection,"_bydate_model.csv")))
}