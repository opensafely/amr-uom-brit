###################################################################

## This script is to extract the controls  2020 part 1           ##

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
start_date = "2020-01-01"
end_date = "2020-06-30"

###### Controls definition ######
## 1. any age 
## 2. sex (M/F)
## 3. at least one year of GP records prior to their index date
## 4. No sepsis admission 
## 5. has region (stp) information
## 6. has IMD 
## 7. has no COVID
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
        AND NOT has_outcome
        AND NOT imd = "0"
        AND NOT has_SGSS_positive
        AND NOT has_GP_positive
        AND NOT has_covid_admission
        """,

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="index_date - 365 days",
            end_date="index_date",
            return_expectations={"incidence": 0.95},
        ),

        has_outcome=patients.admitted_to_hospital(
            with_these_diagnoses=sepsis_hosp,  # include diagnoses as sepsis (primary or secondary)
            between=["index_date - 15 days","index_date + 200 days"],
        ),
        
        has_SGSS_positive=patients.with_test_result_in_sgss(
            pathogen="SARS-CoV-2",
            test_result="positive",
            between=["index_date - 15 days","index_date + 200 days"],
            returning="binary_flag",
            return_expectations={
            "rate" : "exponential_increase",
            "incidence" : 0.25}, ),
    
        has_GP_positive=patients.with_these_clinical_events(
            any_primary_care_code,        
            returning="binary_flag",
            between=["index_date - 15 days","index_date + 200 days"],
            return_expectations={
            "rate" : "exponential_increase",
            "incidence" : 0.25},  ),

            ## covid infection record hosp ##
        has_covid_admission=patients.admitted_to_hospital(
            returning="binary_flag",
            with_these_diagnoses=covid_codelist,
            between=["index_date - 15 days","index_date + 200 days"],
            return_expectations={
            "rate" : "exponential_increase",
            "incidence" : 0.25},    ),

    ),


 ## Age
    age=patients.age_as_of(
        "index_date",
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
        "index_date",
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
            "index_date",
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


