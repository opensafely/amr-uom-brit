
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
start_date = "2019-01-01"
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

    ### STAR-PU Age categories

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

      
    ### Region - NHS England 9 regions
    region=patients.registered_practice_as_of(
    "index_date",
    returning="nuts1_region_name",
    return_expectations={
        "rate": "universal",
        "category": {
            "ratios": {
                "North East": 0.1,
                "North West": 0.1,
                "Yorkshire and the Humber": 0.1,
                "East Midlands": 0.1,
                "West Midlands": 0.1,
                "East of England": 0.1,
                "London": 0.2,
                "South East": 0.2, },},
         },
    ),
    
    ## antibiotic use
    antibiotic_count=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
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

    ## Broad spectrum antibiotics(co-amoxiclav-cephalosporins-and-quinolones)
    broad_ab_count=patients.with_these_medications(
        broad_spectrum_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 3, "stddev": 1}, "incidence": 0.5}
    ),

    broad_ab_binary=patients.with_these_medications(
        broad_spectrum_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.1,},
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

)

measures = [
###  Monthly total number of antibiotic items ###   
    Measure(
        id="antibiotic_items",
        numerator="antibiotic_count",
        denominator="population",
        group_by="population",
    ),

###  Monthly total number of antibiotic items STAR-PU adjust ###   
    Measure(
        id="antibiotic_items_STAR-PU",
        numerator="antibiotic_count",
        denominator="population",
        group_by=["age_cat", "sex"],
    ),

###  Monthly total number of antibiotic items ###   
    Measure(
        id="broad-spectrum-ratio",
        numerator="broad_ab_count",
        denominator="antibiotic_count",
        group_by="population",
    ),

###  Monthly number of patients tested positive for SARS-CoV-2 ###   
    Measure(
        id="covid-case",
        numerator="Tested_for_covid_event",
        denominator="population",
        group_by=["population"],
    ),

###  Monthly broad-spectrum-ratio stratified ###   
    Measure(
        id="broad-spectrum-ratio_age",
        numerator="broad_ab_count",
        denominator="antibiotic_count",
        group_by="age_cat",
    ),

    Measure(
        id="broad-spectrum-ratio_sex",
        numerator="broad_ab_count",
        denominator="antibiotic_count",
        group_by="sex",
    ),

    Measure(
        id="broad-spectrum-ratio_region",
        numerator="broad_ab_count",
        denominator="antibiotic_count",
        group_by="region",
    ),

    Measure(
        id="14D_window_ab",
        numerator="AB_given_14D_window",
        denominator="Positive_test_event",
        group_by="broad_ab_binary",
    ),

]