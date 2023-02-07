######################################

# Some covariates used in the study are created from codelists of clinical conditions or
# numerical values available on a patient's records.
# This script fetches all of the codelists identified in codelists.txt from OpenCodelists.

######################################


# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import codelist, codelist_from_csv, combine_codelists


# --- CODELISTS ---

ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)


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

# HAZARDOUS ALCOHOL USE CODELIST
hazardous_alcohol_codes = codelist_from_csv(
    "codelists/opensafely-hazardous-alcohol-drinking.csv", system="ctv3", column="code",
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

antibacterials_codes_brit = codelist_from_csv(
    "codelists/user-BillyZhongUOM-brit_new_dmd.csv", system="snomed", column="dmd_id", category_column="type",
)
## ab types: 79
codes_ab_type_Amikacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_amikacincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Amoxicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_amoxicillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Ampicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ampicillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Azithromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_azithromycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Aztreonam= codelist_from_csv('codelists/user-yayang-codes_ab_type_aztreonamcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Benzylpenicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_benzylpenicillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefaclor= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefaclorcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefadroxil= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefadroxilcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefalexin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefalexincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefamandole= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefamandolecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefazolin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefazolincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefepime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefepimecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefixime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefiximecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefotaxime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefotaximecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefoxitin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefoxitincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefpirome= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefpiromecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefpodoxime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefpodoximecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefprozil= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefprozilcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefradine= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefradinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Ceftazidime= codelist_from_csv('codelists/user-yayang-codes_ab_type_ceftazidimecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Ceftriaxone= codelist_from_csv('codelists/user-yayang-codes_ab_type_ceftriaxonecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cefuroxime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefuroximecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Chloramphenicol= codelist_from_csv('codelists/user-yayang-codes_ab_type_chloramphenicolcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Cilastatin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cilastatincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Ciprofloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ciprofloxacincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Clarithromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_clarithromycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Clindamycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_clindamycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Co_amoxiclav= codelist_from_csv('codelists/user-yayang-codes_ab_type_co-amoxiclavcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Co_fluampicil= codelist_from_csv('codelists/user-yayang-codes_ab_type_co-fluampicilcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Colistimethate= codelist_from_csv('codelists/user-yayang-codes_ab_type_colistimethatecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Dalbavancin= codelist_from_csv('codelists/user-yayang-codes_ab_type_dalbavancincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Dalfopristin= codelist_from_csv('codelists/user-yayang-codes_ab_type_dalfopristincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Daptomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_daptomycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Demeclocycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_demeclocyclinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Doripenem= codelist_from_csv('codelists/user-yayang-codes_ab_type_doripenemcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Doxycycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_doxycyclinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Ertapenem= codelist_from_csv('codelists/user-yayang-codes_ab_type_ertapenemcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Erythromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_erythromycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Fidaxomicin= codelist_from_csv('codelists/user-yayang-codes_ab_type_fidaxomicincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Flucloxacillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_flucloxacillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Fosfomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_fosfomycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Fusidate= codelist_from_csv('codelists/user-yayang-codes_ab_type_fusidatecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Gentamicin= codelist_from_csv('codelists/user-yayang-codes_ab_type_gentamicincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Levofloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_levofloxacincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Linezolid= codelist_from_csv('codelists/user-yayang-codes_ab_type_linezolidcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Lymecycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_lymecyclinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Meropenem= codelist_from_csv('codelists/user-yayang-codes_ab_type_meropenemcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Methenamine= codelist_from_csv('codelists/user-yayang-codes_ab_type_methenaminecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Metronidazole= codelist_from_csv('codelists/user-yayang-codes_ab_type_metronidazolecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Minocycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_minocyclinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Moxifloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_moxifloxacincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Nalidixic_acid= codelist_from_csv('codelists/user-yayang-codes_ab_type_nalidixic-acidcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Neomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_neomycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Netilmicin= codelist_from_csv('codelists/user-yayang-codes_ab_type_netilmicincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Nitazoxanid= codelist_from_csv('codelists/user-yayang-codes_ab_type_nitazoxanidcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Nitrofurantoin= codelist_from_csv('codelists/user-yayang-codes_ab_type_nitrofurantoincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Norfloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_norfloxacincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Ofloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ofloxacincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Oxytetracycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_oxytetracyclinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Phenoxymethylpenicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_phenoxymethylpenicillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Piperacillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_piperacillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Pivmecillinam= codelist_from_csv('codelists/user-yayang-codes_ab_type_pivmecillinamcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Pristinamycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_pristinamycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Rifaximin= codelist_from_csv('codelists/user-yayang-codes_ab_type_rifaximincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Sulfadiazine= codelist_from_csv('codelists/user-yayang-codes_ab_type_sulfadiazinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Sulfamethoxazole= codelist_from_csv('codelists/user-yayang-codes_ab_type_sulfamethoxazolecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Sulfapyridine= codelist_from_csv('codelists/user-yayang-codes_ab_type_sulfapyridinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Taurolidin= codelist_from_csv('codelists/user-yayang-codes_ab_type_taurolidincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Tedizolid= codelist_from_csv('codelists/user-yayang-codes_ab_type_tedizolidcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Teicoplanin= codelist_from_csv('codelists/user-yayang-codes_ab_type_teicoplanincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Telithromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_telithromycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Temocillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_temocillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Tetracycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_tetracyclinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Ticarcillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ticarcillincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Tigecycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_tigecyclinecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Tinidazole= codelist_from_csv('codelists/user-yayang-codes_ab_type_tinidazolecsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Tobramycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_tobramycincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Trimethoprim= codelist_from_csv('codelists/user-yayang-codes_ab_type_trimethoprimcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Vancomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_vancomycincsv.csv', system ='snomed',column ='dmd_id')
