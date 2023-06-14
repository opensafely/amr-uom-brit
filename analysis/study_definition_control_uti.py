#### This script is to extract the cases: emergency admission & AE ICD-10  + had event 30 days before the index date


from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2019-01-01"
end_date = "2023-03-31"

###### Controls definition ######
## 1. age 18-110
## 2. sex (M/F)
## 3. at least one year of GP records prior to their index date
## 4. has incident uti infeciton record (no any other uti infection record six weeks before)
## 4. has no ICD-10 related emergency admission within 30 days after the infection
## 5. has no chronic res
##############################

emergency_admission_codes = [
    "21",  # Emergency Admission: Emergency Care Department or dental casualty department of the Health Care Provider
    "22",  # Emergency Admission: GENERAL PRACTITIONER: after a request for immediate admission has been made direct to a Hospital Provider, i.e. not through a Bed bureau, by a GENERAL PRACTITIONER or deputy
    "23",  # Emergency Admission: Bed bureau
    "24",  # Emergency Admission: Consultant Clinic, of this or another Health Care Provider
    "25",  # Emergency Admission: Admission via Mental Health Crisis Resolution Team
    "2A",  # Emergency Admission: Emergency Care Department of another provider where the PATIENT  had not been admitted
    "2B",  # Emergency Admission: Transfer of an admitted PATIENT from another Hospital Provider in an emergency
    "2D",  # Emergency Admission: Other emergency admission
    "28"   # Emergency Admission: Other means, examples are:
           # - admitted from the Emergency Care Department of another provider where they had not been admitted
           # - transfer of an admitted PATIENT from another Hospital Provider in an emergency
           # - baby born at home as intended
    ]


study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 1,
    },

    # Set index date to start date
    index_date=start_date,
   
    # study population
    population=patients.satisfying(
        """
        NOT has_died
        AND has_follow_up_previous_year
        AND (sex = "M" OR sex = "F")
        AND (age >=18 AND age <= 110)
        AND NOT has_outcome_in_30_days
        AND NOT has_chronic_respiratory_disease
        AND NOT has_uti_history_previous_6_month
        AND NOT has_outcome_previous_year
    
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="patient_index_date",
            returning="binary_flag",
        ),

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="patient_index_date - 365 days",
            end_date="patient_index_date",
            return_expectations={"incidence": 0.95},
        ),

        has_outcome_in_30_days=patients.admitted_to_hospital(
            with_these_primary_diagnoses=all_ae_codes,
            with_admission_method=emergency_admission_codes, 
            between=["patient_index_date", "patient_index_date + 30 days"], 
        ),

        has_chronic_respiratory_disease=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes,  
            returning="binary_flag",
            on_or_before="patient_index_date",
            find_last_match_in_period=True,
        ),

        has_uti_history_previous_6_month=patients.with_these_clinical_events(
            uti_codes,  
            returning="binary_flag",
            between=["patient_index_date - 180 days ", "patient_index_date - 1 day"],
        ),

        has_outcome_previous_year=patients.admitted_to_hospital(
            with_these_primary_diagnoses=all_ae_codes, 
            with_admission_method=emergency_admission_codes, 
            returning="binary_flag",
            between=["patient_index_date- 366 days", "patient_index_date - 1 day"],
            return_expectations={"incidence": 0.65},
        ),

    ),

    ### patient index date = UTI infection date
    patient_index_date=patients.with_these_clinical_events(
        uti_codes, 
        between=[start_date, end_date], 
        returning="date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2019-01-01"}, "incidence" : 1},
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
    
    ## Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),



    #Check COVID-diagnsis within +/- 6 weeks #

    ## covid infection record sgss+gp ##
    SGSS_positive_6weeks=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["patient_index_date - 42 days","patient_index_date + 42 days"],
        returning="binary_flag",
        return_expectations={
        "rate" : "exponential_increase",
        "incidence" : 0.25},
    ),
    
    GP_positive_6weeks=patients.with_these_clinical_events(
        any_primary_care_code,        
        returning="binary_flag",
        between=["patient_index_date - 42 days","patient_index_date + 42 days"],
         return_expectations={
        "rate" : "exponential_increase",
        "incidence" : 0.25},  ),

        ## covid infection record hosp ##
    covid_admission_6weeks=patients.admitted_to_hospital(
        returning="binary_flag",
        with_these_diagnoses=covid_codelist,
        between=["patient_index_date - 42 days","patient_index_date + 42 days"],
        return_expectations={
        "rate" : "exponential_increase",
        "incidence" : 0.25},    ),

    covid_6weeks=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                  SGSS_positive_6weeks OR GP_positive_6weeks OR covid_admission_6weeks
            """,
        },
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "0": 0.8,
                                        "1": 0.2
                                        }
                                    },
                                },
    ),

)