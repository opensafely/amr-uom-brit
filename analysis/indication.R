### check valid code for uploading ###

library("data.table")
library("dplyr")
library('tidyverse')
library('here')

# remove scientific notation
options(scipen=999)

# read flie list from codelists folder
csvFiles = list.files(here::here("codelists"),pattern="abindic", full.names = TRUE)
temp <- vector("list", length(csvFiles))
for (i in seq_along(csvFiles))
  temp[[i]] <- fread(csvFiles[i]) 
 

# combine list of data.table
df_input <- rbindlist(temp)


# filter coding system=snomed & reorder columns
df_sub=
  df_input %>%
  filter(code_type== "conceptid") %>%
  select(code_new,description)

# remove first 3 digit in code
df_sub$code_new=str_sub(df_sub$code_new,start=4)

# export file in codelists folder
write.table(df_sub, file.path(here::here("codelists"), "indication_snomed.csv"), sep=",", col.names=FALSE, row.names = FALSE)
