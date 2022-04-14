
######################################

# This script provides the formal specification of the study data that will be extracted from
# the OpenSAFELY database.

######################################

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

## Import codelists from codelist.py (which pulls them from the codelist folder)

#from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, uti_codes, lrti_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes, flu_med_codes, flu_clinical_given_codes, flu_clinical_not_given_codes, covrx_code, hospitalisation_infection_related #, any_lrti_urti_uti_hospitalisation_codes#, flu_vaccine_codes

from codelists import *


# DEFINE STUDY POPULATION ---

## Define study time variables
from datetime import datetime

start_date = "2019-01-01"
end_date = datetime.today().strftime('%Y-%m-%d')

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
        NOT has_died
        AND
        registered
        AND
        age
        AND
        has_follow_up_previous_year
        AND
        (sex = "M" OR sex = "F")
        """,

        has_died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
        ),

        registered=patients.satisfying(
            "registered_at_start",
            registered_at_start=patients.registered_as_of("index_date"),
        ),

        has_follow_up_previous_year=patients.registered_with_one_practice_between(
            start_date="index_date - 1 year",
            end_date="index_date",
            return_expectations={"incidence": 0.95},
        ),

    ),

    ########## patient demographics to group_by for measures:
    ### Age
    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
            "incidence": 0.001
        },
    ),

    ### Age categories

    ## 0-4; 5-14; 15-24; 25-34; 35-44; 45-54; 55-64; 65-74; 75+
    age_cat=patients.categorised_as(
        {
            "0":"DEFAULT",
            "0-4": """ age >= 0 AND age < 5""",
            "5-14": """ age >= 5 AND age < 15""",
            "15-24": """ age >= 15 AND age < 25""",
            "25-34": """ age >= 25 AND age < 35""",
            "35-44": """ age >= 35 AND age < 45""",
            "45-54": """ age >= 45 AND age < 55""",
            "55-64": """ age >= 55 AND age < 65""",
            "65-74": """ age >= 65 AND age < 75""",
            "75+": """ age >= 75 AND age < 120""",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0,
                    "0-4": 0.12, 
                    "5-14": 0.11,
                    "15-24": 0.11,
                    "25-34": 0.11,
                    "35-44": 0.11,
                    "45-54": 0.11,
                    "55-64": 0.11,
                    "65-74": 0.11,
                    "75+": 0.11,
                }
            },
        },
    ),

    
    ### Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    #deregistration for censoring
    deregistered_date=patients.date_deregistered_from_all_supported_practices(
            date_format="YYYY-MM-DD",
            # between=["index_date", "last_day_of_month(index_date)"],
        #     return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        # ),
            return_expectations={"date": {"earliest": "index_date"}, "incidence": 0.05}, 
        ),

    ## Death
    died_date=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},  "rate" : "exponential_increase"
        },
    ),

    ########## patient infection events to group_by for measures #############

    urti_date_1=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["index_date", "today"],
        # on_or_after='index_date',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "today()"}},
        ),

    #numbers of antibiotic prescribed for this infection 
    urti_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_1','urti_date_1 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1}, "incidence":0.2}
        ),


    urti_date_2=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        # on_or_after='urti_date_1 + 3 days',
        between=["urti_date_1 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date + 3 days": "today()"}},
        ),

    urti_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_2','urti_date_2 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    urti_date_3=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        # on_or_after='urti_date_2 + 3 days',
        between=["urti_date_2 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "today()"}},
        ),

    urti_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_3','urti_date_3 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    urti_date_4=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        # on_or_after='urti_date_3 + 3 days',
        between=["urti_date_3 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "today()"}},
        ),

    urti_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_4','urti_date_4 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

        ## GP consultations for urti
    gp_cons_urti_1=patients.with_gp_consultations(
        between=["urti_date_1", "urti_date_1"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    gp_cons_urti_2=patients.with_gp_consultations(
        between=["urti_date_2", "urti_date_2"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    gp_cons_urti_3=patients.with_gp_consultations(
        between=["urti_date_3", "urti_date_3"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    gp_cons_urti_4=patients.with_gp_consultations(
        between=["urti_date_4", "urti_date_4"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    ## GP consultations for urti resulted in antibiotics
    gp_cons_urti_ab_1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_urti_1','gp_cons_urti_1 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    gp_cons_urti_ab_2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_urti_2','gp_cons_urti_2 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    gp_cons_urti_ab_3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_urti_3','gp_cons_urti_3 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    gp_cons_urti_ab_4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_urti_4','gp_cons_urti_4 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    #  --URTI 
    incdt_urti_date_1=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_urti_1 - 42 days", "gp_cons_urti_1"], #["urti_date_1 - 42 days", "urti_date_1"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_2=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_urti_2 - 42 days", "gp_cons_urti_2"], #["urti_date_2 - 42 days", "urti_date_2"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_3=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_urti_3 - 42 days", "gp_cons_urti_3"], #["urti_date_3 - 42 days", "urti_date_3"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_4=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_urti_4 - 42 days", "gp_cons_urti_4"], #["urti_date_4 - 42 days", "urti_date_4"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

## hospitalisation with incident OR prevalent urti
    admitted_urti_date_1=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_urti_1", "gp_cons_urti_1 + 30 days"], #["urti_date_1", "urti_date_1 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_2=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_urti_2", "gp_cons_urti_2 + 30 days"], #["urti_date_2", "urti_date_2 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_3=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_urti_3", "gp_cons_urti_3 + 30 days"], #["urti_date_3", "urti_date_3 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_4=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_urti_4", "gp_cons_urti_4 + 30 days"], #["urti_date_4", "urti_date_4 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    ## Covid positive test result during hospital admission related to urti
    sgss_pos_covid_date_urti_1=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_urti_1 - 90 days", "gp_cons_urti_1 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis during hospital admission related to urti
    gp_covid_date_urti_1=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_urti_1 - 90 days", "gp_cons_urti_1 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_1=patients.satisfying(
        """
        sgss_pos_covid_date_urti_1 OR
        gp_covid_date_urti_1
        """,
    ),

    ## Covid positive test result
    sgss_pos_covid_date_urti_2=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_urti_2 - 90 days", "gp_cons_urti_2 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_2=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_urti_2 - 90 days", "gp_cons_urti_2 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_2=patients.satisfying(
        """
        sgss_pos_covid_date_urti_2 OR
        gp_covid_date_urti_2
        """,
    ),

    ## Covid positive test result
    sgss_pos_covid_date_urti_3=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_urti_3 - 90 days", "gp_cons_urti_3 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_3=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_urti_3 - 90 days", "gp_cons_urti_3 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_3=patients.satisfying(
        """
        sgss_pos_covid_date_urti_3 OR
        gp_covid_date_urti_3
        """,
    ),

    ## Covid positive test result
    sgss_pos_covid_date_urti_4=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_urti_4 - 90 days", "gp_cons_urti_4 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_4=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_urti_4 - 90 days", "gp_cons_urti_4 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_4=patients.satisfying(
        """
        sgss_pos_covid_date_urti_4 OR
        gp_covid_date_urti_4
        """,
    ),

    ######### comorbidities

    cancer_comor=patients.with_these_clinical_events(
        charlson01_cancer,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    cardiovascular_comor=patients.with_these_clinical_events(
        charlson02_cvd,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    chronic_obstructive_pulmonary_comor=patients.with_these_clinical_events(
       charlson03_copd,
       between=["index_date - 5 years", "index_date"],
       returning="binary_flag",
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    heart_failure_comor=patients.with_these_clinical_events(
       charlson04_heart_failure,
       between=["index_date - 5 years", "index_date"],
       returning="binary_flag",
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    connective_tissue_comor=patients.with_these_clinical_events(
        charlson05_connective_tissue,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    dementia_comor=patients.with_these_clinical_events(
        charlson06_dementia,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    diabetes_comor=patients.with_these_clinical_events(
        charlson07_diabetes,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    diabetes_complications_comor=patients.with_these_clinical_events(
        charlson08_diabetes_with_complications,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    hemiplegia_comor=patients.with_these_clinical_events(
        charlson09_hemiplegia,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    hiv_comor=patients.with_these_clinical_events(
        charlson10_hiv,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    metastatic_cancer_comor=patients.with_these_clinical_events(
        charlson11_metastatic_cancer,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    mild_liver_comor=patients.with_these_clinical_events(
        charlson12_mild_liver,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    mod_severe_liver_comor=patients.with_these_clinical_events(
        charlson13_mod_severe_liver,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    mod_severe_renal_comor=patients.with_these_clinical_events(
        charlson14_moderate_several_renal_disease,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}
        },
    ),

    mi_comor=patients.with_these_clinical_events(
        charlson15_mi,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}
        },
    ),

    peptic_ulcer_comor=patients.with_these_clinical_events(
        charlson16_peptic_ulcer,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}
        },
    ),

    peripheral_vascular_comor=patients.with_these_clinical_events(
        charlson17_peripheral_vascular,
        between=["index_date - 5 years", "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}
        },
    ),

)