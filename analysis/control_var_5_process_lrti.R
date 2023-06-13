# Load libraries & custom functions ---
library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)


# directory where input files are located
input_dir <- here::here("output")

# create output directory if it doesn't exist
output_dir <- here::here("output", "processed")
fs::dir_create(output_dir)

# initialize an empty list to store data frames
list_df <- list()

# loop over all input control files
for(i in 1:9) {
  # generate input file name
  input_file <- paste0("input_control_", i, "_lrti_var_5.csv")

  # generate full path of input file
  input_file_path <- file.path(input_dir, input_file)

  # Load data from the input file
  data <- read.csv(input_file_path)

  # Select the desired columns
  data_selected <- data[,c('patient_id', 'patient_index_date', 'infection_date')]

  # add to the list of data frames
  list_df[[i]] <- data_selected
}

# combine all data frames in the list into a single data frame
data_combined <- do.call(rbind, list_df)

# determine output file name
output_file_name <- "input_control_lrti_var_5.rds"

# Save output
saveRDS(object = data_combined,
        file = file.path(output_dir, output_file_name),
        compress = TRUE)
