
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
        AND NOT region = ""
        AND NOT imd = "0"
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
        ),

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="index_date - 365 days",
            end_date="index_date",
            return_expectations={"incidence": 0.95},
        ),
    ),
    ## clinical events
    # Admitted to hospital - all emergency admissions
    patient_index_date=patients.admitted_to_hospital(
        returning= "date_admitted",  
        with_admission_method=emergency_admission_codes,  
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2019-01-01"}, "incidence" : 1},
    ),

    admitted = patients.admitted_to_hospital(
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        with_admission_method=emergency_admission_codes,
        return_expectations={"incidence": 0.1},
    ),
    
    # Admitted to hospital - all ambulatory care sensitive
    ae_admitted = patients.admitted_to_hospital(
        returning="binary_flag",
        with_these_primary_diagnoses=all_ae_codes,
        with_admission_method=emergency_admission_codes,  
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={"incidence": 0.05},
    ),

    ## antibiotic use
    antibiotic_treatment=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="binary_flag",
        between=['patient_index_date - 30 days', 'patient_index_date'],
        return_expectations={"incidence":0.5}
    ),  

    #  --UTI
    uti_record=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=['patient_index_date - 42 days', 'patient_index_date'],
        return_expectations={"incidence":0.5}
    ),  
    #  --LRTI 
    lrti_record=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=['patient_index_date - 42 days', 'patient_index_date'],
        return_expectations={"incidence":0.6}
    ),  

    #  --URTI  
    urti_record=patients.with_these_clinical_events(
        all_urti_codes,
        returning="binary_flag",
        between=['patient_index_date - 42 days', 'patient_index_date'],
        return_expectations={"incidence":0.4}
    ),  

    #  --sinusitis 
    sinusitis_record=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=['patient_index_date - 42 days', 'patient_index_date'],
        return_expectations={"incidence":0.3}
    ),  

    #  --otitis externa
    ot_externa_record=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=['patient_index_date - 42 days', 'patient_index_date'],
        return_expectations={"incidence":0.2}
    ),   

    #  --otitis media
    ot_media_record=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=['patient_index_date - 42 days', 'patient_index_date'],
        return_expectations={"incidence":0.1}
    ),   

    # pneumonia
    pneumonia_record=patients.with_these_clinical_events(
        pneumonia_codes,
        returning="binary_flag",
        between=['patient_index_date - 42 days', 'patient_index_date'],
        return_expectations={"incidence":0.05}
    ),   

    ## Age
    age=patients.age_as_of(
        "index_date",
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
    # Region - NHS England 9 regions
    region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                  "North East": 0.1,
                  "North West": 0.1,
                  "Yorkshire and The Humber": 0.1,
                  "East Midlands": 0.1,
                  "West Midlands": 0.1,
                  "East": 0.1,
                  "London": 0.2,
                  "South West": 0.1,
                  "South East": 0.1, }, },
        },
    ),

    # index of multiple deprivation, estimate of SES based on patient post code 
	imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
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
### Create monthly measures of summary statistics ###

measures = [
    
    # 1. Total ae admissions
    
    # 1a. Overall
        Measure(
        id="2ae_admission_overall",
        numerator="admitted",
        denominator="population",
        group_by="population", 
    ),

    # 2a. Adverse event only
    Measure(
        id="2ae_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["antibiotic_treatment","covid_6weeks"]
    ),

    # 3a.UTI Adverse event only  
    Measure(
        id="2ae_uti_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["uti_record","antibiotic_treatment","covid_6weeks"],
    ),
    # 3a.LRTI Adverse event only  
    Measure(
        id="2ae_lrti_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["lrti_record","antibiotic_treatment","covid_6weeks"],
    ),
    # 3a.URTI Adverse event only  
    Measure(
        id="2ae_urti_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["urti_record","antibiotic_treatment","covid_6weeks"],
    ),
    # 3a.sinusitis Adverse event only  
    Measure(
        id="2ae_sinusitis_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["sinusitis_record","antibiotic_treatment","covid_6weeks"],
    ),
    # 3a.otitis externa Adverse event only  
    Measure(
        id="2ae_ot_externa_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["ot_externa_record","antibiotic_treatment","covid_6weeks"],
    ),
    # 3a.otitis media Adverse event only  
    Measure(
        id="2ae_ot_media_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["ot_media_record","antibiotic_treatment","covid_6weeks"],
    ),
    # 3a.pneumonia Adverse event only  
    Measure(
        id="2ae_pneumonia_ae_admission",
        numerator="ae_admitted",
        denominator="population",
        group_by=["pneumonia_record","antibiotic_treatment","covid_6weeks"],
    ),
]