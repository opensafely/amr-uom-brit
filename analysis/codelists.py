######################################

# Some covariates used in the study are created from codelists of clinical conditions or
# numerical values available on a patient's records.
# This script fetches all of the codelists identified in codelists.txt from OpenCodelists.

######################################


# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import codelist, codelist_from_csv, combine_codelists


# --- CODELISTS ---

### The following should be our own codelists in the future


### cold
cold_codes = codelist_from_csv(
    "codelists/user-rriefu-cold_subset.csv", system="snomed", column="code")


### cough
cough_codes= codelist_from_csv(
  "codelists/user-rriefu-cough.csv",
  system = "snomed",
  column = "code"
)


### LRTI
lrti_codes= codelist_from_csv(
  "codelists/user-rriefu-lrti.csv",
  system = "snomed",
  column = "code"
)


### ot externa
ot_externa_codes= codelist_from_csv(
  "codelists/user-rriefu-ot_externa.csv",
  system = "snomed",
  column = "code"
)


### otmedia
otmedia_codes= codelist_from_csv(
  "codelists/user-rriefu-otmedia.csv",
  system = "snomed",
  column = "code"
)


###  pneumonia
pneumonia_codes= codelist_from_csv(
  "codelists/user-rriefu-pneumonia.csv",
  system = "snomed",
  column = "code"
)


###  sinusits
sinusitis_codes= codelist_from_csv(
  "codelists/user-rriefu-sinusits.csv",
  system = "snomed",
  column = "code"
)


###  throat
throat_codes= codelist_from_csv(
  "codelists/user-rriefu-throat.csv",
  system = "snomed",
  column = "code"
)


###  URTI
urti_codes= codelist_from_csv(
  "codelists/user-rriefu-urti.csv",
  system = "snomed",
  column = "code"
)


###  UTI
uti_codes = codelist_from_csv(
    "codelists/user-rriefu-uti.csv", system="snomed", column="code"
)


## all upper respiratory infection
all_urti_codes = combine_codelists(urti_codes,cough_codes,cold_codes,throat_codes)

## all infection code
all_infection_codes = combine_codelists(lrti_codes,ot_externa_codes,otmedia_codes,pneumonia_codes,sinusitis_codes,uti_codes,all_urti_codes)

### infection-related-complication

infection_related_complication_codes = codelist_from_csv(
  "codelists/user-BillyZhongUOM-infection-related-complication.csv",
  system = "icd10",
  column = "code"
)

### adverse-event
adverse_event_codes = codelist_from_csv(
  "codelists/user-BillyZhongUOM-adverse-event-hospital-admission.csv",
  system = "icd10",
  column = "code"
)

outcome_code = combine_codelists(
    infection_related_complication_codes,
    adverse_event_codes,
    )