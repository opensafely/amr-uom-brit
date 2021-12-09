from cohortextractor import (
    patients,
)

# define recurrent event variables
# (https://github.com/opensafely/covid-ve-change-over-time/blob/059735ab27b1bfa00c56a62189e3e3fd28ead295/analysis/recurrent_event_funs.py)
# clinical events with codelist

# medications with codelist
def with_these_medications_date_X(name, codelist, index_date, n, return_expectations):
    
    def var_signature(name, on_or_before, codelist, return_expectations):
        return {
            name: patients.with_these_medications(
                    codelist,
                    returning="date",
                    on_or_before=on_or_before,
                    date_format="YYYY-MM-DD",
                    find_last_match_in_period=True,
                    return_expectations=return_expectations
	        ),
        }
    variables=var_signature(f"{name}_1_date", index_date, codelist, return_expectations)
    for i in range(2, n+1):
        variables.update(var_signature(f"{name}_{i}_date", f"{name}_{i-1}_date - 1 day", codelist, return_expectations))
    return variables
