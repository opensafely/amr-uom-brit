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

    
    ## hospitalisation with diagnosis of lrti, urti, or uti
    #admitted_date=patients.admitted_to_hospital(
    #    with_these_diagnoses=any_lrti_urti_uti_hospitalisation_codes,
    #    returning="date_admitted",
    #    date_format="YYYY-MM-DD",
    #    find_first_match_in_period=True,
    #    return_expectations={"incidence": 0.3},
    #),
    
    ## hospitalised because of covid diagnosis
    #hospital_covid=patients.admitted_to_hospital(
    #    with_these_diagnoses=covid_codes,
    #    returning="date_admitted",
    #    date_format="YYYY-MM-DD",
    #    find_first_match_in_period=True,
    #    return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    #),

    ## Infection Hospitalisation records
    hospitalisation_infec = patients.admitted_to_hospital(
        with_these_diagnoses= hospitalisation_infection_related,
        between=["index_date - 12 months", "index_date"],
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "index_date", "latest": "today"}},
    ),

        ########## any infection or any AB records in prior 90days (incident/prevelent prescribing)#############
        ## 0=incident case  / 1=prevelent
    hx_indications=patients.with_these_clinical_events(
        all_indication_codes,
        returning="binary_flag",
        between=["index_date - 90 days", "index_date"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),
    
    hx_antibiotics= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date - 90 days", "index_date"],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),




  ########## number of infection cousultations #############
    
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
    ## count infection events 
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



########## identify incidenct case (without same infection in prior 90 days)#############
    #  --UTI 
    hx_uti_pt=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=["index_date - 90 days", "index_date"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),
    #  --LRTI 
    hx_lrti_pt=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=["index_date - 90 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --URTI  
    hx_urti_pt=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["index_date - 90 days", "index_date"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),

    #  --sinusitis 
    hx_sinusitis_pt=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=["index_date - 90 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    hx_ot_externa_pt=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=["index_date - 90 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    hx_otmedia_pt=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=["index_date - 90 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 


####### 6 common infection date

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

    
    uti_date_2=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        between=["uti_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    
    uti_date_3=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        between=["uti_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    uti_date_4=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        between=["uti_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
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
    
    lrti_date_2=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        between=["lrti_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    
    lrti_date_3=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        between=["lrti_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_date_4=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        between=["lrti_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
        
        
#---- URTI 
#find patient's infection date 
    urti_date_1=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    
    urti_date_2=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    
    urti_date_3=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    urti_date_4=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
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

    
    sinusitis_date_2=patients.with_these_clinical_events(
        sinusitis_codes,
        returning='date',
        between=["sinusitis_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    
    sinusitis_date_3=patients.with_these_clinical_events(
        sinusitis_codes,
        returning='date',
        between=["sinusitis_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    sinusitis_date_4=patients.with_these_clinical_events(
        sinusitis_codes,
        returning='date',
        between=["sinusitis_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
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
    
    otmedia_date_2=patients.with_these_clinical_events(
        otmedia_codes,
        returning='date',
        between=["otmedia_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    
    otmedia_date_3=patients.with_these_clinical_events(
        otmedia_codes,
        returning='date',
        between=["otmedia_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    otmedia_date_4=patients.with_these_clinical_events(
        otmedia_codes,
        returning='date',
        between=["otmedia_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
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
    
    ot_externa_date_2=patients.with_these_clinical_events(
        ot_externa_codes,
        returning='date',
        between=["ot_externa_date_1 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),
    
    ot_externa_date_3=patients.with_these_clinical_events(
        ot_externa_codes,
        returning='date',
        between=["ot_externa_date_2 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    ot_externa_date_4=patients.with_these_clinical_events(
        ot_externa_codes,
        returning='date',
        between=["ot_externa_date_3 + 1 day", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),



    ###  consultation with AB prescribing 
    ## uti
    uti_ab_flag_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_1','uti_date_1'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),
    
    uti_ab_flag_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_2','uti_date_2'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),
    
    uti_ab_flag_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_3','uti_date_3'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    uti_ab_flag_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['uti_date_4','uti_date_4'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    uti_ab_flag=patients.satisfying(
        """
        uti_ab_flag_1 OR
        uti_ab_flag_2 OR
        uti_ab_flag_3 OR
        uti_ab_flag_4
        """,
    ),

    ## urti
    urti_ab_flag_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_1','urti_date_1'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    urti_ab_flag_2 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_2','urti_date_2'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    urti_ab_flag_3 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_3','urti_date_3'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    urti_ab_flag_4 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_4','urti_date_4'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    urti_ab_flag=patients.satisfying(
        """
        urti_ab_flag_1 OR
        urti_ab_flag_2 OR
        urti_ab_flag_3 OR
        urti_ab_flag_4
        """,
    ),

    #lrti
    lrti_ab_flag_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_1','lrti_date_1'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    lrti_ab_flag_2 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_2','lrti_date_2'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    lrti_ab_flag_3 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_3','lrti_date_3'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    lrti_ab_flag_4 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_4','lrti_date_4'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    lrti_ab_flag=patients.satisfying(
        """
        lrti_ab_flag_1 OR
        lrti_ab_flag_2 OR
        lrti_ab_flag_3 OR
        lrti_ab_flag_4
        """,
    ),

    #sinusitis
    sinusitis_ab_flag_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_1','sinusitis_date_1'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    sinusitis_ab_flag_2 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_2','sinusitis_date_2'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    sinusitis_ab_flag_3 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_3','sinusitis_date_3'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    sinusitis_ab_flag_4 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['sinusitis_date_4','sinusitis_date_4'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    sinusitis_ab_flag=patients.satisfying(
        """
        sinusitis_ab_flag_1 OR
        sinusitis_ab_flag_2 OR
        sinusitis_ab_flag_3 OR
        sinusitis_ab_flag_4
        """,
    ),

    #otmedia
    otmedia_ab_flag_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_1','otmedia_date_1'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    otmedia_ab_flag_2 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_2','otmedia_date_2'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    otmedia_ab_flag_3 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_3','otmedia_date_3'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    otmedia_ab_flag_4 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['otmedia_date_4','otmedia_date_4'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    otmedia_ab_flag=patients.satisfying(
        """
        otmedia_ab_flag_1 OR
        otmedia_ab_flag_2 OR
        otmedia_ab_flag_3 OR
        otmedia_ab_flag_4
        """,
    ),

    #ot_externa
    ot_externa_ab_flag_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_1','ot_externa_date_1'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    ot_externa_ab_flag_2 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_2','ot_externa_date_2'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    ot_externa_ab_flag_3 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_3','ot_externa_date_3'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    ot_externa_ab_flag_4 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['ot_externa_date_4','ot_externa_date_4'],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    ot_externa_ab_flag=patients.satisfying(
        """
        ot_externa_ab_flag_1 OR
        ot_externa_ab_flag_2 OR
        ot_externa_ab_flag_3 OR
        ot_externa_ab_flag_4
        """,
    ),

)

# --- DEFINE MEASURES ---


measures = [

    
    # incident consultation: UTI
    Measure(id="infection_consult_UTI",
            numerator="uti_counts",
            denominator="population",
            group_by=["practice", "hx_uti_pt", "age_cat"]
    ),
    # incident consultation: LRTI
    Measure(id="infection_consult_LRTI",
            numerator="lrti_counts",
            denominator="population",
            group_by=["practice", "hx_lrti_pt", "age_cat"]
    ),
    # incident consultation: URTI
    Measure(id="infection_consult_URTI",
            numerator="urti_counts",
            denominator="population",
            group_by=["practice", "hx_urti_pt", "age_cat"]
    ),
    # incident consultation: sinusitis
    Measure(id="infection_consult_sinusitis",
            numerator="sinusitis_counts",
            denominator="population",
            group_by=["practice", "hx_sinusitis_pt", "age_cat"]
    ),
    # incident consultation: ot_externa
    Measure(id="infection_consult_ot_externa",
            numerator="ot_externa_counts",
            denominator="population",
            group_by=["practice", "hx_ot_externa_pt", "age_cat"]
    ),
    # incident consultation: otmedia
    Measure(id="infection_consult_otmedia",
            numerator="otmedia_counts",
            denominator="population",
            group_by=["practice", "hx_otmedia_pt", "age_cat"]
    ),

   
    Measure(id="infection_repeat_antibiotics",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "hx_antibiotics", "sex", "age_cat"],
            ),

    Measure(id="infection_repeat_antibiotics_uti",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "hx_antibiotics", "uti_ab_flag", "sex", "age_cat"],
            ),

    Measure(id="infection_repeat_antibiotics_urti",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "hx_antibiotics", "urti_ab_flag", "sex", "age_cat"],
            ),

    Measure(id="infection_repeat_antibiotics_lrti",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "hx_antibiotics", "lrti_ab_flag", "sex", "age_cat"],
            ),

    Measure(id="infection_repeat_antibiotics_sinusitis",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "hx_antibiotics", "sinusitis_ab_flag", "sex", "age_cat"],
            ),

    Measure(id="infection_repeat_antibiotics_otmedia",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "hx_antibiotics", "otmedia_ab_flag", "sex", "age_cat"],
            ),

    Measure(id="infection_repeat_antibiotics_ot_externa",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "hx_antibiotics", "ot_externa_ab_flag", "sex", "age_cat"],
            ), 



]
