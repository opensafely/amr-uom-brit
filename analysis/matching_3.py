from osmatching import match

match(
    case_csv="case_3_uti",
    match_csv="control_3_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_3_uti",
    output_path="output",
)

match(
    case_csv="case_3_lrti",
    match_csv="control_3_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_3_lrti",
    output_path="output",
)

match(
    case_csv="case_3_urti",
    match_csv="control_3_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_3_urti",
    output_path="output",
)

match(
    case_csv="case_3_sinusitis",
    match_csv="control_3_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_3_sinusitis",
    output_path="output",
)

match(
    case_csv="case_3_ot_externa",
    match_csv="control_3_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_3_ot_externa",
    output_path="output",
)

match(
    case_csv="case_3_ot_media",
    match_csv="control_3_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_3_ot_media",
    output_path="output",
)

match(
    case_csv="case_3_pneumonia",
    match_csv="control_3_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_3_pneumonia",
    output_path="output",
)
