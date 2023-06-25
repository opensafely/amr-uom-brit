from osmatching import match

match(
    case_csv="input_case_lrti",
    match_csv="input_control_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_lrti",
    output_path="output",
)