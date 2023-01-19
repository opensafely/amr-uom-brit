from osmatching import match

match(
    case_csv="case_201",
    match_csv="control_201",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_201",
    output_path="output",
)

match(
    case_csv="case_202",
    match_csv="control_202",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_202",
    output_path="output",
)