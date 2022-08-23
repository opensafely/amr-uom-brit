
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

from codelists import *


#from codelists import antibacterials_codes, broad_spectrum_antibiotics_codes, uti_codes, lrti_codes, ethnicity_codes, bmi_codes, any_primary_care_code, clear_smoking_codes, unclear_smoking_codes, flu_med_codes, flu_clinical_given_codes, flu_clinical_not_given_codes, covrx_code, hospitalisation_infection_related #, any_lrti_urti_uti_hospitalisation_codes#, flu_vaccine_codes

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
        between=["2015-01-01", "index_date"],
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2015-01-01", "latest": "index_date"},
            "float": {"distribution": "normal", "mean": 27, "stddev": 6},
            "incidence": 0.70,
        },
    ),

    # # self-reported ethnicity 
    # ethnicity=patients.with_these_clinical_events(
    #     ethnicity_codes,
    #     returning="category",
    #     find_last_match_in_period=True,
    #     include_date_of_match=False,
    #     return_expectations={
    #         "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
    #         "incidence": 0.75,
    #     },
    # ),

    ethnicity=patients.with_ethnicity_from_sus(
    returning="group_6",
    use_most_frequent_code=True,
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
            on_or_before="index_date",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="index_date",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="index_date",
        return_last_date_in_period=True,
        include_month=True,
    ),
    most_recent_unclear_smoking_cat_date=patients.with_these_clinical_events(
        unclear_smoking_codes,
        on_or_before="index_date",
        return_last_date_in_period=True,
        include_month=True,
    ),

    ## GP consultations
    gp_count=patients.with_gp_consultations(
        between=["index_date - 12 months", "index_date"],
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

    ### Antibiotics from opensafely antimicrobial-stewardship repo
    # ## all antibacterials 
    # antibacterial_prescriptions=patients.with_these_medications(
    #     antibacterials_codes,
    #     between=["index_date", "last_day_of_month(index_date)"],
    #     returning="number_of_matches_in_period",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 3, "stddev": 1},
    #         "incidence": 0.5,
    #     },
    # ),

    # antibacterial_prescriptions_date=patients.with_these_medications(
    #     antibacterials_codes,
    #     between=["index_date", "last_day_of_month(index_date)"],
    #     returning="date",
    #     date_format="YYYY-MM-DD",
    #     return_expectations={"date": {"index_date": "last_day_of_month(index_date)"}},
    #     ),


    ## all antibacterials from BRIT (dmd codes)
    antibacterial_brit=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
    ),

    ### Antibiotics - TYPE
    antibacterial_brit_abtype=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="category",
        return_expectations={
            "category": {"ratios": {"Amikacin":0.05, "Amoxicillin":0.1, "Azithromycin":0.04, "Cefaclor":0.05,
            "Co-amoxiclav":0.05, "Co-fluampicil":0.05, "Metronidazole":0.05, "Nitrofurantoin":0.05,
            "Norfloxacin":0.05, "Trimethoprim":0.05, "Linezolid":0.05, "Doxycycline":0.05,
            "Lymecycline":0.05, "Levofloxacin":0.05, "Clarithromycin":0.03, "Cefamandole":0.05, 
            "Gentamicin":0.05, "Ceftazidime":0.05, "Fosfomycin":0.03, "Flucloxacillin":0.05}},
            "incidence": 0.99,
        },
    ),

    ## all antibacterials 12m before
    antibacterial_12mb4=patients.with_these_medications(
        antibacterials_codes_brit,
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
            "int": {"distribution": "poisson", "mean": 3, "stddev": 1}, "incidence": 0.5}
    ),

    broad_prescriptions_check=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.3,},
    ),
    

    ## Covid positive test result
    ## Positive covid test_sgss
    Covid_test_result_sgss=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        returning='binary_flag',
        return_expectations={
            "incidence": 0.5},
    ),

    ## positive date_sgss
    first_positive_test_date_sgss=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        returning='date',
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "index_date"},
                             "rate": "exponential_increase",
                             "incidence":0.5},
    ),

    ## number of posstive test patients
    covid_positive_count_sgss=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning='number_of_matches_in_period',
        restrict_to_earliest_specimen_date = False,
        return_expectations={
            "int": {"distribution":"normal","mean":10,"stddev":1},"incidence":0.5},
    ),        

    ## Same day antibiotic prescribed binary

    sgss_ab_prescribed=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["first_positive_test_date_sgss - 2 days","first_positive_test_date_sgss + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.3,},
    ),

    ## Covid diagnosis record by primary care (gp)

    gp_covid=patients.with_these_clinical_events(
        any_primary_care_code,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.5},
    ),

    gp_covid_date=patients.with_these_clinical_events(
        any_primary_care_code,
        returning="date",
        between=["index_date", "last_day_of_month(index_date)"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date":{"earliest":start_date},
                             "rate": "exponential_increase",
                             "incidence": 0.5},
    ),

    gp_covid_count=patients.with_these_clinical_events(
        any_primary_care_code,
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution":"normal","mean":10,"stddev":1},"incidence":0.5},
    ),   

    gp_covid_ab_prescribed=patients.with_these_medications(
        antibacterials_codes_brit,
        between=["gp_covid_date - 2 days","gp_covid_date + 2 days"],
        returning="binary_flag",
        return_expectations={"incidence":0.3,},
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
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase", "date":{"earliest":"2020-11-29"},
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
        on_or_after="covrx1_dat + 19 days",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase", 
            "incidence": 0.5,
        }
    ),

    # ## hospitalisation
    # admitted=patients.admitted_to_hospital(
    #     returning="binary_flag",
    #     #returning="date_admitted",
    #     #date_format="YYYY-MM-DD",
    #     between=["index_date", "today"],
    #     return_expectations={"incidence": 0.1},
    # ),

    ## hospitalisation with diagnosis of lrti, urti, or uti
    #admitted_date=patients.admitted_to_hospital(
    #    with_these_diagnoses=any_lrti_urti_uti_hospitalisation_codes,
    #    returning="date_admitted",
    #    date_format="YYYY-MM-DD",
    #    find_first_match_in_period=True,
    #    return_expectations={"incidence": 0.3},
    #),
    
    ## hospitalised because of covid diagnosis
    #hospital_covid=patients.admitted_to_hospital(
    #    with_these_diagnoses=covid_codes,
    #    returning="date_admitted",
    #    date_format="YYYY-MM-DD",
    #    find_first_match_in_period=True,
    #    return_expectations={"incidence": 0.1, "date": {"earliest": "index_date"}},
    #),

    # ## Infaction Hospitalisation records
    # hospitalisation_infec = patients.with_these_clinical_events(
    #     hospitalisation_infection_related,
    #     between=["index_date - 12 months", "index_date"],
    #     returning="date",
    #     find_first_match_in_period=True,
    #     return_expectations={"date": {"earliest": "index_date", "latest": "today"}},
    # ),

    ## Death
    died_date=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},  "rate" : "exponential_increase"
        },
    ),

  ########## number of infection cousultations #############
    
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

    ########## identify incidenct case (without same infection in prior 6 weeks)#############
    ## incdt=0 incident case  
    #  --UTI 
    incdt_uti_pt=patients.with_these_clinical_events(
        uti_codes,
        returning="binary_flag",
        between=["first_day_of_month(index_date) - 42 days", "first_day_of_month(index_date)"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),
    #  --LRTI 
    incdt_lrti_pt=patients.with_these_clinical_events(
        lrti_codes,
        returning="binary_flag",
        between=["first_day_of_month(index_date) - 42 days", "first_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --URTI  
    incdt_urti_pt=patients.with_these_clinical_events(
        urti_codes,
        returning="binary_flag",
        between=["first_day_of_month(index_date) - 42 days", "first_day_of_month(index_date)"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),

    #  --sinusitis 
    incdt_sinusitis_pt=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="binary_flag",
        between=["first_day_of_month(index_date) - 42 days", "first_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    incdt_ot_externa_pt=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="binary_flag",
        between=["first_day_of_month(index_date) - 42 days", "first_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    incdt_otmedia_pt=patients.with_these_clinical_events(
        otmedia_codes,
        returning="binary_flag",
        between=["first_day_of_month(index_date) - 42 days", "first_day_of_month(index_date)"],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    ########## any infection or any AB records in prior 1 month (incident/prevelent prescribing)#############
    ## 0=incident case  / 1=prevelent
    # 
    hx_indications=patients.with_these_clinical_events(
        all_indication_codes,
        returning="binary_flag",
        between=["first_day_of_month(index_date) - 1 month", "index_date"],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "first_day_of_month(index_date) - 42 days"}}
    ),
    
    hx_antibiotics= patients.with_these_medications(
        antibacterials_codes_brit,
        between=["first_day_of_month(index_date) - 1 month", "index_date"],
        returning='binary_flag',
        return_expectations={"incidence": 0.1, "date": {"earliest": start_date}},
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

# --- DEFINE MEASURES ---


measures = [

    # antibiotic rx rate
    Measure(id="antibiotics_overall",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice"]
            ),
    
    ## Antibiotic Rx rate by TyPE
    Measure(id="antibiotics_overall_brit_abtype",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["antibacterial_brit_abtype"]
            ),

    ## Broad spectrum antibiotics
    Measure(id="broad_spectrum_proportion",
            numerator="broad_spectrum_antibiotics_prescriptions",
            denominator="antibacterial_brit",
            group_by=["practice"]
            ),

    # ## antibiotic count rolling 12m before
    # Measure(id="ABs_12mb4",
    #         numerator="antibacterial_12mb4",
    #         denominator="population",
    #         group_by=["practice", "patient_id"]
    #         ),

    
    # STRPU antibiotics
    Measure(id="STARPU_antibiotics",
            numerator="antibacterial_brit",
            denominator="population",
            group_by=["practice", "sex", "age_cat"]
            ),

    # ## STRPU broad_spectrum
    # Measure(id="STARPU_broad_spectrum",
    #         numerator="broad_spectrum_antibiotics_prescriptions",
    #         denominator="population",
    #         group_by=["practice", "sex", "age_cat"]
    #         ),

    # ## hospitalisation 
    # Measure(id="hosp_admission_infection",
    #         numerator="hospitalisation_infec",
    #         denominator="population",
    #         group_by=["practice"]
    #         ),

    # # ## hospitalisation STARPU
    # # Measure(id="hosp_admission_STARPU",
    # #         numerator="admitted",
    # #         denominator="population",
    # #         group_by=["practice", "sex", "age_cat"]
    # #         ),
    
    # ## repeat prescribing
    # Measure(id="repeat_antibiotics",
    #         numerator="antibacterial_brit",
    #         denominator="population",
    #         group_by=["practice", "hx_antibiotics", "sex", "age_cat"]
    #         ),
    
    ## covid diagnosis same day prescribing
    # Measure(id="gp_same_day_pos_ab",
    #         numerator="gp_covid_ab_prescribed",
    #         denominator="population",
    #         group_by=["gp_covid"]
    #         ),

    # Measure(id="Same_day_pos_ab_sgss",
    #         numerator="sgss_ab_prescribed",
    #         denominator="population",
    #         group_by=["Covid_test_result_sgss"]
    #         ),

    # ## broad_vs_narrow
    # Measure(id="broad_narrow_prescribing",
    #         numerator="broad_spectrum_antibiotics_prescriptions",
    #         denominator="antibacterial_brit",
    #         group_by=["practice","broad_prescriptions_check","age_cat"]
    #         ),    


]
