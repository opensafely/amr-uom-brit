
from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
    filter_codes_by_category,
    Measure
)

###### Code lists
from codelists import *

# DEFINE STUDY TIME #
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
        age
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
        between=[start_date,end_date],
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
    
    antibiotic_type=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date", "last_day_of_month(index_date)"],
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

    ## Covid positive test result-SGSS
    Tested_for_covid_event=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="any",
        between=["index_date", "last_day_of_month(index_date)"],
        returning = "binary_flag",
        return_expectations={"incidence": 0.5},
    ),

    Positive_test_event=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["index_date", "last_day_of_month(index_date)"],
        returning = "binary_flag",
        return_expectations={"incidence": 0.5},
    ),
    
    Positive_test_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},
            "rate" : "exponential_increase"
        },
    ),

    ## Same day antibiotic prescribed binary

    AB_given_14D_window=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["Positive_test_date - 14 days","Positive_test_date + 14 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.3,},
    ),

    Broad_given_14D_window=patients.with_these_medications(
        broad_spectrum_codes,
        between=["Positive_test_date - 14 days","Positive_test_date + 14 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.3,},
    ),


    AB_given_2D_window=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["Positive_test_date - 2 days","Positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.3,},
    ),

    Broad_given_2D_window=patients.with_these_medications(
        broad_spectrum_codes,
        between=["Positive_test_date - 2 days","Positive_test_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.3,},
    ),
    ### Infection coded binary ###
    Infection_coded_14D_window=patients.with_these_clinical_events(
        antibiotics_indications,
        between=["Positive_test_date - 14 days","Positive_test_date + 14 days"],
        returning='binary_flag',
        return_expectations={"incidence":0.3,},
    ),

    Infection_coded_2D_window=patients.with_these_clinical_events(
        antibiotics_indications,
        between=["Positive_test_date - 2 days","Positive_test_date + 2 days"],
        returning='binary_flag',
        return_expectations={"incidence":0.3,},
    ),
)




measures = [
###  Antibiotic use among SAR-CoV-2 positive patients ###

    Measure(
        id="21_infection_coded_14D_window_ab",
        numerator="AB_given_14D_window",
        denominator="Positive_test_event",
        group_by="Infection_coded_14D_window",
    ),

    Measure(
        id="21_infection_coded_14D_window_broad",
        numerator="Broad_given_14D_window",
        denominator="Positive_test_event",
        group_by="Infection_coded_14D_window",
    ),

    Measure(
        id="21_infection_coded_2D_window_ab",
        numerator="AB_given_2D_window",
        denominator="Positive_test_event",
        group_by="Infection_coded_2D_window",
    ),

    Measure(
        id="21_infection_coded_2D_window_broad",
        numerator="Broad_given_2D_window",
        denominator="Positive_test_event",
        group_by="Infection_coded_2D_window",
    ),

]