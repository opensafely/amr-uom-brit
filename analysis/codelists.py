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


antibacterials_codes_brit = codelist_from_csv(
    "codelists/user-BillyZhongUOM-brit_new_dmd.csv", system="snomed", column="dmd_id", category_column="type",
)


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
I15_codelist = codelist(["I158", "I159"], system="icd10")
I26_codelist = codelist(["I260", "I269"], system="icd10")
I31_codelist = codelist(["I312"], system="icd10")
I42_codelist = codelist(["I427"], system="icd10")
I44_codelist = codelist(["I44", "I440", "I441", "I442", "I443", "I444", "I445", "I446", "I447"], system="icd10")
I45_codelist = codelist(["I458"], system="icd10")
I46_codelist = codelist(["I461"], system="icd10")
I47_codelist = codelist(["I472"], system="icd10")
I49_codelist = codelist(["I490"], system="icd10")
I60_codelist = codelist(["I60"], system="icd10")
I61_codelist = codelist(["I61", "I610", "I611", "I612", "I613", "I614", "I615", "I616", "I618", "I619"], system="icd10")
I62_codelist = codelist(["I62"], system="icd10")
I80_codelist = codelist(["I80", "I800", "I801", "I802", "I803", "I808", "I809"], system="icd10")
I85_codelist = codelist(["I850"], system="icd10")
I95_codelist = codelist(["I95", "I952"], system="icd10")
J38_codelist = codelist(["J385"], system="icd10")
J45_codelist = codelist(["J450", "J451", "J458"], system="icd10")
J46_codelist = codelist(["J46"], system="icd10")
J70_codelist = codelist(["J702", "J703", "J704"], system="icd10")
J80_codelist = codelist(["J80"], system="icd10")
J81_codelist = codelist(["J81"], system="icd10")
N14_codelist = codelist(["N141", "N142", "N144"], system="icd10")
N17_codelist = codelist(["N17", "N170", "N171", "N172", "N178", "N179"], system="icd10")
N19_codelist = codelist(["N19"], system="icd10")
R00_codelist = codelist(["R001"], system="icd10")
R04_codelist = codelist(["R040", "R041", "R048", "R049"], system="icd10")
R06_codelist = codelist(["R060"], system="icd10")
R41_codelist = codelist(["R410"], system="icd10")
R42_codelist = codelist(["R42"], system="icd10")
R44_codelist = codelist(["R44", "R440", "R441", "R442", "R443"], system="icd10")
R50_codelist = codelist(["R502"], system="icd10")
R51_codelist = codelist(["R51"], system="icd10")
R55_codelist = codelist(["R55"], system="icd10")
R58_codelist = codelist(["R58"], system="icd10")
S06_codelist = codelist(["S064"], system="icd10")
X44_codelist = codelist(["X44"], system="icd10")
Y40_codelist = codelist(["Y40"], system="icd10")
Y41_codelist = codelist(["Y41"], system="icd10")
Y57_codelist = codelist(["Y57", "Y579"], system="icd10")
Y88_codelist = codelist(["Y880"], system="icd10")
Z88_codelist = codelist(["Z88"], system="icd10")
K25_codelist = codelist(["K25", "K250", "K251", "K252", "K253", "K254", "K255", "K256", "K257", "K259"], system="icd10")
K26_codelist = codelist(["K26", "K260", "K261", "K262", "K263", "K264", "K265", "K266", "K267", "K269"], system="icd10")
K27_codelist = codelist(["K27", "K270", "K271", "K272", "K273", "K274", "K275", "K276", "K277", "K279"], system="icd10")
K28_codelist = codelist(["K28", "K280", "K281", "K282", "K283", "K284", "K285", "K286", "K287", "K289", "K290"], system="icd10")
K52_codelist = codelist(["K521"], system="icd10")
K62_codelist = codelist(["K625"], system="icd10")
K66_codelist = codelist(["K661"], system="icd10")
K85_codelist = codelist(["K853"], system="icd10")
K92_codelist = codelist(["K920", "K921", "K922"], system="icd10")
R11_codelist = codelist(["R11"], system="icd10")
R17_codelist = codelist(["R17"], system="icd10")
E03_codelist = codelist(["E032"], system="icd10")
E06_codelist = codelist(["E064"], system="icd10")
E15_codelist = codelist(["E15"], system="icd10")
E16_codelist = codelist(["E160"], system="icd10")
E23_codelist = codelist(["E231"], system="icd10")
E24_codelist = codelist(["E242"], system="icd10")
E27_codelist = codelist(["E273"], system="icd10")
E66_codelist = codelist(["E661"], system="icd10")
E86_codelist = codelist(["E86"], system="icd10")
E87_codelist = codelist(["E87", "E870", "E871", "E872", "E873", "E874", "E875", "E876", "E877", "E878"], system="icd10")
N42_codelist = codelist(["N421"], system="icd10")
N62_codelist = codelist(["N62"], system="icd10")
N83_codelist = codelist(["N836", "N837"], system="icd10")
N85_codelist = codelist(["N857"], system="icd10")
N89_codelist = codelist(["N897"], system="icd10")
N92_codelist = codelist(["N921", "N922", "N923", "N924", "N926"], system="icd10")
N93_codelist = codelist(["N93"], system="icd10")
N95_codelist = codelist(["N950", "N953"], system="icd10")
R31_codelist = codelist(["R31"], system="icd10")
R34_codelist = codelist(["R34"], system="icd10")
D52_codelist = codelist(["D521"], system="icd10")
D59_codelist = codelist(["D590", "D592"], system="icd10")
D61_codelist = codelist(["D619"], system="icd10")
D64_codelist = codelist(["D642"], system="icd10")
D65_codelist = codelist(["D65"], system="icd10")
D68_codelist = codelist(["D684", "D688", "D689"], system="icd10")
D69_codelist = codelist(["D69", "D695", "D696", "D699"], system="icd10")
D70_codelist = codelist(["D70"], system="icd10")
R73_codelist = codelist(["R739"], system="icd10")
K71_codelist = codelist(["K71", "K710", "K711", "K712", "K713", "K714", "K715", "K716", "K717", "K718", "K719"], system="icd10")
K72_codelist = codelist(["K72", "K720", "K729"], system="icd10")
K75_codelist = codelist(["K759"], system="icd10")
K76_codelist = codelist(["K762", "K767"], system="icd10")
R74_codelist = codelist(["R740"], system="icd10")
T36_codelist = codelist(["T36", "T360", "T361", "T362", "T363", "T364", "T365", "T366", "T367", "T368", "T369"], system="icd10")
T37_codelist = codelist(["T378", "T379"], system="icd10")
T47_codelist = codelist(["T478", "T479"], system="icd10")
T50_codelist = codelist(["T509"], system="icd10")
T78_codelist = codelist(["T78", "T782", "T783", "T784", "T788", "T789"], system="icd10")
T88_codelist = codelist(["T887", "T887"], system="icd10")
L10_codelist = codelist(["L105"], system="icd10")
L20_codelist = codelist(["L20"], system="icd10")
L21_codelist = codelist(["L21", "L210", "L211"], system="icd10")
L26_codelist = codelist(["L26"], system="icd10")
L27_codelist = codelist(["L27", "L270", "L271", "L278", "L279"], system="icd10")
L28_codelist = codelist(["L28"], system="icd10")
L29_codelist = codelist(["L29", "L290", "L291", "L292", "L293", "L298", "L299"], system="icd10")
L30_codelist = codelist(["L30"], system="icd10")
L43_codelist = codelist(["L432"], system="icd10")
L50_codelist = codelist(["L500"], system="icd10")
L51_codelist = codelist(["L51", "L510", "L511", "L512", "L518", "L519"], system="icd10")
L52_codelist = codelist(["L52"], system="icd10")
L56_codelist = codelist(["L560", "L561", "L562"], system="icd10")
L64_codelist = codelist(["L640"], system="icd10")
L71_codelist = codelist(["L710"], system="icd10")
R20_codelist = codelist(["R20"], system="icd10")
R21_codelist = codelist(["R21"], system="icd10")
R23_codelist = codelist(["R23", "R233"], system="icd10")

### adverse-event-part 2
diarrhea = codelist(["R197"], system="icd10")
candidiasis = codelist(["B37", "B370","B371","B372","B373","B374","B375","B376","B377","B378","B379"], system="icd10")
## adverse-event-part 2
ae_study2 = combine_codelists(diarrhea,candidiasis)

cdi = codelist(["A047"], system="icd10")

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
                                 ae_respiratory_code,ae_skin_code,ae_unclassified_code,candidiasis)

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