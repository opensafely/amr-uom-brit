
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a plot to show overall antibiotics prescribing rate by month
# By practice, by month, per 1000 patient
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")

# impoprt data
df_input <- read_csv(
  here::here("output", "measures", "measure_antibiotics_overall.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    antibacterial_prescriptions  = col_double(),
    population  = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

df_input <- df_input %>% filter(practice >0)

measure=df_input%>%
  group_by(date)%>%
  summarize(count=n(),
            pres=sum(antibacterial_prescriptions),
            popul=sum(population),
            prescrib=pres*1000/(popul*count))
  
plot_prescrib <- ggplot(data=measure,mapping = aes(
  x = date, 
  y = prescrib))+
geom_line()+geom_point()+
  labs(
    title = "Overall antibiotics prescribing rate by month",
    subtitle = "01/2019 -09/2021 ",
    caption = "TPP Practices",
    x = "Time",
    y = "overall AB prescribing rate"
  )
plot_prescrib 

ggsave(
  plot= plot_prescrib,
  filename="overall.png", path=here::here("output"),
)

#boxplot

overallbox <- ggplot(df_input, aes(group=date,x=date,y=value)) + 
  geom_boxplot()
ggsave(
  plot= overallbox,
  filename="overallbox.png", path=here::here("output"),
)














