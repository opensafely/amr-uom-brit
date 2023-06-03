from osmatching import match

match(
    case_csv="case_6_uti",
    match_csv="control_6_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_6_uti",
    output_path="output",
)

match(
    case_csv="case_6_lrti",
    match_csv="control_6_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_6_lrti",
    output_path="output",
)

match(
    case_csv="case_6_urti",
    match_csv="control_6_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_6_urti",
    output_path="output",
)

match(
    case_csv="case_6_sinusitis",
    match_csv="control_6_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_6_sinusitis",
    output_path="output",
)

match(
    case_csv="case_6_ot_externa",
    match_csv="control_6_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_6_ot_externa",
    output_path="output",
)

match(
    case_csv="case_6_ot_media",
    match_csv="control_6_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_6_ot_media",
    output_path="output",
)

match(
    case_csv="case_6_pneumonia",
    match_csv="control_6_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_6_pneumonia",
    output_path="output",
)
