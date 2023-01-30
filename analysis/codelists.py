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


# Smoking
clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

# COMORBIDITIES
# Hypertension diagnosis
hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv",
    system="ctv3",
    column="CTV3ID",
)

# Chronic respiratory disease diagnosis
chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

# Asthma diagnosis
asthma_codes = codelist_from_csv(
    "codelists/opensafely-asthma-diagnosis.csv",
    system="ctv3",
    column="CTV3ID",
)

# Blood pressure
systolic_blood_pressure_codes = codelist(
    ["2469."],
    system="ctv3",)
diastolic_blood_pressure_codes = codelist(
    ["246A."],
    system="ctv3")

# Presence of a prescription for a course of prednisolone (likely to be related
# to poor asthma control)
pred_codes = codelist_from_csv(
    "codelists/opensafely-asthma-oral-prednisolone-medication.csv",
    system="snomed",
    column="snomed_id",
)

# Chronic cardiac disease diagnosis
chronic_cardiac_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

# Diabetes diagnosis
diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes.csv",
    system="ctv3",
    column="CTV3ID",
)

# Measures of hba1c
# 'new' codes: hba1c in mmol/mol
hba1c_new_codes = codelist_from_csv(
    "codelists/opensafely-glycated-haemoglobin-hba1c-tests-ifcc.csv",
    system="ctv3",
    column="code",
)
# 'old' codes: hba1c in percentage, should not be used in clinical practice but
#  alas it is sometimes best to use both
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")

# Cancer diagnosis
haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv",
    system="ctv3",
    column="CTV3ID",
)

lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv",
    system="ctv3",
    column="CTV3ID",
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)

# Dialysis
dialysis_codes = codelist_from_csv(
  "codelists/opensafely-dialysis.csv",
  system="ctv3",
  column="CTV3ID",
)

# Kidney transplant
kidney_transplant_codes = codelist_from_csv(
  "codelists/opensafely-kidney-transplant.csv",
  system="ctv3",
  column="CTV3ID",
)

# Creatinine codes
creatinine_codes = codelist(["XE2q5"], system="ctv3")

# Chronic liver disease diagnosis
chronic_liver_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

# Stroke
stroke = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv",
    system="ctv3",
    column="CTV3ID",
)

# Dementia diagnosis
dementia = codelist_from_csv(
    "codelists/opensafely-dementia.csv",
    system="ctv3",
    column="CTV3ID",
)

# Other neurolgoical conditions
other_neuro = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions.csv",
    system="ctv3",
    column="CTV3ID",
)

# Presence of organ transplant (excluding kidney transplants)
other_organ_transplant_codes = codelist_from_csv(
    "codelists/opensafely-other-organ-transplant.csv",
    system="ctv3",
    column="CTV3ID",
)

# Asplenia or dysplenia (acquired or congenital) diagnosis
spleen_codes = codelist_from_csv(
    "codelists/opensafely-asplenia.csv",
    system="ctv3",
    column="CTV3ID",
)

# Sickle cell disease diagnosis
sickle_cell_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease.csv",
    system="ctv3",
    column="CTV3ID",
)
# Rheumatoid/Lupus/Psoriasis diagnosis
ra_sle_psoriasis_codes = codelist_from_csv(
    "codelists/opensafely-ra-sle-psoriasis.csv",
    system="ctv3",
    column="CTV3ID",
)

# Immunosuppressive condition
immunosupression_diagnosis_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-immdx_cov.csv",
    system="snomed",
    column="code",
)
immunosuppression_medication_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-immrx.csv",
    system="snomed",
    column="code",
)
# Learning disabilities
learning_disability_codes = codelist_from_csv(
  "codelists/nhsd-primary-care-domain-refsets-ld_cod.csv",
  system="snomed",
  column="code",
)

# Severe mental illness
sev_mental_ill_codes = codelist_from_csv(
  "codelists/primis-covid19-vacc-uptake-sev_mental.csv",
  system="snomed",
  column="code",
)

