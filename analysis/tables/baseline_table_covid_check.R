
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate baseline table to check new COVID variables by xtracting one cohort
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
    Covid_test_result_sgss_1 = col_date(format = ""),
    Covid_test_result_sgss_2 = col_date(format = ""),
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
write_csv(overall_counts_covid, here::here("output", "overall_covid.csv"))
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
# df$age_cat<- as.factor(df$age_cat)
# 
# # # count of GP consultations in 12m before random index date
# # 
# # ### flu vac in 12m before random index date
# # #summary(df$flu_vaccine)
# # df$flu_vaccine <- as.factor(df$flu_vaccine)
# # 
# # 
# # # ## Any covid vaccine
# # # str(df$covrx1_dat)
# # summary(df$covrx1_dat)
# # summary(df$covrx2_dat)
# df$covrx1=ifelse(is.na(df$covrx1_dat),0,1)
# df$covrx2=ifelse(is.na(df$covrx2_dat),0,1)
# df$covrx=ifelse(df$covrx1 >0 | df$covrx2 >0, 1, 0)
# df$covrx <- as.factor(df$covrx)
# # #summary(df$covrx)
# 
# # ever died
# df$died_ever <- ifelse(is.na(df$died_date),0,1)
# df$died_ever <- as.factor(df$died_ever)
# #summary(df$died_ever)
# 
# ## covid positive ever
# #df$covid_positive<- df$Covid_test_result_sgss
# #df$covid_positive<-as.factor(df$covid_positive)
# df$Covid_test_result_sgss<- as.factor(df$Covid_test_result_sgss)
# 
# df$hx_indications <- as.factor(df$hx_indications)
# df$hx_antibiotics <- as.factor(df$hx_antibiotics)
# 
# 
# ## select variables for the baseline table
# bltab_vars <- select(df, date, age, age_cat, sex, bmi, 
#                      bmi_cat, ethnicity_6, charlsonGrp, smoking_cat, 
#                      flu_vaccine, gp_count, antibacterial_brit,
#                      antibacterial_12mb4, broad_spectrum_antibiotics_prescriptions, 
#                      Covid_test_result_sgss, imd, hx_indications, hx_antibiotics, 
#                      covrx, died_ever) 
# 
# # generate data table 
# 
# 
# # columns for baseline table
# colsfortab <- colnames(bltab_vars)
# bltab_vars %>% summary_factorlist(explanatory = colsfortab) -> t
# #str(t)
# write_csv(t, here::here("output", "blt_one_random_obs_perpat.csv"))
# 
# ####### code for tableone package - not in OS platform yet
# #blt <- CreateTableOne(data=bltab_vars)
# #blt_all_levs <- print(blt, showAllLevels=T, quote=F)
# #View(blt_all_levs)
# #write.csv(blt_all_levs, "blt_one_random_obs_perpat.csv")
# 
# ####### code for tbl_summary() in gtsummary package
# #test <- bltab_vars %>% rownames_to_column()
# 
# 
