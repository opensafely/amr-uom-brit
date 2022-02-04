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


    ## ab history: incident(no ab 90 days before index)/ prevalent
    hx_antibiotics= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["first_day_of_month(index_date) - 90 days", "index_date"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),


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


######## antibiotics for infection
#  return code date and ab counts
    ## search infection codes date for 4 times in one month
    ## count same-date AB prescriobing numbers

#### 6 common ifenction ####
#---- UTI 

    #find patient's infection date 
    uti_date_1=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),


    ##numbers of antibiotic prescribed for this infection 
    uti_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_1','uti_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    uti_date_2=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        between=["uti_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    uti_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_2','uti_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    uti_date_3=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        between=["uti_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    uti_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_3','uti_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    uti_date_4=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        between=["uti_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    uti_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_4','uti_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#---- LRTI

    lrti_date_1=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_1','lrti_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    lrti_date_2=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        between=["lrti_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_2','lrti_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    lrti_date_3=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        between=["lrti_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_3','lrti_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    lrti_date_4=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        between=["lrti_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_4','lrti_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
        
        
#---- URTI 

    urti_date_1=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    urti_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_1','urti_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    urti_date_2=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    urti_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_2','urti_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    urti_date_3=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    urti_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_3','urti_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    urti_date_4=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    urti_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_4','urti_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

  

#---- sinusitis
    sinusitis_date_1=patients.with_these_clinical_events(
        sinusitis_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sinusitis_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_1','sinusitis_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    sinusitis_date_2=patients.with_these_clinical_events(
        sinusitis_codes,
        returning='date',
        between=["sinusitis_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sinusitis_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_2','sinusitis_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    sinusitis_date_3=patients.with_these_clinical_events(
        sinusitis_codes,
        returning='date',
        between=["sinusitis_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sinusitis_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_3','sinusitis_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    sinusitis_date_4=patients.with_these_clinical_events(
        sinusitis_codes,
        returning='date',
        between=["sinusitis_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sinusitis_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_4','sinusitis_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#---- otmedia
    otmedia_date_1=patients.with_these_clinical_events(
        otmedia_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    otmedia_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_1','otmedia_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    otmedia_date_2=patients.with_these_clinical_events(
        otmedia_codes,
        returning='date',
        between=["otmedia_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    otmedia_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_2','otmedia_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    otmedia_date_3=patients.with_these_clinical_events(
        otmedia_codes,
        returning='date',
        between=["otmedia_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    otmedia_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_3','otmedia_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    otmedia_date_4=patients.with_these_clinical_events(
        otmedia_codes,
        returning='date',
        between=["otmedia_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    otmedia_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_4','otmedia_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#---- ot_externa
    ot_externa_date_1=patients.with_these_clinical_events(
        ot_externa_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),


    ot_externa_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_1','ot_externa_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    ot_externa_date_2=patients.with_these_clinical_events(
        ot_externa_codes,
        returning='date',
        between=["ot_externa_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    ot_externa_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_2','ot_externa_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    ot_externa_date_3=patients.with_these_clinical_events(
        ot_externa_codes,
        returning='date',
        between=["ot_externa_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    ot_externa_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_3','ot_externa_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    ot_externa_date_4=patients.with_these_clinical_events(
        ot_externa_codes,
        returning='date',
        between=["ot_externa_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    ot_externa_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_4','ot_externa_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),


#### other ifenction:8types ####
#----01. asthma_codes

    #find patient's infection date 
    asthma_date_1=patients.with_these_clinical_events(
        asthma_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    ##numbers of antibiotic prescribed for this infection 
    asthma_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['asthma_date_1','asthma_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    asthma_date_2=patients.with_these_clinical_events(
        asthma_codes,
        returning='date',
        between=["asthma_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    asthma_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['asthma_date_2','asthma_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    asthma_date_3=patients.with_these_clinical_events(
        asthma_codes,
        returning='date',
        between=["asthma_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    asthma_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['asthma_date_3','asthma_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    asthma_date_4=patients.with_these_clinical_events(
        asthma_codes,
        returning='date',
        between=["asthma_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    asthma_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['asthma_date_4','asthma_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#----02. cold_codes
    cold_date_1=patients.with_these_clinical_events(
        cold_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cold_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cold_date_1','cold_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    cold_date_2=patients.with_these_clinical_events(
        cold_codes,
        returning='date',
        between=["cold_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cold_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cold_date_2','cold_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    cold_date_3=patients.with_these_clinical_events(
        cold_codes,
        returning='date',
        between=["cold_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cold_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cold_date_3','cold_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    cold_date_4=patients.with_these_clinical_events(
        cold_codes,
        returning='date',
        between=["cold_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cold_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cold_date_4','cold_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#----03. cough_codes
    cough_date_1=patients.with_these_clinical_events(
        cough_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cough_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cough_date_1','cough_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
 
    cough_date_2=patients.with_these_clinical_events(
        cough_codes,
        returning='date',
        between=["cough_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cough_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cough_date_2','cough_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    cough_date_3=patients.with_these_clinical_events(
        cough_codes,
        returning='date',
        between=["cough_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cough_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cough_date_3','cough_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    cough_date_4=patients.with_these_clinical_events(
        cough_codes,
        returning='date',
        between=["cough_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    cough_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['cough_date_4','cough_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#----04. copd_codes
    copd_date_1=patients.with_these_clinical_events(
        copd_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    copd_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['copd_date_1','copd_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
 
    copd_date_2=patients.with_these_clinical_events(
        copd_codes,
        returning='date',
        between=["copd_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    copd_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['copd_date_2','copd_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    copd_date_3=patients.with_these_clinical_events(
        copd_codes,
        returning='date',
        between=["copd_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    copd_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['copd_date_3','copd_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    copd_date_4=patients.with_these_clinical_events(
        copd_codes,
        returning='date',
        between=["copd_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    copd_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['copd_date_4','copd_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#----05. pneumonia_codes

    pneumonia_date_1=patients.with_these_clinical_events(
         pneumonia_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    pneumonia_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['pneumonia_date_1','pneumonia_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    pneumonia_date_2=patients.with_these_clinical_events(
        pneumonia_codes,
        returning='date',
        between=["pneumonia_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    pneumonia_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['pneumonia_date_2','pneumonia_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    pneumonia_date_3=patients.with_these_clinical_events(
        pneumonia_codes,
        returning='date',
        between=["pneumonia_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    pneumonia_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['pneumonia_date_3','pneumonia_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    pneumonia_date_4=patients.with_these_clinical_events(
        pneumonia_codes,
        returning='date',
        between=["pneumonia_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    pneumonia_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['pneumonia_date_4','pneumonia_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#----06. renal_codes

    renal_date_1=patients.with_these_clinical_events(
        renal_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    renal_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['renal_date_1','renal_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    renal_date_2=patients.with_these_clinical_events(
        renal_codes,
        returning='date',
        between=["renal_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    renal_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['renal_date_2','renal_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    renal_date_3=patients.with_these_clinical_events(
        renal_codes,
        returning='date',
        between=["renal_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    renal_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['renal_date_3','renal_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    renal_date_4=patients.with_these_clinical_events(
        renal_codes,
        returning='date',
        between=["renal_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    renal_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['renal_date_4','renal_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

#----07. sepsis_codes
    sepsis_date_1=patients.with_these_clinical_events(
        sepsis_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sepsis_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sepsis_date_1','sepsis_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    sepsis_date_2=patients.with_these_clinical_events(
        sepsis_codes,
        returning='date',
        between=["sepsis_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sepsis_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sepsis_date_2','sepsis_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    sepsis_date_3=patients.with_these_clinical_events(
        sepsis_codes,
        returning='date',
        between=["sepsis_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sepsis_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sepsis_date_3','sepsis_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    sepsis_date_4=patients.with_these_clinical_events(
        sepsis_codes,
        returning='date',
        between=["sepsis_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sepsis_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sepsis_date_4','sepsis_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    #----08. throat_codes
    throat_date_1=patients.with_these_clinical_events(
        throat_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    throat_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['throat_date_1','throat_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    throat_date_2=patients.with_these_clinical_events(
        throat_codes,
        returning='date',
        between=["throat_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    throat_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['throat_date_2','throat_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    throat_date_3=patients.with_these_clinical_events(
        throat_codes,
        returning='date',
        between=["throat_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    throat_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['throat_date_3','throat_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    throat_date_4=patients.with_these_clinical_events(
        throat_codes,
        returning='date',
        between=["throat_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    throat_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['throat_date_4','throat_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),


########## for table check: number of infection cousultations #############
    
    #  --UTI 
    ## count infection events 
    uti_counts=patients.with_these_clinical_events(
        uti_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --LRTI 
    lrti_counts=patients.with_these_clinical_events(
        lrti_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),


    #  --URTI  
    urti_counts=patients.with_these_clinical_events(
        urti_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --sinusitis 
    sinusitis_counts=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    ot_externa_counts=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    otmedia_counts=patients.with_these_clinical_events(
        otmedia_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

   #  --asthma
    asthma_counts=patients.with_these_clinical_events(
        asthma_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

     #  --cold
    cold_counts=patients.with_these_clinical_events(
        cold_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

     #  --copd
    copd_counts=patients.with_these_clinical_events(
        copd_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --cough
    cough_counts=patients.with_these_clinical_events(
        cough_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --renal
    renal_counts=patients.with_these_clinical_events(
        renal_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),
    
     #  --sepsis
    sepsis_counts=patients.with_these_clinical_events(
        sepsis_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --throat
    throat_counts=patients.with_these_clinical_events(
        throat_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

     #  --pneumonia
    pneumonia_counts=patients.with_these_clinical_events(
        pneumonia_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),
 )

# --- DEFINE MEASURES ---


# measures = [

    
#     incident consultation: UTI
#     Measure(id="infec_consult_UTI",
#             numerator="uti_counts",
#             denominator="population",
#             group_by=["practice", "incdt_uti_pt", "age_cat"]
#     ),
#     incident consultation: LRTI
#     Measure(id="infec_consult_LRTI",
#             numerator="lrti_counts",
#             denominator="population",
#             group_by=["practice", "incdt_lrti_pt", "age_cat"]
#     ),
#     incident consultation: URTI
#     Measure(id="infec_consult_URTI",
#             numerator="urti_counts",
#             denominator="population",
#             group_by=["practice", "incdt_urti_pt", "age_cat"]
#     ),
#     incident consultation: sinusitis
#     Measure(id="infec_consult_sinusitis",
#             numerator="sinusitis_counts",
#             denominator="population",
#             group_by=["practice", "incdt_sinusitis_pt", "age_cat"]
#     ),
#     incident consultation: ot_externa
#     Measure(id="infec_consult_ot_externa",
#             numerator="ot_externa_counts",
#             denominator="population",
#             group_by=["practice", "incdt_ot_externa_pt", "age_cat"]
#     ),
#     incident consultation: otmedia
#     Measure(id="infec_consult_otmedia",
#             numerator="otmedia_counts",
#             denominator="population",
#             group_by=["practice", "incdt_otmedia_pt", "age_cat"]
#     ),

#     incident prescribing: UTI
#     Measure(id="infec_Rx_percent_UTI",
#             numerator="uti_ab_flag_1",
#             denominator="uti_pt",
#             group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
#     ),
#     incident prescribing: URTI
#     Measure(id="infec_Rx_percent_URTI",
#             numerator="urti_ab_flag_1",
#             denominator="urti_pt",
#             group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
#     ),
#     incident prescribing: LRTI
#     Measure(id="infec_Rx_percent_LRTI",
#             numerator="lrti_ab_flag_1",
#             denominator="lrti_pt",
#             group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
#     ),
#     incident prescribing: sinusitis
#     Measure(id="infec_Rx_percent_sinusitis",
#             numerator="sinusitis_ab_flag_1",
#             denominator="sinusitis_pt",
#             group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
#     ),
#     incident prescribing: otmedia
#     Measure(id="infec_Rx_percent_otmedia",
#             numerator="otmedia_ab_flag_1",
#             denominator="otmedia_pt",
#             group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
#     ),
#      incident prescribing: ot_externa
#     Measure(id="infec_Rx_percent_ot_externa",
#             numerator="ot_externa_ab_flag_1",
#             denominator="ot_externa_pt",
#             group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
#     ),   
    
#     #  AB TYPE by infection-1
#     Measure(id="infec_abtype_UTI_1",
#             numerator="uti_ab_count_1",
#             denominator="population",
#             group_by=["uti_abtype1"]
#             ),
#     Measure(id="infec_abtype_URTI_1",
#             numerator="urti_ab_count_1",
#             denominator="population",
#             group_by=["urti_abtype1"]
#             ),
#     Measure(id="infec_abtype_LRTI_1",
#             numerator="lrti_ab_count_1",
#             denominator="population",
#             group_by=["lrti_abtype1"]
#             ),
#     Measure(id="infec_abtype_sinusitis_1",
#             numerator="sinusitis_ab_count_1",
#             denominator="population",
#             group_by=["sinusitis_abtype1"]
#             ),
#     Measure(id="infec_abtype_ot_externa_1",
#             numerator="ot_externa_ab_count_1",
#             denominator="population",
#             group_by=["ot_externa_abtype1"]
#             ),
#     Measure(id="infec_abtype_otmedia_1",
#             numerator="otmedia_ab_count_1",
#             denominator="population",
#             group_by=["otmedia_abtype1"]
#             ),

#     #  AB TYPE by infection-2
#     Measure(id="infec_abtype_UTI_2",
#             numerator="uti_ab_count_2",
#             denominator="population",
#             group_by=["uti_abtype2"]
#             ),
#     Measure(id="infec_abtype_URTI_2",
#             numerator="urti_ab_count_2",
#             denominator="population",
#             group_by=["urti_abtype2"]
#             ),
#     Measure(id="infec_abtype_LRTI_2",
#             numerator="lrti_ab_count_2",
#             denominator="population",
#             group_by=["lrti_abtype2"]
#             ),
#     Measure(id="infec_abtype_sinusitis_2",
#             numerator="sinusitis_ab_count_2",
#             denominator="population",
#             group_by=["sinusitis_abtype2"]
#             ),
#     Measure(id="infec_abtype_ot_externa_2",
#             numerator="ot_externa_ab_count_2",
#             denominator="population",
#             group_by=["ot_externa_abtype2"]
#             ),
#     Measure(id="infec_abtype_otmedia_2",
#             numerator="otmedia_ab_count_2",
#             denominator="population",
#             group_by=["otmedia_abtype2"]
#             ),
    
#     #  AB TYPE by infection-3
#     Measure(id="infec_abtype_UTI_3",
#             numerator="uti_ab_count_3",
#             denominator="population",
#             group_by=["uti_abtype3"]
#             ),
#     Measure(id="infec_abtype_URTI_3",
#             numerator="urti_ab_count_3",
#             denominator="population",
#             group_by=["urti_abtype3"]
#             ),
#     Measure(id="infec_abtype_LRTI_3",
#             numerator="lrti_ab_count_3",
#             denominator="population",
#             group_by=["lrti_abtype3"]
#             ),
#     Measure(id="infec_abtype_sinusitis_3",
#             numerator="sinusitis_ab_count_3",
#             denominator="population",
#             group_by=["sinusitis_abtype3"]
#             ),
#     Measure(id="infec_abtype_ot_externa_3",
#             numerator="ot_externa_ab_count_3",
#             denominator="population",
#             group_by=["ot_externa_abtype3"]
#             ),
#     Measure(id="infec_abtype_otmedia_3",
#             numerator="otmedia_ab_count_3",
#             denominator="population",
#             group_by=["otmedia_abtype3"]
#             ),
    
#     #  AB TYPE by infection-4
#     Measure(id="infec_abtype_UTI_4",
#             numerator="uti_ab_count_4",
#             denominator="population",
#             group_by=["uti_abtype4"]
#             ),
#     Measure(id="infec_abtype_URTI_4",
#             numerator="urti_ab_count_4",
#             denominator="population",
#             group_by=["urti_abtype4"]
#             ),
#     Measure(id="infec_abtype_LRTI_4",
#             numerator="lrti_ab_count_4",
#             denominator="population",
#             group_by=["lrti_abtype4"]
#             ),
#     Measure(id="infec_abtype_sinusitis_4",
#             numerator="sinusitis_ab_count_4",
#             denominator="population",
#             group_by=["sinusitis_abtype4"]
#             ),
#     Measure(id="infec_abtype_ot_externa_4",
#             numerator="ot_externa_ab_count_4",
#             denominator="population",
#             group_by=["ot_externa_abtype4"]
#             ),
#     Measure(id="infec_abtype_otmedia_4",
#             numerator="otmedia_ab_count_4",
#             denominator="population",
#             group_by=["otmedia_abtype4"]
#             ),

#     Measure(id="infec_repeat_antibiotics",
#             numerator="antibacterial_brit",
#             denominator="population",
#             group_by=["practice", "hx_antibiotics", "sex", "age_cat"],
#             ),

#     Measure(id="infec_repeat_antibiotics_uti",
#             numerator="antibacterial_brit",
#             denominator="population",
#             group_by=["practice", "hx_antibiotics", "uti_ab_flag", "sex", "age_cat"],
#             ),

#     Measure(id="infec_repeat_antibiotics_urti",
#             numerator="antibacterial_brit",
#             denominator="population",
#             group_by=["practice", "hx_antibiotics", "urti_ab_flag", "sex", "age_cat"],
#             ),

#     Measure(id="infec_repeat_antibiotics_lrti",
#             numerator="antibacterial_brit",
#             denominator="population",
#             group_by=["practice", "hx_antibiotics", "lrti_ab_flag", "sex", "age_cat"],
#             ),

#     Measure(id="infec_repeat_antibiotics_sinusitis",
#             numerator="antibacterial_brit",
#             denominator="population",
#             group_by=["practice", "hx_antibiotics", "sinusitis_ab_flag", "sex", "age_cat"],
#             ),

#     Measure(id="infec_repeat_antibiotics_otmedia",
#             numerator="antibacterial_brit",
#             denominator="population",
#             group_by=["practice", "hx_antibiotics", "otmedia_ab_flag", "sex", "age_cat"],
#             ),

#     Measure(id="infec_repeat_antibiotics_ot_externa",
#             numerator="antibacterial_brit",
#             denominator="population",
#             group_by=["practice", "hx_antibiotics", "ot_externa_ab_flag", "sex", "age_cat"],
#             ), 



# ]
