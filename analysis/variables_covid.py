from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_covid_variables(index_date_variable):
    covid_variables  = dict(
             
    ## covid infection
    SGSS_positive_test_date=patients.with_test_result_in_sgss(
    pathogen="SARS-CoV-2",
    test_result="positive",
    on_or_before=f'{index_date_variable}',
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
        "date": {"earliest" : "2020-03-01"},
        "rate" : "exponential_increase"
    },
),
    
    primary_care_covid_date=patients.with_these_clinical_events(
        any_primary_care_code,        
        returning="date",
        find_first_match_in_period=True,
        on_or_before=f'{index_date_variable}',
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "2020-03-01"},
            "rate" : "exponential_increase"},
    ),



#        covid_admission_date=patients.admitted_to_hospital(
#         returning= "date_admitted" ,  
#         with_these_diagnoses=covid_codelist,  # not only primary diagnosis
#         on_or_after="index_date",
#         find_first_match_in_period=False,  
#         date_format="YYYY-MM-DD",  
#         return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 0.25},
#    ),

 ## HOSPITAL ADMISSION
    covid_admission_date=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_primary_diagnoses=covid_codelist,  # only include primary_diagnoses as covid
        on_or_before=f'{index_date_variable}',
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 0.25},
    ),

    covid_admission_discharge_date=patients.admitted_to_hospital(
        returning= "date_discharged" , 
        with_these_primary_diagnoses=covid_codelist,  # only include admission for covid(primary_diagnoses)
        on_or_after="covid_admission_date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"}},
   ),

    icu_days=patients.admitted_to_hospital(
        with_these_primary_diagnoses=covid_codelist,
        on_or_after="covid_admission_date",
        returning="days_in_critical_care",
        find_first_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": {
                    "0": 0.6,
                    "1": 0.1,
                    "2": 0.2,
                    "3": 0.1,
                }
            },
            "incidence": 0.1,
        },
    ),

    # ##ICU ADMISSION
    # icu_date_admitted=patients.admitted_to_icu(
    #     on_or_before=f'{index_date_variable}',
    #     find_first_match_in_period=True,
    #     returning="date_admitted",
    #     date_format="YYYY-MM-DD",
    #     return_expectations={
    #         "date": {"earliest" : "2020-03-01"},
    #         "incidence" : 0.25
    #    },
    # ),

    ## died (CPNS: all in-hospital covid-related deaths)
    died_date_cpns=patients.with_death_recorded_in_cpns(
        on_or_before=f'{index_date_variable}',
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01"},
        "rate" : "exponential_increase"},
    ),

    # died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
    #     covid_codelist,
    #     on_or_after="index_date",
    #     returning="date_of_death",
    #     date_format="YYYY-MM-DD",
    #     match_only_underlying_cause=True,
    #     return_expectations={"date": {"earliest" : "2020-02-01"},
    #     "incidence" : 0.25},
    # ),
    # # died_ons_confirmedcovid_flag_any=patients.with_these_codes_on_death_certificate(
    # #     confirmed_covid_codelist,
    # #     on_or_after="2020-02-01",
    # #     match_only_underlying_cause=False,
    # #     return_expectations={"date": {"earliest" : "2020-02-01"},
    # #     "rate" : "exponential_increase"},
    # # ),
    # # died_ons_suspectedcovid_flag_any=patients.with_these_codes_on_death_certificate(
    # #     suspected_covid_codelist,
    # #     on_or_after="2020-02-01",
    # #     match_only_underlying_cause=False,
    # #     return_expectations={"date": {"earliest" : "2020-02-01"},
    # #     "rate" : "exponential_increase"},
    # # ),

    died_date_ons_covid=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_before=f'{index_date_variable}',
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        match_only_underlying_cause=True,
        return_expectations={"date": {"earliest": "2020-02-01"},
        "incidence" : 0.25},
    ),

  )
    return covid_variables