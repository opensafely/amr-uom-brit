
from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)

###### import matched cohort
COHORT = "output/matched_patients_id_ab.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2020-02-01"
end_date = "2021-12-31"

####### Import variables

# ## infection before patient_index_date
# from variables_infection import generate_infection_variables
# infection_variables = generate_infection_variables(index_date_variable="patient_index_date")



study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.1,
    },

    # Set index date to start date
    index_date=start_date,
   
    # study population
    population=patients.which_exist_in_file(COHORT),

    ### patient index date  
    # case_infection_date
    patient_index_date=patients.with_value_from_file(
        COHORT,
        returning="patient_index_date",
        returning_type="date",
    ),

    ## Age
    age=patients.age_as_of(
        "patient_index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
            "incidence": 0.001
        },
    ),

    # ## Age categories
    # ## 0-4; 5-14; 15-24; 25-34; 35-44; 45-54; 55-64; 65-74; 75+
    # age_cat=patients.categorised_as(
    #     {
    #         "0":"DEFAULT",
    #         "0-4": """ age >= 0 AND age < 5""",
    #         "5-14": """ age >= 5 AND age < 15""",
    #         "15-24": """ age >= 15 AND age < 25""",
    #         "25-34": """ age >= 25 AND age < 35""",
    #         "35-44": """ age >= 35 AND age < 45""",
    #         "45-54": """ age >= 45 AND age < 55""",
    #         "55-64": """ age >= 55 AND age < 65""",
    #         "65-74": """ age >= 65 AND age < 75""",
    #         "75+": """ age >= 75 AND age < 120""",
    #     },
    #     return_expectations={
    #         "rate": "universal",
    #         "category": {
    #             "ratios": {
    #                 "0": 0,
    #                 "0-4": 0.12, 
    #                 "5-14": 0.11,
    #                 "15-24": 0.11,
    #                 "25-34": 0.11,
    #                 "35-44": 0.11,
    #                 "45-54": 0.11,
    #                 "55-64": 0.11,
    #                 "65-74": 0.11,
    #                 "75+": 0.11,
    #             }
    #         },
    #     },
    # ),

    
    ## Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

## region
    stp=patients.registered_practice_as_of(
             "patient_index_date",
            returning="stp_code",
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "STP1": 0.1,
                        "STP2": 0.1,
                        "STP3": 0.1,
                        "STP4": 0.1,
                        "STP5": 0.1,
                        "STP6": 0.1,
                        "STP7": 0.1,
                        "STP8": 0.1,
                        "STP9": 0.1,
                        "STP10": 0.1,
                    }
                },
            },
    ),

    
# # data check	
#     ## de-register after start date	
#     dereg_date=patients.date_deregistered_from_all_supported_practices(	
#         on_or_before="patient_index_date - 1 day",	
#         date_format="YYYY-MM-DD",	
#         return_expectations={	
#         "date": {"earliest": "2020-02-01"},	
#         "incidence": 0.05	
#         }	
#     ),	
#     ## died after patient index date	
#     ons_died_date_after=patients.died_from_any_cause(	
#         between=["patient_index_date" , "patient_index_date + 1 month"],        	
#         returning="date_of_death",	
#         date_format="YYYY-MM-DD",	
#         return_expectations={"date": {"earliest": "2020-03-01"},"incidence": 0.1},	
#     ),

#     ## died before patient index date	
#     ons_died_date_before=patients.died_from_any_cause(	
#         on_or_before="patient_index_date - 1 day",        	
#         returning="date_of_death",	
#         date_format="YYYY-MM-DD",	
#         return_expectations={"date": {"earliest": "2020-02-01"},"incidence": 0.1},	
#     ),

    AB_6wk=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="number_of_matches_in_period",
        between=["patient_index_date - 42 days", "patient_index_date"],
        return_last_date_in_period=True,
        include_date_of_match= True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),  
    AB_1=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="number_of_matches_in_period",
        between=["patient_index_date - 1137 days", "patient_index_date - 43 days"],
        return_last_date_in_period=True,
        include_date_of_match= True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),  

    AB_2=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="number_of_matches_in_period",
        between=["patient_index_date - 1137 days", "AB_1_date"],
        return_last_date_in_period=True,
        include_date_of_match= True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),)
