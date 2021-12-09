from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_ab_time_variables(index_date_variable): 
  ab_time_variables  = dict(

  def with_these_clinical_events_date_X(name, codelist, index_date_variable, n, return_expectations):

    def var_signature(name, codelist, on_or_before, return_expectations):
        return {
            name: patients.with_these_clinical_events(
                    codelist,
                    returning="date",
                    on_or_before=on_or_before,
                    date_format="YYYY-MM-DD",
                    find_last_match_in_period=True,
                    return_expectations=return_expectations
        ),
        }
    variables = var_signature(f"{name}_1", antibacterials_codes_brit, f'{index_date_variable}', return_expectations)
    for i in range(2, n+1):
        variables.update(var_signature(f"{name}_{i}", antibacterials_codes_brit, f"{name}_{i-1} + 1 day", return_expectations))
  )
    return ab_time_variables

