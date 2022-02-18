from osmatching import match
#The algorithm currently does matching without replacement.

#### general population & covid infection(case) 
match(
    case_csv="covid_infection_1_4",
    match_csv="general_population_1_4",
    matches_per_case=6,
    match_variables={
     #   "sex": "category",
        "age": 5, #+- 5 years old
     #   "stp": "category",
    },
    closest_match_variables=["age"],
    index_date_variable="patient_index_date",
    replace_match_index_date_with_case="no_offset",
    date_exclusion_variables={
        "dereg_date": "before",
        "ons_died_date": "before",
        "SGSS_positive_test_date": "before",
        "primary_care_covid_date": "before",
        "covid_admission_date": "before",
        #"icu_date_admitted": "before",
        "died_date_cpns": "before",
        "died_date_ons_covid": "before",
    },
    output_suffix="_general_population_infection_1_4",
    output_path="output",
)

