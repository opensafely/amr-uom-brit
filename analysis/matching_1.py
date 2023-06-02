from osmatching import match

match(
    case_csv="case_1_uti",
    match_csv="control_1_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_1_uti",
    output_path="output",
)
