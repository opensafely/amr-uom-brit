from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_ab_variables_yr1(index_date_variable):
    ab_variables_yr1 = dict(
         ## ab types:79
Rx_1_Amoxicillin=patients.with_these_medications(codes_ab_type_Amoxicillin,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Azithromycin=patients.with_these_medications(codes_ab_type_Azithromycin,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Cefalexin=patients.with_these_medications(codes_ab_type_Cefalexin,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Ciprofloxacin=patients.with_these_medications(codes_ab_type_Ciprofloxacin,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Clarithromycin=patients.with_these_medications(codes_ab_type_Clarithromycin,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Co_amoxiclav=patients.with_these_medications(codes_ab_type_Co_amoxiclav,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Doxycycline=patients.with_these_medications(codes_ab_type_Doxycycline,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Flucloxacillin=patients.with_these_medications(codes_ab_type_Flucloxacillin,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Nitrofurantoin=patients.with_these_medications(codes_ab_type_Nitrofurantoin,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Phenoxymethylpenicillin=patients.with_these_medications(codes_ab_type_Phenoxymethylpenicillin,between=[f'{index_date_variable}-72days', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_1_Trimethoprim=patients.with_these_medications(codes_ab_type_Trimethoprim,between=[f'{index_date_variable}- 6 months', f'{index_date_variable}-42days'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Amoxicillin=patients.with_these_medications(codes_ab_type_Amoxicillin,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Azithromycin=patients.with_these_medications(codes_ab_type_Azithromycin,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Cefalexin=patients.with_these_medications(codes_ab_type_Cefalexin,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Ciprofloxacin=patients.with_these_medications(codes_ab_type_Ciprofloxacin,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Clarithromycin=patients.with_these_medications(codes_ab_type_Clarithromycin,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Co_amoxiclav=patients.with_these_medications(codes_ab_type_Co_amoxiclav,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Doxycycline=patients.with_these_medications(codes_ab_type_Doxycycline,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Flucloxacillin=patients.with_these_medications(codes_ab_type_Flucloxacillin,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Nitrofurantoin=patients.with_these_medications(codes_ab_type_Nitrofurantoin,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Phenoxymethylpenicillin=patients.with_these_medications(codes_ab_type_Phenoxymethylpenicillin,between=[f'{index_date_variable}-102days', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),
Rx_2_Trimethoprim=patients.with_these_medications(codes_ab_type_Trimethoprim,between=[f'{index_date_variable}-12 months', f'{index_date_variable}-6 months'],returning='number_of_matches_in_period',return_expectations={'int': {'distribution': 'normal', 'mean': 3, 'stddev': 1},'incidence': 0.5,}),

        
    ## number of total prescriptions 
    ab_prescriptions=patients.with_these_medications(
        antibacterials_codes_brit,
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),
    
    ## time period ab prescriptions 
    ab_first_date=patients.with_these_medications(
        antibacterials_codes_brit,
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        returning="date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 0.5},
    ),

    ab_last_date=patients.with_these_medications(
        antibacterials_codes_brit,
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        returning="date",
        find_last_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 0.5},
    ),


    ## number of broad-spectrum ab prescriptions
   
    broad_ab_prescriptions=patients.with_these_medications(
        broad_spectrum_antibiotics_codes,
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 0.5,
        },
    ),

    ## time difference

  )
    return ab_variables_yr1


