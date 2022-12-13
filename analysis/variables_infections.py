from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_infection_variables(index_date_variable):
    infection_variables  = dict(


    # #  all infecition
    # infection_record=patients.with_these_clinical_events(
    #     all_indication_codes,
    #     returning=binary_flag,
    #     between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
    #     return_expectations={"incidence":0.5}
    # ),      


    #  --UTI 
    uti_record=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
        return_expectations={"incidence":0.5}
    ),  
    #  --LRTI 
    lrti_record=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
        return_expectations={"incidence":0.5}
    ),  

    #  --URTI  
    urti_record=patients.with_these_clinical_events(
        all_urti_codes,
        returning="binary_flag",
        between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
        return_expectations={"incidence":0.5}
    ),  

    #  --sinusitis 
    sinusitis_record=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
        return_expectations={"incidence":0.5}
    ),  

    #  --otitis externa
    ot_externa_record=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
        return_expectations={"incidence":0.5}
    ),   

    #  --otitis media
    ot_media_record=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
        return_expectations={"incidence":0.5}
    ),   

    # pneumonia
    pneumonia_record=patients.with_these_clinical_events(
        pneumonia_codes,
        returning="binary_flag",
        between=[f'{index_date_variable}- 43 days', f'{index_date_variable}'],
        return_expectations={"incidence":0.5}
    ),   
  )
    return infection_variables