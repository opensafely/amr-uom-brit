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
COHORT = "output/p_control_id.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2019-01-01"
end_date = "2023-03-31"


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

    # sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
   #Check COVID-diagnsis within +/- 6 weeks #

    ## covid infection record sgss+gp ##
    SGSS_positive_6weeks=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["patient_index_date - 42 days","patient_index_date + 42 days"],
        returning="binary_flag",
        return_expectations={
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),
    
    GP_positive_6weeks=patients.with_these_clinical_events(
        any_primary_care_code,        
        returning="binary_flag",
        between=["patient_index_date - 42 days","patient_index_date + 42 days"],
         return_expectations={
        "rate" : "exponential_increase",
        "incidence" : 0.25},  ),

        ## covid infection record hosp ##
    covid_admission_6weeks=patients.admitted_to_hospital(
        returning="binary_flag",
        with_these_diagnoses=covid_codelist,
        between=["patient_index_date - 42 days","patient_index_date + 42 days"],
        return_expectations={
        "rate" : "exponential_increase",
        "incidence" : 0.25},    ),

    covid_6weeks=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                  SGSS_positive_6weeks OR GP_positive_6weeks OR covid_admission_6weeks
            """,
        },
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "0": 0.8,
                                        "1": 0.2
                                        }
                                    },
                                },
    ),

    ab_history_3yr=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["patient_index_date - 1185 days","patient_index_date - 90 days"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),
 ) 