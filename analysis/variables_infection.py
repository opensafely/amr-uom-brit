from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_infection_variables(index_date_variable):
    infection_variables  = dict(
             
    
######### infection record 30 days before the antibiotic prescribing date #########

    has_uti=patients.with_these_clinical_events(
        uti_codes,
        between=[f'{index_date_variable} - 30 days', f'{index_date_variable}'],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_urti=patients.with_these_clinical_events(
        all_urti_codes,
        between=[f'{index_date_variable} - 30 days', f'{index_date_variable}'],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_lrti=patients.with_these_clinical_events(
        lrti_codes,
        between=[f'{index_date_variable} - 30 days', f'{index_date_variable}'],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_sinusitis=patients.with_these_clinical_events(
        sinusitis_codes,
        between=[f'{index_date_variable} - 30 days', f'{index_date_variable}'],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_ot_externa=patients.with_these_clinical_events(
        ot_externa_codes,
        between=[f'{index_date_variable} - 30 days', f'{index_date_variable}'],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),

    has_otmedia=patients.with_these_clinical_events(
        otmedia_codes,
        between=[f'{index_date_variable} - 30 days', f'{index_date_variable}'],
        returning="binary_flag",
        return_expectations={"incidence": 0.1,
        },
    ),
  )
    return infection_variables