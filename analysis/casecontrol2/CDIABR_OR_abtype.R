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

main <- function(condition) {
  # Read the dataset
  df <- readRDS(here::here("output", "processed", paste0("model_", condition, ".rds")))

   # Preprocess the dataset
  df$case=as.numeric(df$case) #1/0
  df$set_id=as.factor(df$set_id) #pair id
  df$ethnicity= relevel(as.factor(df$ethnicity), ref="White")
  df$region= relevel(as.factor(df$region), ref="East of England")
  df$bmi= relevel(as.factor(df$bmi), ref="Healthy range (18.5-24.9 kg/m2)")
  df$imd= relevel(as.factor(df$imd), ref="5 (least deprived)")
  df$smoking_status_comb= relevel(as.factor(df$smoking_status_comb), ref="Never and unknown")
  df$patient_index_date <- as.Date(df$patient_index_date, format = "%Y%m%d")

  df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                        patient_index_date >=as.Date("2020-03-26") & patient_index_date < as.Date("2021-03-08") ~ "2",
                                        patient_index_date >= as.Date("2021-03-08") ~ "3"))
  df$covid=relevel(as.factor(df$covid), ref="1")

  df <- df %>% mutate(ab_history_count = case_when(ab_history_3yr == 0 ~ "0",
                                                    ab_history_3yr == 1 ~ "1",
                                                    ab_history_3yr > 1 & ab_history_3yr <3 ~ "2-3",
                                                    ab_history_3yr >= 3 ~ "3+"))

  df <- df %>% mutate(exposure_ab = case_when(
  ab_history_count == "0" & ab_type_num == "0" ~ "count_0_type_0",
  ab_history_count == "1" & ab_type_num == "1" ~ "count_1_type_1",
  ab_history_count == "2-3" & ab_type_num == "1" ~ "count_23_type_1",
  ab_history_count == "2-3" & ab_type_num == "2-3" ~ "count_23_type_23",
  ab_history_count == "3+" & ab_type_num == "1" ~ "count_4_type_1",
  ab_history_count == "3+" & ab_type_num == "2-3" ~ "count_4_type_23",
  ab_history_count == "3+" & ab_type_num == "3+" ~ "count_4_type_4",
  TRUE ~ "count_0_type_0"
))

df$exposure_ab = relevel(as.factor(df$exposure_ab), ref="count_0_type_0")

  # Initialize an empty list
  dfs <- list()

  for (i in 1:7) {
      
    if(i==1){
      mod=clogit(case ~ exposure_ab + strata(set_id), df)
    }
    else if(i==2){
      mod=clogit(case ~ covid*exposure_ab + exposure_ab + covid + strata(set_id), df)
    }
    else if(i==3){
      mod=clogit(case ~ exposure_ab + ethnicity + region + bmi + imd + smoking_status_comb + strata(set_id), df)
    }
    else if(i==4){
      mod=clogit(case ~ exposure_ab + ethnicity + region + bmi + imd + smoking_status_comb + ckd_rrt + strata(set_id), df)
    }
    else if(i==5){
      mod=clogit(case ~ exposure_ab + ethnicity + region + bmi + imd + smoking_status_comb + charlsonGrp + strata(set_id), df)
    }
    else if(i==6){
      mod=clogit(case ~ ab_history_count*exposure_ab + exposure_ab + ab_history_count + strata(set_id), df)
    }
    else if(i==7){
      mod=clogit(case ~ ab_history_count*exposure_ab + exposure_ab + ab_history_count + ethnicity + region + bmi + imd + smoking_status_comb + charlsonGrp + strata(set_id), df)
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
  write_csv(combined_df, here::here("output", paste0(condition, "_model_result_abtype.csv")))
}

# Call the main function for each condition
main("ae2")

