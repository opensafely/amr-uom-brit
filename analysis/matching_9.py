from osmatching import match

match(
    case_csv="case_9_uti",
    match_csv="control_9_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_9_uti",
    output_path="output",
)

match(
    case_csv="case_9_lrti",
    match_csv="control_9_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_9_lrti",
    output_path="output",
)

match(
    case_csv="case_9_urti",
    match_csv="control_9_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_9_urti",
    output_path="output",
)

match(
    case_csv="case_9_sinusitis",
    match_csv="control_9_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_9_sinusitis",
    output_path="output",
)

match(
    case_csv="case_9_ot_externa",
    match_csv="control_9_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_9_ot_externa",
    output_path="output",
)

match(
    case_csv="case_9_ot_media",
    match_csv="control_9_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_9_ot_media",
    output_path="output",
)

match(
    case_csv="case_9_pneumonia",
    match_csv="control_9_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_9_pneumonia",
    output_path="output",
)
