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

## COVID codelist

covid_codelist = codelist(["U071", "U072"], system="icd10")
confirmed_covid_codelist = codelist(["U071"], system="icd10")
suspected_covid_codelist = codelist(["U072"], system="icd10")



## comobidity
aplastic_codes = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv", system="ctv3", column="CTV3ID"
)

hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv", system="ctv3", column="CTV3ID"
)

permanent_immune_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

temp_immune_codes = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

stroke = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv", system="ctv3", column="CTV3ID"
)

dementia = codelist_from_csv(
    "codelists/opensafely-dementia.csv", system="ctv3", column="CTV3ID"
)

other_neuro = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions.csv",
    system="ctv3",
    column="CTV3ID",
)


chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

asthma_codes = codelist_from_csv(
    "codelists/opensafely-current-asthma.csv", system="ctv3", column="CTV3ID"
)

salbutamol_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-salbutamol-medication.csv",
    system="snomed",
    column="id",
)

ics_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv",
    system="snomed",
    column="id",
)

pred_codes = codelist_from_csv(
    "codelists/opensafely-asthma-oral-prednisolone-medication.csv",
    system="snomed",
    column="snomed_id",
)

chronic_cardiac_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv", system="ctv3", column="CTV3ID"
)


diabetes_t1_codes = codelist_from_csv(
    "codelists/opensafely-type-1-diabetes.csv", system="ctv3", column="CTV3ID"
)

diabetes_t2_codes = codelist_from_csv(
    "codelists/opensafely-type-2-diabetes.csv", system="ctv3", column="CTV3ID"
)

diabetes_unknown_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-unknown-type.csv", system="ctv3", column="CTV3ID"
)

diabetes_t1t2_codes_exeter = codelist_from_csv(
        "codelists/opensafely-diabetes-exeter-group.csv", 
        system="ctv3", 
        column="CTV3ID",
        category_column="Category",
)

lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv", system="ctv3", column="CTV3ID"
)

haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv", system="ctv3", column="CTV3ID"
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)

chronic_liver_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv", system="ctv3", column="CTV3ID"
)
gi_bleed_and_ulcer_codes = codelist_from_csv(
    "codelists/opensafely-gi-bleed-or-ulcer.csv", system="ctv3", column="CTV3ID"
)
inflammatory_bowel_disease_codes = codelist_from_csv(
    "codelists/opensafely-inflammatory-bowel-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

creatinine_codes = codelist(["XE2q5"], system="ctv3")

hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")


dialysis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease.csv", system="ctv3", column="CTV3ID"
)

organ_transplant_codes = codelist_from_csv(
    "codelists/opensafely-solid-organ-transplantation.csv",
    system="ctv3",
    column="CTV3ID",
)

spleen_codes = codelist_from_csv(
    "codelists/opensafely-asplenia.csv", system="ctv3", column="CTV3ID"
)

sickle_cell_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease.csv", system="ctv3", column="CTV3ID"
)

ra_sle_psoriasis_codes = codelist_from_csv(
    "codelists/opensafely-ra-sle-psoriasis.csv", system="ctv3", column="CTV3ID"
)

systolic_blood_pressure_codes = codelist(["2469."], system="ctv3")
diastolic_blood_pressure_codes = codelist(["246A."], system="ctv3")

hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv", system="ctv3", column="CTV3ID"
)

# MEDICATION CODELISTS
ace_codes = codelist_from_csv(
    "codelists/opensafely-ace-inhibitor-medications.csv",
    system="snomed",
    column="id",
)

alpha_blocker_codes = codelist_from_csv(
    "codelists/opensafely-alpha-adrenoceptor-blocking-drugs.csv",
    system="snomed",
    column="id",
)

arb_codes = codelist_from_csv(
    "codelists/opensafely-angiotensin-ii-receptor-blockers-arbs.csv",
    system="snomed",
    column="id",
)

betablocker_codes = codelist_from_csv(
    "codelists/opensafely-beta-blocker-medications.csv",
    system="snomed",
    column="id",
)

calcium_channel_blockers_codes = codelist_from_csv(
    "codelists/opensafely-calcium-channel-blockers.csv",
    system="snomed",
    column="id",
)

combination_bp_med_codes = codelist_from_csv(
    "codelists/opensafely-combination-blood-pressure-medication.csv",
    system="snomed",
    column="id",
)

spironolactone_codes = codelist_from_csv(
    "codelists/opensafely-spironolactone.csv",
    system="snomed",
    column="id",
)

thiazide_type_diuretic_codes = codelist_from_csv(
    "codelists/opensafely-thiazide-type-diuretic-medication.csv",
    system="snomed",
    column="id",
)

insulin_med_codes = codelist_from_csv(
    "codelists/opensafely-insulin-medication.csv", 
    system="snomed", 
    column="id"
)

statin_med_codes = codelist_from_csv(
    "codelists/opensafely-statin-medication.csv", 
    system="snomed", 
    column="id"
)

oad_med_codes = codelist_from_csv(
    "codelists/opensafely-antidiabetic-drugs.csv",
    system="snomed",
    column="id"
)
