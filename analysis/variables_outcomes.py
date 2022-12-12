from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_hospital_admission_variables(index_date_variable):
    hospital_admission_variables  = dict(
             
 ## HOSPITAL ADMISSION
    infection_related_admission_date=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_diagnoses=infection_related_complication_codes,  
        on_or_before=f'{index_date_variable} - 1 day',
        find_last_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},    ),


    adverse_event_related_admission_date=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_diagnoses=adverse_event_codes,  # not only primary diagnosis
        on_or_before=f'{index_date_variable} - 1 day',
        find_last_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},    ),



    ## exclusion criteria for 30 days after


    covid_admission_date_after=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_diagnoses=covid_codelist, 
        between=[f'{index_date_variable}' , f'{index_date_variable} + 1 month'],        
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 0.25},
    ),

    ## died (CPNS: all in-hospital covid-related deaths)
    died_date_cpns_after=patients.with_death_recorded_in_cpns(
        between=[f'{index_date_variable}' , f'{index_date_variable} +   1 month'],        
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),

    died_date_ons_covid_after=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        between=[f'{index_date_variable}' , f'{index_date_variable} +  1 month'],        
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        match_only_underlying_cause=False, # not restricted to primary cause
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),


       ## exclusion criteria for 30 days before

       ## covid infection
    SGSS_positive_test_date_before=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_before=f'{index_date_variable} - 1 month',      
        returning="date",
        date_format="YYYY-MM-DD",
                return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
),
    
    primary_care_covid_date_before=patients.with_these_clinical_events(
        any_primary_care_code,        
        returning="date",
        on_or_before=f'{index_date_variable} - 1 month',      
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),


    covid_admission_date_before=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_diagnoses=covid_codelist,  # only include primary_diagnoses as covid
        on_or_before=f'{index_date_variable} - 1 month',      
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),

    ## died (CPNS: all in-hospital covid-related deaths)
    died_date_cpns_before=patients.with_death_recorded_in_cpns(
        on_or_before=f'{index_date_variable} - 1 month',      
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),

    died_date_ons_covid_before=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_before=f'{index_date_variable} - 1 month',      
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),


  )
    return hospital_admission_variables
