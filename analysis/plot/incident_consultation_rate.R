


### 1. import practice-level data(measure.csv) for infection event 
df_infection <- read_csv(
  here::here("output", "measures", "measure_UTI_event.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    uti_counts  = col_double(),
    population  = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )
