from osmatching import match

match(
    case_csv="case_5_uti",
    match_csv="control_5_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_5_uti",
    output_path="output",
)

match(
    case_csv="case_5_lrti",
    match_csv="control_5_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_5_lrti",
    output_path="output",
)

match(
    case_csv="case_5_urti",
    match_csv="control_5_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_5_urti",
    output_path="output",
)

match(
    case_csv="case_5_sinusitis",
    match_csv="control_5_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_5_sinusitis",
    output_path="output",
)

match(
    case_csv="case_5_ot_externa",
    match_csv="control_5_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_5_ot_externa",
    output_path="output",
)

match(
    case_csv="case_5_ot_media",
    match_csv="control_5_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_5_ot_media",
    output_path="output",
)

match(
    case_csv="case_5_pneumonia",
    match_csv="control_5_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_5_pneumonia",
    output_path="output",
)
