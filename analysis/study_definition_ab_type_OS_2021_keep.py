

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
end_date = "2021-01-31"

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

    ## all antibacterials from BRIT (dmd codes)
    antibacterial_brit=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
    ),

######## all antibacterials from BRIT (dmd codes)
##### antibiotics date- 12 times per month 
    AB_date_1=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["index_date", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_2=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_1 + 1 day ", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_3=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_2 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_4=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_3 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_5=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_4 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_6=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_5 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_7=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_6 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_8=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_7 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_9=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_8 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

    AB_date_10=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_9 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

     AB_date_11=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_10 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

     AB_date_12=patients.with_these_medications(
        antibacterials_codes_brit,
        return_first_date_in_period = True,
        include_date_of_match = True,
        between=["AB_date_11 + 1 day", "last_day_of_month(index_date)"],
        date_format="YYYY-MM-DD",    
    ),

##### indication fit on AB date 1-12

    AB_date_1_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_1", "AB_date_1"],
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_2_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_2", "AB_date_2"],
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_3_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_3", "AB_date_3"],
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_4_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_4", "AB_date_4"],
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_5_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_5", "AB_date_5"], 
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_6_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_6", "AB_date_6"],
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_7_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_7", "AB_date_7"],
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_8_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_8", "AB_date_8"],
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_9_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_9", "AB_date_9"], 
        return_expectations={
           "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_10_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_10", "AB_date_10"],
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_11_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_11", "AB_date_11"],
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),
    AB_date_12_indication=patients.with_these_clinical_events(
        antibiotics_indications,
        find_first_match_in_period = True,
        returning='category',
        between=["AB_date_12", "AB_date_12"],
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),

#### ab type

    Ab_date_1_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_1", "AB_date_1"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_2_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_2", "AB_date_2"],
        find_first_match_in_period = True,
        returning="category",
         return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_3_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_3", "AB_date_3"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_4_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_4", "AB_date_4"],
        find_first_match_in_period = True,
        returning="category",
          return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_5_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_5", "AB_date_5"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_6_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_6", "AB_date_6"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_7_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_7", "AB_date_7"],
        find_first_match_in_period = True,
        returning="category",
         return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_8_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_8", "AB_date_8"],
        find_first_match_in_period = True,
        returning="category",
         return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_9_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_9", "AB_date_9"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_10_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_10", "AB_date_10"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_11_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_11", "AB_date_11"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
    Ab_date_12_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_12", "AB_date_12"],
        find_first_match_in_period = True,
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amoxicillin":0.25, "Nitrofurantoin":0.25, "Trimethoprim":0.25, "Phenoxymethylpenicillin":0.25}},
            "incidence": 0.99,
        },
    ),
)

