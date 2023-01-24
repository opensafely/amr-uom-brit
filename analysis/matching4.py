from osmatching import match

match(
    case_csv="case_221",
    match_csv="control_221",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_221",
    output_path="output",
)
