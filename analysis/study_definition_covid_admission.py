
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
end_date = "2020-12-31"

###### Import variables

## covid history before patient_index_date
from variables_covid import generate_covid_variables
covid_variables = generate_covid_variables(index_date_variable="patient_index_date")

## Exposure variables: antibiotics 
from variables_antibiotics import generate_ab_variables
ab_variables = generate_ab_variables(index_date_variable="patient_index_date")

## Demographics, vaccine, included as they are potential confounders 
from variables_confounding import generate_confounding_variables
confounding_variables = generate_confounding_variables(index_date_variable="patient_index_date")

## Comobidities related to covid outcome 
from variables_comobidities import generate_comobidities_variables
comobidities_variables = generate_comobidities_variables(index_date_variable="patient_index_date")

# ## import recurring event functions
# from recurrent_event_funs import *

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
    population=patients.satisfying(
        """
        NOT has_died
        AND has_follow_up_previous_3years
        AND (sex = "M" OR sex = "F")
        AND (age >=18 AND age <= 110)
        AND NOT stp = ""
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
        ),

        has_follow_up_previous_3years=patients.registered_with_one_practice_between(
            start_date="patient_index_date - 1137 days",
            end_date="patient_index_date",
            return_expectations={"incidence": 0.95},
        ),

    ),
    ### patient index date = covid hospital admission
    # covid_admission_date
    patient_index_date=patients.admitted_to_hospital(
        returning= "date_admitted" ,  
        with_these_primary_diagnoses=covid_codelist,  # only include primary_diagnoses as covid
        on_or_after="index_date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 0.25},
    ),


    # observation end date
    ## de-register after start date
    dereg_date=patients.date_deregistered_from_all_supported_practices(
        on_or_after="index_date",
        date_format="YYYY-MM-DD",
        return_expectations={
        "date": {"earliest": "2020-02-01"},
        "incidence": 0.05
        }
    ),
    ## died after start date
    ons_died_date=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),

    # # antibiotics prescribing time 
    # ab_0_date=patients.with_these_medications(
    #     antibacterials_codes_brit,
    #     returning="date",
    #     date_format="YYYY-MM-DD",
    #     on_or_before="patient_index_date",
    #     find_last_match_in_period=True,
    #     return_expectations={
    #         "date": {"earliest": start_date, "latest": end_date},
    #         "rate": "exponential_increase",
    #         "incidence": 0.01
    #     },
    # ),
    # **with_these_medications_date_X(
    #     name="ab",
    #     n=6,
    #     index_date="patient_index_date",
    #     codelist=mantibacterials_codes_brit,
    #     return_expectations={
    #         "date": {"earliest": start_date, "latest": end_date},
    #         "rate": "uniform",
    #         "incidence": 0.01,
    #     },
    # ),


    **ab_variables,
    **confounding_variables,
    **covid_variables,
    **comobidities_variables,
    # **ab_time_variables,
  
)