from osmatching import match

match(
    case_csv="case_2_uti",
    match_csv="control_2_uti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_2_uti",
    output_path="output",
)

match(
    case_csv="case_2_lrti",
    match_csv="control_2_lrti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_2_lrti",
    output_path="output",
)

match(
    case_csv="case_2_urti",
    match_csv="control_2_urti",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_2_urti",
    output_path="output",
)

match(
    case_csv="case_2_sinusitis",
    match_csv="control_2_sinusitis",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_2_sinusitis",
    output_path="output",
)

match(
    case_csv="case_2_ot_externa",
    match_csv="control_2_ot_externa",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_2_ot_externa",
    output_path="output",
)

match(
    case_csv="case_2_ot_media",
    match_csv="control_2_ot_media",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_2_ot_media",
    output_path="output",
)

match(
    case_csv="case_2_pneumonia",
    match_csv="control_2_pneumonia",
    matches_per_case=6,
    match_variables={
        "sex": "category",
        "age": 5,
        "patient_index_date": "month_only",
    },
    index_date_variable="patient_index_date",
    closest_match_variables=["age"],
    output_suffix="_2_pneumonia",
    output_path="output",
)