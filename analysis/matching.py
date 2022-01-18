from osmatching import match
#The algorithm currently does matching without replacement.

#### covid infection & hospital admission
match(
    case_csv="case_covid_admission",
    match_csv="case_covid_infection",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5, #+- 5 years old
        "stp": "category",
        "cal_YM": "category"
    },
    closest_match_variables=["age"],
    index_date_variable="patient_index_date",
    date_exclusion_variables={
        "dereg_date": "before",
        "ons_died_date": "before",
    },
    output_suffix="_infection_hosp",
    output_path="output",
)


#### covid hospital admission & covid ICU or death

match(
    case_csv="case_covid_icu_death",
    match_csv="case_covid_admission",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5, #+- 5 years old
        "stp": "category",
        "cal_YM": "category"
    },
    closest_match_variables=["age"],
    index_date_variable="patient_index_date",
    date_exclusion_variables={
        "dereg_date": "before",
        "ons_died_date": "before",
    },
    output_suffix="_hosp_icu_death",
    output_path="output",
)


#### general population & covid infection
match(
    case_csv="case_covid_infection_2020-08",
    match_csv="control_general_population_2020-08",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5, #+- 5 years old
        "stp": "category",
        "cal_YM": "category"
    },
    closest_match_variables=["age"],
    index_date_variable="patient_index_date",
    date_exclusion_variables={
        "dereg_date": "before",
        "ons_died_date": "before",
    },
    output_suffix="_hosp_icu_death",
    output_path="output",
)



# from osmatching import match
# #The algorithm currently does matching without replacement.
# match(
#     case_csv="case_covid_infection",
#     match_csv="case_covid_admission",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 1 years old
#         "stp": "category",
#         "patient_index_date":"month_only"
#     },
#     closest_match_variables=["age"],
#     #replace_match_index_date_with_case="no_offset", #when match general population(no index date)
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_outcome_hosp_admission",
#     output_path="output",
# )

# match(
#     case_csv="input_infection",
#     match_csv="input_general_population",
#     matches_per_case=2,
#     match_variables={
#         "sex": "category",
#         "age": 1,
#         "stp": "category",
#     },
#     closest_match_variables=["age"],
#     replace_match_index_date_with_case="no_offset",
#     index_date_variable="indexdate",
#     date_exclusion_variables={
#        "ons_died_date_": "before",
#         "covid_admission_date": "before",
#         "icu_date_admitted": "before",
#     },
#     output_suffix="_infection&control",
#     output_path="output",
# )