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
antibacterials_codes_brit = codelist_from_csv(
    "codelists/user-rriefu-antibiotics_dmd.csv", system="snomed", column="dmd_id"
)


### broad antibacterials
broad_spectrum_antibiotics_codes = codelist_from_csv(
    "codelists/user-rriefu-broad-spectrum-antibiotics.csv", system="snomed", column="dmd_id"
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
    "codelists/user-rriefu-cold_subset.csv", system="snomed", column="code")

### ethnicity 
ethnicity_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth2001.csv",
    system="snomed",
    column="code",
    category_column="grouping_6_id",
)


### bmi 
bmi_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi_stage.csv",
    system="snomed",
    column="code",
)

#Smoking
clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

unclear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

### flu vaccine
flu_med_codes = codelist_from_csv(
    "codelists/opensafely-influenza-vaccination.csv",
    system="snomed",
    column="snomed_id",
)

flu_clinical_given_codes = codelist_from_csv(
    "codelists/opensafely-influenza-vaccination-clinical-codes-given.csv",
    system="ctv3",
    column="CTV3ID",
)

flu_clinical_not_given_codes = codelist_from_csv(
    "codelists/opensafely-influenza-vaccination-clinical-codes-not-given.csv",
    system="ctv3",
    column="CTV3ID",
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

# COVID vaccination medication codes
covrx_code = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covrx.csv",
    system="snomed",
    column="code",
)


### asthma & COPD
asthma_copd_codes= codelist_from_csv(
  "codelists/user-rriefu-asthma_copd.csv",
  system = "snomed",
  column = "code"
)


### asthma 
asthma_codes= codelist_from_csv(
  "codelists/user-rriefu-asthma.csv",
  system = "snomed",
  column = "code"
)


### cold
cold_codes= codelist_from_csv(
  "codelists/user-rriefu-cold_subset.csv",
  system = "snomed",
  column = "code"
)


### copd
copd_codes= codelist_from_csv(
  "codelists/user-rriefu-copd.csv",
  system = "snomed",
  column = "code"
)

### cough & cold  
cough_cold_codes= codelist_from_csv(
  "codelists/user-rriefu-cough_cold.csv",
  system = "snomed",
  column = "code"
)


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


###  renal
renal_codes= codelist_from_csv(
  "codelists/user-rriefu-renal.csv",
  system = "snomed",
  column = "code"
)


###  sepsis
sepsis_codes= codelist_from_csv(
  "codelists/user-rriefu-sepsis.csv",
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


## all infections
all_infection_codes = combine_codelists(asthma_copd_codes, asthma_codes, cold_codes, copd_codes, 
      cough_cold_codes, cough_codes, lrti_codes, ot_externa_codes, otmedia_codes, pneumonia_codes, 
      renal_codes, sepsis_codes, sinusitis_codes, throat_codes, urti_codes, uti_codes )


###  vaccination
vaccination_codes = codelist_from_csv(
    "codelists/user-rriefu-vaccination.csv", system="snomed", column="code"
)

## Patients in long-stay nursing and residential care
carehome_primis_codes = codelist_from_csv(
  "codelists/primis-covid19-vacc-uptake-longres.csv",
  system = "snomed",
  column = "code",
)

##Charlson comobidities
charlson01_cancer= codelist_from_csv(
  "codelists/user-yayang-charlson01_cancer.csv",
  system = "snomed",
  column = "code"
)
charlson02_cvd= codelist_from_csv(
  "codelists/user-yayang-charlson02_cvd.csv",
  system = "snomed",
  column = "code"
)
charlson04_heart_failure= codelist_from_csv(
  "codelists/user-yayang-charlson03_copd.csv",
  system = "snomed",
  column = "code"
)
charlson05_connective_tissue= codelist_from_csv(
  "codelists/user-yayang-charlson05_connective_tissue.csv",
  system = "snomed",
  column = "code"
)
charlson06_dementia= codelist_from_csv(
  "codelists/user-yayang-charlson06_dementia.csv",
  system = "snomed",
  column = "code"
)
charlson07_diabetes= codelist_from_csv(
  "codelists/user-yayang-charlson07_diabetes.csv",
  system = "snomed",
  column = "code"
)
charlson08_diabetes_with_complications= codelist_from_csv(
  "codelists/user-yayang-charlson08_diabetes_with_complications.csv",
  system = "snomed",
  column = "code"
)
charlson09_hemiplegiad= codelist_from_csv(
  "codelists/user-yayang-charlson09_hemiplegia.csv",
  system = "snomed",
  column = "code"
)
charlson10_hiv= codelist_from_csv(
  "codelists/user-yayang-charlson10_hiv.csv",
  system = "snomed",
  column = "code"
)
charlson11_metastatic_cancer= codelist_from_csv(
  "codelists/user-yayang-charlson11_metastatic_cancer.csv",
  system = "snomed",
  column = "code"
)
charlson12_mild_liver= codelist_from_csv(
  "codelists/user-yayang-charlson12_mild_liver.csv",
  system = "snomed",
  column = "code"
)
charlson13_mod_severe_liver= codelist_from_csv(
  "codelists/user-yayang-charlson13_mod_severe_liver.csv",
  system = "snomed",
  column = "code"
)
charlson14_moderate_several_renaldiseae= codelist_from_csv(
  "codelists/user-yayang-charlson14_moderate_several_renaldiseae.csv",
  system = "snomed",
  column = "code"
)
charlson15_mi= codelist_from_csv(
  "codelists/user-yayang-charlson15_mi.csv",
  system = "snomed",
  column = "code"
)
charlson16_peptic_ulcer= codelist_from_csv(
  "codelists/user-yayang-charlson16_peptic_ulcer.csv",
  system = "snomed",
  column = "code"
)
charlson17_peripheral_vascular= codelist_from_csv(
  "codelists/user-yayang-charlson17_peripheral_vascular.csv",
  system = "snomed",
  column = "code"
)