from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_confounding_variables(index_date_variable):
    confounding_variables  = dict(
         

    ## Demographics
    # #age
    # age=patients.age_as_of(
    #     "patient_index_date",
    #     return_expectations={
    #         "rate": "universal",
    #         "int": {"distribution": "population_ages"},
    #         "incidence": 0.001
    #     },
    # ),

    # Age categories(18-29; 30-39; 40-49; 50-59; 60-69; 70-79; 80+)
    age_cat=patients.categorised_as(
        {
            "0":"DEFAULT",
            "18-29": """ age >= 18 AND age < 30""",
            "30-39": """ age >= 30 AND age < 40""",
            "40-49": """ age >= 40 AND age < 50""",
            "50-59": """ age >= 50 AND age < 60""",
            "60-69": """ age >= 60 AND age < 70""",
            "70-79": """ age >= 70 AND age < 80""",
            "80+": """ age >= 80 AND age < 110""",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0,
                    "18-29": 0.24, 
                    "30-39": 0.21,
                    "40-49": 0.11,
                    "50-59": 0.11,
                    "60-69": 0.11,
                    "70-79": 0.11,
                    "80+": 0.11,
                }
            },
        },
    ),

    
    # #Sex
    # sex=patients.sex(
    #     return_expectations={
    #         "rate": "universal",
    #         "category": {"ratios": {"M": 0.49, "F": 0.51}},
    #     }
    # ),


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

## re-extract ethnicity
    ethnicity=patients.with_ethnicity_from_sus(
        returning="group_6",
        use_most_frequent_code=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),

   # ever hospitalisation
    hospital_counts=patients.admitted_to_hospital(
        returning= "number_of_matches_in_period" ,  
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={"int": {"distribution": "normal",
                                     "mean": 25, "stddev": 5}, "incidence": 1}
   ),

    # Care home
    care_home=patients.with_these_clinical_events(
        carehome_primis_codes,
        on_or_before=f'{index_date_variable}',
        include_date_of_match=True,
        returning="binary_flag",
        return_expectations={"incidence": 0.5},
     ),

        #care_home_type - binary 
    care_home_type=patients.care_home_status_as_of(
        "index_date",
        categorised_as={
            "Yes": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='Y'
              AND LocationRequiresNursing='N'
            """,
            "Yes": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='N'
              AND LocationRequiresNursing='Y'
            """,
            "Yes": "IsPotentialCareHome",
            "No": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"Yes": 0.30, "No": 0.70},},
        },
    ), 

    # index of multiple deprivation, estimate of SES based on patient post code 
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
            f'{index_date_variable}',
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

    ##REGION
    # Practice
    practice=patients.registered_practice_as_of(
        f'{index_date_variable}',
        returning="pseudo_id",
        return_expectations={"int": {"distribution": "normal",
                                     "mean": 25, "stddev": 5}, "incidence": 1}
    ), 
    
    # stp=patients.registered_practice_as_of(
    #         f'{index_date_variable}',
    #         returning="stp_code",
    #         return_expectations={
    #             "rate": "universal",
    #             "category": {
    #                 "ratios": {
    #                     "STP1": 0.1,
    #                     "STP2": 0.1,
    #                     "STP3": 0.1,
    #                     "STP4": 0.1,
    #                     "STP5": 0.1,
    #                     "STP6": 0.1,
    #                     "STP7": 0.1,
    #                     "STP8": 0.1,
    #                     "STP9": 0.1,
    #                     "STP10": 0.1,
    #                 }
    #             },
    #         },
    # ),

    # Region - NHS England 9 regions
    region=patients.registered_practice_as_of(
        f'{index_date_variable}',
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
    
    # # middle layer super output area (msoa) - nhs administrative region 
    # msoa=patients.registered_practice_as_of(
    #     f'{index_date_variable}',
    #     returning="msoa_code",
    #     return_expectations={
    #         "rate": "universal",
    #         "category": {"ratios": {"E02000001": 0.5, "E02000002": 0.5}},
    #     },
    # ), 
    
    

    # LIFESTYLE
    ## BMI, most recent
    bmi=patients.most_recent_bmi(
        between=[f'{index_date_variable}- 5 years', f'{index_date_variable}'],
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2010-02-01", "latest": "today"},
            "float": {"distribution": "normal", "mean": 28, "stddev": 8},
            "incidence": 0.80,
        },
    ),

    #smoking https://github.com/ebmdatalab/tpp-sql-notebook/issues/6
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
            on_or_before=f'{index_date_variable}',
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before=f'{index_date_variable}',
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before=f'{index_date_variable}',
        return_last_date_in_period=True,
        include_month=True,
    ),
    most_recent_unclear_smoking_cat_date=patients.with_these_clinical_events(
        unclear_smoking_codes,
        on_or_before=f'{index_date_variable}',
        return_last_date_in_period=True,
        include_month=True,
    ),

    # MEDICATION
    ### Flu vaccine
    ## flu vaccine in tpp
    flu_vaccine_tpp=patients.with_tpp_vaccination_record(
        target_disease_matches="influenza",
        between=[f'{index_date_variable}-12 months', f'{index_date_variable}'],
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "index_date - 6 months", "latest": "index_date"}
        }
    ),

    ### flu vaccine 
    ## flu vaccine entered as a medication 
    flu_vaccine_med=patients.with_these_medications(
        flu_med_codes,
        between=[f'{index_date_variable}- 12 months', f'{index_date_variable}'],  
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
        between=[f'{index_date_variable}- 12 months', f'{index_date_variable}'],  
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



    ### First COVID vaccination medication code (any)
    covrx1_dat=patients.with_tpp_vaccination_record(
        returning="date",
        
        # product_name_matches=
        #         "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        #         "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        #         "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
        target_disease_matches="SARS-2 CORONAVIRUS",
        # emis={
        #     "product_codes": covrx_code,
        # },
        # find_first_match_in_period=True,
        on_or_before=f'{index_date_variable}',
        on_or_after="2020-11-29",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase",
            "incidence": 0.5,
        }
    ),

    # Second COVID vaccination medication code (any)
    covrx2_dat=patients.with_tpp_vaccination_record(
        returning="date",
     #   tpp={
        # product_name_matches=
        #         "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        #         "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        #         "COVID-19 mRNA (nucleoside modified) Vaccine Moderna 0.1mg/0.5mL dose dispersion for inj MDV",
        target_disease_matches="SARS-2 CORONAVIRUS",
   #     },
        # emis={
        #     "product_codes": covrx_code,
        # },
        find_last_match_in_period=True,
        on_or_before=f'{index_date_variable}',
        on_or_after="covrx1_dat + 19 days",
        date_format="YYYY-MM-DD",
        return_expectations={
            "rate": "exponential_increase",
            "incidence": 0.5,
        }
    ),



  )
    return confounding_variables