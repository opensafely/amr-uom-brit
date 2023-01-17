######################################

# Some covariates used in the study are created from codelists of clinical conditions or
# numerical values available on a patient's records.
# This script fetches all of the codelists identified in codelists.txt from OpenCodelists.

######################################


# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import codelist, codelist_from_csv, combine_codelists


# --- CODELISTS ---

### sepsis_hosp
sepsis_hosp = codelist_from_csv(
  "codelists/user-BillyZhongUOM-codes_for_sepsis.csv",
  system = "icd10",
  column = "code"
)

###  sepsis gp
sepsis_gp= codelist_from_csv(
  "codelists/user-rriefu-sepsis.csv",
  system = "snomed",
  column = "code"
)

#Covid diagnosis
covid_primary_care_code = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv",
    system="ctv3",
    column="CTV3ID",
    )

covid_primary_care_positive_test = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv",
    system="ctv3",
    column="CTV3ID",
    )

covid_primary_care_sequalae = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv",
    system="ctv3",
    column="CTV3ID",
    )

any_primary_care_code = combine_codelists(
    covid_primary_care_code,
    covid_primary_care_positive_test,
    covid_primary_care_sequalae,
    )

## COVID codelist

covid_codelist = codelist(["U071", "U072"], system="icd10")
confirmed_covid_codelist = codelist(["U071"], system="icd10")
suspected_covid_codelist = codelist(["U072"], system="icd10")
