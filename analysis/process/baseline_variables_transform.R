## Import libraries---
library("tidyverse") 
library('dplyr')
library('lubridate')

rm(list=ls())
setwd(here::here("output", "measures"))

# file list
csvFiles_19 = list.files(pattern="input_2019", full.names = FALSE)
csvFiles_20 = list.files(pattern="input_2020", full.names = FALSE)
csvFiles_21 = list.files(pattern="input_2021", full.names = FALSE)
csvFiles_22 = list.files(pattern="input_2022", full.names = FALSE)


# date list
date_19= seq(as.Date("2019-01-01"), as.Date("2019-12-01"), "month")
date_20= seq(as.Date("2020-01-01"), as.Date("2020-12-01"), "month")
date_21= seq(as.Date("2021-01-01"), as.Date("2021-12-01"), "month")
date_22= seq(as.Date("2022-01-01"), as.Date("2022-12-01"), "month")


temp <- vector("list", length(csvFiles_19))
for (i in seq_along(csvFiles_19)){
  temp_df <- read_csv((csvFiles_19[i]),
                    col_types = cols_only(
                        #bmi_date_measured = col_date(format = "")
                        # smoking_status_date = col_logical(),
                        #most_recent_unclear_smoking_cat_date = col_logical(),
                        #flu_vaccine_med = col_character(),
                        #flu_vaccine_clinical = col_character(),
                        #first_positive_test_date_sgss = col_logical(),
                        #gp_covid_date = col_logical(),
                        covrx1_dat = col_date(format = ""),
                        covrx2_dat = col_date(format = ""),
                        died_date = col_date(format = ""),
                        age = col_integer(),
                        age_cat = col_character(),
                        sex = col_character(),
                        practice = col_integer(),
                        region = col_factor(),
                        #msoa = col_character(),
                        imd = col_integer(),
                        bmi = col_number(),
                        ethnicity = col_factor(),
                        smoking_status = col_character(),
                        gp_count = col_integer(),
                        #flu_vaccine_tpp = col_double(),
                        flu_vaccine = col_integer(),
                        antibacterial_brit = col_integer(),
                        #antibacterial_brit_abtype = col_character(),
                        antibacterial_12mb4 = col_integer(),
                        broad_spectrum_antibiotics_prescriptions = col_integer(),
                        #broad_prescriptions_check = col_double(),
                        Covid_test_result_sgss = col_integer(),
                        #covid_positive_count_sgss = col_double(),
                        #sgss_ab_prescribed = col_double(),
                        #gp_covid = col_double(),
                        #gp_covid_count = col_double(),
                        #gp_covid_ab_prescribed = col_double(),
                        #uti_counts = col_double(),
                        #lrti_counts = col_double(),
                        #urti_counts = col_double(),
                        #sinusitis_counts = col_double(),
                        #ot_externa_counts = col_double(),
                        #otmedia_counts = col_double(),
                        #incdt_uti_pt = col_double(),
                        #incdt_lrti_pt = col_double(),
                        #incdt_urti_pt = col_double(),
                        #incdt_sinusitis_pt = col_double(),
                        #incdt_ot_externa_pt = col_double(),
                        #incdt_otmedia_pt = col_double(),
                        hx_indications = col_integer(),
                        hx_antibiotics = col_integer(),
                        cancer_comor = col_integer(),
                        cardiovascular_comor = col_integer(),
                        chronic_obstructive_pulmonary_comor = col_integer(),
                        heart_failure_comor = col_integer(),
                        connective_tissue_comor = col_integer(),
                        dementia_comor = col_integer(),
                        diabetes_comor = col_integer(),
                        diabetes_complications_comor = col_integer(),
                        hemiplegia_comor = col_integer(),
                        hiv_comor = col_integer(),
                        metastatic_cancer_comor = col_integer(),
                        mild_liver_comor = col_integer(),
                        mod_severe_liver_comor = col_integer(),
                        mod_severe_renal_comor = col_integer(),
                        mi_comor = col_integer(),
                        peptic_ulcer_comor = col_integer(),
                        peripheral_vascular_comor = col_integer(),
                        patient_id = col_integer()
                    ),
                    na = character()
)

  temp_df$date=date_19[i]
  
  #add df to list
  temp[[i]] <- temp_df
  rm(temp_df)
}

dat=dplyr::bind_rows(temp)
rm(temp,i,date_19,csvFiles_19)

dat$date <- as.Date(dat$date)

saveRDS(dat, "basic_record_2019.rds")
rm(dat)

temp <- vector("list", length(csvFiles_20))
for (i in seq_along(csvFiles_20)){
  temp_df <- read_csv((csvFiles_20[i]),
                    col_types = cols_only(
                        #bmi_date_measured = col_date(format = "")
                        # smoking_status_date = col_logical(),
                        #most_recent_unclear_smoking_cat_date = col_logical(),
                        #flu_vaccine_med = col_character(),
                        #flu_vaccine_clinical = col_character(),
                        #first_positive_test_date_sgss = col_logical(),
                        #gp_covid_date = col_logical(),
                        covrx1_dat = col_date(format = ""),
                        covrx2_dat = col_date(format = ""),
                        died_date = col_date(format = ""),
                        age = col_integer(),
                        age_cat = col_character(),
                        sex = col_character(),
                        practice = col_integer(),
                        region = col_factor(),
                        #msoa = col_character(),
                        imd = col_integer(),
                        bmi = col_number(),
                        ethnicity = col_factor(),
                        smoking_status = col_character(),
                        gp_count = col_integer(),
                        #flu_vaccine_tpp = col_double(),
                        flu_vaccine = col_integer(),
                        antibacterial_brit = col_integer(),
                        #antibacterial_brit_abtype = col_character(),
                        antibacterial_12mb4 = col_integer(),
                        broad_spectrum_antibiotics_prescriptions = col_integer(),
                        #broad_prescriptions_check = col_double(),
                        Covid_test_result_sgss = col_integer(),
                        #covid_positive_count_sgss = col_double(),
                        #sgss_ab_prescribed = col_double(),
                        #gp_covid = col_double(),
                        #gp_covid_count = col_double(),
                        #gp_covid_ab_prescribed = col_double(),
                        #uti_counts = col_double(),
                        #lrti_counts = col_double(),
                        #urti_counts = col_double(),
                        #sinusitis_counts = col_double(),
                        #ot_externa_counts = col_double(),
                        #otmedia_counts = col_double(),
                        #incdt_uti_pt = col_double(),
                        #incdt_lrti_pt = col_double(),
                        #incdt_urti_pt = col_double(),
                        #incdt_sinusitis_pt = col_double(),
                        #incdt_ot_externa_pt = col_double(),
                        #incdt_otmedia_pt = col_double(),
                        hx_indications = col_integer(),
                        hx_antibiotics = col_integer(),
                        cancer_comor = col_integer(),
                        cardiovascular_comor = col_integer(),
                        chronic_obstructive_pulmonary_comor = col_integer(),
                        heart_failure_comor = col_integer(),
                        connective_tissue_comor = col_integer(),
                        dementia_comor = col_integer(),
                        diabetes_comor = col_integer(),
                        diabetes_complications_comor = col_integer(),
                        hemiplegia_comor = col_integer(),
                        hiv_comor = col_integer(),
                        metastatic_cancer_comor = col_integer(),
                        mild_liver_comor = col_integer(),
                        mod_severe_liver_comor = col_integer(),
                        mod_severe_renal_comor = col_integer(),
                        mi_comor = col_integer(),
                        peptic_ulcer_comor = col_integer(),
                        peripheral_vascular_comor = col_integer(),
                        patient_id = col_integer()
                    ),
                    na = character()
)

  temp_df$date=date_20[i]
  
  #add df to list
  temp[[i]] <- temp_df
  rm(temp_df)
}

dat=dplyr::bind_rows(temp)
rm(temp,i,date_20,csvFiles_20)

dat$date <- as.Date(dat$date)

saveRDS(dat, "basic_record_2020.rds")
rm(dat)

temp <- vector("list", length(csvFiles_21))
for (i in seq_along(csvFiles_21)){
  temp_df <- read_csv((csvFiles_21[i]),
                    col_types = cols_only(
                        #bmi_date_measured = col_date(format = "")
                        # smoking_status_date = col_logical(),
                        #most_recent_unclear_smoking_cat_date = col_logical(),
                        #flu_vaccine_med = col_character(),
                        #flu_vaccine_clinical = col_character(),
                        #first_positive_test_date_sgss = col_logical(),
                        #gp_covid_date = col_logical(),
                        covrx1_dat = col_date(format = ""),
                        covrx2_dat = col_date(format = ""),
                        died_date = col_date(format = ""),
                        age = col_integer(),
                        age_cat = col_character(),
                        sex = col_character(),
                        practice = col_integer(),
                        region = col_factor(),
                        #msoa = col_character(),
                        imd = col_integer(),
                        bmi = col_number(),
                        ethnicity = col_factor(),
                        smoking_status = col_character(),
                        gp_count = col_integer(),
                        #flu_vaccine_tpp = col_double(),
                        flu_vaccine = col_integer(),
                        antibacterial_brit = col_integer(),
                        #antibacterial_brit_abtype = col_character(),
                        antibacterial_12mb4 = col_integer(),
                        broad_spectrum_antibiotics_prescriptions = col_integer(),
                        #broad_prescriptions_check = col_double(),
                        Covid_test_result_sgss = col_integer(),
                        #covid_positive_count_sgss = col_double(),
                        #sgss_ab_prescribed = col_double(),
                        #gp_covid = col_double(),
                        #gp_covid_count = col_double(),
                        #gp_covid_ab_prescribed = col_double(),
                        #uti_counts = col_double(),
                        #lrti_counts = col_double(),
                        #urti_counts = col_double(),
                        #sinusitis_counts = col_double(),
                        #ot_externa_counts = col_double(),
                        #otmedia_counts = col_double(),
                        #incdt_uti_pt = col_double(),
                        #incdt_lrti_pt = col_double(),
                        #incdt_urti_pt = col_double(),
                        #incdt_sinusitis_pt = col_double(),
                        #incdt_ot_externa_pt = col_double(),
                        #incdt_otmedia_pt = col_double(),
                        hx_indications = col_integer(),
                        hx_antibiotics = col_integer(),
                        cancer_comor = col_integer(),
                        cardiovascular_comor = col_integer(),
                        chronic_obstructive_pulmonary_comor = col_integer(),
                        heart_failure_comor = col_integer(),
                        connective_tissue_comor = col_integer(),
                        dementia_comor = col_integer(),
                        diabetes_comor = col_integer(),
                        diabetes_complications_comor = col_integer(),
                        hemiplegia_comor = col_integer(),
                        hiv_comor = col_integer(),
                        metastatic_cancer_comor = col_integer(),
                        mild_liver_comor = col_integer(),
                        mod_severe_liver_comor = col_integer(),
                        mod_severe_renal_comor = col_integer(),
                        mi_comor = col_integer(),
                        peptic_ulcer_comor = col_integer(),
                        peripheral_vascular_comor = col_integer(),
                        patient_id = col_integer()
                    ),
                    na = character()
)

  temp_df$date=date_21[i]
  
  #add df to list
  temp[[i]] <- temp_df
  rm(temp_df)
}

dat=dplyr::bind_rows(temp)
rm(temp,i,date_21,csvFiles_21)

dat$date <- as.Date(dat$date)

saveRDS(dat, "basic_record_2021.rds")
rm(dat)

temp <- vector("list", length(csvFiles_22))
for (i in seq_along(csvFiles_22)){
  temp_df <- read_csv((csvFiles_22[i]),
                    col_types = cols_only(
                        #bmi_date_measured = col_date(format = "")
                        # smoking_status_date = col_logical(),
                        #most_recent_unclear_smoking_cat_date = col_logical(),
                        #flu_vaccine_med = col_character(),
                        #flu_vaccine_clinical = col_character(),
                        #first_positive_test_date_sgss = col_logical(),
                        #gp_covid_date = col_logical(),
                        covrx1_dat = col_date(format = ""),
                        covrx2_dat = col_date(format = ""),
                        died_date = col_date(format = ""),
                        age = col_integer(),
                        age_cat = col_character(),
                        sex = col_character(),
                        practice = col_integer(),
                        region = col_factor(),
                        #msoa = col_character(),
                        imd = col_integer(),
                        bmi = col_number(),
                        ethnicity = col_factor(),
                        smoking_status = col_character(),
                        gp_count = col_integer(),
                        #flu_vaccine_tpp = col_double(),
                        flu_vaccine = col_integer(),
                        antibacterial_brit = col_integer(),
                        #antibacterial_brit_abtype = col_character(),
                        antibacterial_12mb4 = col_integer(),
                        broad_spectrum_antibiotics_prescriptions = col_integer(),
                        #broad_prescriptions_check = col_double(),
                        Covid_test_result_sgss = col_integer(),
                        #covid_positive_count_sgss = col_double(),
                        #sgss_ab_prescribed = col_double(),
                        #gp_covid = col_double(),
                        #gp_covid_count = col_double(),
                        #gp_covid_ab_prescribed = col_double(),
                        #uti_counts = col_double(),
                        #lrti_counts = col_double(),
                        #urti_counts = col_double(),
                        #sinusitis_counts = col_double(),
                        #ot_externa_counts = col_double(),
                        #otmedia_counts = col_double(),
                        #incdt_uti_pt = col_double(),
                        #incdt_lrti_pt = col_double(),
                        #incdt_urti_pt = col_double(),
                        #incdt_sinusitis_pt = col_double(),
                        #incdt_ot_externa_pt = col_double(),
                        #incdt_otmedia_pt = col_double(),
                        hx_indications = col_integer(),
                        hx_antibiotics = col_integer(),
                        cancer_comor = col_integer(),
                        cardiovascular_comor = col_integer(),
                        chronic_obstructive_pulmonary_comor = col_integer(),
                        heart_failure_comor = col_integer(),
                        connective_tissue_comor = col_integer(),
                        dementia_comor = col_integer(),
                        diabetes_comor = col_integer(),
                        diabetes_complications_comor = col_integer(),
                        hemiplegia_comor = col_integer(),
                        hiv_comor = col_integer(),
                        metastatic_cancer_comor = col_integer(),
                        mild_liver_comor = col_integer(),
                        mod_severe_liver_comor = col_integer(),
                        mod_severe_renal_comor = col_integer(),
                        mi_comor = col_integer(),
                        peptic_ulcer_comor = col_integer(),
                        peripheral_vascular_comor = col_integer(),
                        patient_id = col_integer()
                    ),
                    na = character()
)

  temp_df$date=date_22[i]
  
  #add df to list
  temp[[i]] <- temp_df
  rm(temp_df)
}

dat=dplyr::bind_rows(temp)
rm(temp,i,date_22,csvFiles_22)

dat$date <- as.Date(dat$date)

saveRDS(dat, "basic_record_2022.rds")
rm(dat)

