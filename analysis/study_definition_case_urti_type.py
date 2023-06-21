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
COHORT = "output/matched_cases_urti.csv"

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

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2019-01-01"
end_date = "2023-03-31"

####### Import variables
## Exposure variables: antibiotics 
from variables_antibiotics import generate_ab_variables
from variables_CCI import generate_CCI_variables
ab_variables = generate_ab_variables(index_date_variable="emergency_admission_date")
CCI_variables = generate_CCI_variables(index_date_variable="emergency_admission_date")


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
        date_format="YYYY-MM-DD",  
    ),

    emergency_admission_date=patients.with_value_from_file(
        COHORT,
        returning="emergency_admission_date",
        returning_type="date",
        date_format="YYYY-MM-DD",  
    ),

    side_effect=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=urti_sideeffect,
        with_admission_method=emergency_admission_codes,  
        between=["emergency_admission_date", "emergency_admission_date"], 
        find_first_match_in_period=True, 
    ),

    disease=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=urti_disease,
        with_admission_method=emergency_admission_codes,  
        between=["emergency_admission_date", "emergency_admission_date"], 
        find_first_match_in_period=True, 
    ),

    outcome_type=patients.categorised_as(
        {
            "blank": "DEFAULT",
            "side effect": """side_effect AND NOT disease""",
            "disease": """disease AND NOT side_effect"""
        },
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "blank": 0.05,
                                        "side effect": 0.85,
                                        "disease":0.1
                                        }
                                    },
                                },
    ),

) 