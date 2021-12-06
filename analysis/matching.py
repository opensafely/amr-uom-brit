from osmatching import match
#The algorithm currently does matching without replacement.
match(
    case_csv="input_covid_admission",
    match_csv="input_covid_infection",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 1, #+- age 1
        "stp": "category",
        "patient_index_date":"month_only"
    },
    closest_match_variables=["age"],
    #replace_match_index_date_with_case="no_offset", #when match general population(no index date)
    index_date_variable="patient_index_date",
    date_exclusion_variables={
        "ons_died_date_": "before",
        "covid_admission_date": "before",
        "icu_date_admitted": "before",
        #"dereg_date": "after",
    },
    output_suffix="_infection&admission",
    output_path="output",
)

match(
    case_csv="input_infection",
    match_csv="input_general_population",
    matches_per_case=2,
    match_variables={
        "sex": "category",
        "age": 1,
        "stp": "category",
    },
    closest_match_variables=["age"],
    replace_match_index_date_with_case="no_offset",
    index_date_variable="indexdate",
    date_exclusion_variables={
       "ons_died_date_": "before",
        "covid_admission_date": "before",
        "icu_date_admitted": "before",
    },
    output_suffix="_infection&control",
    output_path="output",
)