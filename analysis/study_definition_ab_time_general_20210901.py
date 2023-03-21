
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
COHORT = "output/general_id_2021-09.csv"

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

#     ## Age
#     age=patients.age_as_of(
#         "patient_index_date",
#         return_expectations={
#             "rate": "universal",
#             "int": {"distribution": "population_ages"},
#             "incidence": 0.001
#         },
#     ),

#     # ## Age categories
#     # ## 0-4; 5-14; 15-24; 25-34; 35-44; 45-54; 55-64; 65-74; 75+
#     # age_cat=patients.categorised_as(
#     #     {
#     #         "0":"DEFAULT",
#     #         "0-4": """ age >= 0 AND age < 5""",
#     #         "5-14": """ age >= 5 AND age < 15""",
#     #         "15-24": """ age >= 15 AND age < 25""",
#     #         "25-34": """ age >= 25 AND age < 35""",
#     #         "35-44": """ age >= 35 AND age < 45""",
#     #         "45-54": """ age >= 45 AND age < 55""",
#     #         "55-64": """ age >= 55 AND age < 65""",
#     #         "65-74": """ age >= 65 AND age < 75""",
#     #         "75+": """ age >= 75 AND age < 120""",
#     #     },
#     #     return_expectations={
#     #         "rate": "universal",
#     #         "category": {
#     #             "ratios": {
#     #                 "0": 0,
#     #                 "0-4": 0.12, 
#     #                 "5-14": 0.11,
#     #                 "15-24": 0.11,
#     #                 "25-34": 0.11,
#     #                 "35-44": 0.11,
#     #                 "45-54": 0.11,
#     #                 "55-64": 0.11,
#     #                 "65-74": 0.11,
#     #                 "75+": 0.11,
#     #             }
#     #         },
#     #     },
#     # ),

    
#     ## Sex
#     sex=patients.sex(
#         return_expectations={
#             "rate": "universal",
#             "category": {"ratios": {"M": 0.49, "F": 0.51}},
#         }
#     ),

# ## region
#     stp=patients.registered_practice_as_of(
#              "patient_index_date",
#             returning="stp_code",
#             return_expectations={
#                 "rate": "universal",
#                 "category": {
#                     "ratios": {
#                         "STP1": 0.1,
#                         "STP2": 0.1,
#                         "STP3": 0.1,
#                         "STP4": 0.1,
#                         "STP5": 0.1,
#                         "STP6": 0.1,
#                         "STP7": 0.1,
#                         "STP8": 0.1,
#                         "STP9": 0.1,
#                         "STP10": 0.1,
#                     }
#                 },
#             },
#     ),

    
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
        include_date_of_match= True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),  


AB_date_0=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'patient_index_date - 42 days '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_1=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'patient_index_date - 43 days '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_2=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_1- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_3=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_2- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_4=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_3- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_5=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_4- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_6=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_5- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_7=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_6- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_8=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_7- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_9=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_8- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_10=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_9- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_11=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_10- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_12=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_11- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_13=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_12- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_14=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_13- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_15=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_14- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_16=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_15- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_17=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_16- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_18=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_17- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_19=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_18- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_20=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_19- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_21=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_20- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_22=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_21- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_23=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_22- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_24=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_23- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_25=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_24- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_26=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_25- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_27=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_26- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_28=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_27- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_29=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_28- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_30=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_29- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_31=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_30- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_32=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_31- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_33=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_32- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_34=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_33- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_35=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_34- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_36=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_35- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_37=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_36- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_38=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_37- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_39=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_38- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_40=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_39- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_41=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_40- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_42=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_41- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_43=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_42- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_44=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_43- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_45=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_44- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_46=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_45- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_47=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_46- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_48=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_47- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_49=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_48- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_50=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_49- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_51=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_50- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_52=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_51- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_53=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_52- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_54=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_53- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_55=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_54- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_56=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_55- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_57=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_56- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_58=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_57- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_59=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_58- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_date_60=patients.with_these_medications(antibacterials_codes_brit,returning='date',between=['patient_index_date - 1137 days', 'AB_date_59- 1 day '],find_last_match_in_period=True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),


AB_0=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_0', 'AB_date_0'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_1=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_1', 'AB_date_1'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_2=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_2', 'AB_date_2'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_3=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_3', 'AB_date_3'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_4=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_4', 'AB_date_4'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_5=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_5', 'AB_date_5'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_6=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_6', 'AB_date_6'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_7=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_7', 'AB_date_7'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_8=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_8', 'AB_date_8'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_9=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_9', 'AB_date_9'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_10=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_10', 'AB_date_10'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_11=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_11', 'AB_date_11'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_12=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_12', 'AB_date_12'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_13=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_13', 'AB_date_13'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_14=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_14', 'AB_date_14'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_15=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_15', 'AB_date_15'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_16=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_16', 'AB_date_16'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_17=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_17', 'AB_date_17'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_18=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_18', 'AB_date_18'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_19=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_19', 'AB_date_19'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_20=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_20', 'AB_date_20'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_21=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_21', 'AB_date_21'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_22=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_22', 'AB_date_22'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_23=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_23', 'AB_date_23'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_24=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_24', 'AB_date_24'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_25=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_25', 'AB_date_25'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_26=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_26', 'AB_date_26'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_27=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_27', 'AB_date_27'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_28=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_28', 'AB_date_28'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_29=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_29', 'AB_date_29'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_30=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_30', 'AB_date_30'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_31=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_31', 'AB_date_31'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_32=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_32', 'AB_date_32'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_33=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_33', 'AB_date_33'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_34=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_34', 'AB_date_34'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_35=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_35', 'AB_date_35'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_36=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_36', 'AB_date_36'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_37=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_37', 'AB_date_37'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_38=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_38', 'AB_date_38'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_39=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_39', 'AB_date_39'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_40=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_40', 'AB_date_40'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_41=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_41', 'AB_date_41'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_42=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_42', 'AB_date_42'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_43=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_43', 'AB_date_43'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_44=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_44', 'AB_date_44'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_45=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_45', 'AB_date_45'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_46=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_46', 'AB_date_46'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_47=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_47', 'AB_date_47'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_48=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_48', 'AB_date_48'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_49=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_49', 'AB_date_49'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_50=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_50', 'AB_date_50'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_51=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_51', 'AB_date_51'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_52=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_52', 'AB_date_52'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_53=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_53', 'AB_date_53'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_54=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_54', 'AB_date_54'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_55=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_55', 'AB_date_55'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_56=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_56', 'AB_date_56'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_57=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_57', 'AB_date_57'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_58=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_58', 'AB_date_58'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_59=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_59', 'AB_date_59'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
AB_60=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['AB_date_60', 'AB_date_60'],return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),


#     AB_6wk_type=patients.with_these_medications(
#         antibacterials_codes_brit,
#         returning="category",
#         between=["patient_index_date - 42 days", "patient_index_date"],
#         find_last_match_in_period=True,
#      #   include_date_of_match= True,
#      #   date_format="YYYY-MM-DD",
#         return_expectations={
#             "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
#             "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
#             "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
#             "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
#             "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
#             "incidence": 0.99,
#         },   
#          ),  
#    # most recent ab type 
#     AB_1_type=patients.with_these_medications( 
#         antibacterials_codes_brit,
#         returning="category",
#         between=['patient_index_date - 1137 days', 'patient_index_date - 43 days '],
#         find_last_match_in_period=True,
#      #   include_date_of_match= True,
#      #   date_format="YYYY-MM-DD",
#         return_expectations={
#             "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
#             "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
#             "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
#             "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
#             "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
#             "incidence": 0.99,
#         },   
#          ),  

# AB_0=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'patient_index_date - 42 days'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_1=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'patient_index_date - 43 days'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_2=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_1_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_3=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_2_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_4=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_3_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_5=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_4_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_6=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_5_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_7=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_6_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_8=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_7_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_9=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_8_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_10=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_9_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_11=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_10_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_12=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_11_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_13=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_12_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_14=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_13_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_15=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_14_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_16=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_15_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_17=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_16_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_18=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_17_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_19=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_18_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_20=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_19_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_21=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_20_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_22=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_21_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_23=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_22_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_24=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_23_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_25=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_24_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_26=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_25_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_27=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_26_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_28=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_27_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_29=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_28_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_30=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_29_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_31=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_30_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_32=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_31_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_33=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_32_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_34=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_33_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_35=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_34_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_36=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_35_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_37=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_36_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_38=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_37_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_39=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_38_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_40=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_39_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_41=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_40_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_42=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_41_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_43=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_42_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_44=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_43_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
# AB_45=patients.with_these_medications(antibacterials_codes_brit,returning='number_of_matches_in_period',between=['patient_index_date - 1137 days', 'AB_44_date'], include_date_of_match= True,date_format='YYYY-MM-DD',return_expectations={'int' : {'distribution': 'normal', 'mean': 5, 'stddev': 1},'incidence':0.2}),
    )
