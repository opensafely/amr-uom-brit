
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a plot to show overall antibiotics prescribing rate by month
# By practice, by month, per 1000 patient
# mean 25th and 75th percentile
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

# impoprt data
df <- read_csv(
  here::here("output", "measures", "measure_ABs_12mb4.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    patient_id = col_integer(),
    # Outcomes
    antibacterial_ABs_12mb4  = col_double(),
    population  = col_double(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

df$date <- as.Date(df$date)
df$cal_mon <- month(df$date)
df$cal_year <- year(df$date)

# remove last month data
last.date=max(df$date)
df=df%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))


### replace NA in number of abs 12 months before to 0
df$antibacterial_12mb4[is.na(df$antibacterial_12mb4)] <- 0

### make variable for categorising num ABs in 12m before
### group_by pract and month
df_gp <- df %>% group_by(practice, cal_mon, cal_year) %>%
  mutate(ab_cat = case_when(antibacterial_12mb4 >0 & antibacterial_12mb4 <4 ~ 2,
                            antibacterial_12mb4 >3 & antibacterial_12mb4 <7 ~ 3,
                            antibacterial_12mb4 >=7 ~ 4,
                            antibacterial_12mb4 == 0 ~1)) 
df_gp$ab_cat <- as.factor(df_gp$ab_cat)

### calculate % (for each practice) for each ab_category 
### by dividing by 'nrows' in groups to get practice population by month
df_percent <- df_gp %>% group_by(practice, cal_mon, cal_year) %>%
  mutate(mon_listsize = n())
### group by ab cat to work out percentage by category using practice listsize
df_per_abgp <- df_percent %>% group_by(practice, cal_mon, cal_year, ab_cat) %>%
  mutate(num_abcats = n()) %>%
  mutate(percentgp = (num_abcats/mon_listsize)*100)

stackedbar <- ggplot(df_per_abgp, aes(x=date, y=percentgp))+
    geom_col(aes(fill=ab_cat)) +
    scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
    theme(axis.text.x=element_text(angle=60,hjust=1))



ggsave(
  plot= stackedbar,
  filename="AB_1yb4_stackedbar.png", path=here::here("output"),
)
