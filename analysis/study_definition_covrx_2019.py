
###### import matched cohort
# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)
COHORT = "output/measures/id_2019.csv"

## Import codelists from codelist.py (which pulls them from the codelist folder)
#from codelists import *

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

    # study population
    population=patients.which_exist_in_file(COHORT),

    # index_date
    patient_index_date=patients.with_value_from_file(
        COHORT,
        returning="patient_index_date",
        returning_type="date",
    ),

        ### First COVID vaccination medication code (any)
    covrx1_dat=patients.with_tpp_vaccination_record(
        returning="date",
        
        # product_name_matches=
        #         "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        #         "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        #         "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
        target_disease_matches="SARS-2 CORONAVIRUS",
        # emis={
        #     "product_codes": covrx_code,
        # },
        # find_first_match_in_period=True,
        on_or_before="patient_index_date",
    #    on_or_after="2020-11-29",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase",
            "incidence": 0.5,
        }
    ),

    # Second COVID vaccination medication code (any)
    covrx2_dat=patients.with_tpp_vaccination_record(
        returning="date",
     #   tpp={
        # product_name_matches=
        #         "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        #         "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        #         "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
        target_disease_matches="SARS-2 CORONAVIRUS",
   #     },
        # emis={
        #     "product_codes": covrx_code,
        # },
        find_last_match_in_period=True,
        on_or_after="covrx1_dat + 19 days",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase",
            "incidence": 0.5,
        }
    ),

)