
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
start_date = "2020-02-01"
end_date = "2022-12-31"

# # ###### Import variables

## covid history before patient_index_date
# from variables_covid import generate_covid_variables
# covid_variables = generate_covid_variables(index_date_variable="patient_index_date")

# # ## Exposure variables: antibiotics 
# # from variables_antibiotics import generate_ab_variables
# # ab_variables = generate_ab_variables(index_date_variable="patient_index_date")

# # ## Demographics, vaccine, included as they are potential confounders 
# # from variables_confounding import generate_confounding_variables
# # confounding_variables = generate_confounding_variables(index_date_variable="patient_index_date")

# # # ## Comobidities related to covid outcome 
# # # from variables_comobidities import generate_comobidities_variables
# # # comobidities_variables = generate_comobidities_variables(index_date_variable="patient_index_date")

# # ## Charlson Comobidity Index
# # from variables_CCI import generate_CCI_variables
# # CCI_variables = generate_CCI_variables(index_date_variable="patient_index_date")


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
        AND has_follow_up_previous_3years
        AND (sex = "M" OR sex = "F")
        AND (age >=18 AND age <= 110)
        AND NOT stp = ""
        AND had_antibiotics
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
        ),

        has_follow_up_previous_3years=patients.registered_with_one_practice_between(
            start_date="index_date - 1137 days",
            end_date="2022-12-31",
            return_expectations={"incidence": 0.95},
        ),

        had_antibiotics=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date- 1137 days", "2022-12-31"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.5,
        },
    ),

    ),
    ### patient index date = covid hospital admission
    # covid_admission_date
    covid_hosp_date=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_primary_diagnoses=covid_codelist,  # only include primary_diagnoses as covid
        on_or_after="index_date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 1},
    ),
    
    covid_primarycare_date=patients.with_these_clinical_events(
        any_primary_care_code,        
        returning="date",
        on_or_after="index_date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 1},
    ),

    covid_SGSS_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 1},
    ),

    covid_died_date_cpns=patients.with_death_recorded_in_cpns(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},    
        ),

    covid_died_date_ons=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        match_only_underlying_cause=False,
          return_expectations={"date": {"earliest": "2020-03-01"},
        "rate" : "exponential_increase",
        "incidence" : 0.25},
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

    dob=patients.date_of_birth(
        "YYYY-MM",
        return_expectations={
            "date": {"earliest": "1950-01-01", "latest": "today"},
            "rate": "uniform",
        }
    ),
    
    ## Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    ## region
    stp=patients.registered_practice_as_of(
             "index_date",
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
    	
# data check	
    ## de-register after start date	
    dereg_date=patients.date_deregistered_from_all_supported_practices(	
        between=["index_date" , "2022-12-31"],        	
        date_format="YYYY-MM-DD",	
        return_expectations={	
        "date": {"earliest": "2020-02-01"},	
        "incidence": 0.05	
        }	
    ),	
    ## died after patient index date	
    ons_died_date=patients.died_from_any_cause(	
        between=["index_date" , "2022-12-31"],        	
        returning="date_of_death",	
        date_format="YYYY-MM-DD",	
        return_expectations={"date": {"earliest": "2020-03-01"},"incidence": 0.1},	
    ),

    ## died before patient index date	
    ons_died_date_before=patients.died_from_any_cause(	
        on_or_before="index_date - 1 day",        	
        returning="date_of_death",	
        date_format="YYYY-MM-DD",	
        return_expectations={"date": {"earliest": "2020-02-01"},"incidence": 0.1},	
    ),

    antibiotic=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date- 1137 days", "2022-12-31"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibiotic_include_6wk=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date- 1137 days", "2022-12-31"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    # # **ab_variables,
    # # **confounding_variables,
    ##**covid_variables,
    # # #**comobidities_variables,
    # # **CCI_variables,
  
)