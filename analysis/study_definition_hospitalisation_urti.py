
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

#from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, uti_codes, urti_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes, flu_med_codes, flu_clinical_given_codes, flu_clinical_not_given_codes, covrx_code, hospitalisation_infection_related #, any_urti_urti_uti_hospitalisation_codes#, flu_vaccine_codes

from codelists import *


# DEFINE STUDY POPULATION ---

## Define study time variables
from datetime import datetime

start_date = "2019-01-01"
end_date = "2020-01-01" #datetime.today().strftime('%Y-%m-%d')

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
        AND
        has_urti
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

        has_urti=patients.with_these_clinical_events(
        urti_codes,
        between=[start_date,end_date],
        returning="binary_flag",
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

    ########## risk factors

    ### Practice
    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={"int": {"distribution": "normal",
                                     "mean": 25, "stddev": 5}, "incidence": 1}
    ),
      
    ### Region - NHS England 9 regions
    region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                  "North East": 0.1,
                  "North West": 0.1,
                  "Yorkshire and The Humber": 0.1,
                  "East Midlands": 0.1,
                  "West Midlands": 0.1,
                  "East": 0.1,
                  "London": 0.2,
                  "South West": 0.1,
                  "South East": 0.1, }, },
        },
    ),
    
    ## middle layer super output area (msoa) - nhs administrative region 
    msoa=patients.registered_practice_as_of(
        "index_date",
        returning="msoa_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"E02000001": 0.5, "E02000002": 0.5}},
        },
    ), 
    
    ## index of multiple deprivation, estimate of SES based on patient post code 
	imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            }, "incidence": 0.55,
        },
    ),

    ## BMI, most recent
    bmi=patients.most_recent_bmi(
        between=["index_date - 60 months", "index_date"],#"2010-01-01",
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "date": {},
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
            "incidence": 0.75,
        },
    ),

    # self-reported ethnicity 
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=False,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/6
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                 most_recent_smoking_code = 'E' OR (
                   most_recent_smoking_code = 'N' AND ever_smoked
                 )
            """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}, "incidence": 0.65,
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="today",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="today",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="today",
        return_last_date_in_period=True,
        include_month=True,
    ),
    most_recent_unclear_smoking_cat_date=patients.with_these_clinical_events(
        unclear_smoking_codes,
        on_or_before="today",
        return_last_date_in_period=True,
        include_month=True,
    ),

    # ## GP consultations
    # gp_count=patients.with_gp_consultations(
    #     between=["index_date - 12 months", "last_day_of_month(index_date)"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 6, "stddev": 3},
    #         "incidence": 0.6,
    #     },
    # ),


    ### Flu vaccine
    ## flu vaccine in tpp
    flu_vaccine_tpp=patients.with_tpp_vaccination_record(
        target_disease_matches="influenza",
        between=["index_date - 12 months", "index_date"],
        returning="binary_flag",
        #date_format=binary,
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "index_date - 12 months", "latest": "index_date"}
        }
    ),

    ### flu vaccine 
    ## flu vaccine entered as a medication 
    flu_vaccine_med=patients.with_these_medications(
        flu_med_codes,
        between=["index_date - 12 months", "index_date"],  # current flu season
        returning="binary_flag",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "index_date - 12 months", "latest": "index_date"}
        },
    ),
    ## flu vaccine as a read code 
    flu_vaccine_clinical=patients.with_these_clinical_events(
        flu_clinical_given_codes,
        ignore_days_where_these_codes_occur=flu_clinical_not_given_codes,
        between=["index_date - 12 months", "index_date"],  # current flu season
        returning="binary_flag",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "index_date - 12 months", "latest": "index_date"}
        },
    ),
    ## flu vaccine any of the above 
    flu_vaccine=patients.satisfying(
        """
        flu_vaccine_tpp OR
        flu_vaccine_med OR
        flu_vaccine_clinical
        """,
    ),

    ########## antibacterials

    # ## all antibacterials from BRIT (dmd codes)
    # antibacterial_brit=patients.with_these_medications(
    #     antibacterials_codes_brit,
    #     # between=["index_date", "last_day_of_month(index_date)"],
    #     between=["index_date - 12 months", "last_day_of_month(index_date)"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 3, "stddev": 1},
    #         "incidence": 0.5,
    #     },
    # ),

    # all_meds=patients.with_these_medications(
    #     all_meds_codes,
    #     between=["index_date - 12 months", "last_day_of_month(index_date)"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 3, "stddev": 1},
    #         "incidence": 0.5,
    #     },
    # ),

    # # all meds except antibiotics (dmd codes) 
    # antibacterial_brit_one_month=patients.with_these_medications(
    #     antibacterials_codes_brit,
    #     # between=["index_date", "last_day_of_month(index_date)"],
    #     between=["index_date - 1 months", "last_day_of_month(index_date)"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 3, "stddev": 1},
    #         "incidence": 0.5,
    #     },
    # ),

    # all_meds_one_month=patients.with_these_medications(
    #     all_meds_codes,
    #     between=["index_date - 1 months", "last_day_of_month(index_date)"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 3, "stddev": 1},
    #         "incidence": 0.5,
    #     },
    # ),

    ########## hospital admission

    ## hospitalisation
    admitted=patients.admitted_to_hospital(
        returning="binary_flag",
        #returning="date_admitted",
        #date_format="YYYY-MM-DD",
        between=["index_date", "today"],
        return_expectations={"incidence": 0.1},
    ),

    ## hospitalisation history 
    hx_hosp=patients.admitted_to_hospital(
        between=["index_date - 12 months", "index_date"],
        returning="number_of_matches_in_period",
        #returning="date_admitted",
        #date_format="YYYY-MM-DD",
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1}, "incidence":0.1}
    ),

    # hospitalisation with diagnosis of urti, urti, or uti
    admitted_date=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
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

    ################################################### URTI

    urti_date_1=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        # between=["index_date", "today"],
        on_or_after='index_date',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "today()"}},
        ),

    urti_date_2=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        # on_or_after='urti_date_1 + 3 days',
        between=["urti_date_1 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_1": "today()"}},
        ),

    urti_date_3=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        # on_or_after='urti_date_2 + 3 days',
        between=["urti_date_2 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_2": "today()"}},
        ),

    urti_date_4=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_3 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_3": "today()"}},
        ),

    urti_date_5=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_4 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_4": "today()"}},
        ),

    urti_date_6=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_5 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_5": "today()"}},
        ),

    urti_date_7=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_6 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_6": "today()"}},
        ),

    urti_date_8=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_7 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_7": "today()"}},
        ),

    urti_date_9=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_8 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_8": "today()"}},
        ),

    urti_date_10=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_9 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_9": "today()"}},
        ),

    urti_date_11=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_10 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_10": "today()"}},
        ),

    urti_date_12=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_11 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_11": "today()"}},
        ),

    urti_date_13=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_12 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_12": "today()"}},
        ),

    urti_date_14=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_13 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_13": "today()"}},
        ),

    urti_date_15=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_14 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_14": "today()"}},
        ),

    urti_date_16=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_15 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_15": "today()"}},
        ),

    urti_date_17=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_16 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_16": "today()"}},
        ),

    urti_date_18=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_17 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_17": "today()"}},
        ),

    urti_date_19=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_18 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_18": "today()"}},
        ),

    urti_date_20=patients.with_these_clinical_events(
        urti_codes,
        returning='date',
        between=["urti_date_19 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"urti_date_19": "today()"}},
        ),

####################################################################################

# # ## count of GP consultations
#     gp_count_1=patients.with_gp_consultations(
#         between=["urti_date_1 - 12 months", "urti_date_1"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_2=patients.with_gp_consultations(
#         between=["urti_date_2 - 12 months", "urti_date_2"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_3=patients.with_gp_consultations(
#         between=["urti_date_3 - 12 months", "urti_date_3"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_4=patients.with_gp_consultations(
#         between=["urti_date_4 - 12 months", "urti_date_4"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_5=patients.with_gp_consultations(
#         between=["urti_date_5 - 12 months", "urti_date_5"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_6=patients.with_gp_consultations(
#         between=["urti_date_6 - 12 months", "urti_date_6"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_7=patients.with_gp_consultations(
#         between=["urti_date_7 - 12 months", "urti_date_7"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_8=patients.with_gp_consultations(
#         between=["urti_date_8 - 12 months", "urti_date_8"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_9=patients.with_gp_consultations(
#         between=["urti_date_9 - 12 months", "urti_date_9"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_10=patients.with_gp_consultations(
#         between=["urti_date_10 - 12 months", "urti_date_10"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_11=patients.with_gp_consultations(
#         between=["urti_date_11 - 12 months", "urti_date_11"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_12=patients.with_gp_consultations(
#         between=["urti_date_12 - 12 months", "urti_date_12"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_13=patients.with_gp_consultations(
#         between=["urti_date_13 - 12 months", "urti_date_13"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_14=patients.with_gp_consultations(
#         between=["urti_date_14 - 12 months", "urti_date_14"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_15=patients.with_gp_consultations(
#         between=["urti_date_15 - 12 months", "urti_date_15"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_16=patients.with_gp_consultations(
#         between=["urti_date_16 - 12 months", "urti_date_16"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_17=patients.with_gp_consultations(
#         between=["urti_date_17 - 12 months", "urti_date_17"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_18=patients.with_gp_consultations(
#         between=["urti_date_18 - 12 months", "urti_date_18"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_19=patients.with_gp_consultations(
#         between=["urti_date_19 - 12 months", "urti_date_19"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),

#     gp_count_20=patients.with_gp_consultations(
#         between=["urti_date_20 - 12 months", "urti_date_20"],
#         returning="number_of_matches_in_period",
#         return_expectations={
#             "int": {"distribution": "normal", "mean": 6, "stddev": 3},
#             "incidence": 0.6,
#         },
#     ),


    # count of abs
    antibacterial_brit_1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_1 - 12 months", "urti_date_1"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_2 - 12 months", "urti_date_2"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_3 - 12 months", "urti_date_3"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_4 - 12 months", "urti_date_4"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_5=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_5 - 12 months", "urti_date_5"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_6=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_6 - 12 months", "urti_date_6"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_7=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_7 - 12 months", "urti_date_7"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_8=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_8 - 12 months", "urti_date_8"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_9=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_9 - 12 months", "urti_date_9"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_10=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_10 - 12 months", "urti_date_10"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_11=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_11 - 12 months", "urti_date_11"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_12=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_12 - 12 months", "urti_date_12"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_13=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_13 - 12 months", "urti_date_13"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_14=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_14 - 12 months", "urti_date_14"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_15=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_15 - 12 months", "urti_date_15"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_16=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_16 - 12 months", "urti_date_16"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_17=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_17 - 12 months", "urti_date_17"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_18=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_18 - 12 months", "urti_date_18"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_19=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_19 - 12 months", "urti_date_19"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_20=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["urti_date_20 - 12 months", "urti_date_20"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),


###################################################################################

    #  incidence 
    incdt_urti_date_1=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_1 - 42 days", "urti_date_1 - 1 day"], #["urti_date_1 - 42 days", "urti_date_1"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_2=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_2 - 42 days", "urti_date_2 - 1 day"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_3=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_3 - 42 days", "urti_date_3 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_4=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_4 - 42 days", "urti_date_4 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_5=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_5 - 42 days", "urti_date_5 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_6=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_6 - 42 days", "urti_date_6 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_7=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_7 - 42 days", "urti_date_7 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_8=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_8 - 42 days", "urti_date_8 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_9=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_9 - 42 days", "urti_date_9 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_10=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_10 - 42 days", "urti_date_10 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_11=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_11 - 42 days", "urti_date_1 - 11 day"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_12=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_12 - 42 days", "urti_date_12 - 1 day"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_13=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_13 - 42 days", "urti_date_13 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_14=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_14 - 42 days", "urti_date_14 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_15=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_15 - 42 days", "urti_date_15 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_16=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_16 - 42 days", "urti_date_16 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_17=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_17 - 42 days", "urti_date_17 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_18=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_18 - 42 days", "urti_date_18 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_19=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_19 - 42 days", "urti_date_19 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_urti_date_20=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["urti_date_20 - 42 days", "urti_date_20 - 1 day"], 
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),



## hospitalisation with incident OR prevalent urti
    admitted_urti_date_1=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_1", "urti_date_1 + 30 days"], #["urti_date_1", "urti_date_1 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_2=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_2", "urti_date_2 + 30 days"], #["urti_date_2", "urti_date_2 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_3=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_3", "urti_date_3 + 30 days"], #["urti_date_3", "urti_date_3 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_4=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_4", "urti_date_4 + 30 days"], #["urti_date_4", "urti_date_4 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_5=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_5", "urti_date_5 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_6=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_6", "urti_date_6 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_7=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_7", "urti_date_7 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_8=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_8", "urti_date_8 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_9=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_9", "urti_date_9 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_10=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_10", "urti_date_10 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_11=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_11", "urti_date_11 + 30 days"], 
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_12=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_12", "urti_date_12 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_13=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_13", "urti_date_13 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_14=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_14", "urti_date_14 + 30 days"], 
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_15=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_15", "urti_date_15 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_16=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_16", "urti_date_16 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_17=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_17", "urti_date_17 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_18=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_18", "urti_date_18 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_19=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_19", "urti_date_19 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_urti_date_20=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["urti_date_20", "urti_date_20 + 30 days"],
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),




    ## Covid positive test result during hospital admission related to urti
    sgss_pos_covid_date_urti_1=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_1 - 90 days", "urti_date_1 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis during hospital admission related to urti
    gp_covid_date_urti_1=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_1 - 90 days", "urti_date_1 + 30 days"],
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
        between=["urti_date_2 - 90 days", "urti_date_2 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_2=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_2 - 90 days", "urti_date_2 + 30 days"],
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

    ## Covid positive test result 3
    sgss_pos_covid_date_urti_3=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_3 - 90 days", "urti_date_3 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_3=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_3 - 90 days", "urti_date_3 + 30 days"],
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
        between=["urti_date_4 - 90 days", "urti_date_4 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_4=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_4 - 90 days", "urti_date_4 + 30 days"],
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

########################################
    ## Covid positive test result 5
    sgss_pos_covid_date_urti_5=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_5 - 90 days", "urti_date_5 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_5=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_5 - 90 days", "urti_date_5 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_5=patients.satisfying(
        """
        sgss_pos_covid_date_urti_5 OR
        gp_covid_date_urti_5
        """,
    ),

########################################
    ## Covid positive test result 6
    sgss_pos_covid_date_urti_6=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_6 - 90 days", "urti_date_6 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_6=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_6 - 90 days", "urti_date_6 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_6=patients.satisfying(
        """
        sgss_pos_covid_date_urti_6 OR
        gp_covid_date_urti_6
        """,
    ),
########################################
    ## Covid positive test result 7
    sgss_pos_covid_date_urti_7=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_7 - 90 days", "urti_date_7 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_7=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_7 - 90 days", "urti_date_7 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_7=patients.satisfying(
        """
        sgss_pos_covid_date_urti_7 OR
        gp_covid_date_urti_7
        """,
    ),

########################################
    ## Covid positive test result 8
    sgss_pos_covid_date_urti_8=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_8 - 90 days", "urti_date_8 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_8=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_8 - 90 days", "urti_date_8 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_8=patients.satisfying(
        """
        sgss_pos_covid_date_urti_8 OR
        gp_covid_date_urti_8
        """,
    ),

########################################
    ## Covid positive test result 9
    sgss_pos_covid_date_urti_9=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_9 - 90 days", "urti_date_9 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_9=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_9 - 90 days", "urti_date_9 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_9=patients.satisfying(
        """
        sgss_pos_covid_date_urti_9 OR
        gp_covid_date_urti_9
        """,
    ),

########################################
    ## Covid positive test result 10
    sgss_pos_covid_date_urti_10=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_10 - 90 days", "urti_date_10 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_10=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_10 - 90 days", "urti_date_10 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_10=patients.satisfying(
        """
        sgss_pos_covid_date_urti_10 OR
        gp_covid_date_urti_10
        """,
    ),

########################################
    ## Covid positive test result 11
    sgss_pos_covid_date_urti_11=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_11 - 90 days", "urti_date_11 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_11=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_11 - 90 days", "urti_date_11 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_11=patients.satisfying(
        """
        sgss_pos_covid_date_urti_11 OR
        gp_covid_date_urti_11
        """,
    ),

########################################
    ## Covid positive test result 12
    sgss_pos_covid_date_urti_12=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_12 - 90 days", "urti_date_12 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_12=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_12 - 90 days", "urti_date_12 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_12=patients.satisfying(
        """
        sgss_pos_covid_date_urti_12 OR
        gp_covid_date_urti_12
        """,
    ),

########################################
    ## Covid positive test result 13
    sgss_pos_covid_date_urti_13=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_13 - 90 days", "urti_date_13 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_13=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_13 - 90 days", "urti_date_13 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_13=patients.satisfying(
        """
        sgss_pos_covid_date_urti_13 OR
        gp_covid_date_urti_13
        """,
    ),

########################################
    ## Covid positive test result 14
    sgss_pos_covid_date_urti_14=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_14 - 90 days", "urti_date_14 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_14=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_14 - 90 days", "urti_date_14 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_14=patients.satisfying(
        """
        sgss_pos_covid_date_urti_14 OR
        gp_covid_date_urti_14
        """,
    ),

########################################
    ## Covid positive test result 15
    sgss_pos_covid_date_urti_15=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_15 - 90 days", "urti_date_15 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_15=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_15 - 90 days", "urti_date_15 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_15=patients.satisfying(
        """
        sgss_pos_covid_date_urti_15 OR
        gp_covid_date_urti_15
        """,
    ),

########################################
    ## Covid positive test result 16
    sgss_pos_covid_date_urti_16=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_16 - 90 days", "urti_date_16 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_16=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_16 - 90 days", "urti_date_16 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_16=patients.satisfying(
        """
        sgss_pos_covid_date_urti_16 OR
        gp_covid_date_urti_16
        """,
    ),

########################################
    ## Covid positive test result 17
    sgss_pos_covid_date_urti_17=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_17 - 90 days", "urti_date_17 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_17=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_17 - 90 days", "urti_date_17 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_17=patients.satisfying(
        """
        sgss_pos_covid_date_urti_17 OR
        gp_covid_date_urti_17
        """,
    ),

########################################
    ## Covid positive test result 18
    sgss_pos_covid_date_urti_18=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_18 - 90 days", "urti_date_18 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_18=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_18 - 90 days", "urti_date_18 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_18=patients.satisfying(
        """
        sgss_pos_covid_date_urti_18 OR
        gp_covid_date_urti_18
        """,
    ),

########################################
    ## Covid positive test result 19
    sgss_pos_covid_date_urti_19=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_19 - 90 days", "urti_date_19 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_19=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_19 - 90 days", "urti_date_19 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_19=patients.satisfying(
        """
        sgss_pos_covid_date_urti_19 OR
        gp_covid_date_urti_19
        """,
    ),

########################################
    ## Covid positive test result 20
    sgss_pos_covid_date_urti_20=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["urti_date_20 - 90 days", "urti_date_20 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_urti_20=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["urti_date_20 - 90 days", "urti_date_20 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
    sgss_gp_cov_urti_date_20=patients.satisfying(
        """
        sgss_pos_covid_date_urti_20 OR
        gp_covid_date_urti_20
        """,
    ),



    #numbers of antibiotic prescribed for this infection 
    urti_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_1','urti_date_1 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    urti_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_2','urti_date_2 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    urti_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_3','urti_date_3 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    urti_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_4','urti_date_4 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    ## GP consultations for urti resulted in antibiotics
    urti_ab_date_1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_1','urti_date_1 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_2','urti_date_2 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_3','urti_date_3 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_4','urti_date_4 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_5=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_5','urti_date_5 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_6=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_6','urti_date_6 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_7=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_7','urti_date_7 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_8=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_8','urti_date_8 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_9=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_9','urti_date_9 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_10=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_10','urti_date_10 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_11=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_11','urti_date_11 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_12=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_12','urti_date_12 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_13=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_13','urti_date_13 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_14=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_14','urti_date_14 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_15=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_15','urti_date_15 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_16=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_16','urti_date_16 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_17=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_17','urti_date_17 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_18=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_18','urti_date_18 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_19=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_19','urti_date_19 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    urti_ab_date_20=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_20','urti_date_20 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    # antibiotics type for urti
    urti_ab_type_1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_1','urti_date_1 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_2','urti_date_2 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_3','urti_date_3 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_4','urti_date_4 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_5=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_5','urti_date_5 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_6=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_6','urti_date_6 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_7=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_7','urti_date_7 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_8=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_8','urti_date_8 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_9=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_9','urti_date_9 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_10=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_10','urti_date_10 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_11=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_11','urti_date_11 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_12=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_12','urti_date_12 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_13=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_13','urti_date_13 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_14=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_14','urti_date_14 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_15=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_15','urti_date_15 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_16=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_16','urti_date_16 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_17=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_17','urti_date_17 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_18=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_18','urti_date_18 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_19=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_19','urti_date_19 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

    urti_ab_type_20=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['urti_date_20','urti_date_20 + 5 days'],
        returning='category',
        return_expectations={"category": {"ratios": {"Doxycycline":0.1, "Cefoxitin":0.05, "Aztreonam":0.05, 
                                                     "Lymecycline":0.05, "Cefotaxime":0.05, "Amoxicillin":0.3,
                                                     "Trimethoprim":0.05, "Cefalexin":0.05, "Cefamandole":0.05,
                                                     "Cefixime":0.05, "Demeclocycline":0.05, "Fosfomycin":0.05,
                                                     "Cefprozil":0.05, "Clarithromycin":0.05}},
            "incidence": 0.2},
        ),

)