
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate charlson comorbidity scores and baseline table for service evaluation
# # # # # # # # # # # # # # # # # # # # #

## install package
#install.packages("tableone")

## Import libraries---
library("tidyverse") 
#library("ggplot2")
library('plyr')
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")
library("finalfit")
#library("tableone")
#library("gtsummary")

setwd(here::here("output", "measures"))

### read data  ###
### 1.1 import patient-level data(study definition input.csv) to summarize antibiotics counts
############ loop reading multiple CSV files ################
# read file list from input.csv
csvFiles = list.files(pattern="input_2", full.names = TRUE)
temp <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles)){
  filename <- csvFiles[i]
  #temp_df <- read_csv(filename)
 temp_df <- read_csv((filename),
                      col_types = cols_only(
                        #bmi_date_measured = col_date(format = "")
                        #smoking_status_date = col_logical(),
                        #most_recent_unclear_smoking_cat_date = col_logical(),
                        #flu_vaccine_med = col_character(),
                        #flu_vaccine_clinical = col_character(),
                        #first_positive_test_date_sgss = col_logical(),
                        #gp_covid_date = col_logical(),
                        covrx1_dat = col_date(format = ""),
                        covrx2_dat = col_date(format = ""),
                        died_date = col_date(format = ""),
                        age = col_double(),
                        age_cat = col_character(),
                        sex = col_character(),
                        practice = col_double(),
                        region = col_character(),
                        msoa = col_character(),
                        imd = col_double(),
                        bmi = col_double(),
                        ethnicity = col_double(),
                        smoking_status = col_character(),
                        gp_count = col_double(),
                        #flu_vaccine_tpp = col_double(),
                        flu_vaccine = col_double(),
                        antibacterial_brit = col_double(),
                        #antibacterial_brit_abtype = col_character(),
                        antibacterial_12mb4 = col_double(),
                        broad_spectrum_antibiotics_prescriptions = col_double(),
                        #broad_prescriptions_check = col_double(),
                        Covid_test_result_sgss = col_double(),
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
                        hx_indications = col_double(),
                        hx_antibiotics = col_double(),
                        cancer_comor = col_double(),
                        cardiovascular_comor = col_double(),
                        chronic_obstructive_pulmonary_comor = col_double(),
                        heart_failure_comor = col_double(),
                        connective_tissue_comor = col_double(),
                        dementia_comor = col_double(),
                        diabetes_comor = col_double(),
                        diabetes_complications_comor = col_double(),
                        hemiplegia_comor = col_double(),
                        hiv_comor = col_double(),
                        metastatic_cancer_comor = col_double(),
                        mild_liver_comor = col_double(),
                        mod_severe_liver_comor = col_double(),
                        mod_severe_renal_comor = col_double(),
                        mi_comor = col_double(),
                        peptic_ulcer_comor = col_double(),
                        peripheral_vascular_comor = col_double(),
                        patient_id = col_double()
                      ),
                      na = character()
  )


  filename <- basename(filename)
  filename <-str_remove(filename, "input_")
  filename <-str_remove(filename, ".csv.gz")
  
    
  #add to per-month temp df
  temp_df$date <- filename
  mutate(temp_df, date = as.Date(date, "%Y-%m-%d"))
    
  #add df to list
  temp[[i]] <- temp_df
}


# combine list -> data.table/data.frame
df_input <- plyr::ldply(temp, data.frame)
rm(temp,csvFiles,i)# remove temporary list

df_input$date <- as.Date(df_input$date)
df_input$cal_mon <- month(df_input$date)
df_input$cal_year <- year(df_input$date)
 
# remove last month data
last.date=max(df_input$date)
df=df_input%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))
num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))

  
## randomly select one observation for each patient 
## in the study period to generate baseline table for service evaluation
df_one_pat <- df %>% dplyr::group_by(patient_id) %>%
  dplyr::arrange(date, .group_by=TRUE) %>%
  sample_n(1)
num_pats2 <- length(unique(df_one_pat$patient_id))
num_pracs2 <- length(unique(df_one_pat$practice))

overall_counts <- as.data.frame(cbind(first_mon, last_mon, num_pats, num_pracs, num_pats2, num_pracs2))
write_csv(overall_counts, here::here("output", "overall_counts_blt_split.csv"))

## clear environment to make more space on server...? 
rm(df_input, df)  

## create charlson index
df_one_pat$cancer<- ifelse(df_one_pat$cancer_comor == 1, 2, 0)
df_one_pat$cvd <- ifelse(df_one_pat$cardiovascular_comor == 1, 1, 0)
df_one_pat$copd <- ifelse(df_one_pat$chronic_obstructive_pulmonary_comor == 1, 1, 0)
df_one_pat$heart_failure <- ifelse(df_one_pat$heart_failure_comor == 1, 1, 0)
df_one_pat$connective_tissue <- ifelse(df_one_pat$connective_tissue_comor == 1, 1, 0)
df_one_pat$dementia <- ifelse(df_one_pat$dementia_comor == 1, 1, 0)
df_one_pat$diabetes <- ifelse(df_one_pat$diabetes_comor == 1, 1, 0)
df_one_pat$diabetes_complications <- ifelse(df_one_pat$diabetes_complications_comor == 1, 2, 0)
df_one_pat$hemiplegia <- ifelse(df_one_pat$hemiplegia_comor == 1, 2, 0)
df_one_pat$hiv <- ifelse(df_one_pat$hiv_comor == 1, 6, 0)
df_one_pat$metastatic_cancer <- ifelse(df_one_pat$metastatic_cancer_comor == 1, 6, 0)
df_one_pat$mild_liver <- ifelse(df_one_pat$mild_liver_comor == 1, 1, 0)
df_one_pat$mod_severe_liver <- ifelse(df_one_pat$mod_severe_liver_comor == 1, 3, 0)
df_one_pat$mod_severe_renal <- ifelse(df_one_pat$mod_severe_renal_comor == 1, 2, 0)
df_one_pat$mi <- ifelse(df_one_pat$mi_comor == 1, 1, 0)
df_one_pat$peptic_ulcer <- ifelse(df_one_pat$peptic_ulcer_comor == 1, 1, 0)
df_one_pat$peripheral_vascular <- ifelse(df_one_pat$peripheral_vascular_comor == 1, 1, 0)

## total charlson for each patient 
charlson=c("cancer","cvd", "copd", "heart_failure", "connective_tissue",
        "dementia", "diabetes", "diabetes_complications", "hemiplegia",
        "hiv", "metastatic_cancer", "mild_liver", "mod_severe_liver", 
        "mod_severe_renal", "mi", "peptic_ulcer", "peripheral_vascular")
df_one_pat$charlson_score=rowSums(df_one_pat[charlson])

## Charlson - as a catergorical group variable
df_one_pat <- df_one_pat %>%
  mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                charlson_score >2 & charlson_score <=4 ~ 3,
                                charlson_score >4 & charlson_score <=6 ~ 4,
                                charlson_score >=7 ~ 5,
                                charlson_score == 0 ~ 1))

df_one_pat$charlsonGrp <- as.factor(df_one_pat$charlsonGrp)
df_one_pat$charlsonGrp <- factor(df_one_pat$charlsonGrp, 
                                 labels = c("zero", "low", "medium", "high", "very high"))

chars<- df_one_pat %>% dplyr::group_by(charlsonGrp) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentChar= (n/total)*100)
write_csv(chars, here::here("output", "chars_blt.csv"))


#bmi 
#remove very low observations
df_one_pat$bmi <- ifelse(df_one_pat$bmi <8 | df_one_pat$bmi>50, NA, df_one_pat$bmi)
# bmi categories 
df_one_pat<- df_one_pat %>% 
  mutate(bmi_cat = case_when(is.na(bmi) ~ "unknown",
                             bmi>=8 & bmi< 18.5 ~ "underweight",
                             bmi>=18.5 & bmi<=24.9 ~ "healthy weight",
                             bmi>24.9 & bmi<=29.9 ~ "overweight",
                             bmi>29.9 ~"obese"))
df_one_pat$bmi_cat<- as.factor(df_one_pat$bmi_cat)
#summary(df_one_pat$bmi_cat)

bmi_bl <- df_one_pat %>% dplyr::group_by(bmi_cat) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentBMI= (n/total)*100)
write_csv(bmi_bl, here::here("output", "bmi_blt.csv"))

df_one_pat$age_cat<- as.factor(df_one_pat$age_cat)
age_bl <- df_one_pat %>% dplyr::group_by(age_cat) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentAge= (n/total)*100)
write_csv(age_bl, here::here("output", "age_blt.csv"))

df_one_pat$region<- as.factor(df_one_pat$region)
region_bl <- df_one_pat %>% dplyr::group_by(region) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentRegion= (n/total)*100)
write_csv(region_bl, here::here("output", "region_blt.csv"))


# smoking
#str(df_one_pat$smoking_status) #factor with 5 levels - so doesnt recognise missing values
df_one_pat <- df_one_pat %>% 
  mutate(smoking_cat = case_when(smoking_status=="S" ~ "current",
                                 smoking_status=="E" ~ "former",
                                 smoking_status=="N" ~ "never",
                                 smoking_status=="M"| smoking_status=="" ~ "unknown"))
df_one_pat$smoking_cat<- as.factor(df_one_pat$smoking_cat)
#summary(df_one_pat$smoking_cat)
smoke_bl <- df_one_pat %>% dplyr::group_by(region) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentSmoke= (n/total)*100)
write_csv(smoke_bl, here::here("output", "smoke_blt.csv"))


# imd levels
#summary(df_one_pat$imd) #str(df_one_pat$imd) ## int 0,1,2,3,4,5
# make it a factor variable and 0 is missing
df_one_pat$imd<- as.factor(df_one_pat$imd)
imd_bl <- df_one_pat %>% dplyr::group_by(imd) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentIMD= (n/total)*100)
write_csv(imd_bl, here::here("output", "imd_blt.csv"))

## ethnicity
df_one_pat$ethnicity=ifelse(is.na(df_one_pat$ethnicity),"6",df_one_pat$ethnicity)
df_one_pat <- df_one_pat %>% 
  mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                 ethnicity == 2  ~ "Mixed",
                                 ethnicity == 3  ~ "South Asian",
                                 ethnicity == 4  ~ "Black",
                                 ethnicity == 5  ~ "Other",
                                 ethnicity == 6   ~ "Unknown"))
df_one_pat$ethnicity_6 <- as.factor(df_one_pat$ethnicity_6)
#table(df_one_pat$ethnicity_6)
enth_bl <- df_one_pat %>% dplyr::group_by(ethnicity_6) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentEth= (n/total)*100)
write_csv(enth_bl, here::here("output", "eth_blt.csv"))


# count of GP consultations in 12m before random index date
#summary(df_one_pat$gp_count) #negative values in dummy data
df_one_pat$gp_count <- ifelse(df_one_pat$gp_count > 0, 
                              df_one_pat$gp_count, 0)

gp_count_bl <- df_one_pat %>% dplyr::group_by(gp_count) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentGP_count= (n/total)*100)
write_csv(gp_count_bl, here::here("output", "gp_count_blt.csv"))

### flu vac in 12m before random index date
#summary(df_one_pat$flu_vaccine)
df_one_pat$flu_vaccine <- as.factor(df_one_pat$flu_vaccine)
flu_vaccine_bl <- df_one_pat %>% dplyr::group_by(flu_vaccine) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentFLU= (n/total)*100)
write_csv(flu_vaccine_bl, here::here("output", "flu_vac_blt.csv"))


# ## Any covid vaccine
df_one_pat$covrx1=ifelse(is.na(df_one_pat$covrx1_dat),0,1)
df_one_pat$covrx2=ifelse(is.na(df_one_pat$covrx2_dat),0,1)
df_one_pat$covrx=ifelse(df_one_pat$covrx1 >0 | df_one_pat$covrx2 >0, 1, 0)
df_one_pat$covrx <- as.factor(df_one_pat$covrx)
covrx_bl <- df_one_pat %>% dplyr::group_by(covrx) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentCovrx= (n/total)*100)
write_csv(covrx_bl, here::here("output", "covrx_blt.csv"))


# ever died
df_one_pat$died_ever <- ifelse(is.na(df_one_pat$died_date),0,1)
df_one_pat$died_ever <- as.factor(df_one_pat$died_ever)
#summary(df_one_pat$died_ever)
died_ever_bl <- df_one_pat %>% dplyr::group_by(died_ever) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentDied= (n/total)*100)
write_csv(died_ever_bl, here::here("output", "died_blt.csv"))

## covid positive ever
df_one_pat$covid_positive<- df_one_pat$Covid_test_result_sgss
df_one_pat$covid_positive<-as.factor(df_one_pat$covid_positive)
covid_positive_bl <- df_one_pat %>% dplyr::group_by(covid_positive) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percentCOVID= (n/total)*100)
write_csv(covid_positive_bl, here::here("output", "covid_blt.csv"))

df_one_pat$hx_indications <- as.factor(df_one_pat$hx_indications)
hx_indi_bl <- df_one_pat %>% dplyr::group_by(hx_indications) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percent_hx_indications= (n/total)*100)
write_csv(hx_indi_bl, here::here("output", "hx_indi_blt.csv"))

df_one_pat$hx_antibiotics <- as.factor(df_one_pat$hx_antibiotics)
hx_anti_bl <- df_one_pat %>% dplyr::group_by(hx_antibiotics) %>%
  dplyr::count(total=n()) %>%
  dplyr::mutate(percent_hx_antibiotics= (n/total)*100)
write_csv(hx_anti_bl, here::here("output", "hx_anti_blt.csv"))