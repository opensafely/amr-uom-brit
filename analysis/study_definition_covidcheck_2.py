
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

    # COVID Vaccination from repo: https://github.com/opensafely/covid-diabetes-outcomes
    # First COVID vaccination (GP record)
    date_vaccin_gp_1=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="2020-12-01",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-12-08"},  "incidence": 0.7},
    ),
        
    # Second COVID vaccination (GP record)
    date_vaccin_gp_2=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="date_vaccin_gp_1 + 19 days",
        find_last_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-12-08"},  "incidence": 0.5},
    ),


    ####### Covid positive test result
    ## Positive covid test_sgss 1
    Covid_test_result_sgss_1=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="2020-02-01",
        find_first_match_in_period=True,
        returning='binary_flag',
        return_expectations={
            "incidence": 0.5},
    ),

    ## positive date_sgss 1
    Covid_test_result_sgss_1_DATE=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after = "2020-02-01",
        find_first_match_in_period=True,
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-02-01"},  "incidence": 0.5},
    ),

    ## Positive covid test_sgss 2
    Covid_test_result_sgss_2=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="Covid_test_result_sgss_1_DATE",
        find_first_match_in_period=True,
        returning='binary_flag',
        return_expectations={
            "incidence": 0.1},
    ),

    
    ## positive date_sgss
    Covid_test_result_sgss_2_DATE=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="Covid_test_result_sgss_1_DATE + 19 days",
        find_first_match_in_period=True,
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-06-08"},  "incidence": 0.5},
    ),


    ## number of positive test patients
    covid_positive_count_sgss=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="2020-02-01",
        returning='number_of_matches_in_period',
        restrict_to_earliest_specimen_date = False,
        return_expectations={
            "int": {"distribution":"normal","mean":10,"stddev":1},"incidence":0.5},
    ),        

    ## Covid diagnosis record by primary care (gp)
    gp_covid_count=patients.with_these_clinical_events(
        any_primary_care_code,
        on_or_after="2020-02-01",
        find_first_match_in_period=True,
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution":"normal","mean":10,"stddev":1},"incidence":0.5},
    ),




    ## flu vaccine in tpp 2019
    flu_vaccine_tpp_2019=patients.with_tpp_vaccination_record(
        target_disease_matches="influenza",
        on_or_before = "2019-12-31",
        find_last_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2019-01-01"},  "incidence": 0.7},
    ),

    ## flu vaccine in tpp 2020
    flu_vaccine_tpp_2020=patients.with_tpp_vaccination_record(
        target_disease_matches="influenza",
        on_or_before="2020-12-31",
        find_last_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-01-01"},  "incidence": 0.7},
    ),

    ## flu vaccine in tpp 2021
    flu_vaccine_tpp_2021=patients.with_tpp_vaccination_record(
        target_disease_matches="influenza",
        on_or_before="2021-12-31",
        find_last_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2021-01-01"},  "incidence": 0.7},
    ),

    ## flu vaccine in tpp 2022
    flu_vaccine_tpp_2022=patients.with_tpp_vaccination_record(
        target_disease_matches="influenza",
        on_or_before="today",
        find_last_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2022-01-01"},  "incidence": 0.7},
    ),

    # Antibiotics
    antibiotics_prescriptions=patients.with_these_medications(
        antibacterials_codes_brit,
        on_or_after="index_date",
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 5, "stddev": 1}, "incidence": 0.5}
    ),

    # Broad spectrum antibiotics
    broad_spectrum_antibiotics_prescriptions=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["index_date", "today"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 5, "stddev": 1}, "incidence": 0.5}
    ),

    


    ## our vaccination covid script
    ### First COVID vaccination medication code (any)
    covrx1_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
                "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_code,
        },
        find_first_match_in_period=True,
        on_or_after="index_date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase", "date":{"earliest":"2020-11-29"},
            "incidence": 0.5,
        }
    ),
    # Second COVID vaccination medication code (any)
    covrx2_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
                "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_code,
        },
        find_last_match_in_period=True,
        on_or_after="covrx1_dat + 19 days",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase", 
            "incidence": 0.5,
        }
    ),

    # #Death
    died_date=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},  "rate" : "exponential_increase"
        },
    ),
)


#     ## using def from repo: https://github.com/opensafely/covid-vaccine-safety-research/blob/59b09d417dd114dbfc2719b9b54d921b50ea1bcb/analysis/vaccine_variables.py
#     ## define covid vaccinations 
#     def generate_vaccine_variables(index_date):
#     vaccine_variables = dict(
#     # COVID VACCINATION VARIABLES  
#     # any COVID vaccination (first dose)
#     first_any_vaccine_date=patients.with_tpp_vaccination_record(
#         target_disease_matches="SARS-2 CORONAVIRUS",
#         on_or_after="2020-12-07",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  # first vaccine administered on the 8/12
#                 "latest": "2021-03-01",
#             }
#         },
#     ),
#     # pfizer (first dose) 
#     first_pfizer_date=patients.with_tpp_vaccination_record(
#         target_disease_matches="SARS-2 CORONAVIRUS",
#         product_name_matches="COVID-19 mRNA Vaccine Pfizer-BioNTech BNT162b2 30micrograms/0.3ml dose conc for susp for inj MDV",
#         on_or_after="2020-12-07",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  # first vaccine administered on the 8/12
#                 "latest": "2021-03-01",
#             }
#         },
#     ),
#     # az (first dose)
#     first_az_date=patients.with_tpp_vaccination_record(
#         target_disease_matches="SARS-2 CORONAVIRUS",
#         product_name_matches="COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
#         on_or_after="2020-12-07",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  # first vaccine administered on the 8/12
#                 "latest": "2021-03-01",
#             }
#         },
#     ),

#     # moderna (first dose)
#     first_moderna_date=patients.with_tpp_vaccination_record(
#         product_name_matches="COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
#         on_or_after="2020-12-07",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  
#                 "latest": "2021-03-01",
#             },
#         },
#     ),

#     # any COVID vaccination (second dose)
#     second_any_vaccine_date=patients.with_tpp_vaccination_record(
#         target_disease_matches="SARS-2 CORONAVIRUS",
#         on_or_after="first_any_vaccine_date + 21 days",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  # first vaccine administered on the 8/12
#                 "latest": "2021-03-01",
#             }
#         },
#     ),
#     # pfizer (second dose) 
#     second_pfizer_date=patients.with_tpp_vaccination_record(
#         target_disease_matches="SARS-2 CORONAVIRUS",
#         product_name_matches="COVID-19 mRNA Vaccine Pfizer-BioNTech BNT162b2 30micrograms/0.3ml dose conc for susp for inj MDV",
#         on_or_after="first_any_vaccine_date + 21 days",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  # first vaccine administered on the 8/12
#                 "latest": "2021-03-01",
#             }
#         },
#     ),
#     # az (second dose)
#     second_az_date=patients.with_tpp_vaccination_record(
#         target_disease_matches="SARS-2 CORONAVIRUS",
#         product_name_matches="COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
#         on_or_after="first_any_vaccine_date + 21 days",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  # first vaccine administered on the 8/12
#                 "latest": "2021-03-01",
#             }
#         },
#     ),
#     second_moderna_date=patients.with_tpp_vaccination_record(
#         product_name_matches="COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
#         on_or_after="first_any_vaccine_date + 21 days",  
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {
#                 "earliest": "2020-12-08",  
#                 "latest": "2021-03-01",
#             },
#         },
#     ),
#     )
#     return vaccine_variables
# )

# # define measures:

# measures = [

    
#     # ## Broad spectrum antibiotics
#     # Measure(id="broad_spectrum_proportion",
#     #         numerator="broad_spectrum_antibiotics_prescriptions",
#     #         denominator="antibacterial_brit",
#     #         group_by=["practice"]
#     #         ),

#     # ## antibiotic count rolling 12m before
#     # Measure(id="ABs_12mb4",
#     #         numerator="antibacterial_12mb4",
#     #         denominator="population",
#     #         group_by=["practice", "patient_id"]
#     #         ),

    
       
#     ## covid diagnosis same day prescribing
#     Measure(id="gp_same_day_pos_ab",
#             numerator="gp_covid_ab_prescribed",
#             denominator="population",
#             group_by=["gp_covid"]
#             ),

#     Measure(id="Same_day_pos_ab_sgss",
#             numerator="sgss_ab_prescribed",
#             denominator="population",
#             group_by=["Covid_test_result_sgss"]
#             ),

#     # ## broad_vs_narrow
#     # Measure(id="broad_narrow_prescribing",
#     #         numerator="broad_spectrum_antibiotics_prescriptions",
#     #         denominator="antibacterial_brit",
#     #         group_by=["practice","broad_prescriptions_check","age_cat"]
#     #         ),    


# ]
