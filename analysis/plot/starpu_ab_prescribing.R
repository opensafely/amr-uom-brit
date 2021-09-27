# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a plot to show overall antibiotics prescribing rate by month after star-pu adjustment
# By practice, by month, per 1000 patient
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library("dplyr")

# impoprt data
starpu <- read_csv(
  here::here("output", "measures", "measure_STARPU_antibiotics.csv"),
  col_types = cols_only(

  practice = col_double(),
      sex = col_character(),
      age_cat = col_character(),
      antibacterial_prescriptions = col_double(),
      population = col_double(),
      value = col_double(),
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

starpu <- starpu %>% filter(practice >0)


                                        
measurestar <- starpu%>%mutate(advalue= case_when(age_cat=="0-4" ~ value*0.8,
                               age_cat =="5-14"& sex=="M"~value*0.3,
                               age_cat =="5-14"& sex=="F"~value*0.4,
                               age_cat =="15-24"& sex=="M"~value*0.3,
                               age_cat =="15-24"& sex=="F"~value*0.6,
                               age_cat =="25-34"& sex=="M"~value*0.2,
                               age_cat =="25-34"& sex=="F"~value*0.6,
                               age_cat =="35-44"& sex=="M"~value*0.3,
                               age_cat =="35-44"& sex=="F"~value*0.6,
                               age_cat =="45-54"& sex=="M"~value*0.3,
                               age_cat =="45-54"& sex=="F"~value*0.6,
                               age_cat =="55-64"& sex=="M"~value*0.4,
                               age_cat =="55-64"& sex=="F"~value*0.7,
                               age_cat =="65-74"& sex=="M"~value*0.7,
                               age_cat =="65-74"& sex=="F"~value*1.0,
                               age_cat =="75+"& sex=="M"~value*1.0,
                               age_cat =="75+"& sex=="F"~value*1.3,
                      TRUE ~ 0))

measurstarpu=measurestar%>%
  group_by(date)%>%
  summarize(count=n(),
            sumadvalue=sum(advalue,na.rm=TRUE),
            prescrib=sumadvalue*1000/(count))
                      
plot_starpu <- ggplot(data=measurstarpu,mapping = aes(
  x = date, 
  y = prescrib))+geom_line()+geom_point()+
  labs(
    title = "Overall star-pu adjusted antibiotics prescribing rate by month",
    subtitle = "01/2019 -09/2021 ",
    caption = "dummy data",
    x = "Time",
    y = "Star-pu adjusted AB prescribing rate"
  )
plot_starpu

ggsave(
  plot= plot_starpu,
  filename="starpuline.png", path=here::here("output"),
)
#star-pu boxplot                                        
starpubox <- ggplot(measurestar, aes(group=date,x=date,y=advalue)) + 
  geom_boxplot()

ggsave(
  plot= starpubox,
  filename="starpubox.png", path=here::here("output"),
)                                        
                  