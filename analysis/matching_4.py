from osmatching import match

match(
    case_csv="case_4_uti",
    match_csv="control_4_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_4_uti",
    output_path="output",
)

match(
    case_csv="case_4_lrti",
    match_csv="control_4_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_4_lrti",
    output_path="output",
)

match(
    case_csv="case_4_urti",
    match_csv="control_4_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_4_urti",
    output_path="output",
)

match(
    case_csv="case_4_sinusitis",
    match_csv="control_4_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_4_sinusitis",
    output_path="output",
)

match(
    case_csv="case_4_ot_externa",
    match_csv="control_4_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_4_ot_externa",
    output_path="output",
)

match(
    case_csv="case_4_ot_media",
    match_csv="control_4_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_4_ot_media",
    output_path="output",
)

match(
    case_csv="case_4_pneumonia",
    match_csv="control_4_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_4_pneumonia",
    output_path="output",
)
