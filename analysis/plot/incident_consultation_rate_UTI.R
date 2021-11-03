##############
## Consultation rates for UTI over time,
## stratified overall and by age categories. 
## Consultation for common infection will only include those with no prior records in 6 weeks of the same infection.
##############

library("data.table")
library("dplyr")
library('here')
library("tidyverse")


### 1. import data 

df <- read_csv(
  here::here("output", "measures", "measure_UTI consultation rate.csv"),
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    uti_counts  = col_double(),
    population  = col_double(),
    incdt_uti_pt = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
)

### 2. summarise table

df$cal_YM=format(as.Date(df$date) , "%Y-%m")# group_by calendar Year-Month

df[is.na(df)] <- 0 # replace NA ->0

# select incdt=0 , count incident patient number, (if incdt=1 then set count=0 )
df$incdt_counts=ifelse(df$incdt_uti_pt==0,df$uti_counts,0)

# add col: population per GP in each time point- same number in multiple row within same gp
df=df%>%
  group_by(cal_YM,practice)%>% 
  mutate(population=sum(population))
         
# summarize incident number of each age_cat
df_sum_gp_age=df%>%
  group_by(cal_YM,practice,age_cat)%>% 
  summarise(pt_counts=sum(incdt_counts), # count consultation number in each age_cat; incident=1(count=0), incident=0(add count)
            pupulation=mean(population)) # both incident=1 or 0 has same GP population, so add mean
 
# "rate per 1,000 registered patients"
df_sum_gp_age$rate=df_sum_gp_age$pt_counts/df_sum_gp_age$pupulation*1000


### 3. plot

df_plot=df_sum_gp_age%>%
  group_by(cal_YM,age_cat)%>%
  summarise(rate=mean(rate))



stackedbar <- ggplot(df_plot, aes(x=cal_YM, y=rate,fill=age_cat))+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    x = "Time", 
    y = "consultation rate per 1,000 registered patients")+
  scale_y_continuous(labels = scales::percent) +
  scale_fill_brewer(palette = "Paired")


ggsave(
  plot= stackedbar,
  filename="incident_consultation_rate.png", path=here::here("output")
)

  