###################################################################

## This script is to extract the controls pre covid              ##

###################################################################

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
end_date = "2019-06-30"

###### Controls definition ######
## 1. any age 
## 2. sex (M/F)
## 3. at least one year of GP records prior to their index date
## 4. No sepsis admission 
## 5. has region (stp) information
## 6. has IMD 
## 7. has no COVID
##############################
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
        "incidence": 1,
    },

    # Set index date to start date
    index_date=start_date,
   
    # study population
    population=patients.satisfying(
        """
        NOT has_died
        AND has_follow_up_previous_year
        AND (sex = "M" OR sex = "F")
        AND (age > 0 AND age <= 110)
        AND has_infection
        AND NOT has_outcome
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="patient_index_date",
            returning="binary_flag",
        ),

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="patient_index_date - 365 days",
            end_date="patient_index_date",
            return_expectations={"incidence": 0.95},
        ),

        has_outcome=patients.admitted_to_hospital(
            with_these_primary_diagnoses=all_ae_codes,
            with_admission_method=emergency_admission_codes, 
            between=["patient_index_date - 365 days","patient_index_date + 30 days"],
        ),

        has_infection=patients.with_these_clinical_events(
            all_infection_codes,
            between=[start_date,end_date],
        ),


    ),

    ### patient index date for control = infection date
    patient_index_date=patients.with_these_clinical_events(
        all_infection_codes, 
        between=[start_date, end_date], 
        returning="date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2019-01-01"}, "incidence" : 1},
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
    #  --UTI
    uti_record=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=['patient_index_date', 'patient_index_date'],
        return_expectations={"incidence":0.5}
    ),  
    #  --LRTI 
    lrti_record=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=['patient_index_date', 'patient_index_date'],
        return_expectations={"incidence":0.6}
    ),  

    #  --URTI  
    urti_record=patients.with_these_clinical_events(
        all_urti_codes,
        returning="binary_flag",
        between=['patient_index_date', 'patient_index_date'],
        return_expectations={"incidence":0.4}
    ),  

    #  --sinusitis 
    sinusitis_record=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=['patient_index_date', 'patient_index_date'],
        return_expectations={"incidence":0.3}
    ),  

    #  --otitis externa
    ot_externa_record=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=['patient_index_date', 'patient_index_date'],
        return_expectations={"incidence":0.2}
    ),   

    #  --otitis media
    ot_media_record=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=['patient_index_date', 'patient_index_date'],
        return_expectations={"incidence":0.1}
    ),   

    # pneumonia
    pneumonia_record=patients.with_these_clinical_events(
        pneumonia_codes,
        returning="binary_flag",
        between=['patient_index_date', 'patient_index_date'],
        return_expectations={"incidence":0.05}
    ),   


)