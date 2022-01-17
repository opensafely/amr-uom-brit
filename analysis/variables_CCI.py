from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_CCI_variables(index_date_variable):
    CCI_variables  = dict(
             
    
        ######### comorbidities

    cancer_comor=patients.with_these_clinical_events(
        charlson01_cancer,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    cardiovascular_comor=patients.with_these_clinical_events(
        charlson02_cvd,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    chronic_obstructive_pulmonary_comor=patients.with_these_clinical_events(
       charlson03_copd,
       between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
       returning="binary_flag",
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
       },
    ),

    heart_failure_comor=patients.with_these_clinical_events(
       charlson04_heart_failure,
       between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
       returning="binary_flag",
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
       },
    ),

    connective_tissue_comor=patients.with_these_clinical_events(
        charlson05_connective_tissue,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    dementia_comor=patients.with_these_clinical_events(
        charlson06_dementia,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    diabetes_comor=patients.with_these_clinical_events(
        charlson07_diabetes,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    diabetes_complications_comor=patients.with_these_clinical_events(
        charlson08_diabetes_with_complications,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest":"2019-02-01"}
        },
    ),

    hemiplegia_comor=patients.with_these_clinical_events(
        charlson09_hemiplegia,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    hiv_comor=patients.with_these_clinical_events(
        charlson10_hiv,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    metastatic_cancer_comor=patients.with_these_clinical_events(
        charlson11_metastatic_cancer,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    mild_liver_comor=patients.with_these_clinical_events(
        charlson12_mild_liver,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    mod_severe_liver_comor=patients.with_these_clinical_events(
        charlson13_mod_severe_liver,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    mod_severe_renal_comor=patients.with_these_clinical_events(
        charlson14_moderate_several_renal_disease,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    mi_comor=patients.with_these_clinical_events(
        charlson15_mi,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    peptic_ulcer_comor=patients.with_these_clinical_events(
        charlson16_peptic_ulcer,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

    peripheral_vascular_comor=patients.with_these_clinical_events(
        charlson17_peripheral_vascular,
        between=[f'{index_date_variable} - 5 years', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2019-02-01"}
        },
    ),

  )
    return CCI_variables