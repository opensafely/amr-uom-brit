from osmatching import match

match(
    case_csv="case_csv",
    match_csv="match_csv",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "stp": "category",
        "patient_index_date": "month_only",
        "charlsonGrp": "category",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_path="output",
)