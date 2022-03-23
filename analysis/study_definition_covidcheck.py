
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

    
    ## Broad spectrum antibiotics
    broad_spectrum_antibiotics_prescriptions=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=["index_date", "last_day_of_month(index_date)"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 3, "stddev": 1}, "incidence": 0.5}
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

    #Death
    died_date=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "index_date"},  "rate" : "exponential_increase"
        },
    ),

    ## using def from repo: https://github.com/opensafely/comparative-ve-research 
    ## define covid vaccinations 1st, 2nd, 3rd using 3 brands
  ###############################################################################
  # COVID VACCINATION
  ###############################################################################
  
  #################################################################
  ## COVID VACCINATION TYPE = pfizer
  #################################################################
  
  covid_vax_pfizer_1_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 mRNA Vaccine Comirnaty 30micrograms/0.3ml dose conc for susp for inj MDV (Pfizer)",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date_pfizer,  
        "latest": days(start_date_pfizer, 120),
      },
      "incidence": 0.001
    },
  ),
  
  
  covid_vax_pfizer_2_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 mRNA Vaccine Comirnaty 30micrograms/0.3ml dose conc for susp for inj MDV (Pfizer)",
    on_or_after="covid_vax_pfizer_1_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date_pfizer,  
        "latest": days(start_date_pfizer, 120),
      },
      "incidence": 1
    },
  ),
  
  covid_vax_pfizer_3_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 mRNA Vaccine Comirnaty 30micrograms/0.3ml dose conc for susp for inj MDV (Pfizer)",
    on_or_after="covid_vax_pfizer_2_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": "2020-12-29",  # first reported second dose administered on the 29/12
        "latest": "2021-02-01",
      },
      "incidence": 0.2
    },
  ),
  
  
  #################################################################
  ## COVID VACCINATION TYPE = Oxford -AZ
  #################################################################
  
  covid_vax_az_1_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date_az, 
        "latest": days(start_date_az, 120),
      },
      "incidence": 0.001
    },
  ),
  
  
  covid_vax_az_2_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
    on_or_after="covid_vax_az_1_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date_az,  
        "latest": days(start_date_az, 120),
      },
      "incidence": 1
    },
  ),
  
  covid_vax_az_3_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
    on_or_after="covid_vax_az_2_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": "2021-02-01",
        "latest": "2021-03-01",
        "incidence": 0.3
      }
    },
  ),
  
  
  #################################################################
  ## COVID VACCINATION TYPE = moderna
  #################################################################
  covid_vax_moderna_1_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date_moderna, 
        "latest": days(start_date_moderna, 120),
      },
      "incidence": 0.001
    },
  ),
  
  
  covid_vax_moderna_2_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
    on_or_after="covid_vax_moderna_1_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date_moderna, 
        "latest": days(start_date_moderna, 120),
      },
      "incidence": 1
    },
  ),
  
  covid_vax_moderna_3_date=patients.with_tpp_vaccination_record(
    product_name_matches="COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
    on_or_after="covid_vax_moderna_2_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": "2021-02-01",
        "latest": "2021-03-01",
        "incidence": 0.3
      }
    },
  ),
  
  
  #################################################################
  ## COVID VACCINATION TYPE = any based on disease target
  #################################################################
  
  # any prior covid vaccination
  covid_vax_disease_1_date=patients.with_tpp_vaccination_record(
    target_disease_matches="SARS-2 CORONAVIRUS",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date, 
        "latest": days(start_date, 120),
      },
      "incidence": 0.001
    },
  ),
  
  covid_vax_disease_2_date=patients.with_tpp_vaccination_record(
    target_disease_matches="SARS-2 CORONAVIRUS",
    on_or_after="covid_vax_disease_1_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": start_date, 
        "latest": days(start_date, 120),
      },
      "incidence": 1
    },
  ),
  # SECOND DOSE COVID VACCINATION - any type
  covid_vax_disease_3_date=patients.with_tpp_vaccination_record(
    target_disease_matches="SARS-2 CORONAVIRUS",
    on_or_after="covid_vax_disease_2_date + 1 days",
    find_first_match_in_period=True,
    returning="date",
    date_format="YYYY-MM-DD",
    return_expectations={
      "date": {
        "earliest": "2021-02-02",
        "latest": "2021-04-30",
      }
    },
  ),
  
  #################################################################
  ## COVID VACCINATION TYPE = combine brands
  #################################################################
  # any COVID vaccination, combination of az and pfizer
  
  covid_vax_any_1_date=patients.minimum_of(
    "covid_vax_pfizer_1_date", "covid_vax_az_1_date", "covid_vax_moderna_1_date"
  ),
  
  covid_vax_any_2_date=patients.minimum_of(
    "covid_vax_pfizer_2_date", "covid_vax_az_2_date", "covid_vax_moderna_2_date"
  ),
  
  covid_vax_any_3_date=patients.minimum_of(
    "covid_vax_pfizer_3_date", "covid_vax_az_3_date", "covid_vax_moderna_3_date"
  ),
)

# define measures:

measures = [

    
    # ## Broad spectrum antibiotics
    # Measure(id="broad_spectrum_proportion",
    #         numerator="broad_spectrum_antibiotics_prescriptions",
    #         denominator="antibacterial_brit",
    #         group_by=["practice"]
    #         ),

    # ## antibiotic count rolling 12m before
    # Measure(id="ABs_12mb4",
    #         numerator="antibacterial_12mb4",
    #         denominator="population",
    #         group_by=["practice", "patient_id"]
    #         ),

    
       
    ## covid diagnosis same day prescribing
    Measure(id="gp_same_day_pos_ab",
            numerator="gp_covid_ab_prescribed",
            denominator="population",
            group_by=["gp_covid"]
            ),

    Measure(id="Same_day_pos_ab_sgss",
            numerator="sgss_ab_prescribed",
            denominator="population",
            group_by=["Covid_test_result_sgss"]
            ),

    # ## broad_vs_narrow
    # Measure(id="broad_narrow_prescribing",
    #         numerator="broad_spectrum_antibiotics_prescriptions",
    #         denominator="antibacterial_brit",
    #         group_by=["practice","broad_prescriptions_check","age_cat"]
    #         ),    


]
