from osmatching import match

match(
    case_csv="input_covid_admission",
    match_csv="input_covid_SGSS",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5, #+/- age 5
        "stp": "category",
        "patient_index_date":"month_only"
    },
    closest_match_variables=["age"],
    #replace_match_index_date_with_case="no_offset", #when match general population(no index date)
    index_date_variable="patient_index_date",
    date_exclusion_variables={
        "ons_died_date_": "before",
        "died_ons_covid_flag_underlying": "before",
        "icu_date_admitted": "before",
    },
    output_suffix="_admission_SGSS",
    output_path="output",
)