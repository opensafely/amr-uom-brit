
######################################

# This script provides two broad-spectrum codelist to compare the broad prescription percentage

######################################

# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    combine_codelists,
    Measure
)

## Import codelists from codelist.py (which pulls them from the codelist folder)

from codelists import *


#from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, uti_codes, lrti_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes, flu_med_codes, flu_clinical_given_codes, flu_clinical_not_given_codes, covrx_code, hospitalisation_infection_related #, any_lrti_urti_uti_hospitalisation_codes#, flu_vaccine_codes

# DEFINE STUDY POPULATION ---

## Define study time variables
from datetime import datetime

start_date = "2019-01-01"
end_date = "2019-12-31"

## Define study population and variables
study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.1,
    },
    # Set index date to start date
    index_date=start_date,
    # Define the study population
    population=patients.satisfying(
        """
        has_ab

        """,

        has_ab=patients.with_these_medications(
        codes_ab_type_nuro_trim,
        between=[start_date, end_date],
        returning="binary_flag"
        ),

    ),


    ## all antibacterials from BRIT (dmd codes)
    antibacterial_brit=patients.with_these_medications(
        codes_ab_type_nuro_trim,
        between=["index_date","last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
    ),

    antibacterial_brit_abtype=patients.with_these_medications(
        codes_ab_type_nuro_trim,
        between=["index_date","last_day_of_month(index_date)"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"FURADANTIN 100MG TABLETS":0.95, "FURADANTIN 25MG/5ML ORAL SUSPENSION":0.05}},
            "incidence": 0.99,
        },
    ),


)
