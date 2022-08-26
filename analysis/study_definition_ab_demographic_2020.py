

from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)

###### import matched cohort
COHORT = "output/cohort_1_id_2020.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2020-01-01"
end_date = "2020-12-31"


study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.1,
    },

    # Set index date to start date
    index_date=start_date,
   
    # study population
    population=patients.which_exist_in_file(COHORT),

    ### patient index date  
    # case_infection_date
    patient_index_date=patients.with_value_from_file(
        COHORT,
        returning="patient_index_date",
        returning_type="date",
    ),


## region
    stp=patients.registered_practice_as_of(
             "patient_index_date",
            returning="stp_code",
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "STP1": 0.1,
                        "STP2": 0.1,
                        "STP3": 0.1,
                        "STP4": 0.1,
                        "STP5": 0.1,
                        "STP6": 0.1,
                        "STP7": 0.1,
                        "STP8": 0.1,
                        "STP9": 0.1,
                        "STP10": 0.1,
                    }
                },
            },
    ),

    # updated ethnicity extraction
    ethnicity=patients.with_ethnicity_from_sus(
        returning="group_6",
        use_most_frequent_code=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),


    # index of multiple deprivation, estimate of SES based on patient post code 
	imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "patient_index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
    ),   
    
    ##REGION
    region=patients.registered_practice_as_of(
    "patient_index_date",
    returning="nuts1_region_name",
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "North East": 0.1,
                "North West": 0.1,
                "Yorkshire and the Humber": 0.1,
                "East Midlands": 0.1,
                "West Midlands": 0.1,
                "East of England": 0.1,
                "London": 0.2,
                "South East": 0.2, },},
         },
    ),

     ######### comorbidities

    cancer_comor=patients.with_these_clinical_events(
        charlson01_cancer,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    cardiovascular_comor=patients.with_these_clinical_events(
        charlson02_cvd,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    chronic_obstructive_pulmonary_comor=patients.with_these_clinical_events(
       charlson03_copd,
       between=["patient_index_date - 5 years", "patient_index_date"],
       returning="binary_flag",
       find_last_match_in_period=True,
       return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
       },
    ),

    heart_failure_comor=patients.with_these_clinical_events(
       charlson04_heart_failure,
       between=["patient_index_date - 5 years", "patient_index_date"],
       returning="binary_flag",
       find_last_match_in_period=True,
       return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
       },
    ),

    connective_tissue_comor=patients.with_these_clinical_events(
        charlson05_connective_tissue,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    dementia_comor=patients.with_these_clinical_events(
        charlson06_dementia,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    diabetes_comor=patients.with_these_clinical_events(
        charlson07_diabetes,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    diabetes_complications_comor=patients.with_these_clinical_events(
        charlson08_diabetes_with_complications,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    hemiplegia_comor=patients.with_these_clinical_events(
        charlson09_hemiplegia,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    hiv_comor=patients.with_these_clinical_events(
        charlson10_hiv,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    metastatic_cancer_comor=patients.with_these_clinical_events(
        charlson11_metastatic_cancer,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    mild_liver_comor=patients.with_these_clinical_events(
        charlson12_mild_liver,
        between=["patient_index_date - 5 years", "patient_index_date"], 
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    mod_severe_liver_comor=patients.with_these_clinical_events(
        charlson13_mod_severe_liver,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    mod_severe_renal_comor=patients.with_these_clinical_events(
        charlson14_moderate_several_renal_disease,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    mi_comor=patients.with_these_clinical_events(
        charlson15_mi,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    peptic_ulcer_comor=patients.with_these_clinical_events(
        charlson16_peptic_ulcer,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),

    peripheral_vascular_comor=patients.with_these_clinical_events(
        charlson17_peripheral_vascular,
        between=["patient_index_date - 5 years", "patient_index_date"],
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-01-01"}
        },
    ),
)