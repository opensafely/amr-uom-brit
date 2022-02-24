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


    # ## ab history: incident(no ab 90 days before index)/ prevalent
    # hx_antibiotics= patients.with_these_medications(
    #     antibacterials_codes_brit,
    #     between=["first_day_of_month(index_date) - 90 days", "index_date"],
    #     returning='binary_flag',
    #     return_expectations={"incidence": 0.8},
    # ),


######## all antibacterials from BRIT (dmd codes)


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


##### antibiotics date- 10 times per month 
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

##### antibiotics date check - incidence/prevalence
    prevalent_AB_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_1 - 91 days", "AB_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_2 - 91 days", "AB_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_3 - 91 days", "AB_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_4 - 91 days", "AB_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_5= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_5 - 91 days", "AB_date_5 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_6= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_6 - 91 days", "AB_date_6 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_7= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_7 - 91 days", "AB_date_7 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_8= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_8 - 91 days", "AB_date_8 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_9= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_9 - 91 days", "AB_date_9 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_10= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_10 - 91 days", "AB_date_10 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_11= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_11 - 91 days", "AB_date_11 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    prevalent_AB_date_12= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["AB_date_12 - 91 days", "AB_date_12 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
 
##### antibiotics numbers fit each date ---for check coverage%
    AB_date_1_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_1','AB_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_2_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_2','AB_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_3_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_3','AB_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_4_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_4','AB_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_5_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_5','AB_date_5'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_6_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_6','AB_date_6'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_7_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_7','AB_date_7'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_8_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_8','AB_date_8'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_9_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_9','AB_date_9'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_10_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_10','AB_date_10'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_11_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_11','AB_date_11'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    AB_date_12_count= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['AB_date_12','AB_date_12'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
##### indication fit on AB date 1-10

    AB_date_1_indication=patients.with_these_clinical_events(
        antibiotics_indications,
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
        returning='category',
        between=["AB_date_12", "AB_date_12"], 
        return_expectations={
            "category": {"ratios": {"asthma":0.05, "cold":0.05, "copd":0.05, "cough":0.05,
            "lrti":0.1, "ot_externa":0.1, "otmedia":0.1, "pneumonia":0.05,
            "renal":0.05, "sepsis":0.05, "sinusits":0.1, "throat":0.05,
            "urti":0.1, "uti":0.1,}},
            "incidence": 0.8,},
            ),

#### broad sprctrum antibiotics- binary flag
    Ab_date_1_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_1", "AB_date_1"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_2_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_2", "AB_date_2"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_3_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_3", "AB_date_3"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_4_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_4", "AB_date_4"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_5_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_5", "AB_date_5"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_6_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_6", "AB_date_6"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_7_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_7", "AB_date_7"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_8_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_8", "AB_date_8"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_9_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_9", "AB_date_9"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_10_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_10", "AB_date_10"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_11_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_11", "AB_date_11"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    Ab_date_12_broad_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["AB_date_12", "AB_date_12"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),

)
