

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

# DEFINE STUDY POPULATION ---

## Define study time variables
from datetime import datetime

start_date = "2021-01-01"
end_date = "2021-12-31"

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
        (age >=4 AND age <= 110)
        AND
        has_follow_up_previous_year
        AND
        (sex = "M" OR sex = "F")
        AND
        has_ab
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
        
        has_ab=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag"
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

######## all antibacterials from BRIT (dmd codes)
##### antibiotics date- 12 times per month 
    Infect_1=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["index_date", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  

    Infect_2=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["Infect_1_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  

    Infect_3=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["Infect_2_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  

    Infect_4=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["Infect_3_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  

    Infect_5=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["Infect_4_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  

    Infect_6=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["Infect_5_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  

    Infect_7=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["Infect_6_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  

    Infect_8=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        include_date_of_match = True,
        between=["Infect_7_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning='category',
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),  


)

