from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_comobidities_variables(index_date_variable):
    comobidities_variables  = dict(
             
    
    # COMOBIDDITIES https://github.com/opensafely/ethnicity-covid-research/blob/main/analysis/study_definition.py
   ## Blood pressure
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        between=["index_date- 3 years", "index_date"],
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 10},
            "date": {"earliest": "2019-02-01", "latest": "2020-01-31"},
            "incidence": 0.95,
        },
    ),

    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        between=["index_date- 3 years", "index_date"],
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 120, "stddev": 10},
            "date": {"earliest": "2019-02-01", "latest": "2020-01-31"},
            "incidence": 0.95,
        },
    ),

    ## HBA1C
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        between=["index_date- 3 years", "index_date"],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-02-01", "latest": "2020-01-31"},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),

    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        between=["index_date- 3 years", "index_date"],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-02-01", "latest": "2020-01-31"},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),

    # # Creatinine
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        between=["index_date- 3 years", "index_date"],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
            "date": {"earliest": "index_date - 3 years", "latest": "index_date"},
            "incidence": 0.95,
        },
    ),

    # COVARIATES EVER
    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    
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
        return_expectations={"category": {"ratios": {"0": 0.8, "1": 0.1, "2": 0.1}},},
        recent_asthma_code=patients.with_these_clinical_events(
            asthma_codes, between=["index_date- 3 years", "index_date"],
        ),
        asthma_code_ever=patients.with_these_clinical_events(asthma_codes),
        copd_code_ever=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes
        ),
        prednisolone_last_year=patients.with_these_medications(
            pred_codes,
            between=["index_date- 3 years", "index_date"],
            returning="number_of_matches_in_period",
        ),
    ),
    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    type1_diabetes=patients.with_these_clinical_events(
        diabetes_t1_codes,
        on_or_before="index_date",
        return_first_date_in_period=True,
        include_month=True,
    ),
    type2_diabetes=patients.with_these_clinical_events(
        diabetes_t2_codes,
        on_or_before="index_date",
        return_first_date_in_period=True,
        include_month=True,
    ),
    unknown_diabetes=patients.with_these_clinical_events(
        diabetes_unknown_codes,
        on_or_before="index_date",
        return_first_date_in_period=True,
        include_month=True,
    ),

 
     diabetes_type=patients.categorised_as(
        {
            "T1DM":
                """
                        (type1_diabetes AND NOT
                        type2_diabetes) 
                    OR
                        (((type1_diabetes AND type2_diabetes) OR 
                        (type1_diabetes AND unknown_diabetes AND NOT type2_diabetes) OR
                        (unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes))
                        AND 
                        (insulin_lastyear_meds > 0 AND NOT
                        oad_lastyear_meds > 0))
                """,
            "T2DM":
                """
                        (type2_diabetes AND NOT
                        type1_diabetes)
                    OR
                        (((type1_diabetes AND type2_diabetes) OR 
                        (type2_diabetes AND unknown_diabetes AND NOT type1_diabetes) OR
                        (unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes))
                        AND 
                        (oad_lastyear_meds > 0))
                """,
            "UNKNOWN_DM":
                """
                        ((unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes) AND NOT
                        oad_lastyear_meds AND NOT
                        insulin_lastyear_meds) 
                   
                """,
            "NO_DM": "DEFAULT",
        },

        return_expectations={
            "category": {"ratios": {"T1DM": 0.03, "T2DM": 0.2, "UNKNOWN_DM": 0.02, "NO_DM": 0.75}},
            "rate" : "universal"

        },

 
        oad_lastyear_meds=patients.with_these_medications(
            oad_med_codes, 
            between=["index_date- 3 years", "index_date"],
            returning="number_of_matches_in_period",
        ),
        insulin_lastyear_meds=patients.with_these_medications(
            insulin_med_codes,
            between=["index_date- 3 years", "index_date"],
            returning="number_of_matches_in_period",
        ),
    ),

   


    # CANCER - 3 TYPES
    cancer=patients.with_these_clinical_events(
        combine_codelists(lung_cancer_codes,
                          haem_cancer_codes,
                          other_cancer_codes),
        return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    #### PERMANENT
    permanent_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(hiv_codes,
                          permanent_immune_codes,
                          sickle_cell_codes,
                          organ_transplant_codes,
                          spleen_codes)
        ,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    ### TEMPROARY IMMUNE
    temporary_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(aplastic_codes,
                temp_immune_codes),
        between=["2019-03-01", "2020-02-29"], ## THIS IS RESTRICTED TO LAST YEAR
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "index_date-1 years", "latest": "index_date"}
        },
    ),

    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    other_neuro=patients.with_these_clinical_events(
        other_neuro, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    stroke=patients.with_these_clinical_events(
        stroke, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    dementia=patients.with_these_clinical_events(
        dementia, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "index_date"}},
    ),

    # END STAGE RENAL DISEASE - DIALYSIS, TRANSPLANT OR END STAGE RENAL DISEASE
    esrf=patients.with_these_clinical_events(
        dialysis_codes, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-01-31"}},
    ),

    # hypertension
    hypertension=patients.with_these_clinical_events(
        hypertension_codes, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest":"index_date"}},
    ),


    ra_sle_psoriasis=patients.with_these_clinical_events(
        ra_sle_psoriasis_codes, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "index_date"}},

    ),


     # MEDICATION COVARIATES IN THE LAST 12 MONTHS
    ace_inhibitors=patients.with_these_medications(
        ace_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    alpha_blockers=patients.with_these_medications(
        alpha_blocker_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    arbs=patients.with_these_medications(
        arb_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    betablockers=patients.with_these_medications(
        betablocker_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    calcium_channel_blockers=patients.with_these_medications(
        calcium_channel_blockers_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    combination_bp_meds=patients.with_these_medications(
        combination_bp_med_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    spironolactone=patients.with_these_medications(
        spironolactone_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    thiazide_diuretics=patients.with_these_medications(
        thiazide_type_diuretic_codes,
        between=["index_date - 1 years", "index_date"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),
    
    ### INSULIN USE
    insulin=patients.with_these_medications(
        insulin_med_codes,
        between=["index_date - 1 years", "index_date"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-02-01", "latest": "2020-01-31"}
        },
    ),
    ### STATIN USE
    statin=patients.with_these_medications(
        statin_med_codes,
        between=["index_date - 1 years", "index_date"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-02-01", "latest": "2020-01-31"}
        },
    ),

  )
    return comobidities_variables