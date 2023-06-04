###################################################################

## This script is to extract the controls pre covid    2019-1    ##

###################################################################

#### This script is to extract the variable in controls ####

from cohortextractor import (
    StudyDefinition,
    patients,
    #codelist_from_csv,
    codelist,
    filter_codes_by_category,
    #combine_codelists,
    Measure
)

###### import matched cohort
COHORT = "output/matched_matches_4_lrti.csv"

###### Code lists
from codelists import *

###### Define study time variables
from datetime import datetime
start_date = "2020-07-01"
end_date = "2020-12-31"


study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.1,
    },

    # Set index date to start date
    index_date=start_date,
   
    # study population
    population=patients.which_exist_in_file(COHORT),

    ### patient index date  
    # case_infection_date
    patient_index_date=patients.with_value_from_file(
        COHORT,
        returning="patient_index_date",
        returning_type="date",
    ),
    # DEMOGRAPHICS
    # age
    age=patients.age_as_of(
        "patient_index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    # age group (used for descriptives)
    agegroup=patients.categorised_as(
        {
            "<18": "age < 18",
            "18-39": "age >= 18 AND age < 40",
            "40-49": "age >= 40 AND age < 50",
            "50-59": "age >= 50 AND age < 60",
            "60-69": "age >= 60 AND age < 70",
            "70-79": "age >= 70 AND age < 80",
            "80+": "age >= 80",
            "missing": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "<18": 0.07,
                    "18-39": 0.10,
                    "40-49": 0.17,
                    "50-59": 0.17,
                    "60-69": 0.17,
                    "70-79": 0.17,
                    "80+": 0.15,
                    "missing": 0,
                }
            },
        },
    ),
    # sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    # Region - NHS England 9 regions
    region=patients.registered_practice_as_of(
        "patient_index_date",
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
            "patient_index_date",
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

        # ETHNICITY IN 6 CATEGORIES
    eth=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
        include_date_of_match=False,
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "1": 0.2,
                                        "2": 0.2,
                                        "3": 0.2,
                                        "4": 0.2,
                                        "5": 0.2
                                        }
                                    },
                                "incidence": 0.75,
                                },
    ),

    # fill missing ethnicity from SUS
    ethnicity_sus=patients.with_ethnicity_from_sus(
        returning="group_6",
        use_most_frequent_code=True,
        return_expectations={
            "category": {
                            "ratios": {
                                "1": 0.2,
                                "2": 0.2,
                                "3": 0.2,
                                "4": 0.2,
                                "5": 0.2
                                }
                            },
            "incidence": 0.4,
            },
    ),

    ethnicity=patients.categorised_as(
            {
                "0": "DEFAULT",
                "1": "eth='1' OR (NOT eth AND ethnicity_sus='1')",
                "2": "eth='2' OR (NOT eth AND ethnicity_sus='2')",
                "3": "eth='3' OR (NOT eth AND ethnicity_sus='3')",
                "4": "eth='4' OR (NOT eth AND ethnicity_sus='4')",
                "5": "eth='5' OR (NOT eth AND ethnicity_sus='5')",
            },
            return_expectations={
                "category": {
                                "ratios": {
                                    "0": 0.5,  # missing in 50%
                                    "1": 0.1,
                                    "2": 0.1,
                                    "3": 0.1,
                                    "4": 0.1,
                                    "5": 0.1
                                    }
                                },
                "rate": "universal",
            },
    ),

    # BMI & further outcome
    ### CLINICAL MEASUREMENTS
    # BMI
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/10
    bmi_value=patients.most_recent_bmi(
        on_or_after="patient_index_date - 5 years",
        minimum_age_at_measurement=16,
        return_expectations={
            "date": {"latest": "index_date"},
            "float": {"distribution": "normal", "mean": 25.0, "stddev": 7.5},
            "incidence": 0.8,
        },
    ),
    bmi=patients.categorised_as(
        {
            "Underweight (<18.5)": """ bmi_value < 18.5 AND bmi_value > 12""",
            "Healthy range (18.5-24.9)": """ bmi_value >= 1.5 AND bmi_value < 25""",
            "Overweight (25-29.9)": """ bmi_value >= 25 AND bmi_value < 30""",
            "Obese I (30-34.9)": """ bmi_value >= 30 AND bmi_value < 35""",
            "Obese II (35-39.9)": """ bmi_value >= 35 AND bmi_value < 40""",
            "Obese III (40+)": """ bmi_value >= 40 AND bmi_value < 100""",
            "Missing": "DEFAULT", 
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Underweight (<18.5)": 0.1,
                    "Healthy range (18.5-24.9)": 0.3,
                    "Overweight (25-29.9)":0.3,
                    "Obese I (30-34.9)": 0.1,
                    "Obese II (35-39.9)": 0.1,
                    "Obese III (40+)": 0.1,
                }
            },
        },
    ),

    # smoking status
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
            "rate": "universal",
            "category": {
                "ratios": {
                    "S": 0.6,
                    "E": 0.1,
                    "N": 0.2,
                    "M": 0.1,
                }
            },
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="patient_index_date",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="patient_index_date",
        ),
    ),
    # smoking status (combining never and missing)
    smoking_status_comb=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (
                       most_recent_smoking_code = 'N' AND ever_smoked
                    )
                """,
            "N + M": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N + M": 0.3}, }
        },
    ),
    # COMORBIDITIES
    # Diagnosed hypertension
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Respiratory disease ex asthma
    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Asthma
    asthma=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                (
                  recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                  )
                ) AND (
                  prednisolone_last_year = 0 OR
                  prednisolone_last_year > 4
                )
            """,
            "2": """
                (
                  recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                  )
                ) AND
                prednisolone_last_year > 0 AND
                prednisolone_last_year < 5
            """,
        },
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "0": 0.8,
                                        "1": 0.1,
                                        "2": 0.1
                                        }
                                    },
                                },
        recent_asthma_code=patients.with_these_clinical_events(
            asthma_codes,  # imported from codelists.py
            between=["patient_index_date - 3 years", "patient_index_date"],
        ),
        asthma_code_ever=patients.with_these_clinical_events(
            asthma_codes,  # imported from codelists.py
        ),
        copd_code_ever=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes,  # imported from codelists.py
        ),
        prednisolone_last_year=patients.with_these_medications(
            pred_codes,  # imported from codelists.py
            between=["patient_index_date - 1 year", "patient_index_date"],
            returning="number_of_matches_in_period",
        ),
    ),

    # Blood pressure
    # filtering on >0 as missing values are returned as 0
    bp=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                    (bp_sys > 0 AND bp_sys < 120) AND
                        (bp_dia > 0 AND bp_dia < 80)
            """,
            "2": """
                    ((bp_sys >= 120 AND bp_sys < 130) AND
                        (bp_dia > 0 AND bp_dia < 80)) OR
                    ((bp_sys >= 130) OR
                        (bp_dia >= 80))
            """,
        },
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "0": 0.8,
                                        "1": 0.1,
                                        "2": 0.1
                                        }
                                    },
                                },
        bp_sys=patients.mean_recorded_value(
            systolic_blood_pressure_codes,
            on_most_recent_day_of_measurement=True,
            on_or_before="patient_index_date",
            include_measurement_date=True,
            include_month=True,
            return_expectations={
                "incidence": 0.6,
                "float": {"distribution": "normal", "mean": 80, "stddev": 10},
            },
        ),
        bp_dia=patients.mean_recorded_value(
            diastolic_blood_pressure_codes,
            on_most_recent_day_of_measurement=True,
            on_or_before="patient_index_date",
            include_measurement_date=True,
            include_month=True,
            return_expectations={
                "incidence": 0.6,
                "float": {"distribution": "normal", "mean": 120, "stddev": 10},
            },
        ),
    ),
    # Chronic heart disease
    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Diabetes
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # variable indicating whether patient has had a recent test yes/no
    hba1c_flag=patients.with_these_clinical_events(
        combine_codelists(
            hba1c_new_codes,
            hba1c_old_codes
        ),
        returning="binary_flag",
        between=["patient_index_date - 15 months", "patient_index_date"],
        find_last_match_in_period=True,
        return_expectations={
            "incidence": 0.95,
        },
    ),
    # hba1c value in mmol/mol of recent test
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,  # imported from codelists.py
        returning="numeric_value",
        between=["patient_index_date - 15 months", "patient_index_date"],
        find_last_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM",
        return_expectations={
            "date": {"latest": "index_date"},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),
    # hba1c value in % of recent test
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,  # imported from codelists.py
        returning="numeric_value",
        between=["patient_index_date - 15 months", "patient_index_date"],
        find_last_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM",
        return_expectations={
            "date": {"latest": "index_date"},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),
    # Subcategorise recent hba1c measures in no recent measure (0); measure
    # indicating controlled diabetes (1);
    # measure indicating uncontrolled diabetes (2)
    hba1c_category=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                hba1c_flag AND (hba1c_mmol_per_mol < 58 OR
                hba1c_percentage < 7.5)
            """,
            "2": """
                hba1c_flag AND (hba1c_mmol_per_mol >= 58 OR
                hba1c_percentage >= 7.5)
            """,
        },
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "0": 0.2,
                                        "1": 0.4,
                                        "2": 0.4
                                        }
                                    },
                                },
    ),
    # Subcategorise diabetes in no diabetes (0); controlled diabetes (1);
    # uncontrolled diabetes (2);
    # diabetes with missing recent hba1c measure (3)
    diabetes_controlled=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                diabetes AND hba1c_category = "1"
                """,
            "2": """
                diabetes AND hba1c_category = "2"
                """,
            "3": """
                diabetes AND hba1c_category = "0"
                """
        }, return_expectations={
                                "category": {
                                    "ratios": {
                                        "0": 0.8,
                                        "1": 0.09,
                                        "2": 0.09,
                                        "3": 0.02
                                        }
                                    },
                                },
    ),
    # Cancer
    cancer=patients.with_these_clinical_events(
        combine_codelists(
            lung_cancer_codes,
            other_cancer_codes
        ),
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
    ),
    # Haematological malignancy
    haem_cancer=patients.with_these_clinical_events(
        haem_cancer_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
    ),
    # Dialysis
    dialysis=patients.with_these_clinical_events(
        dialysis_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
        include_date_of_match=True,  # generates dialysis_date
        date_format="YYYY-MM-DD",
    ),
    # Kidney transplant
    kidney_transplant=patients.with_these_clinical_events(
        kidney_transplant_codes,
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
        include_date_of_match=True,  # generates kidney_transplant_date
        date_format="YYYY-MM-DD",
    ),
    # Categorise dialysis or kidney transplant
    # ref for logic:
    # https://docs.google.com/document/d/1hi_lMyuAa23u1xXLULLMdAiymiPopPZrAtQCDzYtjtE/edit
    # 0: no rrt
    # 1: rrt (dialysis)
    # 2: rrt (kidney transplant)
    rrt_cat=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                (dialysis AND NOT kidney_transplant) OR
                ((dialysis AND kidney_transplant) AND
                dialysis_date > kidney_transplant_date)
            """,
            "2": """
                (kidney_transplant AND NOT dialysis) OR
                ((kidney_transplant AND dialysis) AND
                kidney_transplant_date >= dialysis_date)
            """,
        },
        return_expectations={
            "category": {"ratios": {"0": 0.8, "1": 0.1, "2": 0.1}},
            "incidence": 1.0,
        },
    ),
    # CKD DEFINITIONS -
    # adapted from https://github.com/opensafely/risk-factors-research
    # Creatinine level for eGFR calculation
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/17
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        between=["patient_index_date - 2 years", "patient_index_date - 1 day"],
        returning="numeric_value",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "float": {"distribution": "normal", "mean": 90, "stddev": 30},
            "incidence": 0.95,
            },
    ),
    # Extract any operators associated with creatinine readings
    creatinine_operator=patients.comparator_from(
        "creatinine",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    None: 0.10,
                    "~": 0.05,
                    "=": 0.65,
                    ">=": 0.05,
                    ">": 0.05,
                    "<": 0.05,
                    "<=": 0.05,
                }
            },
            "incidence": 0.80,
        },
    ),
    # Age at creatinine test
    creatinine_age=patients.age_as_of(
        "creatinine_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    # Liver disease
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Stroke
    stroke=patients.with_these_clinical_events(
        stroke,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Dementia
    dementia=patients.with_these_clinical_events(
        dementia,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Other neurological disease
    other_neuro=patients.with_these_clinical_events(
        other_neuro,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Other organ transplant (excluding kidney transplants)
    other_organ_transplant=patients.with_these_clinical_events(
        other_organ_transplant_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Organ or kidney transplant
    organ_kidney_transplant=patients.categorised_as(
        {
            "No transplant": "DEFAULT",
            "Kidney": """
                kidney_transplant
            """,
            "Organ": """
                other_organ_transplant AND NOT kidney_transplant
            """,
        },
        return_expectations={
                                "category": {
                                    "ratios": {
                                        "No transplant": 0.95,
                                        "Kidney": 0.025,
                                        "Organ": 0.025
                                        }
                                    },
                                },
    ),
    # Asplenia (splenectomy or a spleen dysfunction, including sickle cell
    # disease)
    asplenia=patients.with_these_clinical_events(
        combine_codelists(
            sickle_cell_codes,
            spleen_codes
         ),  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Rheumatoid/Lupus/Psoriasis
    ra_sle_psoriasis=patients.with_these_clinical_events(
        ra_sle_psoriasis_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Immunosuppressive condition
    immunosuppression=patients.with_these_clinical_events(
        combine_codelists(
            immunosuppression_medication_codes,
            immunosupression_diagnosis_codes
        ),  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Learning disabilities
    learning_disability=patients.with_these_clinical_events(
        learning_disability_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),
    # Severe mental illness
    sev_mental_ill=patients.with_these_clinical_events(
        sev_mental_ill_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),

    # Alcohol problems
    alcohol_problems=patients.with_these_clinical_events(
        hazardous_alcohol_codes,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="patient_index_date",
        find_last_match_in_period=True,
    ),

    # CAREHOME STATUS
    care_home_type=patients.care_home_status_as_of(
        "2020-02-01",
        categorised_as={
            "PC": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='Y'
              AND LocationRequiresNursing='N'
            """,
            "PN": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='N'
              AND LocationRequiresNursing='Y'
            """,
            "PS": "IsPotentialCareHome",
            "U": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "PC": 0.05,
                    "PN": 0.05,
                    "PS": 0.05,
                    "U": 0.85,
                },
            },
        },
    ),
    # HOUSEHOLD INFORMATION
    household_id=patients.household_as_of(
        "2020-02-01",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 500, "stddev": 500},
            "incidence": 1,
        },
    ),
    household_size=patients.household_as_of(
        "2020-02-01",
        returning="household_size",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
    ),
 ) 