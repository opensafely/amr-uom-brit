from osmatching import match

match(
    case_csv="case_7_uti",
    match_csv="control_7_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_7_uti",
    output_path="output",
)

match(
    case_csv="case_7_lrti",
    match_csv="control_7_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_7_lrti",
    output_path="output",
)

match(
    case_csv="case_7_urti",
    match_csv="control_7_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_7_urti",
    output_path="output",
)

match(
    case_csv="case_7_sinusitis",
    match_csv="control_7_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_7_sinusitis",
    output_path="output",
)

match(
    case_csv="case_7_ot_externa",
    match_csv="control_7_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_7_ot_externa",
    output_path="output",
)

match(
    case_csv="case_7_ot_media",
    match_csv="control_7_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_7_ot_media",
    output_path="output",
)

match(
    case_csv="case_7_pneumonia",
    match_csv="control_7_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_7_pneumonia",
    output_path="output",
)
