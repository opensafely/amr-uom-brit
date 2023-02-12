

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
COHORT = "output/control_id_192.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2019-07-01"
end_date = "2019-12-31"


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

    age=patients.age_as_of(
        "patient_index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
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
            "Underweight (<18.5)": """ bmi_value < 18.5""",
            "Healthy range (18.5-24.9)": "DEFAULT",
            "Overweight (25-29.9)": """ bmi_value >= 25 AND bmi_value < 30""",
            "Obese I (30-34.9)": """ bmi_value >= 30 AND bmi_value < 35""",
            "Obese II (35-39.9)": """ bmi_value >= 35 AND bmi_value < 40""",
            "Obese III (40+)": """ bmi_value >= 40 AND bmi_value < 100""",
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


    died_any_30d=patients.died_from_any_cause(
    between=["patient_index_date","patient_index_date + 30 day"],
    returning="binary_flag",
    return_expectations={
            "incidence": 0.5,
    },
)

 ) 