######################################
# This script provides the formal specification of the study data that will
# be extracted from the OpenSAFELY database.
# This data extract is the data extract for one of the UK pandemic period (pre,during,post)
# (see file name which period)
# (see config.json for start and end dates of the wave)
######################################


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
end_date = "2020-03-25"

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

# # ###### Import variables

from variables_infection import generate_infection_variables
infection_variables = generate_infection_variables(index_date_variable="patient_index_date")

# DEFINE STUDY POPULATION ----
# Define study population and variables

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
        AND has_follow_up
        AND (sex = "M" OR sex = "F")
        AND (age >=18 AND age <= 110)
        AND NOT region = ""
        AND NOT imd = "0"
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="patient_index_date",
            returning="binary_flag",
        ),

        has_follow_up=patients.registered_with_one_practice_between(
            start_date="patient_index_date - 3 months",
            end_date="patient_index_date",
            return_expectations={"incidence": 0.95},
        ),
    ),
    ### patient index date = hospital admission date
    # hospital_admission_date
    patient_index_date=patients.with_these_medications(
        antibacterials_codes_brit,
        returning='date',
        between=[start_date, end_date],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",    
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
    # Region - NHS England 9 regions
    region=patients.registered_practice_as_of(
        "patient_index_date",
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
            "patient_index_date",
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

        # ETHNICITY IN 6 CATEGORIES
    eth=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
        include_date_of_match=False,
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "1": 0.2,
                                        "2": 0.2,
                                        "3": 0.2,
                                        "4": 0.2,
                                        "5": 0.2
                                        }
                                    },
                                "incidence": 0.75,
                                },
    ),

    # fill missing ethnicity from SUS
    ethnicity_sus=patients.with_ethnicity_from_sus(
        returning="group_6",
        use_most_frequent_code=True,
        return_expectations={
            "category": {
                            "ratios": {
                                "1": 0.2,
                                "2": 0.2,
                                "3": 0.2,
                                "4": 0.2,
                                "5": 0.2
                                }
                            },
            "incidence": 0.4,
            },
    ),

    ethnicity=patients.categorised_as(
            {
                "0": "DEFAULT",
                "1": "eth='1' OR (NOT eth AND ethnicity_sus='1')",
                "2": "eth='2' OR (NOT eth AND ethnicity_sus='2')",
                "3": "eth='3' OR (NOT eth AND ethnicity_sus='3')",
                "4": "eth='4' OR (NOT eth AND ethnicity_sus='4')",
                "5": "eth='5' OR (NOT eth AND ethnicity_sus='5')",
            },
            return_expectations={
                "category": {
                                "ratios": {
                                    "0": 0.5,  # missing in 50%
                                    "1": 0.1,
                                    "2": 0.1,
                                    "3": 0.1,
                                    "4": 0.1,
                                    "5": 0.1
                                    }
                                },
                "rate": "universal",
            },
    ),

    # BMI & further outcome
    ### CLINICAL MEASUREMENTS
    # BMI
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/10
    bmi_value=patients.most_recent_bmi(
        on_or_after="patient_index_date - 5 years",
        minimum_age_at_measurement=16,
        return_expectations={
            "date": {"latest": "index_date"},
            "float": {"distribution": "normal", "mean": 25.0, "stddev": 7.5},
            "incidence": 0.8,
        },
    ),
    bmi=patients.categorised_as(
        {
            "Underweight (<18.5)": """ bmi_value < 18.5 AND bmi_value > 12""",
            "Healthy range (18.5-24.9)": """ bmi_value >= 1.5 AND bmi_value < 25""",
            "Overweight (25-29.9)": """ bmi_value >= 25 AND bmi_value < 30""",
            "Obese I (30-34.9)": """ bmi_value >= 30 AND bmi_value < 35""",
            "Obese II (35-39.9)": """ bmi_value >= 35 AND bmi_value < 40""",
            "Obese III (40+)": """ bmi_value >= 40 AND bmi_value < 100""",
            "Missing": "DEFAULT", 
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Underweight (<18.5)": 0.1,
                    "Healthy range (18.5-24.9)": 0.3,
                    "Overweight (25-29.9)":0.3,
                    "Obese I (30-34.9)": 0.1,
                    "Obese II (35-39.9)": 0.1,
                    "Obese III (40+)": 0.1,
                }
            },
        },
    ),

    # smoking status
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (
                       most_recent_smoking_code = 'N' AND ever_smoked
                    )
                """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "S": 0.6,
                    "E": 0.1,
                    "N": 0.2,
                    "M": 0.1,
                }
            },
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="patient_index_date",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="patient_index_date",
        ),
    ),
    # smoking status (combining never and missing)
    smoking_status_comb=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (
                       most_recent_smoking_code = 'N' AND ever_smoked
                    )
                """,
            "N + M": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N + M": 0.3}, }
        },
    ),


    #Check COVID-diagnsis#

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

    **infection_variables,

    ### any chronic respiratory history ###

    has_chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,  
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),

    # OUTCOMES
    ### emergency admission date
    emergency_admission_date=patients.admitted_to_hospital(
        returning= "date_admitted",  
        with_these_primary_diagnoses=all_ae_codes,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date + 30 days"], 
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2019-01-01"}, "incidence" : 1},
    ),

    # Death from any cause (to be used for censoring)
    died_any_date=patients.died_from_any_cause(
        between=["patient_index_date", "patient_index_date + 30 days"], 
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date", "latest": end_date},
            "incidence": 0.01,
        },
    ),

    # Any other antibiotic used after the first prescription  (to be used for censoring) #

    ab_30d_after=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="binary_flag",
        between=["patient_index_date + 1 day", "patient_index_date + 30 days"],
    ),    

    # Any other antibiotic used in the past 30 days

    ab_30d=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="binary_flag",
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
    ),    

    # Any other antibiotic used before the end date
    ab_after=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="binary_flag",
        between=["patient_index_date + 1 day", end_date],
    ),  
    # if Any other antibiotic used before the end date = yes, then new index date need to be extracted
    ab_date_2=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="date",
        between=["patient_index_date + 1 day", end_date],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",  
    ),

    ab_date_3=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="date",
        between=["ab_date_2 + 1 day", end_date],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",  
    ),

    ab_date_4=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="date",
        between=["ab_date_3 + 1 day", end_date],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",  
    ),

    ab_date_5=patients.with_these_medications(
        antibacterials_codes_brit,
        returning="date",
        between=["ab_date_4 + 1 day", end_date],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",  
    ),
)