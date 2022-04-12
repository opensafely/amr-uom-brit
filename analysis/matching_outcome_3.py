from osmatching import match
#The algorithm currently does matching without replacement.

# #### general population & covid infection(case) 
# match(
#     case_csv="case_covid_infection",
#     match_csv="input_general_population",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     replace_match_index_date_with_case="no_offset",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#         "SGSS_positive_test_date": "before",
#         "primary_care_covid_date": "before",
#         "covid_admission_date": "before",
#         #"icu_date_admitted": "before",
#         "died_date_cpns": "before",
#         "died_date_ons_covid": "before",
#     },
#     output_suffix="_general_population_infection",
#     output_path="output",
# )

# #### covid infection(control) & hospital admission(case)
# match(
#     case_csv="case_covid_admission",
#     match_csv="control_covid_infection",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_infection_hosp",
#     output_path="output",
# )


#### covid hospital admission(control) & covid death(case)

match(
    case_csv="case_covid_icu_death",
    match_csv="control_covid_admission",
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


# #### general population(control) & covid infection(case)- matching monthly datasets
# # 2020-02-01 ~ 2021-12-31
# match(
#     case_csv="case_covid_infection_2020-02",
#     match_csv="control_general_population_2020-02-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_02",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-03",
#     match_csv="control_general_population_2020-03-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_03",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-04",
#     match_csv="control_general_population_2020-04-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_04",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-05",
#     match_csv="control_general_population_2020-05-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_05",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-06",
#     match_csv="control_general_population_2020-06-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_06",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-07",
#     match_csv="control_general_population_2020-07-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_07",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-08",
#     match_csv="control_general_population_2020-08-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_08",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-09",
#     match_csv="control_general_population_2020-09-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_09",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-10",
#     match_csv="control_general_population_2020-10-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_10",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-11",
#     match_csv="control_general_population_2020-11-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_11",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2020-12",
#     match_csv="control_general_population_2020-12-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2020_12",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-01",
#     match_csv="control_general_population_2021-01-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-01",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-02",
#     match_csv="control_general_population_2021-02-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-02",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-03",
#     match_csv="control_general_population_2021-03-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-03",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-04",
#     match_csv="control_general_population_2021-04-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-04",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-05",
#     match_csv="control_general_population_2021-05-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-05",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-06",
#     match_csv="control_general_population_2021-06-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-06",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-07",
#     match_csv="control_general_population_2021-07-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-07",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-08",
#     match_csv="control_general_population_2021-08-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021_08",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-09",
#     match_csv="control_general_population_2021-09-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-09",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-10",
#     match_csv="control_general_population_2021-10-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-10",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-11",
#     match_csv="control_general_population_2021-11-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-11",
#     output_path="output",
# )

# match(
#     case_csv="case_covid_infection_2021-12",
#     match_csv="control_general_population_2021-12-01",
#     matches_per_case=6,
#     match_variables={
#         "sex": "category",
#         "age": 5, #+- 5 years old
#         "stp": "category",
#         "cal_YM": "category"
#     },
#     closest_match_variables=["age"],
#     index_date_variable="patient_index_date",
#     date_exclusion_variables={
#         "dereg_date": "before",
#         "ons_died_date": "before",
#     },
#     output_suffix="_general_pupulation_infection_2021-12",
#     output_path="output",
# )



# # from osmatching import match
# # #The algorithm currently does matching without replacement.
# # match(
# #     case_csv="case_covid_infection",
# #     match_csv="case_covid_admission",
# #     matches_per_case=6,
# #     match_variables={
# #         "sex": "category",
# #         "age": 5, #+- 1 years old
# #         "stp": "category",
# #         "patient_index_date":"month_only"
# #     },
# #     closest_match_variables=["age"],
# #     #replace_match_index_date_with_case="no_offset", #when match general population(no index date)
# #     index_date_variable="patient_index_date",
# #     date_exclusion_variables={
# #         "dereg_date": "before",
# #         "ons_died_date": "before",
# #     },
# #     output_suffix="_outcome_hosp_admission",
# #     output_path="output",
# # )

# # match(
# #     case_csv="input_infection",
# #     match_csv="input_general_population",
# #     matches_per_case=2,
# #     match_variables={
# #         "sex": "category",
# #         "age": 1,
# #         "stp": "category",
# #     },
# #     closest_match_variables=["age"],
# #     replace_match_index_date_with_case="no_offset",
# #     index_date_variable="indexdate",
# #     date_exclusion_variables={
# #        "ons_died_date_": "before",
# #         "covid_admission_date": "before",
# #         "icu_date_admitted": "before",
# #     },
# #     output_suffix="_infection&control",
# #     output_path="output",
# # )