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

match(
    case_csv="case_1_lrti",
    match_csv="control_1_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_1_lrti",
    output_path="output",
)

match(
    case_csv="case_1_urti",
    match_csv="control_1_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_1_urti",
    output_path="output",
)

match(
    case_csv="case_1_sinusitis",
    match_csv="control_1_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_1_sinusitis",
    output_path="output",
)

match(
    case_csv="case_1_ot_externa",
    match_csv="control_1_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_1_ot_externa",
    output_path="output",
)

match(
    case_csv="case_1_ot_media",
    match_csv="control_1_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_1_ot_media",
    output_path="output",
)

match(
    case_csv="case_1_pneumonia",
    match_csv="control_1_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_1_pneumonia",
    output_path="output",
)