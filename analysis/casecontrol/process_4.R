### This script extract the id for all cases, group by infection type ###
library("dplyr")
library("tidyverse")
library("lubridate")

# define the disease types and cases
diseases <- c("uti", "lrti", "urti", "sinusitis", "ot_externa", "ot_media", "pneumonia")
cases <- 1:9

# define the column specifications
col_spec <- cols_only(patient_index_date = col_date(format = ""),
                      age = col_number(),
                      sex = col_character(),
                      set_id = col_number(),
                      case = col_number(),
                      patient_id = col_number())

# create an empty data frame for the summary table
summary_table <- data.frame()

# iterate over each disease
for (disease in diseases) {
  
  # create an empty list to store data frames
  df_list <- list()
  
  # iterate over each case
  for (case in cases) {
    
    # read the CSV file and append it to the list
    filename <- paste0("output/matched_matches_", case, "_", disease, ".csv")
    df <- read_csv(here::here(filename), col_types = col_spec)
    df_list[[case]] <- df
  }
  
  # bind all data frames in the list into one data frame
  combined_df <- bind_rows(df_list)
  
  # write the combined data frame to a new CSV file
  output_filename <- paste0("output/controls_", disease, ".csv")
  write_csv(combined_df, here::here(output_filename))
  
 # calculate summary statistics
  mean_age <- round(mean(combined_df$age, na.rm = TRUE), 3)
  sd_age <- round(sd(combined_df$age, na.rm = TRUE), 3)
  perc_sex <- round(table(combined_df$sex) / nrow(combined_df) * 100, 3)
  n_samples <- nrow(combined_df)
  
  # append summary statistics to the summary table
  summary_table <- rbind(summary_table, data.frame(
    Disease = disease,
    Mean_Age = mean_age,
    SD_Age = sd_age,
    Perc_Female = perc_sex["F"],
    Perc_Male = perc_sex["M"],
    N_Samples = n_samples,
    row.names = NULL
  ))
}

# write the summary table to a new CSV file
write_csv(summary_table, here::here("output/summary_controls_table.csv"))
