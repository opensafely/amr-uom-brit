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
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
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


### adverse-event

### by type
ae_hematologic_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_-hematologic.csv",
  system = "icd10",
  column = "code"
)
ae_behavioral_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_behavioral-syndromes.csv",
  system = "icd10",
  column = "code"
)
ae_circulatory_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_circulatory-system.csv",
  system = "icd10",
  column = "code"
)
ae_digestive_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_digestive-system.csv",
  system = "icd10",
  column = "code"
)
ae_endocrine_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_endocrine.csv",
  system = "icd10",
  column = "code"
)
ae_eyeear_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_eye-and-ear.csv",
  system = "icd10",
  column = "code"
)
ae_genitourinary_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_genitourinary-system-other-than-kidney.csv",
  system = "icd10",
  column = "code"
)
ae_liver_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_liver.csv",
  system = "icd10",
  column = "code"
)
ae_nervous_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_nervous-system.csv",
  system = "icd10",
  column = "code"
)
ae_musculoskeletal_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_musculoskeletal-system-and-connective-tissue.csv",
  system = "icd10",
  column = "code"
)
ae_poisoning_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_poisoning.csv",
  system = "icd10",
  column = "code"
)
ae_renal_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_renal.csv",
  system = "icd10",
  column = "code"
)
ae_respiratory_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_respiratory-system.csv",
  system = "icd10",
  column = "code"
)
ae_skin_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_skin-and-subcutaneous-tissue.csv",
  system = "icd10",
  column = "code"
)
ae_unclassified_code = codelist_from_csv(
  "codelists/user-BillyZhongUOM-ae_unclassified.csv",
  system = "icd10",
  column = "code"
)

###all adverse-event
all_ae_codes = combine_codelists(ae_hematologic_code,ae_behavioral_code,ae_circulatory_code,ae_digestive_code,
                                 ae_endocrine_code,ae_eyeear_code,ae_genitourinary_code,ae_liver_code,
                                 ae_nervous_code,ae_musculoskeletal_code,ae_poisoning_code,ae_renal_code,
                                 ae_respiratory_code,ae_skin_code,ae_unclassified_code)

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
charlson03_copd= codelist_from_csv(
  "codelists/user-yayang-charlson03_copd.csv",
  system = "snomed",
  column = "code"
)
charlson04_heart_failure= codelist_from_csv(
  "codelists/user-yayang-charlson04_heart_failure.csv",
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
charlson09_hemiplegia= codelist_from_csv(
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
charlson14_moderate_several_renal_disease= codelist_from_csv(
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