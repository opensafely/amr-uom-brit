######################################

# Some covariates used in the study are created from codelists of clinical conditions or 
# numerical values available on a patient's records.
# This script fetches all of the codelists identified in codelists.txt from OpenCodelists.

######################################


# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import (codelist, codelist_from_csv, combine_codelists)


# --- CODELISTS ---

### The following should be our own codelists in the future

### All antibacterials
antibacterials_codes= codelist_from_csv(
  "codelists/opensafely-antibacterials.csv",
  system = "snomed",
  column = "dmd_id"
)

### All antibacterials
broad_spectrum_antibiotics_codes= codelist_from_csv(
  "codelists/opensafely-antibacterials.csv",
  system = "snomed",
  column = "dmd_id"
)

### ethnicity 
#ethnicity_codes = codelist_from_csv(
#    "codelists/opensafely-ethnicity-2020-04-27.csv",
#    system="ctv3",
#    column="Code",
#    category_column="Grouping_6",
#)

### ethnicity 
ethnicity_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth2001-v1.csv",
    system="snomed",
    column="code",
    category_column="grouping_6_id",
)


### bmi 
bmi_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi-v1.csv",
    system="snomed",
    column="code",
)


### flu vaccine
#flu_vaccine_codes= codelist_from_csv(
#  "codelists/vaccination_med1_mapped.csv",
#  system = "snomed",
#  column = "dmd_id"
#)
