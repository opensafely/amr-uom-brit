#### This script is to extract the variable in cases ####

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
COHORT = "output/cases_pneumonia.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2019-01-01"
end_date = "2023-03-31"

emergency_admission_codes = [
    "21",  # Emergency Admission: Emergency Care Department or dental casualty department of the Health Care Provider
    "22",  # Emergency Admission: GENERAL PRACTITIONER: after a request for immediate admission has been made direct to a Hospital Provider, i.e. not through a Bed bureau, by a GENERAL PRACTITIONER or deputy
    "23",  # Emergency Admission: Bed bureau
    "24",  # Emergency Admission: Consultant Clinic, of this or another Health Care Provider
    "25",  # Emergency Admission: Admission via Mental Health Crisis Resolution Team
    "2A",  # Emergency Admission: Emergency Care Department of another provider where the PATIENT  had not been admitted
    "2B",  # Emergency Admission: Transfer of an admitted PATIENT from another Hospital Provider in an emergency
    "2D",  # Emergency Admission: Other emergency admission
    "28"   # Emergency Admission: Other means, examples are:
           # - admitted from the Emergency Care Department of another provider where they had not been admitted
           # - transfer of an admitted PATIENT from another Hospital Provider in an emergency
           # - baby born at home as intended
    ]

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
    # DEMOGRAPHICS
    # age
    age=patients.age_as_of(
        "patient_index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    ###  emergency admission by type
    ae_hematologic=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_hematologic_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_behavioral=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_behavioral_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_circulatory=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_circulatory_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_digestive=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_digestive_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_endocrine=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_endocrine_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_eyeear=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_eyeear_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_genitourinary=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_genitourinary_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_liver=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_liver_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_nervous=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_nervous_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_musculoskeletal=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_musculoskeletal_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_poisoning=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_poisoning_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_renal=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_renal_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_respiratory=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_respiratory_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_skin=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_skin_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_unclassified=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=ae_unclassified_code,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

)