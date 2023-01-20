###################################################################

## This script is to extract the Spesis hospital admission cases ##

###################################################################

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
start_date = "2022-06-01"
end_date = "2022-12-31"

###### Cases definition ######
## 1. any age 
## 2. sex (M/F)
## 3. at least one year of GP records prior to their index date
## 4. sepsis admission 
## 5. has region (stp) information
## 6. has IMD 
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
        has_follow_up_previous_year
        AND (sex = "M" OR sex = "F")
        AND (age > 0 AND age <= 110)
        AND NOT region = ""
        AND has_outcome
        AND NOT imd = "0"
        """,

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="patient_index_date - 365 days",
            end_date="patient_index_date",
            return_expectations={"incidence": 0.95},
        ),

        has_outcome=patients.admitted_to_hospital(
            with_these_diagnoses=sepsis_hosp,  # include diagnoses as sepsis (primary or secondary)
            between=["2022-06-01","2022-12-31"],
        ),

    ),

    ### patient index date = sepsis hospital admission
    # sepsis hospital admission
    patient_index_date=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_diagnoses=sepsis_hosp,  # only include primary_diagnoses as covid
        on_or_after="index_date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2022-06-01"}, "incidence" : 1},
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


  )


