from osmatching import match

match(
    case_csv="case_8_uti",
    match_csv="control_8_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_8_uti",
    output_path="output",
)

match(
    case_csv="case_8_lrti",
    match_csv="control_8_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_8_lrti",
    output_path="output",
)

match(
    case_csv="case_8_urti",
    match_csv="control_8_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_8_urti",
    output_path="output",
)

match(
    case_csv="case_8_sinusitis",
    match_csv="control_8_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_8_sinusitis",
    output_path="output",
)

match(
    case_csv="case_8_ot_externa",
    match_csv="control_8_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_8_ot_externa",
    output_path="output",
)

match(
    case_csv="case_8_ot_media",
    match_csv="control_8_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_8_ot_media",
    output_path="output",
)

match(
    case_csv="case_8_pneumonia",
    match_csv="control_8_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_8_pneumonia",
    output_path="output",
)
