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

### All antibacterials
antibacterials_codes = codelist_from_csv(
    "codelists/opensafely-antibacterials.csv", system="snomed", column="dmd_id"
)


### All antibacterials
broad_spectrum_antibiotics_codes = codelist_from_csv(
    "codelists/opensafely-antibacterials.csv", system="snomed", column="dmd_id"
)



### asthma & COPD
asthma_copd_codes = codelist_from_csv(
    "codelists/user-rriefu-asthma_copd.csv", system="snomed", column="code"
)


### asthma
asthma_codes = codelist_from_csv(
    "codelists/user-rriefu-asthma.csv", system="snomed", column="code"
)


### cold
cold_codes = codelist_from_csv(
    "codelists/user-rriefu-cold_subset.csv", system="snomed", column="code"
)


### copd
copd_codes = codelist_from_csv(
    "codelists/user-rriefu-copd.csv", system="snomed", column="code"
)


### cough & cold
cough_cold_codes = codelist_from_csv(
    "codelists/user-rriefu-cough_cold.csv", system="snomed", column="code"
)


### cough
cough_codes = codelist_from_csv(
    "codelists/user-rriefu-cough.csv", system="snomed", column="code"
)


### LRTI
lrti_codes = codelist_from_csv(
    "codelists/user-rriefu-lrti.csv", system="snomed", column="code"
)


### ot externa
ot_externa_codes = codelist_from_csv(
    "codelists/user-rriefu-ot_externa.csv", system="snomed", column="code"
)


### otmedia
otmedia_codes = codelist_from_csv(
    "codelists/user-rriefu-otmedia.csv", system="snomed", column="code"
)


###  pneumonia
pneumonia_codes = codelist_from_csv(
    "codelists/user-rriefu-pneumonia.csv", system="snomed", column="code"
)


###  renal
renal_codes = codelist_from_csv(
    "codelists/user-rriefu-renal.csv", system="snomed", column="code"
)


###  sepsis
sepsis_codes = codelist_from_csv(
    "codelists/user-rriefu-sepsis.csv", system="snomed", column="code"
)


###  sinusits
sinusits_codes = codelist_from_csv(
    "codelists/user-rriefu-sinusits.csv", system="snomed", column="code"
)


###  throat
throat_codes = codelist_from_csv(
    "codelists/user-rriefu-throat.csv", system="snomed", column="code"
)


###  URTI
urti_codes = codelist_from_csv(
    "codelists/user-rriefu-urti.csv", system="snomed", column="code"
)


###  UTI
uti_codes = codelist_from_csv(
    "codelists/user-rriefu-uti.csv", system="snomed", column="code"
)


## all infections
all_infection_codes = combine_codelists(asthma_copd_codes, asthma_codes, cold_codes, copd_codes, 
      cough_cold_codes, cough_codes, lrti_codes, ot_externa_codes, otmedia_codes, pneumonia_codes, 
      renal_codes, sepsis_codes, sinusits_codes, throat_codes, urti_codes, uti_codes )






###  vaccination
vaccination_codes = codelist_from_csv(
    "codelists/user-rriefu-vaccination.csv", system="snomed", column="code"
)


