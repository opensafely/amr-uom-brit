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
        AND has_infection 
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

        has_infection=patients.with_these_clinical_events( # only include 6 infection patients
        six_indication_codes,
        between=["index_date", "last_day_of_month(index_date)"],
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



  ####### Antibiotics types

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
    

    ####### ab history: incident(no ab 90 days before index)/ prevalent
# --UTI
    hx_ab_uti_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_1 - 91 days", " uti_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_uti_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_2 - 91 days", " uti_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_uti_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_3 - 91 days", " uti_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_uti_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["uti_date_4 - 91 days", " uti_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
# --URTI
    hx_ab_urti_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_1 - 91 days", " urti_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_urti_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_2 - 91 days", " urti_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_urti_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_3 - 91 days", " urti_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_urti_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_4 - 91 days", " urti_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
# -- LRTI
    hx_ab_lrti_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_1 - 91 days", " lrti_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_lrti_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_2 - 91 days", " lrti_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_lrti_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_3 - 91 days", " lrti_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_lrti_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["lrti_date_4 - 91 days", " lrti_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),

# -- sisusitis
    hx_ab_sinusitis_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_1 - 91 days", " sinusitis_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_sinusitis_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_2 - 91 days", " sinusitis_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_sinusitis_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_3 - 91 days", " sinusitis_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_sinusitis_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["sinusitis_date_4 - 91 days", " sinusitis_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
# otmedia

    hx_ab_otmedia_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_1 - 91 days", " otmedia_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_otmedia_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_2 - 91 days", " otmedia_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_otmedia_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_3 - 91 days", " otmedia_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_otmedia_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["otmedia_date_4 - 91 days", " otmedia_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
# ot_externa
    hx_ab_ot_externa_date_1= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_1 - 91 days", " ot_externa_date_1 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_ot_externa_date_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_2 - 91 days", " ot_externa_date_2 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_ot_externa_date_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_3 - 91 days", " ot_externa_date_3 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),
    hx_ab_ot_externa_date_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["ot_externa_date_4 - 91 days", " ot_externa_date_4 - 1 day"],
        returning='binary_flag',
        return_expectations={"incidence": 0.8},
    ),





)