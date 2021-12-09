
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
from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, asthma_copd_codes, asthma_codes, cold_codes, copd_codes, cough_cold_codes, cough_codes, lrti_codes, ot_externa_codes, otmedia_codes, pneumonia_codes, renal_codes, sepsis_codes, sinusitis_codes, throat_codes, urti_codes, uti_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes, flu_med_codes, flu_clinical_given_codes, flu_clinical_not_given_codes, covrx_code#, flu_vaccine_codes

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
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
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

    ## GP consultations
    gp_count=patients.with_gp_consultations(
        between=["index_date", "today"],
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
        between=[start_date, "index_date"],
        returning="binary_flag",
        #date_format=binary,
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "index_date - 6 months", "latest": "index_date"}
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
            "date": {"earliest": "index_date - 6 months", "latest": "index_date"}
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

    ### Antibiotics from opensafely antimicrobial-stewardship repo
    ## all antibacterials
    antibacterial_prescriptions=patients.with_these_medications(
        antibacterials_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
    ),

    ## all antibacterials 12m before
    antibacterial_12mb4=patients.with_these_medications(
        antibacterials_codes,
        between=["first_day_of_month(index_date) - 12 months", "first_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 3, "stddev": 2},
            "incidence": 1,
        },
    ),

    ## Broad spectrum antibiotics
    broad_spectrum_antibiotics_prescriptions=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1}, "incidence": 0.5}
    ),

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

    ### First COVID vaccination medication code (any)
    covrx1_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
                "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_code,
        },
        find_first_match_in_period=True,
        on_or_before="index_date",
        on_or_after="2020-11-29",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase",
            "incidence": 0.5,
        }
    ),
    # Second COVID vaccination medication code (any)
    covrx2_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
                "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_code,
        },
        find_last_match_in_period=True,
        on_or_before="index_date",
        on_or_after="covrx1_dat + 19 days",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase",
            "incidence": 0.5,
        }
    ),

    ## hospitalisation
    admitted=patients.admitted_to_hospital(
        returning="binary_flag",
        #returning="date",
        #date_format="YYYY-MM-DD",
        between=["index_date", "today"],
        return_expectations={"incidence": 0.1},
    ),
    
    ## hospitalised because of covid diagnosis
    #hospital_covid=patients.admitted_to_hospital(
    #    with_these_diagnoses=covid_codes,
    #    returning="date_admitted",
    #    date_format="YYYY-MM-DD",
    #    find_first_match_in_period=True,
    #    return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    #),

    ## Hospitalisation records
    #hospitalisation = patients.with_these_clinical_events(
    #    hospitalisation_codes,
    #    between=["index_date", "today"],
    #    returning="date",
    #    find_first_match_in_period=True,
    #    return_expectations={"date": {earliest: "index_date", "latest": "today"}},
    #),

    ## Death
    died_date=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},
            "rate" : "exponential_increase"
        },
    ),


    ########## patient infection events to group_by for measures #############
    
    #  --UTI 
    ## count infection events 
    uti_counts=patients.with_these_clinical_events(
        uti_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --LRTI 
    ## count infection events 
    lrti_counts=patients.with_these_clinical_events(
        lrti_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --URTI  
    urti_counts=patients.with_these_clinical_events(
        urti_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --sinusitis 
    sinusitis_counts=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    ot_externa_counts=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    otmedia_counts=patients.with_these_clinical_events(
        otmedia_codes,
        returning="number_of_matches_in_period",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

   ########## infection P't numbers to group_by for measures #############
    
    #  --UTI 
    ## count patient number
    uti_pt=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),
    #  --LRTI 
    lrti_pt=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --URTI  
    urti_pt=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --sinusitis 
    sinusitis_pt=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    ot_externa_pt=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    otmedia_pt=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #### prescribing rate by 6 common infection type #####
    #### each infection has 4 columns for antibiotics 

    # ---- UTI 

    ## find patient's infection date 
    uti_date_1=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        on_or_after='index_date',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),


    ## antibiotic prescribed for this infection ("number of matiches"- pt may get more than one antibiotics)
    uti_ab_count_1 = patients.with_these_medications(antibacterials_codes,
        between=['uti_date_1','uti_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    uti_date_2=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        on_or_after='uti_date_1 + 1 day',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    uti_ab_count_2= patients.with_these_medications(antibacterials_codes,
        between=['uti_date_2','uti_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    uti_date_3=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        on_or_after='uti_date_2 + 1 day',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    uti_ab_count_3= patients.with_these_medications(antibacterials_codes,
        between=['uti_date_3','uti_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    uti_date_4=patients.with_these_clinical_events(
        uti_codes,
        returning='date',
        on_or_after='uti_date_3 + 1 day',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    uti_ab_count_4= patients.with_these_medications(antibacterials_codes,
        between=['uti_date_4','uti_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

  # ---- LRTI

    lrti_date_1=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        on_or_after='index_date',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_1 = patients.with_these_medications(antibacterials_codes,
        between=['lrti_date_1','lrti_date_1'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    
    lrti_date_2=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        on_or_after='lrti_date_1 + 1 day',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_2= patients.with_these_medications(antibacterials_codes,
        between=['lrti_date_2','lrti_date_2'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),
    
    lrti_date_3=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        on_or_after='lrti_date_2 + 1 day',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_3= patients.with_these_medications(antibacterials_codes,
        between=['lrti_date_3','lrti_date_3'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),

    lrti_date_4=patients.with_these_clinical_events(
        lrti_codes,
        returning='date',
        on_or_after='lrti_date_3 + 1 day',
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD", ## prescribed AB & infection record in same day
        return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
        ),

    lrti_ab_count_4= patients.with_these_medications(antibacterials_codes,
        between=['lrti_date_4','lrti_date_4'],
        returning='number_of_matches_in_period',
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
        ),



)

    
    



# --- DEFINE MEASURES ---

measures = [
    ## antibiotic rx rate
    Measure(id="antibiotics_overall",
            numerator="antibacterial_prescriptions",
            denominator="population",
            group_by=["practice"]
            ),
    
    ## antibiotic count rolling 12m before
    Measure(id="ABs_12mb4",
            numerator="antibacterial_12mb4",
            denominator="population",
            group_by=["practice", "patient_id"]
    ),

    ## Broad spectrum antibiotics
    #Measure(id="broad_spectrum_proportion",
    #        numerator="broad_spectrum_antibiotics_prescriptions",
    #        denominator="antibacterial_prescriptions",
    #        group_by=["practice"]
    #),
    
    ## STRPU antibiotics
    Measure(id="STARPU_antibiotics",
            numerator="antibacterial_prescriptions",
            denominator="population",
            group_by=["practice", "sex", "age_cat"]
            ),

    ## hospitalisation 
    Measure(id="hosp_admission_any",
            numerator="admitted",
            denominator="population",
            group_by=["practice"]
            ),

    ## hospitalisation STARPU
    Measure(id="hosp_admission_STARPU",
            numerator="admitted",
            denominator="population",
            group_by=["practice", "sex", "age_cat"]
            ),
    
    ## UTI event rate 
    Measure(id="UTI_event",
            numerator="uti_counts",
            denominator="population",
            group_by=["practice"]
    ),

    ## LRTI event rate 
    #Measure(id="LRTI_event",
    #        numerator="lrti_counts",
    #        denominator="population",
    #        group_by=["practice"]
    #),

    ## URTI event rate 
    #Measure(id="URTI_event",
    #        numerator="urti_counts",
    #        denominator="population",
    #        group_by=["practice"]
    #),

    ## sinusitis event rate 
    #Measure(id="sinusitis_event",
    #        numerator="sinusitis_counts",
    #        denominator="population",
    #        group_by=["practice"]
    #),

    ## otitis externa event rate 
    #Measure(id="ot_externa_event",
    #        numerator="ot_externa_counts",
    #        denominator="population",
    #        group_by=["practice"]
    # ),

    ## otitis media event rate 
    #Measure(id="otmedia_event",
    #        numerator="otmedia_counts",
    #        denominator="population",
    #        group_by=["practice"]
    # ),

    ## UTI pt propotion 
    Measure(id="UTI_patient",
            numerator="uti_pt",
            denominator="population",
            group_by=["practice"]
    ),

    ## LTI pt propotion 
    #Measure(id="LRTI_patient",
    #        numerator="lrti_pt",
    #        denominator="population",
    #        group_by=["practice"]
    #),

    ## URTI pt propotion 
    #Measure(id="URTI_patient",
    #        numerator="urti_pt",
    #        denominator="population",
    #        group_by=["practice"]
    #),

    ## sinusitis pt propotion 
    #Measure(id="sinusitis_patient",
    #        numerator="sinusitis_pt",
    #        denominator="population",
    #        group_by=["practice"]
    #),

    ## ot_externa pt propotion 
    #Measure(id="ot_externa_patient",
    #        numerator="ot_externa_pt",
    #        denominator="population",
    #        group_by=["practice"]
    #),

    ## otmedia pt propotion 
    #Measure(id="otmedia_patient",
    #        numerator="otmedia_pt",
    #        denominator="population",
    #        group_by=["practice"]
    #),
]
