
# ######################################

# # This script provides the formal specification of the study data that will be extracted from
# # the OpenSAFELY database.

# ######################################

# # --- IMPORT STATEMENTS ---

# ## Import code building blocks from cohort extractor package
# from cohortextractor import (
#     StudyDefinition,
#     patients,
#     #codelist_from_csv,
#     codelist,
#     filter_codes_by_category,
#     #combine_codelists,
#     Measure
# )

# ## Import codelists from codelist.py (which pulls them from the codelist folder)

# #from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, uti_codes, lrti_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes, flu_med_codes, flu_clinical_given_codes, flu_clinical_not_given_codes, covrx_code, hospitalisation_infection_related #, any_lrti_urti_uti_hospitalisation_codes#, flu_vaccine_codes

# from codelists import *


# # DEFINE STUDY POPULATION ---

# ## Define study time variables
# from datetime import datetime

# start_date = "2019-01-01"
# end_date = datetime.today().strftime('%Y-%m-%d')

# ## Define study population and variables
# study = StudyDefinition(

#     # Configure the expectations framework
#     default_expectations={
#         "date": {"earliest": start_date, "latest": end_date},
#         "rate": "uniform",
#         "incidence": 0.1,
#     },
#     # Set index date to start date
#     index_date=start_date,
#     # Define the study population
#     population=patients.satisfying(
#         """
#         NOT has_died
#         AND
#         registered
#         AND
#         age
#         AND
#         has_follow_up_previous_year
#         AND
#         (sex = "M" OR sex = "F")
#         """,

#         has_died=patients.died_from_any_cause(
#             on_or_before="index_date",
#             returning="binary_flag",
#         ),

#         registered=patients.satisfying(
#             "registered_at_start",
#             registered_at_start=patients.registered_as_of("index_date"),
#         ),

#         has_follow_up_previous_year=patients.registered_with_one_practice_between(
#             start_date="index_date - 1 year",
#             end_date="index_date",
#             return_expectations={"incidence": 0.95},
#         ),

#     ),

#     ########## patient demographics to group_by for measures:
#     ### Age
#     age=patients.age_as_of(
#         "index_date",
#         return_expectations={
#             "rate": "universal",
#             "int": {"distribution": "population_ages"},
#             "incidence": 0.001
#         },
#     ),

#     ### Age categories

#     ## 0-4; 5-14; 15-24; 25-34; 35-44; 45-54; 55-64; 65-74; 75+
#     age_cat=patients.categorised_as(
#         {
#             "0":"DEFAULT",
#             "0-4": """ age >= 0 AND age < 5""",
#             "5-14": """ age >= 5 AND age < 15""",
#             "15-24": """ age >= 15 AND age < 25""",
#             "25-34": """ age >= 25 AND age < 35""",
#             "35-44": """ age >= 35 AND age < 45""",
#             "45-54": """ age >= 45 AND age < 55""",
#             "55-64": """ age >= 55 AND age < 65""",
#             "65-74": """ age >= 65 AND age < 75""",
#             "75+": """ age >= 75 AND age < 120""",
#         },
#         return_expectations={
#             "rate": "universal",
#             "category": {
#                 "ratios": {
#                     "0": 0,
#                     "0-4": 0.12, 
#                     "5-14": 0.11,
#                     "15-24": 0.11,
#                     "25-34": 0.11,
#                     "35-44": 0.11,
#                     "45-54": 0.11,
#                     "55-64": 0.11,
#                     "65-74": 0.11,
#                     "75+": 0.11,
#                 }
#             },
#         },
#     ),

    
#     ### Sex
#     sex=patients.sex(
#         return_expectations={
#             "rate": "universal",
#             "category": {"ratios": {"M": 0.49, "F": 0.51}},
#         }
#     ),

#     #deregistration for censoring
#     deregistered_date=patients.date_deregistered_from_all_supported_practices(
#             date_format="YYYY-MM-DD",
#             # between=["index_date", "last_day_of_month(index_date)"],
#         #     return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
#         # ),
#             return_expectations={"date": {"earliest": "index_date"}, "incidence": 0.05}, 
#         ),

#     ## Death
#     died_date=patients.died_from_any_cause(
#         on_or_after="index_date",
#         returning="date_of_death",
#         date_format="YYYY-MM-DD",
#         return_expectations={
#             "date": {"earliest" : "index_date"},  "rate" : "exponential_increase"
#         },
#     ),

#     ########## risk factors

#     ### Practice
#     practice=patients.registered_practice_as_of(
#         "index_date",
#         returning="pseudo_id",
#         return_expectations={"int": {"distribution": "normal",
#                                      "mean": 25, "stddev": 5}, "incidence": 1}
#     ),
      

#     ########## hospital admission

#     # ## hospitalisation
#     # admitted=patients.admitted_to_hospital(
#     #     returning="binary_flag",
#     #     #returning="date_admitted",
#     #     #date_format="YYYY-MM-DD",
#     #     between=["index_date", "today"],
#     #     return_expectations={"incidence": 0.1},
#     # ),

#     # ## hospitalisation history 
#     # hx_hosp=patients.admitted_to_hospital(
#     #     between=["index_date - 12 months", "index_date"],
#     #     returning="number_of_matches_in_period",
#     #     #returning="date_admitted",
#     #     #date_format="YYYY-MM-DD",
#     #     return_expectations={
#     #         "int" : {"distribution": "normal", "mean": 5, "stddev": 1}, "incidence":0.1}
#     # ),

#     # # hospitalisation with diagnosis of lrti, urti, or uti
#     # admitted_date=patients.admitted_to_hospital(
#     #    with_these_diagnoses=hospitalisation_infection_related,
#     #    returning="date_admitted",
#     #    date_format="YYYY-MM-DD",
#     #    find_first_match_in_period=True,
#     #    return_expectations={"incidence": 0.3},
#     # ),


# ## hospitalisation with incident OR prevalent urti

#     admitted = patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="number_of_matches_in_period",
#     #    date_format="YYYY-MM-DD",
#        between=["index_date", "today"],
#     #    find_first_match_in_period=True,
#     #    return_expectations={"incidence": 0.3},
#         return_expectations={"int": {"distribution": "normal", "mean": 6, "stddev": 3}, "incidence": 0.6},
#     ),

#     admitted_date = patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["index_date", "today"],
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     ## Covid positive test result during hospital admission related to urti
#     sgss_pos_covid_admitted=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["admitted_date - 90 days", "admitted_date + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis during hospital admission related to urti
#     gp_covid_date_admitted = patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["admitted_date - 90 days", "admitted_date + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
#     sgss_gp_cov_admitted = patients.satisfying(
#         """
#         sgss_pos_covid_admitted OR
#         gp_covid_date_admitted
#         """,
#     ),

# )

# # --- DEFINE MEASURES ---


# measures = [

# Measure(id="hosp_rate",
#         numerator="admitted_date",
#         denominator="population",
#         group_by=["sex", "age_cat"],
#         small_number_suppression=True,
#         ),

# ]


from cohortextractor import StudyDefinition, Measure, patients
from codelists import *

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "2019-01-01", "latest": "today"},
        "rate": "exponential_increase",
        "incidence": 0.2,
    },

    index_date="2020-01-01",

    population=patients.registered_as_of("index_date"),

    # stp=patients.registered_practice_as_of(
    #     "index_date",
    #     returning="stp_code",
    #     return_expectations={
    #         "category": {"ratios": {"stp1": 0.1, "stp2": 0.2, "stp3": 0.7}},
    #         "incidence": 1,
    #     },
    # ),

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

    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    # admitted_binary=patients.admitted_to_hospital(
    #     returning="binary_flag",
    #     between=["index_date", "last_day_of_month(index_date)"],
    #     return_expectations={"incidence": 0.1},
    # ),

    # died=patients.died_from_any_cause(
    #     between=["index_date", "last_day_of_month(index_date)"],
    #     returning="binary_flag",
    #     return_expectations={"incidence": 0.05},
    # ),

## hospitalisation with incident OR prevalent urti

    admitted = patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="number_of_matches_in_period",
    #    date_format="YYYY-MM-DD",
       between=["index_date", "last_day_of_month(index_date)"],
    #    find_first_match_in_period=True,
    #    return_expectations={"incidence": 0.3},
        return_expectations={"int": {"distribution": "normal", "mean": 6, "stddev": 3}, "incidence": 0.6},
    ),

    admitted_date = patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["index_date", "last_day_of_month(index_date)"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    ## Covid positive test result during hospital admission related to urti
    sgss_pos_covid_admitted=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["admitted_date - 90 days", "admitted_date + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis during hospital admission related to urti
    gp_covid_date_admitted = patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["admitted_date - 90 days", "admitted_date + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
        # return_expectations={"date":{"earliest":index_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_admitted = patients.satisfying(
        """
        sgss_pos_covid_admitted OR
        gp_covid_date_admitted
        """,
    ),

)

measures = [

    Measure(
        id="hosp_rate",
        numerator="admitted",
        denominator="population",
        # group_by=["sex", 'age_cat'],
        small_number_suppression=True,
    ),

    Measure(
        id="hosp_rate_sex",
        numerator="admitted",
        denominator="population",
        group_by=["sex"],
        small_number_suppression=True,
    ),

    Measure(
        id="hosp_rate_age_cat",
        numerator="admitted",
        denominator="population",
        group_by=['age_cat'],
        small_number_suppression=True,
    ),

    Measure(
        id="hosp_rate_sex_age_cat",
        numerator="admitted",
        denominator="population",
        group_by=["sex", 'age_cat'],
        small_number_suppression=True,
    ),
    
    # Measure(
    #     id="hosp_admission_by_stp",
    #     numerator="admitted_binary",
    #     denominator="population",
    #     group_by="stp",
    # ),    

    # Measure(
    #     id="death_by_stp",
    #     numerator="died",
    #     denominator="population",
    #     group_by="stp",
    #     small_number_suppression=True,
    # ),
]
