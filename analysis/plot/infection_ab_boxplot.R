
# # # # # # # # # # # # # # # # # # # # #
# This script: show percentage of infection received antibiotics - boxplot
# Generate a plot to show overall antibiotics prescribing rate by month
# By practice, by month, per 1000 patient
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")

# impoprt data
df_input <- read_csv(
  here::here("output", "measures", "measure_antibiotics_all_infection.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    antibiotic_infection  = col_double(),
    any_infection_count  = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )
 


#boxplot -describe percentage(value) of each practice

overallbox <- ggplot(df_input, aes(group=date,x=date,y=value)) + 
  geom_boxplot()+
  xlab("time") +
  ylab("infection prescribed antibiotics(%)") +
  geom_dotplot(binaxis = 'y',     
               stackdir = 'center', 
               dotsize = 0.2) 
   
ggsave(
  plot= overallbox,
  filename="all_infection_box.png", path=here::here("output"),
)














