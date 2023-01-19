from osmatching import match

match(
    case_csv="case_191",
    match_csv="control_191",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_191",
    output_path="output",
)

match(
    case_csv="case_192",
    match_csv="control_192",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_192",
    output_path="output",
)