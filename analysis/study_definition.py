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
    #filter_codes_by_category,
    #combine_codelists,
    #Measure
)

## Import codelists from codelist.py (which pulls them from the codelist folder)
#  from codelists import *

## code from template (same as above)
#from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv  # NOQA

# DEFINE STUDY POPULATION ---

## Define study time variables
from datetime import datetime

start_date = "2019-01-01"
end_date = datetime.today().strftime('%Y-%m-%d')

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

    ### Region - NHS England 9 regions
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

    ## Variables

    ### Practice
    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={"int": {"distribution": "normal",
                                     "mean": 25, "stddev": 5}, "incidence": 0.5}
    ),

)


