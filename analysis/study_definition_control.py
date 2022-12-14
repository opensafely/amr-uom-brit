
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
start_date = "2020-01-01"
end_date = "2020-03-31"

# # ###### Import variables

from variables_infections import generate_infection_variables
infection_variables = generate_infection_variables(index_date_variable="patient_index_date")


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
        AND NOT stp = ""
        AND has_infection
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
        ),

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="patient_index_date - 365 days",
            end_date="patient_index_date",
            return_expectations={"incidence": 0.95},
        ),

        has_infection=patients.with_these_clinical_events(
            all_infection_codes,  
            between=["2020-01-01", "2020-03-31"],
            returning="binary_flag"
        ),

    ),

    patient_index_date=patients.with_these_clinical_events(
        all_infection_codes,
        returning='date',
        find_first_match_in_period=True,
        between=["2020-01-01", "2020-03-31"], 
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-01-01"}, "incidence" : 1},
            ),


    ## Age
    age=patients.age_as_of(
        "patient_index_date",
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

    # Region - NHS England 9 regions
    region=patients.registered_practice_as_of(
        "patient_index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                  "North East": 0.1,
                  "North West": 0.1,
                  "Yorkshire and The Humber": 0.1,
                  "East Midlands": 0.1,
                  "West Midlands": 0.1,
                  "East": 0.1,
                  "London": 0.2,
                  "South West": 0.1,
                  "South East": 0.1, }, },
        },
    ),

    has_outcome_1yr=patients.admitted_to_hospital(
            with_these_primary_diagnoses=outcome_code,  # only include primary_diagnoses as covid
            between=["patient_index_date- 366 days", "patient_index_date - 1 day"],
            return_expectations={"incidence": 0.65},
    ),

    has_outcome_6weekafter=patients.admitted_to_hospital(
            with_these_primary_diagnoses=outcome_code,  # only include primary_diagnoses as covid
            between=["patient_index_date + 42 days", "patient_index_date"],
            return_expectations={"incidence": 0.65},
    ),
  
    **infection_variables,

)