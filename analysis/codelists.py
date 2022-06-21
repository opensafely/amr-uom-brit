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
    "codelists/user-rriefu-antibiotics_dmd.csv", system="snomed", column="dmd_id", category_column="type",
)


### broad antibacterials
broad_spectrum_antibiotics_codes = codelist_from_csv(
    "codelists/user-rriefu-broad-spectrum-antibiotics.csv", system="snomed", column="dmd_id", category_column="type",
)

broad_spectrum_antibiotics_op = codelist_from_csv(
    "codelists/user-BillyZhongUOM-broad_spectrum_op.csv", system="snomed", column="dmd_id", category_column="type",
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
all_indication_codes = combine_codelists(asthma_copd_codes, asthma_codes, cold_codes, copd_codes, 
      cough_cold_codes, cough_codes, lrti_codes, ot_externa_codes, otmedia_codes, pneumonia_codes, 
      renal_codes, sepsis_codes, sinusitis_codes, throat_codes, urti_codes, uti_codes )

## 6 common infection
## all infections
six_indication_codes = combine_codelists( lrti_codes, ot_externa_codes, otmedia_codes, sinusitis_codes, urti_codes, uti_codes )


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


# ab types: 79
# codes_ab_type_Amikacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_amikacincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Amoxicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_amoxicillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Ampicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ampicillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Azithromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_azithromycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Aztreonam= codelist_from_csv('codelists/user-yayang-codes_ab_type_aztreonamcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Benzylpenicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_benzylpenicillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefaclor= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefaclorcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefadroxil= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefadroxilcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefalexin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefalexincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefamandole= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefamandolecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefazolin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefazolincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefepime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefepimecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefixime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefiximecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefotaxime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefotaximecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefoxitin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefoxitincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefpirome= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefpiromecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefpodoxime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefpodoximecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefprozil= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefprozilcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefradine= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefradinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Ceftazidime= codelist_from_csv('codelists/user-yayang-codes_ab_type_ceftazidimecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Ceftriaxone= codelist_from_csv('codelists/user-yayang-codes_ab_type_ceftriaxonecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cefuroxime= codelist_from_csv('codelists/user-yayang-codes_ab_type_cefuroximecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Chloramphenicol= codelist_from_csv('codelists/user-yayang-codes_ab_type_chloramphenicolcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Cilastatin= codelist_from_csv('codelists/user-yayang-codes_ab_type_cilastatincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Ciprofloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ciprofloxacincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Clarithromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_clarithromycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Clindamycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_clindamycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Co_amoxiclav= codelist_from_csv('codelists/user-yayang-codes_ab_type_co-amoxiclavcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Co_fluampicil= codelist_from_csv('codelists/user-yayang-codes_ab_type_co-fluampicilcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Colistimethate= codelist_from_csv('codelists/user-yayang-codes_ab_type_colistimethatecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Dalbavancin= codelist_from_csv('codelists/user-yayang-codes_ab_type_dalbavancincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Dalfopristin= codelist_from_csv('codelists/user-yayang-codes_ab_type_dalfopristincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Daptomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_daptomycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Demeclocycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_demeclocyclinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Doripenem= codelist_from_csv('codelists/user-yayang-codes_ab_type_doripenemcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Doxycycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_doxycyclinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Ertapenem= codelist_from_csv('codelists/user-yayang-codes_ab_type_ertapenemcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Erythromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_erythromycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Fidaxomicin= codelist_from_csv('codelists/user-yayang-codes_ab_type_fidaxomicincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Flucloxacillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_flucloxacillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Fosfomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_fosfomycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Fusidate= codelist_from_csv('codelists/user-yayang-codes_ab_type_fusidatecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Gentamicin= codelist_from_csv('codelists/user-yayang-codes_ab_type_gentamicincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Levofloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_levofloxacincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Linezolid= codelist_from_csv('codelists/user-yayang-codes_ab_type_linezolidcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Lymecycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_lymecyclinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Meropenem= codelist_from_csv('codelists/user-yayang-codes_ab_type_meropenemcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Methenamine= codelist_from_csv('codelists/user-yayang-codes_ab_type_methenaminecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Metronidazole= codelist_from_csv('codelists/user-yayang-codes_ab_type_metronidazolecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Minocycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_minocyclinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Moxifloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_moxifloxacincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Nalidixic_acid= codelist_from_csv('codelists/user-yayang-codes_ab_type_nalidixic-acidcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Neomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_neomycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Netilmicin= codelist_from_csv('codelists/user-yayang-codes_ab_type_netilmicincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Nitazoxanid= codelist_from_csv('codelists/user-yayang-codes_ab_type_nitazoxanidcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Nitrofurantoin= codelist_from_csv('codelists/user-yayang-codes_ab_type_nitrofurantoincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Norfloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_norfloxacincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Ofloxacin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ofloxacincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Oxytetracycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_oxytetracyclinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Phenoxymethylpenicillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_phenoxymethylpenicillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Piperacillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_piperacillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Pivmecillinam= codelist_from_csv('codelists/user-yayang-codes_ab_type_pivmecillinamcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Pristinamycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_pristinamycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Rifaximin= codelist_from_csv('codelists/user-yayang-codes_ab_type_rifaximincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Sulfadiazine= codelist_from_csv('codelists/user-yayang-codes_ab_type_sulfadiazinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Sulfamethoxazole= codelist_from_csv('codelists/user-yayang-codes_ab_type_sulfamethoxazolecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Sulfapyridine= codelist_from_csv('codelists/user-yayang-codes_ab_type_sulfapyridinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Taurolidin= codelist_from_csv('codelists/user-yayang-codes_ab_type_taurolidincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Tedizolid= codelist_from_csv('codelists/user-yayang-codes_ab_type_tedizolidcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Teicoplanin= codelist_from_csv('codelists/user-yayang-codes_ab_type_teicoplanincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Telithromycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_telithromycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Temocillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_temocillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Tetracycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_tetracyclinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Ticarcillin= codelist_from_csv('codelists/user-yayang-codes_ab_type_ticarcillincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Tigecycline= codelist_from_csv('codelists/user-yayang-codes_ab_type_tigecyclinecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Tinidazole= codelist_from_csv('codelists/user-yayang-codes_ab_type_tinidazolecsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Tobramycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_tobramycincsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Trimethoprim= codelist_from_csv('codelists/user-yayang-codes_ab_type_trimethoprimcsv.csv', system ='snomed',column ='dmd_id')
# codes_ab_type_Vancomycin= codelist_from_csv('codelists/user-yayang-codes_ab_type_vancomycincsv.csv', system ='snomed',column ='dmd_id')

## hospitalisation_analysis
hospitalisation_infection_related = codelist_from_csv(
  "codelists/user-alifahmi-hospital-admissions-with-infection-related-complication.csv",
  system="icd10",
  column="code",
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

antibiotics_indications= codelist_from_csv(
  "codelists/user-yayang-antibiotics_indications.csv",
  system = "snomed",
  column = "code",
  category_column="category",
)

codes_ab_type_Trimethoprim= codelist_from_csv('codelists/user-yayang-codes_ab_type_trimethoprimcsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Nitrofurantoin= codelist_from_csv('codelists/user-yayang-codes_ab_type_nitrofurantoincsv.csv', system ='snomed',column ='dmd_id')
codes_ab_type_Trimethoprim_op= codelist_from_csv('codelists/user-yayang-trimethoprim_op.csv', system ='snomed',column ='dmd')
codes_ab_type_Nitrofurantoin_op= codelist_from_csv('codelists/user-yayang-nitrofurantoin_op.csv', system ='snomed',column ='dmd')



broad_spec_op= codelist_from_csv('codelists/user-BillyZhongUOM-broad_spec_op_codelist.csv', system ='snomed',column ='dmd_id')