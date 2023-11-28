
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
COHORT = "output/case_id.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2019-01-01"
end_date = "2022-06-30"

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

    ## Age
    age=patients.age_as_of(
        "patient_index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
            "incidence": 0.001
        },
    ),

######### infection record 30 days before the antibiotic prescribing date #########

    has_uti=patients.with_these_clinical_events(
        uti_codes,
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_urti=patients.with_these_clinical_events(
        all_urti_codes,
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_lrti=patients.with_these_clinical_events(
        lrti_codes,
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_sinusitis=patients.with_these_clinical_events(
        sinusitis_codes,
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_ot_externa=patients.with_these_clinical_events(
        ot_externa_codes,
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_otmedia=patients.with_these_clinical_events(
        otmedia_codes,
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_infection=patients.with_these_clinical_events(
        all_infection_codes,
        between=["patient_index_date - 31 days", "patient_index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),
)