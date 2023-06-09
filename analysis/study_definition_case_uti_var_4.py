#### This script is to extract the variable in cases ####

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
COHORT = "output/cases_uti.csv"

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
    ###  emergency admission by type

    ae_I15_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I15_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I26_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I26_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I31_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I31_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I42_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I42_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I44_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I44_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I45_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I45_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I46_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I46_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I47_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I47_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I49_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I49_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I60_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I60_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I61_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I61_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I62_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I62_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I80_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I80_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I85_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I85_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_I95_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=I95_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_J38_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=J38_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_J45_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=J45_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_J46_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=J46_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_J70_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=J70_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_J80_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=J80_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_J81_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=J81_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N14_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N14_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N17_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N17_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N19_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N19_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R00_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R00_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R04_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R04_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R06_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R06_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R41_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R41_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R42_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R42_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R44_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R44_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R50_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R50_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),
    ae_R51_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R51_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R55_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R55_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R58_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R58_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_S06_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=S06_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_X44_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=X44_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_Y40_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=Y40_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),
    ae_Y41_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=Y41_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_Y57_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=Y57_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_Y88_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=Y88_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_Z88_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=Z88_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K25_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K25_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K26_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K26_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K27_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K27_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K28_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K28_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K52_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K52_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K62_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K62_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K66_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K66_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K85_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K85_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),


    ae_K92_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K92_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),


    ae_R11_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R11_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R17_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R17_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E03_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E03_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E06_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E06_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E15_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E15_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E16_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E16_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E23_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E23_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E24_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E24_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E27_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E27_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E66_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E66_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),
    ae_E86_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E86_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_E87_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=E87_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N42_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N42_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N62_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N62_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N83_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N83_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N85_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N85_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N89_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N89_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N92_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N92_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N93_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N93_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_N95_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=N95_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R31_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R31_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R34_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R34_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_D52_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D52_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_D59_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D59_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_D61_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D61_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_D64_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D64_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),
    ae_D65_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D65_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_D68_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D68_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_D69_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D69_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_D70_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=D70_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R73_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R73_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K71_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K71_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K72_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K72_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K75_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K75_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_K76_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=K76_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R74_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R74_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),
    ae_T36_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=T36_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_T37_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=T37_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_T47_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=T47_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_T50_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=T50_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_T78_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=T78_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_T88_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=T88_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L10_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L10_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L20_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L20_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L21_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L21_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L26_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L26_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),
    ae_L27_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L27_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L28_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L28_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L29_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L29_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L30_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L30_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L43_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L43_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L50_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L50_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L51_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L51_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L52_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L52_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L56_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L56_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L64_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L64_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_L71_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=L71_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R20_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R20_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R21_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R21_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

    ae_R23_codelist=patients.admitted_to_hospital(
        returning="binary_flag", 
        with_these_primary_diagnoses=R23_codelist,
        with_admission_method=emergency_admission_codes,  
        between=["patient_index_date", "patient_index_date"], 
        find_first_match_in_period=True, 
    ),

)