

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
   AB_1=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["index_date", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_2=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_1_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_3=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_2_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_4=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_3_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),
   AB_5=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_4_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_6=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_5_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_7=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_6_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_8=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_7_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

   AB_9=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_8_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_10=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_9_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_11=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_10_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),

    AB_12=patients.with_these_medications(
        antibacterials_codes_brit,
        find_first_match_in_period=True,
        include_date_of_match = True,
        between=["AB_11_date + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },    
    ),


)

