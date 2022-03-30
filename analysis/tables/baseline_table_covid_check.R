
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate baseline table to check new COVID variables by extracting one cohort
# not by month
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---
library("tidyverse") 
library('dplyr')
library('lubridate')
#library('stringr')
#library("data.table")
#library("ggpubr")
library("finalfit")

setwd(here::here("output"))

#### read file list from input.csv

df <- read_csv(
  here::here("output", "input_covidcheck_2.csv.gz"),
  col_types = cols_only(
    date_vaccin_gp_1 = col_date(format = ""),
    date_vaccin_gp_2 = col_date(format = ""),
    Covid_test_result_sgss_1_DATE = col_date(format = ""),
    Covid_test_result_sgss_2_DATE = col_date(format = ""),
    flu_vaccine_tpp_2019 = col_date(format = ""),
    flu_vaccine_tpp_2020 = col_date(format = ""),
    flu_vaccine_tpp_2021 = col_date(format = ""),
    flu_vaccine_tpp_2022 = col_date(format = ""),
    covrx1_dat = col_date(format = ""),
    covrx2_dat = col_date(format = ""),
    died_date = col_date(format = ""),
    age = col_number(),
    age_cat = col_factor(),
    sex = col_factor(),
    practice = col_number(),
    Covid_test_result_sgss_1 = col_integer(),
    Covid_test_result_sgss_2 = col_integer(),
    covid_positive_count_sgss = col_number(),
    gp_covid_count = col_number(),
    antibiotics_prescriptions = col_number(),
    broad_spectrum_antibiotics_prescriptions = col_number(),
    patient_id = col_number())
)
  


# remove last month data
#last.date=max(df_input$date)
#df=df_input%>% filter(date!=last.date)
# rm(df_input)
# first_mon <- (format(min(df$date), "%m-%Y"))
# last_mon <- (format(max(df$date), "%m-%Y"))
num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "overall_covid.csv"))
rm(overall_counts)



# ## randomly select one observation for each patient 
# ## in the study period to generate baseline table for service evaluation
# df <- df %>% dplyr::group_by(patient_id) %>%
#   dplyr::arrange(date, .group_by=TRUE) %>%
#   sample_n(1)


# ## Charlson - as a catergorical group variable
# df <- df %>%
#   mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
#                                 charlson_score >2 & charlson_score <=4 ~ 3,
#                                 charlson_score >4 & charlson_score <=6 ~ 4,
#                                 charlson_score >=7 ~ 5,
#                                 charlson_score == 0 ~ 1))
# 
# df$charlsonGrp <- as.factor(df$charlsonGrp)
# df$charlsonGrp <- factor(df$charlsonGrp, 
#                                  labels = c("zero", "low", "medium", "high", "very high"))
# 
df$age_cat<- as.factor(df$age_cat)

# flu vaccines by year (if date present had vaccine)
df$fluvac19=ifelse(is.na(df$flu_vaccine_tpp_2019),0,1)
df$fluvac20=ifelse(is.na(df$flu_vaccine_tpp_2020),0,1)
df$fluvac21=ifelse(is.na(df$flu_vaccine_tpp_2021),0,1)
df$fluvac22=ifelse(is.na(df$flu_vaccine_tpp_2022),0,1)

 
# # # # ## Any covid vaccine
df$covrx1=ifelse(is.na(df$covrx1_dat),0,1)
df$covrx2=ifelse(is.na(df$covrx2_dat),0,1)
df$covrx=ifelse(df$covrx1 >0 | df$covrx2 >0, 1, 0)
df$covrx <- as.factor(df$covrx)


df$covrx_sgss1=ifelse(is.na(df$Covid_test_result_sgss_1_DATE),0,1)
df$covrx_sgss2=ifelse(is.na(df$Covid_test_result_sgss_2_DATE),0,1)
df$covrx_sgss=ifelse(df$covrx_sgss1 >0 | df$covrx_sgss2 >0, 1, 0)
df$covrx_sgss <- as.factor(df$covrx_sgss)


df$covrx_vaccin_gp1=ifelse(is.na(df$date_vaccin_gp_1),0,1)
df$covrx_vaccin_gp2=ifelse(is.na(df$date_vaccin_gp_2),0,1)
df$covrx_vaccin_gp=ifelse(df$covrx_vaccin_gp1 >0 | df$covrx_vaccin_gp2 >0, 1, 0)
df$covrx_vaccin_gp <- as.factor(df$covrx_vaccin_gp)


# # ever died
df$died_ever <- ifelse(is.na(df$died_date),0,1)
df$died_ever <- as.factor(df$died_ever)

# ## covid positive ever
df$covid_positive=ifelse(df$Covid_test_result_sgss_1 >0 | df$Covid_test_result_sgss_2 >0, 1, 0)
df$covid_positive<-as.factor(df$covid_positive)


# generate data table 
# remove practice and patient ID

df2<- select(df, age, age_cat, sex, gp_covid_count,
             antibiotics_prescriptions, broad_spectrum_antibiotics_prescriptions,
             fluvac19, fluvac20, fluvac21, fluvac22,
             covrx, covrx_sgss, covrx_vaccin_gp,
             died_ever, covid_positive)
# # columns for baseline table
colsfortab <- colnames(df2)
df %>% summary_factorlist(explanatory = colsfortab) -> t
write_csv(t, here::here("output", "blt_covid_check.csv"))