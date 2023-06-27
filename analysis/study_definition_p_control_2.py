#### This script is to extract the cases: emergency admission & AE ICD-10  + had event 30 days before the index date


from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2019-01-01"
end_date = "2023-03-31"

###### Cases definition ######
## 1. age 18-110
## 2. sex (M/F)
## 3. at least one year of GP records prior to their index date
## 4. has incident uti infeciton record (no any other uti infection record six weeks before)
## 4. has ICD-10 related emergency admission within 30 days after the infection
## 5. has no chronic res
##############################

study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 1,
    },

    # Set index date to start date
    index_date=start_date,
   
    # study population
    population=patients.satisfying(
        """
        NOT has_died
        AND has_follow_up_previous_year
        AND (sex = "M" OR sex = "F")
        AND (age >=18 AND age <= 110)
        AND NOT has_outcome
        AND NOT has_chronic_respiratory_disease
        """,

        has_died=patients.died_from_any_cause(
            on_or_before=end_date,
            returning="binary_flag",
        ),

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="2018-01-01",
            end_date="2023-03-31",
            return_expectations={"incidence": 0.95},
        ),

        has_outcome=patients.admitted_to_hospital(
            with_these_diagnoses=ae_study2,
            on_or_before=end_date,
        ),

        has_chronic_respiratory_disease=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes,  
            returning="binary_flag",
            on_or_before=end_date,
            find_last_match_in_period=True,
        ),

    ),


    ## Age
    age=patients.age_as_of(
        "2019-01-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
            "incidence": 0.001
        },
    ),
    
    ## Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

)