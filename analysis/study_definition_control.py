
from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)

###### import matched control
CONTROLS = "output/matched_combined_general_population_infection.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2020-02-01"
end_date = "2021-12-31"

####### Import variables

## covid history before patient_index_date
from variables_covid import generate_covid_variables
covid_variables = generate_covid_variables(index_date_variable="patient_index_date")

## Exposure variables: antibiotics 
from variables_antibiotics import generate_ab_variables
ab_variables = generate_ab_variables(index_date_variable="patient_index_date")

## Demographics, vaccine, included as they are potential confounders 
from variables_confounding import generate_confounding_variables
confounding_variables = generate_confounding_variables(index_date_variable="patient_index_date")

# ## Comobidities related to covid outcome 
# from variables_comobidities import generate_comobidities_variables
# comobidities_variables = generate_comobidities_variables(index_date_variable="index_date")

## Charlson Comobidity Index
from variables_CCI import generate_CCI_variables
CCI_variables = generate_CCI_variables(index_date_variable="patient_index_date")


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
    population=patients.which_exist_in_file(CONTROLS),

    ### patient index date  
    # case_infection_date
    patient_index_date=patients.with_value_from_file(
        CONTROLS,
        returning="patient_index_date",
        returning_type="date",
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

    ## Age categories
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

    
    ## Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
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


    **ab_variables,
    **confounding_variables,
    **covid_variables,
    #**comobidities_variables,
    **CCI_variables,
)
