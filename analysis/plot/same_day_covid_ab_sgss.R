library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("cowplot") 
  
  
  
df <- read_csv(
  here::here("output", "measures", "measure_Same_day_pos_ab_sgss.csv"),  
  col_types = cols_only(
    
    # Identifier
    practice = col_integer(),
    
    # Outcomes
    Covid_test_result_sgss  = col_double(),
    population  = col_double(),
    sgss_ab_prescribed = col_double(),
    age_cat = col_character(),
    value = col_double(),
    
    # Date
    date = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

  df$date <- as.Date(df$date,format="%Y-%m-%d")


  df$date <- as.Date(df$date,format="%Y-%m-%d")


  df[is.na(df)] <- 0 
  # remove last month data
  last.date=max(df$date)
  df=df%>% filter(date!=last.date)
  first_mon=format(min(df$date),"%m-%Y")
  last_mon= format(max(df$date),"%m-%Y")
  
  ## remove negative Covid cohorts
  df <- df%>% filter(Covid_test_result_sgss==1)
  
  ## Count the overal Covid Positive Cohort
  df_pos <- df%>% group_by(date,practice,age_cat)%>%
    mutate(total_covid_population=population[sgss_ab_prescribed==1]+population[sgss_ab_prescribed==0])
  
  df_postive_rate <- df_pos%>%filter(sgss_ab_prescribed==1)

  num_uniq_prac <- as.numeric(dim(table((df_postive_rate$practice))))
  
  df_plot <- df_postive_rate%>%group_by(date,age_cat)%>%
    summarise(ab_population=sum(population,na.rm = TRUE),
           covid_population=sum(total_covid_population,na.rm = TRUE))%>%
             mutate(year=format(date,"%Y"))
  
  df_plot$rate <- df_plot$ab_population/df_plot$covid_population

  
  df_plot$age_cat <- factor(df_plot$age_cat, levels=c("0", "0-4", "5-14","15-24","25-34","35-44","45-54","55-64","65-74","75+"))
  
  plot <- ggplot(df_plot, aes(x=date, y=rate))+
    geom_rect(xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-12"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
    geom_rect(xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
    geom_rect(xmin = as.Date("2020-03-23"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
    geom_line(aes(color=year))+
    facet_grid(rows = vars(age_cat))+
    theme(legend.position = "bottom",legend.title =element_blank())+
    scale_x_date(date_breaks = "1 month",date_labels =  "%m")+
    scale_y_continuous(labels = scales::percent)+
    labs(
      title = "Same day Covid diagnosis and antibiotics prescription-sgss",  
      subtitle = paste(first_mon,"-",last_mon),
      caption = paste("Data from approximately", num_uniq_prac,"TPP Practices",';National lockdown in red area'), 
      x = "", 
      y = "Same day antibiotics prescribing %")
  plot

df_plot_2 <- df_plot%>%group_by(date)%>%summarise(ab_population=sum(ab_population,na.rm = TRUE),
                                                  covid_population=sum(covid_population,na.rm = TRUE))%>%
                                                  mutate(year=format(date,"%Y"))
df_plot_2$rate<- df_plot_2$ab_population/df_plot_2$covid_population

  plot2 <- ggplot(df_plot_2, aes(x=date, y=rate))+
    geom_rect(xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-12"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
    geom_rect(xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
    geom_rect(xmin = as.Date("2020-03-23"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="red3", alpha=0.01)+
    geom_line(aes(color=year))+
    theme(legend.position = "bottom",legend.title =element_blank())+
    scale_x_date(date_breaks = "1 month",date_labels =  "%m")+
    scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.005))+
    labs(
      title = "Same day Covid diagnosis and antibiotics prescription-sgss",  
      subtitle = paste(first_mon,"-",last_mon),
      caption = paste("Data from approximately", num_uniq_prac,"TPP Practices",';National lockdown in red area'), 
      x = "", 
      y = "Same day antibiotics prescribing %")
  plot2

  ggsave(
  plot= plot,
  filename="same_day_ab_prop_line_sgss_age.jpeg", path=here::here("output"),
)  

  ggsave(
  plot= plot2,
  filename="same_day_ab_prop_line_sgss.jpeg", path=here::here("output"),
)  

## table 
write_csv(df_plot, here::here("output", "same_day_ab_prop_sgss.csv"))