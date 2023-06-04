###################################################################

## This script is to extract the controls pre covid    2019-1    ##

###################################################################

#### This script is to extract the variable in controls ####

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
COHORT = "output/matched_matches_6_sinusitis.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2021-07-01"
end_date = "2021-12-31"

####### Import variables
## Exposure variables: antibiotics 
from variables_antibiotics import generate_ab_variables
from variables_CCI import generate_CCI_variables
ab_variables = generate_ab_variables(index_date_variable="patient_index_date")
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
    population=patients.which_exist_in_file(COHORT),

    ### patient index date  
    # case_infection_date
    patient_index_date=patients.with_value_from_file(
        COHORT,
        returning="patient_index_date",
        returning_type="date",
    ),
    # DEMOGRAPHICS
    # age
    age=patients.age_as_of(
        "patient_index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),

    **ab_variables,
    **CCI_variables, 
 ) 