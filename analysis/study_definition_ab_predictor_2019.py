

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

start_date = "2019-01-01"
end_date = "2019-12-31"

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
        between=[start_date, end_date],
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
    AB_date_1=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_2=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_1 + 1 day ", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_3=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_4=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_5=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_4 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_6=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_5 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_7=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_6 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_8=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_7 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_9=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_8 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

    AB_date_10=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_9 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

     AB_date_11=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_10 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),

     AB_date_12=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=["AB_date_11 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
    ),


#### incident / prevalent prescription 30 days before ####

    prevalent_AB_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_1 - 31 days", "AB_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_2 - 31 days", "AB_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_3 - 31 days", "AB_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_4 - 31 days", "AB_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_5= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_5 - 31 days", "AB_date_5 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_6= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_6 - 31 days", "AB_date_6 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_7= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_7 - 31 days", "AB_date_7 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_8= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_8 - 31 days", "AB_date_8 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_9= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_9 - 31 days", "AB_date_9 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_10= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_10 - 31 days", "AB_date_10 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_11= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_11 - 31 days", "AB_date_11 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_12= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_12 - 31 days", "AB_date_12 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
 
#### incident / prevalent infection 90 days before ####

    prevalent_infection_AB_date_1= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_1 - 91 days", "AB_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_2= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_2 - 91 days", "AB_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_3= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_3 - 91 days", "AB_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_4= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_4 - 91 days", "AB_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_5= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_5 - 91 days", "AB_date_5 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_6= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_6 - 91 days", "AB_date_6 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_7= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_7 - 91 days", "AB_date_7 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_8= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_8 - 91 days", "AB_date_8 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_9= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_9 - 91 days", "AB_date_9 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_10= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_10 - 91 days", "AB_date_10 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_11= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_11 - 91 days", "AB_date_11 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_infection_AB_date_12= patients.with_these_clinical_events(
        antibiotics_indications,
        between=["AB_date_12 - 91 days", "AB_date_12 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

#### repeat prescription 30 days after ####

    repeat_AB_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_1 + 1 days", " AB_date_1 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_2 + 1 days", " AB_date_2 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_3 + 1 days", " AB_date_3 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_4 + 1 days", " AB_date_4 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_5= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_5 + 1 days", " AB_date_5 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_6= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_6 + 1 days", " AB_date_6 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_7= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_7 + 1 days", " AB_date_7 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_8= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_8 + 1 days", " AB_date_8 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_9= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_9 + 1 days", " AB_date_9 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_10= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_10 + 1 days", " AB_date_10 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_11= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_11 + 1 days", " AB_date_11 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

    repeat_AB_date_12= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_12 + 1 days", " AB_date_12 + 31 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),


)
