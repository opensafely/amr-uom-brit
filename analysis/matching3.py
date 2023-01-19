from osmatching import match

match(
    case_csv="case_211",
    match_csv="control_211",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_211",
    output_path="output",
)

match(
    case_csv="case_212",
    match_csv="control_212",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_212",
    output_path="output",
)