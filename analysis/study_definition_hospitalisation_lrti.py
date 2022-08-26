
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
        on_or_after="2010-01-01",
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
    gp_count_1=patients.with_gp_consultations(
        between=["lrti_date_1 - 12 months", "lrti_date_1"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.6,
        },
    ),

    gp_count_2=patients.with_gp_consultations(
        between=["lrti_date_2 - 12 months", "lrti_date_2"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.6,
        },
    ),

    gp_count_3=patients.with_gp_consultations(
        between=["lrti_date_3 - 12 months", "lrti_date_3"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.6,
        },
    ),

    gp_count_4=patients.with_gp_consultations(
        between=["lrti_date_4 - 12 months", "lrti_date_4"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.6,
        },
    ),


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

    antibacterial_brit_1=patients.with_these_medications(
        antibacterials_codes_brit,
        # between=["index_date", "last_day_of_month(index_date)"],
        between=["lrti_date_1 - 12 months", "lrti_date_1"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_2=patients.with_these_medications(
        antibacterials_codes_brit,
        # between=["index_date", "last_day_of_month(index_date)"],
        between=["lrti_date_2 - 12 months", "lrti_date_2"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_3=patients.with_these_medications(
        antibacterials_codes_brit,
        # between=["index_date", "last_day_of_month(index_date)"],
        between=["lrti_date_3 - 12 months", "lrti_date_3"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    antibacterial_brit_4=patients.with_these_medications(
        antibacterials_codes_brit,
        # between=["index_date", "last_day_of_month(index_date)"],
        between=["lrti_date_4 - 12 months", "lrti_date_4"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

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

    # hospitalisation with diagnosis of lrti, urti, or uti
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

    ########## patient infection events to group_by for measures #############
    ################################################### URTI
#     urti_date_1=patients.with_these_clinical_events(
#         urti_codes,
#         returning='date',
#         between=["index_date", "today"],
#         # on_or_after='index_date',
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", 
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     urti_date_2=patients.with_these_clinical_events(
#         urti_codes,
#         returning='date',
#         # on_or_after='urti_date_1 + 3 days',
#         between=["urti_date_1 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date + 3 days": "today()"}},
#         ),

#     urti_date_3=patients.with_these_clinical_events(
#         urti_codes,
#         returning='date',
#         # on_or_after='urti_date_2 + 3 days',
#         between=["urti_date_2 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     urti_date_4=patients.with_these_clinical_events(
#         urti_codes,
#         returning='date',
#         # on_or_after='urti_date_3 + 3 days',
#         between=["urti_date_3 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#         ## GP consultations for urti
#     gp_cons_urti_1=patients.with_gp_consultations(
#         # urti_codes,
#         # returning='date',
#         between=["urti_date_1", "urti_date_1"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_urti_2=patients.with_gp_consultations(
#         between=["urti_date_2", "urti_date_2"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_urti_3=patients.with_gp_consultations(
#         between=["urti_date_3", "urti_date_3"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_urti_4=patients.with_gp_consultations(
#         between=["urti_date_4", "urti_date_4"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     #  incidence 
#     incdt_urti_date_1=patients.with_these_clinical_events(
#         urti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_urti_1 - 42 days", "gp_cons_urti_1 - 1 day"], #["urti_date_1 - 42 days", "urti_date_1"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_urti_date_2=patients.with_these_clinical_events(
#         urti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_urti_2 - 42 days", "gp_cons_urti_2 - 1 day"], #["urti_date_2 - 42 days", "urti_date_2"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_urti_date_3=patients.with_these_clinical_events(
#         urti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_urti_3 - 42 days", "gp_cons_urti_3 - 1 day"], #["urti_date_3 - 42 days", "urti_date_3"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_urti_date_4=patients.with_these_clinical_events(
#         urti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_urti_4 - 42 days", "gp_cons_urti_4 - 1 day"], #["urti_date_4 - 42 days", "urti_date_4"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

# ## hospitalisation with incident OR prevalent urti
#     admitted_urti_date_1=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_urti_1", "gp_cons_urti_1 + 30 days"], #["urti_date_1", "urti_date_1 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_urti_date_2=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_urti_2", "gp_cons_urti_2 + 30 days"], #["urti_date_2", "urti_date_2 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_urti_date_3=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_urti_3", "gp_cons_urti_3 + 30 days"], #["urti_date_3", "urti_date_3 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_urti_date_4=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_urti_4", "gp_cons_urti_4 + 30 days"], #["urti_date_4", "urti_date_4 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     ## Covid positive test result during hospital admission related to urti
#     sgss_pos_covid_date_urti_1=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_urti_1 - 90 days", "gp_cons_urti_1 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis during hospital admission related to urti
#     gp_covid_date_urti_1=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_urti_1 - 90 days", "gp_cons_urti_1 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
#     sgss_gp_cov_urti_date_1=patients.satisfying(
#         """
#         sgss_pos_covid_date_urti_1 OR
#         gp_covid_date_urti_1
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_urti_2=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_urti_2 - 90 days", "gp_cons_urti_2 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_urti_2=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_urti_2 - 90 days", "gp_cons_urti_2 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
#     sgss_gp_cov_urti_date_2=patients.satisfying(
#         """
#         sgss_pos_covid_date_urti_2 OR
#         gp_covid_date_urti_2
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_urti_3=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_urti_3 - 90 days", "gp_cons_urti_3 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_urti_3=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_urti_3 - 90 days", "gp_cons_urti_3 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
#     sgss_gp_cov_urti_date_3=patients.satisfying(
#         """
#         sgss_pos_covid_date_urti_3 OR
#         gp_covid_date_urti_3
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_urti_4=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_urti_4 - 90 days", "gp_cons_urti_4 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_urti_4=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_urti_4 - 90 days", "gp_cons_urti_4 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after urti dx 
#     sgss_gp_cov_urti_date_4=patients.satisfying(
#         """
#         sgss_pos_covid_date_urti_4 OR
#         gp_covid_date_urti_4
#         """,
#     ),

#         #numbers of antibiotic prescribed for this infection 
#     urti_ab_count_1 = patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['urti_date_1','urti_date_1 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     urti_ab_count_2= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['urti_date_2','urti_date_2 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     urti_ab_count_3= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['urti_date_3','urti_date_3 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     urti_ab_count_4= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['urti_date_4','urti_date_4 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ## GP consultations for urti resulted in antibiotics
#     gp_cons_urti_ab_1=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_urti_1','gp_cons_urti_1 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_urti_ab_2=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_urti_2','gp_cons_urti_2 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_urti_ab_3=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_urti_3','gp_cons_urti_3 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_urti_ab_4=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_urti_4','gp_cons_urti_4 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

    ################################################### LRTI
    lrti_date_1=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        # between=["index_date", "today"],
        on_or_after='index_date',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "today()"}},
        ),

    lrti_date_2=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        # on_or_after='lrti_date_1 + 3 days',
        between=["lrti_date_1 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"lrti_date_1": "today()"}},
        ),

    lrti_date_3=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        # on_or_after='lrti_date_2 + 3 days',
        between=["lrti_date_2 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"lrti_date_2": "today()"}},
        ),

    lrti_date_4=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        # on_or_after='lrti_date_3 + 3 days',
        between=["lrti_date_3 + 1 day", "today"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"lrti_date_3": "today()"}},
        ),

        ## GP consultations for lrti
    gp_cons_lrti_1=patients.with_gp_consultations(
        # lrti_codes,
        # returning='date',
        between=["lrti_date_1", "lrti_date_1"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    gp_cons_lrti_2=patients.with_gp_consultations(
        between=["lrti_date_2", "lrti_date_2"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    gp_cons_lrti_3=patients.with_gp_consultations(
        between=["lrti_date_3", "lrti_date_3"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    gp_cons_lrti_4=patients.with_gp_consultations(
        between=["lrti_date_4", "lrti_date_4"],
        #returning='binary_flag',
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    #  incidence 
    incdt_lrti_date_1=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_lrti_1 - 42 days", "gp_cons_lrti_1 - 1 day"], #["lrti_date_1 - 42 days", "lrti_date_1"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_lrti_date_2=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_lrti_2 - 42 days", "gp_cons_lrti_2 - 1 day"], #["lrti_date_2 - 42 days", "lrti_date_2"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_lrti_date_3=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_lrti_3 - 42 days", "gp_cons_lrti_3 - 1 day"], #["lrti_date_3 - 42 days", "lrti_date_3"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

    incdt_lrti_date_4=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        # returning="date",
        # date_format="YYYY-MM-DD",
        between=["gp_cons_lrti_4 - 42 days", "gp_cons_lrti_4 - 1 day"], #["lrti_date_4 - 42 days", "lrti_date_4"]
        find_first_match_in_period=True,
        # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
    ),

## hospitalisation with incident OR prevalent lrti
    admitted_lrti_date_1=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_lrti_1", "gp_cons_lrti_1 + 30 days"], #["lrti_date_1", "lrti_date_1 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_lrti_date_2=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_lrti_2", "gp_cons_lrti_2 + 30 days"], #["lrti_date_2", "lrti_date_2 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_lrti_date_3=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_lrti_3", "gp_cons_lrti_3 + 30 days"], #["lrti_date_3", "lrti_date_3 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    admitted_lrti_date_4=patients.admitted_to_hospital(
       with_these_diagnoses=hospitalisation_infection_related,
       returning="date_admitted",
       date_format="YYYY-MM-DD",
       between=["gp_cons_lrti_4", "gp_cons_lrti_4 + 30 days"], #["lrti_date_4", "lrti_date_4 + 30 days"]
       find_first_match_in_period=True,
       return_expectations={"incidence": 0.3},
    ),

    ## Covid positive test result during hospital admission related to lrti
    sgss_pos_covid_date_lrti_1=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_lrti_1 - 90 days", "gp_cons_lrti_1 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis during hospital admission related to lrti
    gp_covid_date_lrti_1=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_lrti_1 - 90 days", "gp_cons_lrti_1 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after lrti dx 
    sgss_gp_cov_lrti_date_1=patients.satisfying(
        """
        sgss_pos_covid_date_lrti_1 OR
        gp_covid_date_lrti_1
        """,
    ),

    ## Covid positive test result
    sgss_pos_covid_date_lrti_2=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_lrti_2 - 90 days", "gp_cons_lrti_2 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_lrti_2=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_lrti_2 - 90 days", "gp_cons_lrti_2 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after lrti dx 
    sgss_gp_cov_lrti_date_2=patients.satisfying(
        """
        sgss_pos_covid_date_lrti_2 OR
        gp_covid_date_lrti_2
        """,
    ),

    ## Covid positive test result
    sgss_pos_covid_date_lrti_3=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_lrti_3 - 90 days", "gp_cons_lrti_3 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_lrti_3=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_lrti_3 - 90 days", "gp_cons_lrti_3 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after lrti dx 
    sgss_gp_cov_lrti_date_3=patients.satisfying(
        """
        sgss_pos_covid_date_lrti_3 OR
        gp_covid_date_lrti_3
        """,
    ),

    ## Covid positive test result
    sgss_pos_covid_date_lrti_4=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["gp_cons_lrti_4 - 90 days", "gp_cons_lrti_4 + 30 days"],
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.5},
    ),

    ## Covid diagnosis
    gp_covid_date_lrti_4=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["gp_cons_lrti_4 - 90 days", "gp_cons_lrti_4 + 30 days"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
    ),

    ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after lrti dx 
    sgss_gp_cov_lrti_date_4=patients.satisfying(
        """
        sgss_pos_covid_date_lrti_4 OR
        gp_covid_date_lrti_4
        """,
    ),

    #numbers of antibiotic prescribed for this infection 
    lrti_ab_count_1 = patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_1','lrti_date_1 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    lrti_ab_count_2= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_2','lrti_date_2 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    lrti_ab_count_3= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_3','lrti_date_3 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    lrti_ab_count_4= patients.with_these_medications(
        antibacterials_codes_brit,
        between=['lrti_date_4','lrti_date_4 + 7 days'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    ## GP consultations for lrti resulted in antibiotics
    gp_cons_lrti_ab_1=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_lrti_1','gp_cons_lrti_1 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    gp_cons_lrti_ab_2=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_lrti_2','gp_cons_lrti_2 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    gp_cons_lrti_ab_3=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_lrti_3','gp_cons_lrti_3 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

    gp_cons_lrti_ab_4=patients.with_these_medications(
        antibacterials_codes_brit,
        between=['gp_cons_lrti_4','gp_cons_lrti_4 + 5 days'],
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
        ),

#     ######################################################## UTI
#     uti_date_1=patients.with_these_clinical_events(
#         uti_codes,
#         returning='date',
#         between=["index_date", "today"],
#         # on_or_after='index_date',
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", 
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     uti_date_2=patients.with_these_clinical_events(
#         uti_codes,
#         returning='date',
#         # on_or_after='uti_date_1 + 3 days',
#         between=["uti_date_1 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date + 3 days": "today()"}},
#         ),

#     uti_date_3=patients.with_these_clinical_events(
#         uti_codes,
#         returning='date',
#         # on_or_after='uti_date_2 + 3 days',
#         between=["uti_date_2 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     uti_date_4=patients.with_these_clinical_events(
#         uti_codes,
#         returning='date',
#         # on_or_after='uti_date_3 + 3 days',
#         between=["uti_date_3 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#         ## GP consultations for uti
#     gp_cons_uti_1=patients.with_gp_consultations(
#         # uti_codes,
#         # returning='date',
#         between=["uti_date_1", "uti_date_1"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_uti_2=patients.with_gp_consultations(
#         between=["uti_date_2", "uti_date_2"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_uti_3=patients.with_gp_consultations(
#         between=["uti_date_3", "uti_date_3"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_uti_4=patients.with_gp_consultations(
#         between=["uti_date_4", "uti_date_4"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     #  incidence 
#     incdt_uti_date_1=patients.with_these_clinical_events(
#         uti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_uti_1 - 42 days", "gp_cons_uti_1 - 1 day"], #["uti_date_1 - 42 days", "uti_date_1"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_uti_date_2=patients.with_these_clinical_events(
#         uti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_uti_2 - 42 days", "gp_cons_uti_2 - 1 day"], #["uti_date_2 - 42 days", "uti_date_2"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_uti_date_3=patients.with_these_clinical_events(
#         uti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_uti_3 - 42 days", "gp_cons_uti_3 - 1 day"], #["uti_date_3 - 42 days", "uti_date_3"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_uti_date_4=patients.with_these_clinical_events(
#         uti_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_uti_4 - 42 days", "gp_cons_uti_4 - 1 day"], #["uti_date_4 - 42 days", "uti_date_4"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

# ## hospitalisation with incident OR prevalent uti
#     admitted_uti_date_1=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_uti_1", "gp_cons_uti_1 + 30 days"], #["uti_date_1", "uti_date_1 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_uti_date_2=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_uti_2", "gp_cons_uti_2 + 30 days"], #["uti_date_2", "uti_date_2 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_uti_date_3=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_uti_3", "gp_cons_uti_3 + 30 days"], #["uti_date_3", "uti_date_3 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_uti_date_4=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_uti_4", "gp_cons_uti_4 + 30 days"], #["uti_date_4", "uti_date_4 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     ## Covid positive test result during hospital admission related to uti
#     sgss_pos_covid_date_uti_1=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_uti_1 - 90 days", "gp_cons_uti_1 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis during hospital admission related to uti
#     gp_covid_date_uti_1=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_uti_1 - 90 days", "gp_cons_uti_1 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after uti dx 
#     sgss_gp_cov_uti_date_1=patients.satisfying(
#         """
#         sgss_pos_covid_date_uti_1 OR
#         gp_covid_date_uti_1
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_uti_2=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_uti_2 - 90 days", "gp_cons_uti_2 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_uti_2=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_uti_2 - 90 days", "gp_cons_uti_2 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after uti dx 
#     sgss_gp_cov_uti_date_2=patients.satisfying(
#         """
#         sgss_pos_covid_date_uti_2 OR
#         gp_covid_date_uti_2
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_uti_3=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_uti_3 - 90 days", "gp_cons_uti_3 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_uti_3=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_uti_3 - 90 days", "gp_cons_uti_3 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after uti dx 
#     sgss_gp_cov_uti_date_3=patients.satisfying(
#         """
#         sgss_pos_covid_date_uti_3 OR
#         gp_covid_date_uti_3
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_uti_4=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_uti_4 - 90 days", "gp_cons_uti_4 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_uti_4=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_uti_4 - 90 days", "gp_cons_uti_4 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after uti dx 
#     sgss_gp_cov_uti_date_4=patients.satisfying(
#         """
#         sgss_pos_covid_date_uti_4 OR
#         gp_covid_date_uti_4
#         """,
#     ),

#         #numbers of antibiotic prescribed for this infection 
#     uti_ab_count_1 = patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['uti_date_1','uti_date_1 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     uti_ab_count_2= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['uti_date_2','uti_date_2 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     uti_ab_count_3= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['uti_date_3','uti_date_3 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     uti_ab_count_4= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['uti_date_4','uti_date_4 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ## GP consultations for uti resulted in antibiotics
#     gp_cons_uti_ab_1=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_uti_1','gp_cons_uti_1 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_uti_ab_2=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_uti_2','gp_cons_uti_2 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_uti_ab_3=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_uti_3','gp_cons_uti_3 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_uti_ab_4=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_uti_4','gp_cons_uti_4 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     ######################################################## sinusitis
#     sinusitis_date_1=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning='date',
#         between=["index_date", "today"],
#         # on_or_after='index_date',
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", 
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     sinusitis_date_2=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning='date',
#         # on_or_after='sinusitis_date_1 + 3 days',
#         between=["sinusitis_date_1 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date + 3 days": "today()"}},
#         ),

#     sinusitis_date_3=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning='date',
#         # on_or_after='sinusitis_date_2 + 3 days',
#         between=["sinusitis_date_2 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     sinusitis_date_4=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning='date',
#         # on_or_after='sinusitis_date_3 + 3 days',
#         between=["sinusitis_date_3 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#         ## GP consultations for sinusitis
#     gp_cons_sinusitis_1=patients.with_gp_consultations(
#         # sinusitis_codes,
#         # returning='date',
#         between=["sinusitis_date_1", "sinusitis_date_1"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_sinusitis_2=patients.with_gp_consultations(
#         between=["sinusitis_date_2", "sinusitis_date_2"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_sinusitis_3=patients.with_gp_consultations(
#         between=["sinusitis_date_3", "sinusitis_date_3"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_sinusitis_4=patients.with_gp_consultations(
#         between=["sinusitis_date_4", "sinusitis_date_4"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     #  incidence 
#     incdt_sinusitis_date_1=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_sinusitis_1 - 42 days", "gp_cons_sinusitis_1 - 1 day"], #["sinusitis_date_1 - 42 days", "sinusitis_date_1"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_sinusitis_date_2=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_sinusitis_2 - 42 days", "gp_cons_sinusitis_2 - 1 day"], #["sinusitis_date_2 - 42 days", "sinusitis_date_2"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_sinusitis_date_3=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_sinusitis_3 - 42 days", "gp_cons_sinusitis_3 - 1 day"], #["sinusitis_date_3 - 42 days", "sinusitis_date_3"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_sinusitis_date_4=patients.with_these_clinical_events(
#         sinusitis_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_sinusitis_4 - 42 days", "gp_cons_sinusitis_4 - 1 day"], #["sinusitis_date_4 - 42 days", "sinusitis_date_4"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

# ## hospitalisation with incident OR prevalent sinusitis
#     admitted_sinusitis_date_1=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_sinusitis_1", "gp_cons_sinusitis_1 + 30 days"], #["sinusitis_date_1", "sinusitis_date_1 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_sinusitis_date_2=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_sinusitis_2", "gp_cons_sinusitis_2 + 30 days"], #["sinusitis_date_2", "sinusitis_date_2 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_sinusitis_date_3=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_sinusitis_3", "gp_cons_sinusitis_3 + 30 days"], #["sinusitis_date_3", "sinusitis_date_3 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_sinusitis_date_4=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_sinusitis_4", "gp_cons_sinusitis_4 + 30 days"], #["sinusitis_date_4", "sinusitis_date_4 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     ## Covid positive test result during hospital admission related to sinusitis
#     sgss_pos_covid_date_sinusitis_1=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_sinusitis_1 - 90 days", "gp_cons_sinusitis_1 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis during hospital admission related to sinusitis
#     gp_covid_date_sinusitis_1=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_sinusitis_1 - 90 days", "gp_cons_sinusitis_1 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after sinusitis dx 
#     sgss_gp_cov_sinusitis_date_1=patients.satisfying(
#         """
#         sgss_pos_covid_date_sinusitis_1 OR
#         gp_covid_date_sinusitis_1
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_sinusitis_2=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_sinusitis_2 - 90 days", "gp_cons_sinusitis_2 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_sinusitis_2=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_sinusitis_2 - 90 days", "gp_cons_sinusitis_2 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after sinusitis dx 
#     sgss_gp_cov_sinusitis_date_2=patients.satisfying(
#         """
#         sgss_pos_covid_date_sinusitis_2 OR
#         gp_covid_date_sinusitis_2
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_sinusitis_3=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_sinusitis_3 - 90 days", "gp_cons_sinusitis_3 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_sinusitis_3=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_sinusitis_3 - 90 days", "gp_cons_sinusitis_3 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after sinusitis dx 
#     sgss_gp_cov_sinusitis_date_3=patients.satisfying(
#         """
#         sgss_pos_covid_date_sinusitis_3 OR
#         gp_covid_date_sinusitis_3
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_sinusitis_4=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_sinusitis_4 - 90 days", "gp_cons_sinusitis_4 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_sinusitis_4=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_sinusitis_4 - 90 days", "gp_cons_sinusitis_4 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after sinusitis dx 
#     sgss_gp_cov_sinusitis_date_4=patients.satisfying(
#         """
#         sgss_pos_covid_date_sinusitis_4 OR
#         gp_covid_date_sinusitis_4
#         """,
#     ),

#         #numbers of antibiotic prescribed for this infection 
#     sinusitis_ab_count_1 = patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['sinusitis_date_1','sinusitis_date_1 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     sinusitis_ab_count_2= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['sinusitis_date_2','sinusitis_date_2 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     sinusitis_ab_count_3= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['sinusitis_date_3','sinusitis_date_3 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     sinusitis_ab_count_4= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['sinusitis_date_4','sinusitis_date_4 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ## GP consultations for sinusitis resulted in antibiotics
#     gp_cons_sinusitis_ab_1=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_sinusitis_1','gp_cons_sinusitis_1 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_sinusitis_ab_2=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_sinusitis_2','gp_cons_sinusitis_2 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_sinusitis_ab_3=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_sinusitis_3','gp_cons_sinusitis_3 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_sinusitis_ab_4=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_sinusitis_4','gp_cons_sinusitis_4 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     ################################################### OT-EXTERNA
#     ot_externa_date_1=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning='date',
#         between=["index_date", "today"],
#         # on_or_after='index_date',
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", 
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     ot_externa_date_2=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning='date',
#         # on_or_after='ot_externa_date_1 + 3 days',
#         between=["ot_externa_date_1 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date + 3 days": "today()"}},
#         ),

#     ot_externa_date_3=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning='date',
#         # on_or_after='ot_externa_date_2 + 3 days',
#         between=["ot_externa_date_2 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     ot_externa_date_4=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning='date',
#         # on_or_after='ot_externa_date_3 + 3 days',
#         between=["ot_externa_date_3 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#         ## GP consultations for ot_externa
#     gp_cons_ot_externa_1=patients.with_gp_consultations(
#         # ot_externa_codes,
#         # returning='date',
#         between=["ot_externa_date_1", "ot_externa_date_1"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_ot_externa_2=patients.with_gp_consultations(
#         between=["ot_externa_date_2", "ot_externa_date_2"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_ot_externa_3=patients.with_gp_consultations(
#         between=["ot_externa_date_3", "ot_externa_date_3"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_ot_externa_4=patients.with_gp_consultations(
#         between=["ot_externa_date_4", "ot_externa_date_4"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     #  incidence 
#     incdt_ot_externa_date_1=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_ot_externa_1 - 42 days", "gp_cons_ot_externa_1 - 1 day"], #["ot_externa_date_1 - 42 days", "ot_externa_date_1"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_ot_externa_date_2=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_ot_externa_2 - 42 days", "gp_cons_ot_externa_2 - 1 day"], #["ot_externa_date_2 - 42 days", "ot_externa_date_2"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_ot_externa_date_3=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_ot_externa_3 - 42 days", "gp_cons_ot_externa_3 - 1 day"], #["ot_externa_date_3 - 42 days", "ot_externa_date_3"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_ot_externa_date_4=patients.with_these_clinical_events(
#         ot_externa_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_ot_externa_4 - 42 days", "gp_cons_ot_externa_4 - 1 day"], #["ot_externa_date_4 - 42 days", "ot_externa_date_4"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

# ## hospitalisation with incident OR prevalent ot_externa
#     admitted_ot_externa_date_1=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_ot_externa_1", "gp_cons_ot_externa_1 + 30 days"], #["ot_externa_date_1", "ot_externa_date_1 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_ot_externa_date_2=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_ot_externa_2", "gp_cons_ot_externa_2 + 30 days"], #["ot_externa_date_2", "ot_externa_date_2 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_ot_externa_date_3=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_ot_externa_3", "gp_cons_ot_externa_3 + 30 days"], #["ot_externa_date_3", "ot_externa_date_3 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_ot_externa_date_4=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_ot_externa_4", "gp_cons_ot_externa_4 + 30 days"], #["ot_externa_date_4", "ot_externa_date_4 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     ## Covid positive test result during hospital admission related to ot_externa
#     sgss_pos_covid_date_ot_externa_1=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_ot_externa_1 - 90 days", "gp_cons_ot_externa_1 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis during hospital admission related to ot_externa
#     gp_covid_date_ot_externa_1=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_ot_externa_1 - 90 days", "gp_cons_ot_externa_1 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after ot_externa dx 
#     sgss_gp_cov_ot_externa_date_1=patients.satisfying(
#         """
#         sgss_pos_covid_date_ot_externa_1 OR
#         gp_covid_date_ot_externa_1
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_ot_externa_2=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_ot_externa_2 - 90 days", "gp_cons_ot_externa_2 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_ot_externa_2=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_ot_externa_2 - 90 days", "gp_cons_ot_externa_2 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after ot_externa dx 
#     sgss_gp_cov_ot_externa_date_2=patients.satisfying(
#         """
#         sgss_pos_covid_date_ot_externa_2 OR
#         gp_covid_date_ot_externa_2
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_ot_externa_3=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_ot_externa_3 - 90 days", "gp_cons_ot_externa_3 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_ot_externa_3=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_ot_externa_3 - 90 days", "gp_cons_ot_externa_3 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after ot_externa dx 
#     sgss_gp_cov_ot_externa_date_3=patients.satisfying(
#         """
#         sgss_pos_covid_date_ot_externa_3 OR
#         gp_covid_date_ot_externa_3
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_ot_externa_4=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_ot_externa_4 - 90 days", "gp_cons_ot_externa_4 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_ot_externa_4=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_ot_externa_4 - 90 days", "gp_cons_ot_externa_4 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after ot_externa dx 
#     sgss_gp_cov_ot_externa_date_4=patients.satisfying(
#         """
#         sgss_pos_covid_date_ot_externa_4 OR
#         gp_covid_date_ot_externa_4
#         """,
#     ),

#         #numbers of antibiotic prescribed for this infection 
#     ot_externa_ab_count_1 = patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['ot_externa_date_1','ot_externa_date_1 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ot_externa_ab_count_2= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['ot_externa_date_2','ot_externa_date_2 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ot_externa_ab_count_3= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['ot_externa_date_3','ot_externa_date_3 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ot_externa_ab_count_4= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['ot_externa_date_4','ot_externa_date_4 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ## GP consultations for ot_externa resulted in antibiotics
#     gp_cons_ot_externa_ab_1=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_ot_externa_1','gp_cons_ot_externa_1 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_ot_externa_ab_2=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_ot_externa_2','gp_cons_ot_externa_2 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_ot_externa_ab_3=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_ot_externa_3','gp_cons_ot_externa_3 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_ot_externa_ab_4=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_ot_externa_4','gp_cons_ot_externa_4 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     ################################################### OT MEDIA
#     otmedia_date_1=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning='date',
#         between=["index_date", "today"],
#         # on_or_after='index_date',
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", 
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     otmedia_date_2=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning='date',
#         # on_or_after='otmedia_date_1 + 3 days',
#         between=["otmedia_date_1 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date + 3 days": "today()"}},
#         ),

#     otmedia_date_3=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning='date',
#         # on_or_after='otmedia_date_2 + 3 days',
#         between=["otmedia_date_2 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#     otmedia_date_4=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning='date',
#         # on_or_after='otmedia_date_3 + 3 days',
#         between=["otmedia_date_3 + 1 day", "today"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
#         return_expectations={"date": {"index_date": "today()"}},
#         ),

#         ## GP consultations for otmedia
#     gp_cons_otmedia_1=patients.with_gp_consultations(
#         # otmedia_codes,
#         # returning='date',
#         between=["otmedia_date_1", "otmedia_date_1"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_otmedia_2=patients.with_gp_consultations(
#         between=["otmedia_date_2", "otmedia_date_2"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_otmedia_3=patients.with_gp_consultations(
#         between=["otmedia_date_3", "otmedia_date_3"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     gp_cons_otmedia_4=patients.with_gp_consultations(
#         between=["otmedia_date_4", "otmedia_date_4"],
#         #returning='binary_flag',
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#     ),

#     #  incidence 
#     incdt_otmedia_date_1=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_otmedia_1 - 42 days", "gp_cons_otmedia_1 - 1 day"], #["otmedia_date_1 - 42 days", "otmedia_date_1"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_otmedia_date_2=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_otmedia_2 - 42 days", "gp_cons_otmedia_2 - 1 day"], #["otmedia_date_2 - 42 days", "otmedia_date_2"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_otmedia_date_3=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_otmedia_3 - 42 days", "gp_cons_otmedia_3 - 1 day"], #["otmedia_date_3 - 42 days", "otmedia_date_3"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

#     incdt_otmedia_date_4=patients.with_these_clinical_events(
#         otmedia_codes,
#         returning="binary_flag",
#         # returning="date",
#         # date_format="YYYY-MM-DD",
#         between=["gp_cons_otmedia_4 - 42 days", "gp_cons_otmedia_4 - 1 day"], #["otmedia_date_4 - 42 days", "otmedia_date_4"]
#         find_first_match_in_period=True,
#         # return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
#         return_expectations={"incidence": 0.1, "date": {"earliest": "index_date - 42 days"}}
#     ),

# ## hospitalisation with incident OR prevalent otmedia
#     admitted_otmedia_date_1=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_otmedia_1", "gp_cons_otmedia_1 + 30 days"], #["otmedia_date_1", "otmedia_date_1 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_otmedia_date_2=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_otmedia_2", "gp_cons_otmedia_2 + 30 days"], #["otmedia_date_2", "otmedia_date_2 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_otmedia_date_3=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_otmedia_3", "gp_cons_otmedia_3 + 30 days"], #["otmedia_date_3", "otmedia_date_3 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     admitted_otmedia_date_4=patients.admitted_to_hospital(
#        with_these_diagnoses=hospitalisation_infection_related,
#        returning="date_admitted",
#        date_format="YYYY-MM-DD",
#        between=["gp_cons_otmedia_4", "gp_cons_otmedia_4 + 30 days"], #["otmedia_date_4", "otmedia_date_4 + 30 days"]
#        find_first_match_in_period=True,
#        return_expectations={"incidence": 0.3},
#     ),

#     ## Covid positive test result during hospital admission related to otmedia
#     sgss_pos_covid_date_otmedia_1=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_otmedia_1 - 90 days", "gp_cons_otmedia_1 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis during hospital admission related to otmedia
#     gp_covid_date_otmedia_1=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_otmedia_1 - 90 days", "gp_cons_otmedia_1 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after otmedia dx 
#     sgss_gp_cov_otmedia_date_1=patients.satisfying(
#         """
#         sgss_pos_covid_date_otmedia_1 OR
#         gp_covid_date_otmedia_1
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_otmedia_2=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_otmedia_2 - 90 days", "gp_cons_otmedia_2 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_otmedia_2=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_otmedia_2 - 90 days", "gp_cons_otmedia_2 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after otmedia dx 
#     sgss_gp_cov_otmedia_date_2=patients.satisfying(
#         """
#         sgss_pos_covid_date_otmedia_2 OR
#         gp_covid_date_otmedia_2
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_otmedia_3=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_otmedia_3 - 90 days", "gp_cons_otmedia_3 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_otmedia_3=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_otmedia_3 - 90 days", "gp_cons_otmedia_3 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after otmedia dx 
#     sgss_gp_cov_otmedia_date_3=patients.satisfying(
#         """
#         sgss_pos_covid_date_otmedia_3 OR
#         gp_covid_date_otmedia_3
#         """,
#     ),

#     ## Covid positive test result
#     sgss_pos_covid_date_otmedia_4=patients.with_test_result_in_sgss(
#         pathogen="SARS-CoV-2",
#         test_result="positive",
#         between=["gp_cons_otmedia_4 - 90 days", "gp_cons_otmedia_4 + 30 days"],
#         find_first_match_in_period=True,
#         returning="date",
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.5},
#     ),

#     ## Covid diagnosis
#     gp_covid_date_otmedia_4=patients.with_these_clinical_events(
#         any_primary_care_code,
#         returning="date",
#         between=["gp_cons_otmedia_4 - 90 days", "gp_cons_otmedia_4 + 30 days"],
#         find_first_match_in_period=True,
#         date_format="YYYY-MM-DD",
#         return_expectations={"date":{"earliest":start_date}, "rate": "exponential_increase", "incidence": 0.5},
#     ),

#     ## Covid diagnosis either recorded in sgss or diagnosed by gp within 90 days before and 30 days after otmedia dx 
#     sgss_gp_cov_otmedia_date_4=patients.satisfying(
#         """
#         sgss_pos_covid_date_otmedia_4 OR
#         gp_covid_date_otmedia_4
#         """,
#     ),

#         #numbers of antibiotic prescribed for this infection 
#     otmedia_ab_count_1 = patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['otmedia_date_1','otmedia_date_1 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     otmedia_ab_count_2= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['otmedia_date_2','otmedia_date_2 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     otmedia_ab_count_3= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['otmedia_date_3','otmedia_date_3 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     otmedia_ab_count_4= patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['otmedia_date_4','otmedia_date_4 + 7 days'],
#         returning='number_of_matches_in_period',
#         return_expectations={
#             "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
#         ),

#     ## GP consultations for otmedia resulted in antibiotics
#     gp_cons_otmedia_ab_1=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_otmedia_1','gp_cons_otmedia_1 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_otmedia_ab_2=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_otmedia_2','gp_cons_otmedia_2 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_otmedia_ab_3=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_otmedia_3','gp_cons_otmedia_3 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),

#     gp_cons_otmedia_ab_4=patients.with_these_medications(
#         antibacterials_codes_brit,
#         between=['gp_cons_otmedia_4','gp_cons_otmedia_4 + 5 days'],
#         returning='date',
#         date_format="YYYY-MM-DD",
#         return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
#         ),


)