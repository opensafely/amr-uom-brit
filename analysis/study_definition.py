
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
from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes#, flu_vaccine_codes

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


    

    ## All antibacterials
    antibacterial_prescriptions=patients.with_these_medications(
        antibacterials_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1}, "incidence": 0.5}
    ),


    ## Broad spectrum antibiotics
    broad_spectrum_antibiotics_prescriptions=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1}, "incidence": 0.5}
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
            },
        },
    ),


    ## Date of birth
    dob=patients.date_of_birth(
        "YYYY-MM",
        return_expectations={
            "date": {"earliest": "1950-01-01", "latest": "today"},
            "rate": "uniform",
        },
    ),

    
    ## BMI, most recent
    bmi=patients.most_recent_bmi(
        between=["2010-02-01", "today"],
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM",
        return_expectations={
            "date": {"earliest": "2010-02-01", "latest": "today"},
            "float": {"distribution": "normal", "mean": 28, "stddev": 8},
            "incidence": 0.80,
        },
    ),

    ###########################################
    # BMI
    bmi_dat=patients.with_these_clinical_events(
        bmi_codes,
        returning="date",
        ignore_missing_values=True,
        find_last_match_in_period=True,
        on_or_before="index_date",
        date_format="YYYY-MM-DD",
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

    #########################################
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
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="2020-02-01",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="2020-02-01",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="2020-02-01",
        return_last_date_in_period=True,
        include_month=True,
    ),
    most_recent_unclear_smoking_cat_date=patients.with_these_clinical_events(
        unclear_smoking_codes,
        on_or_before="2020-02-01",
        return_last_date_in_period=True,
        include_month=True,
    ),

    ################################################

    ## GP consultations
    gp_count=patients.with_gp_consultations(
        between=["index_date", "today"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.6,
        },
    ),


    ## Flu vaccine
    flu_vaccine=patients.with_tpp_vaccination_record(
        target_disease_matches="influenza",
        between=[start_date, "index_date"],
        returning="binary_flag",
        #date_format=binary,
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": start_date, "latest": "index_date"}
        }
    ),

    ## Flu vaccine 2
    #flu_vaccine=patients.with_tpp_vaccination_record(
    #    flu_vaccine_codes,
    #    between=["index_date", "today"],
    #    returning="date",
    #    date_format="YYYY-MM",
    #    find_first_match_in_period=True,
    #    return_expectations={
    #        "date": {"earliest": "index_date", "latest": "today"}
    #    }
    #),

    ## Antibiotics
    #antibiotics_count=patients.with_these_medications(
    #    antibiotics_codes,
    #    between=["index_date", "today"],
    #    ignore_days_where_these_clinical_codes_occur=copd_reviews,
    #    returning="number_of_episodes",
    #    episode_defined_as="series of events each <= 28 days apart",
    #    return_expectations={
    #        "int": {"distribution": "normal", "mean": 2, "stddev": 1},
    #        "incidence": 0.2,
    #    },
    #),

    ### from opensafely/long-covid repo
    ## Covid positive test result
    sgss_positive=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    ),

    ## Covid diagnosis
    primary_care_covid=patients.with_these_clinical_events(
        any_primary_care_code,
        between=[start_date, "index_date"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
    ),

    ## hospitalised because of covid diagnosis
    #hospital_covid=patients.admitted_to_hospital(
    #    with_these_diagnoses=covid_codes,
    #    returning="date_admitted",
    #    date_format="YYYY-MM-DD",
    #    find_first_match_in_period=True,
    #    return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    #),

    ### from OpenSafely website
    ## Hospitalisation records
    #hospitalisation = patients.with_these_clinical_events(
    #    hospitalisation_codes,
    #    between=["index_date", "today"],
    #    returning="date",
    #    find_first_match_in_period=True,
    #    return_expectations={"date": {earliest: "index_date", "latest": "today"}},
    #),


    ## hospitalisation
    admitted=patients.admitted_to_hospital(
        returning="binary_flag",
        #returning="date",
        #date_format="YYYY-MM-DD",
        between=["index_date", "today"],
        return_expectations={"incidence": 0.1},
    ),
    
    ## Death
    died_any=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},
            "rate" : "exponential_increase"
        },
    ),

)


# --- DEFINE MEASURES ---

measures = [
    ## antibiotic rx rate
    Measure(id="antibiotics_overall",
            numerator="antibacterial_prescriptions",
            denominator="population",
            group_by=["practice", "sex", "dob"]
            ),
    

    ## Broad spectrum antibiotics
    Measure(id="broad_spectrum_proportion",
            numerator="broad_spectrum_antibiotics_prescriptions",
            denominator="antibacterial_prescriptions",
            group_by=["practice"]
            ),

    
    ## STRPU antibiotics
    Measure(id="STARPU_antibiotics",
            numerator="antibacterial_prescriptions",
            denominator="population",
            group_by=["practice", "sex", "age_cat", "flu_vaccine"]
            ),


    ## hospitalisation 
    Measure(id="hosp_admission",
            numerator="admitted",
            denominator="population",
            group_by=["practice", "sex", "age_cat", "flu_vaccine", "ethnicity", "imd", "primary_care_covid",# "bmi_dat", "smoking_status", 
            ]
            )
    #these haven't worked: bmi, dob, sgss_positive, primary_care_covid
]