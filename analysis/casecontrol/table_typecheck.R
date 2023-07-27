library(dplyr)
library(readr)
library(here)
library("stringr")

# Define the directory
input_dir <- here::here("output")

# List all input files
input_files <- c("input_case_uti_type.csv",
                 "input_case_urti_type.csv",
                 "input_case_lrti_type.csv")

# Define the columns
columns <- c("side_effect", "disease", "ae_I15_codelist", "ae_I26_codelist", "ae_I31_codelist", "ae_I42_codelist", "ae_I44_codelist", "ae_I45_codelist", "ae_I46_codelist", "ae_I47_codelist", "ae_I49_codelist", "ae_I60_codelist", "ae_I61_codelist", "ae_I62_codelist", "ae_I80_codelist", "ae_I85_codelist", "ae_I95_codelist", "ae_J38_codelist", "ae_J45_codelist", "ae_J46_codelist", "ae_J70_codelist", "ae_J80_codelist", "ae_J81_codelist", "ae_N14_codelist", "ae_N17_codelist", "ae_N19_codelist", "ae_R00_codelist", "ae_R04_codelist", "ae_R06_codelist", "ae_R41_codelist", "ae_R42_codelist", "ae_R44_codelist", "ae_R50_codelist", "ae_R51_codelist", "ae_R55_codelist", "ae_R58_codelist", "ae_S06_codelist", "ae_X44_codelist", "ae_Y40_codelist", "ae_Y41_codelist", "ae_Y57_codelist", "ae_Y88_codelist", "ae_Z88_codelist", "ae_K25_codelist", "ae_K26_codelist", "ae_K27_codelist", "ae_K28_codelist", "ae_K52_codelist", "ae_K62_codelist", "ae_K66_codelist", "ae_K85_codelist", "ae_K92_codelist", "ae_R11_codelist", "ae_R17_codelist", "ae_E03_codelist", "ae_E06_codelist", "ae_E15_codelist", "ae_E16_codelist", "ae_E23_codelist", "ae_E24_codelist", "ae_E27_codelist", "ae_E66_codelist", "ae_E86_codelist", "ae_E87_codelist", "ae_N42_codelist", "ae_N62_codelist", "ae_N83_codelist", "ae_N85_codelist", "ae_N89_codelist", "ae_N92_codelist", "ae_N93_codelist", "ae_N95_codelist", "ae_R31_codelist", "ae_R34_codelist", "ae_D52_codelist", "ae_D59_codelist", "ae_D61_codelist", "ae_D64_codelist", "ae_D65_codelist", "ae_D68_codelist", "ae_D69_codelist", "ae_D70_codelist", "ae_R73_codelist", "ae_K71_codelist", "ae_K72_codelist", "ae_K75_codelist", "ae_K76_codelist", "ae_R74_codelist", "ae_T36_codelist", "ae_T37_codelist", "ae_T47_codelist", "ae_T50_codelist", "ae_T78_codelist", "ae_T88_codelist", "ae_L10_codelist", "ae_L20_codelist", "ae_L21_codelist", "ae_L26_codelist", "ae_L27_codelist", "ae_L28_codelist", "ae_L29_codelist", "ae_L30_codelist", "ae_L43_codelist", "ae_L50_codelist", "ae_L51_codelist", "ae_L52_codelist", "ae_L56_codelist", "ae_L64_codelist", "ae_L71_codelist", "ae_R20_codelist", "ae_R21_codelist", "ae_R23_codelist")

# Loop through each file
for (file in input_files) {
  
  # Read the data from the file
  df <- read_csv(file.path(input_dir, file))
  
  # Loop through each column and count the number of 1s
  freqs <- lapply(columns, function(col) {
    sum(df[[col]] == 1, na.rm = TRUE)
  })
  
  # Convert the list to a data frame
  table <- data.frame(column = columns, freq = unlist(freqs))
  
  # Generate the output file name
  output_file <- str_replace(file, "input", "table")
  
  # Write the table to a CSV file
  write_csv(table, file.path(input_dir, output_file))
}
