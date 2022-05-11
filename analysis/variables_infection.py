from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_infection_variables(index_date_variable):
    infection_variables  = dict(


       #  all infecition
    infection_counts_all=patients.with_these_clinical_events(
        infection_codes_all,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),      

           #  all infecition
    infection_counts_6=patients.with_these_clinical_events(
        infection_codes_6,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),  

    #  --UTI 
    ## count infection events 
    uti_counts=patients.with_these_clinical_events(
        uti_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --LRTI 
    ## count infection events 
    lrti_counts=patients.with_these_clinical_events(
        lrti_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),


    #  --URTI  
    urti_counts=patients.with_these_clinical_events(
        urti_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),

    #  --sinusitis 
    sinusitis_counts=patients.with_these_clinical_events(
        sinusitis_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

    #  --otitis externa
    ot_externa_counts=patients.with_these_clinical_events(
        ot_externa_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),    

    #  --otitis media
    otmedia_counts=patients.with_these_clinical_events(
        otmedia_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),   

        #  asthma
    asthma_counts=patients.with_these_clinical_events(
        asthma_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),  

        # cold
    cold_counts=patients.with_these_clinical_events(
       cold_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),  

        # cough
    cough_counts=patients.with_these_clinical_events(
       cough_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ),  

            # pneumonia
    pneumonia_counts=patients.with_these_clinical_events(
       pneumonia_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 
            #renal_

    renal_counts=patients.with_these_clinical_events(
       renal_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

# sepsis_
    sepsis_counts=patients.with_these_clinical_events(
       sepsis_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 

#  throat
    throat_counts=patients.with_these_clinical_events(
        throat_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 


    #  copd
    copd_counts=patients.with_these_clinical_events(
        copd_codes,
        returning="number_of_matches_in_period",
        between=[f'{index_date_variable}- 1137 days', f'{index_date_variable}- 42 days'],
        return_expectations={
            "int" : {"distribution": "normal", "mean": 5, "stddev": 1},"incidence":0.2}
    ), 
  )
    return infection_variables