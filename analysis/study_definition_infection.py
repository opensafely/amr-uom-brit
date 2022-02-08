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

   ########## number of infected patients #############
    
    #  --UTI 
    ## count patient number
    uti_pt=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),
    #  --LRTI 
    lrti_pt=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --URTI  
    urti_pt=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --sinusitis 
    sinusitis_pt=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    ot_externa_pt=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    otmedia_pt=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

########## identify incidenct case (without same infection in prior 6 weeks)#############
## incdt=0 incident case  
    #  --UTI 
    incdt_uti_pt=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=["index_date - 42 days", "index_date"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),
    #  --LRTI 
    incdt_lrti_pt=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=["index_date - 42 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --URTI  
    incdt_urti_pt=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["index_date - 42 days", "index_date"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),

    #  --sinusitis 
    incdt_sinusitis_pt=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=["index_date - 42 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    incdt_ot_externa_pt=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=["index_date - 42 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    incdt_otmedia_pt=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=["index_date - 42 days", "index_date"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 


    ## prescribing rate by 6 common infection type #####
    ## search infection codes for 4 times in one month
    ## count same-date prescriobing numbers of AB

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
#find patient's infection date 
    urti_date_1=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

#numbers of antibiotic prescribed for this infection 
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
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
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


#    numbers of antibiotic prescribed for this infection 
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

#)


#     ## ab types:79
#     Rx_Amikacin=patients.with_these_medications(codes_ab_type_Amikacin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Amoxicillin=patients.with_these_medications(codes_ab_type_Amoxicillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Ampicillin=patients.with_these_medications(codes_ab_type_Ampicillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Azithromycin=patients.with_these_medications(codes_ab_type_Azithromycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Aztreonam=patients.with_these_medications(codes_ab_type_Aztreonam,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Benzylpenicillin=patients.with_these_medications(codes_ab_type_Benzylpenicillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefaclor=patients.with_these_medications(codes_ab_type_Cefaclor,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefadroxil=patients.with_these_medications(codes_ab_type_Cefadroxil,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefalexin=patients.with_these_medications(codes_ab_type_Cefalexin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefamandole=patients.with_these_medications(codes_ab_type_Cefamandole,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefazolin=patients.with_these_medications(codes_ab_type_Cefazolin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefepime=patients.with_these_medications(codes_ab_type_Cefepime,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefixime=patients.with_these_medications(codes_ab_type_Cefixime,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefotaxime=patients.with_these_medications(codes_ab_type_Cefotaxime,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefoxitin=patients.with_these_medications(codes_ab_type_Cefoxitin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefpirome=patients.with_these_medications(codes_ab_type_Cefpirome,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefpodoxime=patients.with_these_medications(codes_ab_type_Cefpodoxime,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefprozil=patients.with_these_medications(codes_ab_type_Cefprozil,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefradine=patients.with_these_medications(codes_ab_type_Cefradine,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Ceftazidime=patients.with_these_medications(codes_ab_type_Ceftazidime,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Ceftriaxone=patients.with_these_medications(codes_ab_type_Ceftriaxone,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cefuroxime=patients.with_these_medications(codes_ab_type_Cefuroxime,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Chloramphenicol=patients.with_these_medications(codes_ab_type_Chloramphenicol,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Cilastatin=patients.with_these_medications(codes_ab_type_Cilastatin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Ciprofloxacin=patients.with_these_medications(codes_ab_type_Ciprofloxacin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Clarithromycin=patients.with_these_medications(codes_ab_type_Clarithromycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Clindamycin=patients.with_these_medications(codes_ab_type_Clindamycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Co_amoxiclav=patients.with_these_medications(codes_ab_type_Co_amoxiclav,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Co_fluampicil=patients.with_these_medications(codes_ab_type_Co_fluampicil,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Colistimethate=patients.with_these_medications(codes_ab_type_Colistimethate,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Dalbavancin=patients.with_these_medications(codes_ab_type_Dalbavancin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Dalfopristin=patients.with_these_medications(codes_ab_type_Dalfopristin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Daptomycin=patients.with_these_medications(codes_ab_type_Daptomycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Demeclocycline=patients.with_these_medications(codes_ab_type_Demeclocycline,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Doripenem=patients.with_these_medications(codes_ab_type_Doripenem,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Doxycycline=patients.with_these_medications(codes_ab_type_Doxycycline,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Ertapenem=patients.with_these_medications(codes_ab_type_Ertapenem,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Erythromycin=patients.with_these_medications(codes_ab_type_Erythromycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Fidaxomicin=patients.with_these_medications(codes_ab_type_Fidaxomicin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Flucloxacillin=patients.with_these_medications(codes_ab_type_Flucloxacillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Fosfomycin=patients.with_these_medications(codes_ab_type_Fosfomycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Fusidate=patients.with_these_medications(codes_ab_type_Fusidate,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Gentamicin=patients.with_these_medications(codes_ab_type_Gentamicin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Levofloxacin=patients.with_these_medications(codes_ab_type_Levofloxacin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Linezolid=patients.with_these_medications(codes_ab_type_Linezolid,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Lymecycline=patients.with_these_medications(codes_ab_type_Lymecycline,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Meropenem=patients.with_these_medications(codes_ab_type_Meropenem,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Methenamine=patients.with_these_medications(codes_ab_type_Methenamine,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Metronidazole=patients.with_these_medications(codes_ab_type_Metronidazole,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Minocycline=patients.with_these_medications(codes_ab_type_Minocycline,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Moxifloxacin=patients.with_these_medications(codes_ab_type_Moxifloxacin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Nalidixic_acid=patients.with_these_medications(codes_ab_type_Nalidixic_acid,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Neomycin=patients.with_these_medications(codes_ab_type_Neomycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Netilmicin=patients.with_these_medications(codes_ab_type_Netilmicin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Nitazoxanid=patients.with_these_medications(codes_ab_type_Nitazoxanid,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Nitrofurantoin=patients.with_these_medications(codes_ab_type_Nitrofurantoin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Norfloxacin=patients.with_these_medications(codes_ab_type_Norfloxacin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Ofloxacin=patients.with_these_medications(codes_ab_type_Ofloxacin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Oxytetracycline=patients.with_these_medications(codes_ab_type_Oxytetracycline,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Phenoxymethylpenicillin=patients.with_these_medications(codes_ab_type_Phenoxymethylpenicillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Piperacillin=patients.with_these_medications(codes_ab_type_Piperacillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Pivmecillinam=patients.with_these_medications(codes_ab_type_Pivmecillinam,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Pristinamycin=patients.with_these_medications(codes_ab_type_Pristinamycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Rifaximin=patients.with_these_medications(codes_ab_type_Rifaximin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Sulfadiazine=patients.with_these_medications(codes_ab_type_Sulfadiazine,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Sulfamethoxazole=patients.with_these_medications(codes_ab_type_Sulfamethoxazole,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Sulfapyridine=patients.with_these_medications(codes_ab_type_Sulfapyridine,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Taurolidin=patients.with_these_medications(codes_ab_type_Taurolidin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Tedizolid=patients.with_these_medications(codes_ab_type_Tedizolid,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Teicoplanin=patients.with_these_medications(codes_ab_type_Teicoplanin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Telithromycin=patients.with_these_medications(codes_ab_type_Telithromycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Temocillin=patients.with_these_medications(codes_ab_type_Temocillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Tetracycline=patients.with_these_medications(codes_ab_type_Tetracycline,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Ticarcillin=patients.with_these_medications(codes_ab_type_Ticarcillin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Tigecycline=patients.with_these_medications(codes_ab_type_Tigecycline,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Tinidazole=patients.with_these_medications(codes_ab_type_Tinidazole,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Tobramycin=patients.with_these_medications(codes_ab_type_Tobramycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Trimethoprim=patients.with_these_medications(codes_ab_type_Trimethoprim,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
#     Rx_Vancomycin=patients.with_these_medications(codes_ab_type_Vancomycin,between=['index_date', 'last_day_of_month(index_date)'],returning='number_of_matches_in_period',
#   return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),


   ### Antibiotics by infection

    uti_abtype1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_1","uti_date_1"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    urti_abtype1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_1","urti_date_1"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    lrti_abtype1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_1","lrti_date_1"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    sinusitis_abtype1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_1","sinusitis_date_1"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),

    otmedia_abtype1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_1","otmedia_date_1"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    ot_externa_abtype1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_1","ot_externa_date_1"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),

    uti_abtype2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_2","uti_date_2"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    urti_abtype2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_2","urti_date_2"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    lrti_abtype2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_2","lrti_date_2"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    sinusitis_abtype2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_2","sinusitis_date_2"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    otmedia_abtype2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_2","otmedia_date_2"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    ot_externa_abtype2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_2","ot_externa_date_2"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),

    uti_abtype3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_3","uti_date_3"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    urti_abtype3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_3","urti_date_3"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    lrti_abtype3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_3","lrti_date_3"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    sinusitis_abtype3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_3","sinusitis_date_3"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),

    otmedia_abtype3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_3","otmedia_date_3"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    ot_externa_abtype3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_3","ot_externa_date_3"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    uti_abtype4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_4","uti_date_4"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    urti_abtype4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_4","urti_date_4"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    lrti_abtype4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_4","lrti_date_4"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    sinusitis_abtype4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_4","sinusitis_date_4"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),

    otmedia_abtype4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_4","otmedia_date_4"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    ot_externa_abtype4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_4","ot_externa_date_4"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),
    


########## any infection or any AB records in prior 1 month (incident/prevelent prescribing)#############
## 0=incident case  / 1=prevelent
    # 
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
            group_by=["practice", "incdt_uti_pt", "age_cat"]
    ),
    # incident consultation: LRTI
    Measure(id="infection_consult_LRTI",
            numerator="lrti_counts",
            denominator="population",
            group_by=["practice", "incdt_lrti_pt", "age_cat"]
    ),
    # incident consultation: URTI
    Measure(id="infection_consult_URTI",
            numerator="urti_counts",
            denominator="population",
            group_by=["practice", "incdt_urti_pt", "age_cat"]
    ),
    # incident consultation: sinusitis
    Measure(id="infection_consult_sinusitis",
            numerator="sinusitis_counts",
            denominator="population",
            group_by=["practice", "incdt_sinusitis_pt", "age_cat"]
    ),
    # incident consultation: ot_externa
    Measure(id="infection_consult_ot_externa",
            numerator="ot_externa_counts",
            denominator="population",
            group_by=["practice", "incdt_ot_externa_pt", "age_cat"]
    ),
    # incident consultation: otmedia
    Measure(id="infection_consult_otmedia",
            numerator="otmedia_counts",
            denominator="population",
            group_by=["practice", "incdt_otmedia_pt", "age_cat"]
    ),

    # incident prescribing: UTI
    Measure(id="infection_Rx_percent_UTI",
            numerator="uti_ab_flag_1",
            denominator="uti_pt",
            group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
    ),
    # incident prescribing: URTI
    Measure(id="infection_Rx_percent_URTI",
            numerator="urti_ab_flag_1",
            denominator="urti_pt",
            group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
    ),
    # incident prescribing: LRTI
    Measure(id="infection_Rx_percent_LRTI",
            numerator="lrti_ab_flag_1",
            denominator="lrti_pt",
            group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
    ),
    # incident prescribing: sinusitis
    Measure(id="infection_Rx_percent_sinusitis",
            numerator="sinusitis_ab_flag_1",
            denominator="sinusitis_pt",
            group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
    ),
    # incident prescribing: otmedia
    Measure(id="infection_Rx_percent_otmedia",
            numerator="otmedia_ab_flag_1",
            denominator="otmedia_pt",
            group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
    ),
     # incident prescribing: ot_externa
    Measure(id="infection_Rx_percent_ot_externa",
            numerator="ot_externa_ab_flag_1",
            denominator="ot_externa_pt",
            group_by=["practice","hx_indications", "hx_antibiotics","age_cat"]
    ),   
    
    ##  AB TYPE by infection-1
    Measure(id="infection_abtype_UTI_1",
            numerator="uti_ab_count_1",
            denominator="population",
            group_by=["uti_abtype1"]
            ),
    Measure(id="infection_abtype_URTI_1",
            numerator="urti_ab_count_1",
            denominator="population",
            group_by=["urti_abtype1"]
            ),
    Measure(id="infection_abtype_LRTI_1",
            numerator="lrti_ab_count_1",
            denominator="population",
            group_by=["lrti_abtype1"]
            ),
    Measure(id="infection_abtype_sinusitis_1",
            numerator="sinusitis_ab_count_1",
            denominator="population",
            group_by=["sinusitis_abtype1"]
            ),
    Measure(id="infection_abtype_ot_externa_1",
            numerator="ot_externa_ab_count_1",
            denominator="population",
            group_by=["ot_externa_abtype1"]
            ),
    Measure(id="infection_abtype_otmedia_1",
            numerator="otmedia_ab_count_1",
            denominator="population",
            group_by=["otmedia_abtype1"]
            ),

    ##  AB TYPE by infection-2
    Measure(id="infection_abtype_UTI_2",
            numerator="uti_ab_count_2",
            denominator="population",
            group_by=["uti_abtype2"]
            ),
    Measure(id="infection_abtype_URTI_2",
            numerator="urti_ab_count_2",
            denominator="population",
            group_by=["urti_abtype2"]
            ),
    Measure(id="infection_abtype_LRTI_2",
            numerator="lrti_ab_count_2",
            denominator="population",
            group_by=["lrti_abtype2"]
            ),
    Measure(id="infection_abtype_sinusitis_2",
            numerator="sinusitis_ab_count_2",
            denominator="population",
            group_by=["sinusitis_abtype2"]
            ),
    Measure(id="infection_abtype_ot_externa_2",
            numerator="ot_externa_ab_count_2",
            denominator="population",
            group_by=["ot_externa_abtype2"]
            ),
    Measure(id="infection_abtype_otmedia_2",
            numerator="otmedia_ab_count_2",
            denominator="population",
            group_by=["otmedia_abtype2"]
            ),
    
    ##  AB TYPE by infection-3
    Measure(id="infection_abtype_UTI_3",
            numerator="uti_ab_count_3",
            denominator="population",
            group_by=["uti_abtype3"]
            ),
    Measure(id="infection_abtype_URTI_3",
            numerator="urti_ab_count_3",
            denominator="population",
            group_by=["urti_abtype3"]
            ),
    Measure(id="infection_abtype_LRTI_3",
            numerator="lrti_ab_count_3",
            denominator="population",
            group_by=["lrti_abtype3"]
            ),
    Measure(id="infection_abtype_sinusitis_3",
            numerator="sinusitis_ab_count_3",
            denominator="population",
            group_by=["sinusitis_abtype3"]
            ),
    Measure(id="infection_abtype_ot_externa_3",
            numerator="ot_externa_ab_count_3",
            denominator="population",
            group_by=["ot_externa_abtype3"]
            ),
    Measure(id="infection_abtype_otmedia_3",
            numerator="otmedia_ab_count_3",
            denominator="population",
            group_by=["otmedia_abtype3"]
            ),
    
    ##  AB TYPE by infection-4
    Measure(id="infection_abtype_UTI_4",
            numerator="uti_ab_count_4",
            denominator="population",
            group_by=["uti_abtype4"]
            ),
    Measure(id="infection_abtype_URTI_4",
            numerator="urti_ab_count_4",
            denominator="population",
            group_by=["urti_abtype4"]
            ),
    Measure(id="infection_abtype_LRTI_4",
            numerator="lrti_ab_count_4",
            denominator="population",
            group_by=["lrti_abtype4"]
            ),
    Measure(id="infection_abtype_sinusitis_4",
            numerator="sinusitis_ab_count_4",
            denominator="population",
            group_by=["sinusitis_abtype4"]
            ),
    Measure(id="infection_abtype_ot_externa_4",
            numerator="ot_externa_ab_count_4",
            denominator="population",
            group_by=["ot_externa_abtype4"]
            ),
    Measure(id="infection_abtype_otmedia_4",
            numerator="otmedia_ab_count_4",
            denominator="population",
            group_by=["otmedia_abtype4"]
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
