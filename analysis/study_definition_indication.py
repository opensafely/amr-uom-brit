######################################

# This script provides the formal specification of the study data that will be extracted from
# the OpenSAFELY database.
# 17 Mar 2022 updated: infection history refer to first date of infection instead of index date

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



    #find patient's first infection date 
    indic_date_1=patients.with_these_clinical_events(
        all_indication_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    # AB_date_1=patients.with_these_medications(
    #     antibacterials_codes_brit,
    #     returning='date',
    #     between=["index_date", "last_day_of_month(index_date)"],
    #     find_first_match_in_period=True,
    #     date_format="YYYY-MM-DD",    
    # ),

 ########## any infection or any AB records in prior 90days (incident/prevelent prescribing)#############
        ## 0=incident case  / 1=prevelent
    hx_indications=patients.with_these_clinical_events(
        all_indication_codes,
        returning="binary_flag",
        between=["indic_date_1 - 90 days", "indic_date_1 - 1 day"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),
    
    # hx_antibiotics= patients.with_these_medications(
    #     antibacterials_codes_brit,
    #     between=["AB_date_1 - 90 days", "AB_date_1 - 1 day"],
    #     returning='binary_flag',
    #     return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    # ),

    
    ########## number of infection cousultations #############
    
    ## count infection events 
    indication_counts=patients.with_these_clinical_events(
        all_indication_codes,
        returning="number_of_matches_in_period",
        between=["indic_date_1", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

        ## all antibacterials from BRIT (dmd codes)
    # antibacterial_brit=patients.with_these_medications(
    #     antibacterials_codes_brit,
    #     between=["AB_date_1", "last_day_of_month(index_date)"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 3, "stddev": 1},
    #         "incidence": 1,
    #     },
    # ),



)

# --- DEFINE MEASURES ---


measures = [


    Measure(id="indication_counts",
            numerator="indication_counts",
            denominator="population",
            group_by=["practice", "hx_indications", "age_cat"]
    ),

    # Measure(id="ab_count_all",
    #         numerator="antibacterial_brit",
    #         denominator="population",
    #         group_by=["practice", "hx_antibiotics", "age_cat"]
    # ),


]
