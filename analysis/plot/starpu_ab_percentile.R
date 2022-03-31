# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a plot to show overall antibiotics prescribing rate by month after star-pu adjustment
# By practice, by month, per 1000 patient
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---

library('tidyverse')
library("ggplot2")
library("dplyr")
library('lubridate')

# impoprt data
starpu <- read_csv(
  here::here("output", "measures", "measure_STARPU_antibiotics.csv"),
  col_types = cols_only(
    practice = col_number(),
    sex = col_character(),
    age_cat = col_factor(),
    antibacterial_brit = col_number(),
    population = col_number(),
    value = col_number(),
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

starpu <- starpu %>% filter(practice >0)

#summary(starpu$antibacterial_brit)

# remove last month data
starpu$date <- as.Date(starpu$date)
last.date=max(starpu$date)
starpu=starpu%>% filter(date!=last.date)
first_mon <- (format(min(starpu$date), "%m-%Y"))
last_mon <- (format(max(starpu$date), "%m-%Y"))
num_uniq_prac <- as.numeric(dim(table((starpu$practice))))

                                        
measurestar <- starpu %>% group_by(date, practice) %>%
  mutate(advalue= case_when(age_cat=="0-4" ~ value*0.8,
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
  group_by(date, practice, .groups=T)%>%
  mutate(starpu_month=sum(advalue,na.rm=TRUE),  ##sum of practice STARPU adjusted prescribing rate
         starpu_month_1000=(starpu_month)*1000) ##sum * 1000, for 1000 registered patients

## quintiles
starpu_quantiles <- measurstarpu %>% group_by(date) %>%
  mutate(starpu_mean = mean(starpu_month_1000,na.rm=TRUE),
         lowquart= quantile(starpu_month_1000, na.rm=TRUE)[2],
         highquart= quantile(starpu_month_1000, na.rm=TRUE)[4],
         ninefive= quantile(starpu_month_1000, na.rm=TRUE, c(0.95)),
         five=quantile(starpu_month_1000, na.rm=TRUE, c(0.05)))

month_mean_starpu_df <- select(starpu_quantiles, starpu_mean,lowquart,
                               highquart,ninefive,five)
month_mean_starpu_df <- month_mean_starpu_df %>% group_by(date) %>%
  slice_head()

write.csv(month_mean_starpu_df, file="monthly_quantile_ab_STARPU.csv")
rm(month_mean_starpu_df)

plot_percentile_STARPU <- ggplot(starpu_quantiles, aes(x=date))+
    geom_line(aes(y=starpu_mean),color="steelblue")+
    geom_point(aes(y=starpu_mean),color="steelblue")+
    geom_line(aes(y=lowquart), color="darkred")+
    geom_point(aes(y=lowquart), color="darkred")+
    geom_line(aes(y=highquart), color="darkred")+
    geom_point(aes(y=highquart), color="darkred")+
    geom_line(aes(y=ninefive), color="black", linetype="dotted")+
    geom_point(aes(y=ninefive), color="black")+
    geom_line(aes(y=five), color="black", linetype="dotted")+
    geom_point(aes(y=five), color="black")+
    scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
    theme(axis.text.x=element_text(angle=60,hjust=1))+
    labs(
      title = "STARPU antibiotic prescribing rate by month",
      subtitle = paste(first_mon,"-",last_mon),
      caption = paste("Data from approximately", num_uniq_prac,"TPP Practices"),
      x = "",
      y = "STARPU antibiotic prescribing rate per 1000 registered patients")+
    geom_vline(xintercept = as.numeric(as.Date("2019-12-31")), color="grey")+
    geom_vline(xintercept = as.numeric(as.Date("2020-12-31")), color="grey")

plot_percentile_STARPU  

ggsave(
  plot= plot_percentile_STARPU,
  filename="overall_25th_75th_percentile_STARPU.jpeg", path=here::here("output"),
)

# #star-pu boxplot                                        
# starpubox <- ggplot(starpu_quantiles, aes(group=date,x=date,y=starpu_month_1000)) + 
#   geom_boxplot()
# 
# ggsave(
#   plot= starpubox,
#   filename="starpubox.png", path=here::here("output"),
# )                                        
                  