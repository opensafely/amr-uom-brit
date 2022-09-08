
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
end_date = '2022-06-30'

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
    positive_test_event=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["index_date", "last_day_of_month(index_date)"],
        returning = "binary_flag",
        return_expectations={"incidence": 0.5},
    ),
    
    positive_test_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},
            "rate" : "exponential_increase"
        },
    ),

    ## Same day antibiotic prescribed binary

    ab_given_sameday=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["positive_test_date - 2 days","positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.3,},
    ),



###Same day antibiotics prescribing (gp)

    ## first positive date 
    pg_positive_test_event=patients.with_these_clinical_events(
        any_primary_care_code,       
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        return_expectations={"rate" : "exponential_increase"},
    ),

    pg_positive_test_date=patients.with_these_clinical_events(
        any_primary_care_code,       
        returning="date",
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"rate" : "exponential_increase"},
    ),

    ## first same day ab
    gp_ab_given_sameday=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["pg_positive_test_date - 2 days","pg_positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.5,},
    ),


)
