
# # # # # # # # # # # # # # # # # # # # #
# This script:
# define covid infection (case) & potiential control group
# 
# 
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')


#### COVID INFECTION

# impoprt data
df <- read_csv(here::here("output", "control_covid_infection.csv"))


# filter male, stp1
df1_1 =df%>%filter( cal_YM == "2020-02")
write_csv(df1_1, here::here("output", "covid_infection_2002.csv"))
rm(df1_1)

# filter male, stp2
df1_2 =df%>%filter( sex=="M" & stp=="STP2")
write_csv(df1_2, here::here("output", "covid_infection_1_2.csv"))
rm(df1_2)

# filter male, stp2
df1_3 =df%>%filter( sex=="M" & stp=="STP3")
write_csv(df1_3, here::here("output", "covid_infection_1_3.csv"))
rm(df1_3)

# filter male, stp4
df1_4 =df%>%filter( sex=="M" & stp=="STP4")
write_csv(df1_4, here::here("output", "covid_infection_1_4.csv"))
rm(df1_4)

# filter male, stp5
df1_5 =df%>%filter( sex=="M" & stp=="STP5")
write_csv(df1_5, here::here("output", "covid_infection_1_5.csv"))
rm(df1_5)

# filter male, stp6
df1_6 =df%>%filter( sex=="M" & stp=="STP6")
write_csv(df1_6, here::here("output", "covid_infection_1_6.csv"))
rm(df1_6)

# filter male, stp7
df1_7 =df%>%filter( sex=="M" & stp=="STP2")
write_csv(df1_7, here::here("output", "covid_infection_1_7.csv"))
rm(df1_7)

# filter male, stp8
df1_8=df%>%filter( sex=="M" & stp=="STP8")
write_csv(df1_8, here::here("output", "covid_infection_1_8.csv"))
rm(df1_8)

# filter male, stp9
df1_9=df%>%filter( sex=="M" & stp=="STP9")
write_csv(df1_9, here::here("output", "covid_infection_1_9.csv"))
rm(df1_9)

# filter male, stp10
df1_10 =df%>%filter( sex=="M" & stp=="STP10")
write_csv(df1_10, here::here("output", "covid_infection_1_10.csv"))
rm(df1_10)



# filter female, stp1
df1_1 =df%>%filter( sex=="F" & stp=="STP1")
write_csv(df1_1, here::here("output", "covid_infection_2_1.csv"))
rm(df1_1)

# filter female, stp2
df1_2 =df%>%filter( sex=="F" & stp=="STP2")
write_csv(df1_2, here::here("output", "covid_infection_2_2.csv"))
rm(df1_2)

# filter female, stp2
df1_3 =df%>%filter( sex=="F" & stp=="STP3")
write_csv(df1_3, here::here("output", "covid_infection_2_3.csv"))
rm(df1_3)

# filter female, stp4
df1_4 =df%>%filter( sex=="F" & stp=="STP4")
write_csv(df1_4, here::here("output", "covid_infection_2_4.csv"))
rm(df1_4)

# filter female, stp5
df1_5 =df%>%filter( sex=="F" & stp=="STP5")
write_csv(df1_5, here::here("output", "covid_infection_2_5.csv"))
rm(df1_5)

# filter female, stp6
df1_6 =df%>%filter( sex=="F" & stp=="STP6")
write_csv(df1_6, here::here("output", "covid_infection_2_6.csv"))
rm(df1_6)

# filter female, stp7
df1_7 =df%>%filter( sex=="F" & stp=="STP2")
write_csv(df1_7, here::here("output", "covid_infection_2_7.csv"))
rm(df1_7)

# filter female, stp8
df1_8=df%>%filter( sex=="F" & stp=="STP8")
write_csv(df1_8, here::here("output", "covid_infection_2_8.csv"))
rm(df1_8)

# filter female, stp9
df1_9=df%>%filter( sex=="F" & stp=="STP9")
write_csv(df1_9, here::here("output", "covid_infection_2_9.csv"))
rm(df1_9)

# filter female, stp10
df1_10 =df%>%filter( sex=="F" & stp=="STP10")
write_csv(df1_10, here::here("output", "covid_infection_2_10.csv"))
rm(df1_10)



