
######################################

# This script provides the formal specification of the study data that will be extracted from
# the OpenSAFELY database.

######################################

# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)

## Import codelists from codelist.py (which pulls them from the codelist folder)

from codelists import *


#from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, uti_codes, lrti_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes, flu_med_codes, flu_clinical_given_codes, flu_clinical_not_given_codes, covrx_code, hospitalisation_infection_related #, any_lrti_urti_uti_hospitalisation_codes#, flu_vaccine_codes

# DEFINE STUDY POPULATION ---

## Define study time variables
from datetime import datetime

start_date = "2019-01-01"
end_date = '2022-03-01'

## Define study population and variables
study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.1,
    },
    # Set index date to start date
    index_date=start_date,
    # Define the study population
    population=patients.satisfying(
        """
        NOT has_died
        AND
        registered
        AND
        age
        AND
        has_follow_up_previous_year
        AND
        (sex = "M" OR sex = "F")
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
        ),

        registered=patients.satisfying(
            "registered_at_start",
            registered_at_start=patients.registered_as_of("index_date"),
        ),

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="index_date - 1 year",
            end_date="index_date",
            return_expectations={"incidence": 0.95},
        ),

    ),

    ########## patient demographics to group_by for measures:
    ### Age
    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
            "incidence": 0.001
        },
    ),

    ### Age categories
    ## 0-4; 5-14; 15-24; 25-34; 35-44; 45-54; 55-64; 65-74; 75+
    age_cat=patients.categorised_as(
        {
            "0":"DEFAULT",
            "0-4": """ age >= 0 AND age < 5""",
            "5-14": """ age >= 5 AND age < 15""",
            "15-24": """ age >= 15 AND age < 25""",
            "25-34": """ age >= 25 AND age < 35""",
            "35-44": """ age >= 35 AND age < 45""",
            "45-54": """ age >= 45 AND age < 55""",
            "55-64": """ age >= 55 AND age < 65""",
            "65-74": """ age >= 65 AND age < 75""",
            "75+": """ age >= 75 AND age < 120""",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0,
                    "0-4": 0.12, 
                    "5-14": 0.11,
                    "15-24": 0.11,
                    "25-34": 0.11,
                    "35-44": 0.11,
                    "45-54": 0.11,
                    "55-64": 0.11,
                    "65-74": 0.11,
                    "75+": 0.11,
                }
            },
        },
    ),
    
    ### Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    ### Practice
    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={"int": {"distribution": "normal",
                                     "mean": 25, "stddev": 5}, "incidence": 1}
    ),


###Same day antibiotics prescribing (sgss)
###(https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/study_definition.py)
    ## first positive date
    first_positive_test_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="2020-02-01",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01"},
        "incidence" : 0.25},
    ),

    ## first same day ab
    sgss_ab_prescribed=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["first_positive_test_date - 2 days","first_positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.5,},
    ),

    ## Second positive date 
    second_positive_test_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="first_positive_test_date + 19 days",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01"},
        "incidence" : 0.25},
    ),
   
    ## second same day ab
    sgss_ab_prescribed_2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["second_positive_test_date - 2 days","second_positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.5,},
    ),



###Same day antibiotics prescribing (gp)

    ## first positive date 
    pg_first_positive_test_date=patients.with_these_clinical_events(
        any_primary_care_code,       
        returning="date",
        on_or_after="2020-02-01",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"rate" : "exponential_increase"},
    ),

    ## first same day ab
    gp_ab_prescribed_1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["pg_first_positive_test_date - 2 days","pg_first_positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.5,},
    ),

    ## Second positive date 
    pg_second_positive_test_date=patients.with_these_clinical_events(
        any_primary_care_code,     
        returning="date",
        on_or_after="pg_first_positive_test_date + 19 days",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"rate" : "exponential_increase"},
    ),

    ## second same day ab
    gp_ab_prescribed_2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["pg_second_positive_test_date - 2 days","pg_second_positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.5,},
    ),


)
