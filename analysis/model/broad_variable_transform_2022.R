###This script keep all the variables apart from charlson score

library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("lubridate")
# library("survival")
library("ggpubr")
library("finalfit")


rm(list=ls())
setwd(here::here("output", "measures"))

df_input <- read_rds('basic_record_2022.rds')

df_input <- df_input %>% select(died_date,age,age_cat,sex,practice,bmi,region,
                                ethnicity,gp_count,flu_vaccine,antibacterial_12mb4,
                                smoking_status,covrx1_dat,covrx2_dat,died_date,
                                Covid_test_result_sgss,hx_indications,hx_antibiotics,             
                                patient_id,date,imd)


last.date=max(df_input$date)
df_input=df_input%>% filter(date!=last.date)

#bmi 
#remove very low observations
df_input$bmi <- ifelse(df_input$bmi <8 | df_input$bmi>50, NA, df_input$bmi)
# bmi categories 
df_input<- df_input %>% 
  mutate(bmi_cat = case_when(is.na(bmi) ~ "unknown",
                             bmi>=8 & bmi< 18.5 ~ "underweight",
                             bmi>=18.5 & bmi<=24.9 ~ "healthy weight",
                             bmi>24.9 & bmi<=29.9 ~ "overweight",
                             bmi>29.9 ~"obese"))
df_input$bmi_cat<- as.factor(df_input$bmi_cat)

df_input$age_cat<- as.factor(df_input$age_cat)
df_input$region<- as.factor(df_input$region)

# imd levels
#summary(df_one_pat$imd) #str(df_one_pat$imd) ## int 0,1,2,3,4,5
# make it a factor variable and 0 is missing
df_input$imd<- as.factor(df_input$imd)

## ethnicity
df_input$ethnicity=ifelse(is.na(df_input$ethnicity),"6",df_input$ethnicity)
df_input <- df_input %>% 
  mutate(ethnicity_6 = case_when(ethnicity == 1 ~ "White",
                                 ethnicity == 2  ~ "Mixed",
                                 ethnicity == 3  ~ "South Asian",
                                 ethnicity == 4  ~ "Black",
                                 ethnicity == 5  ~ "Other",
                                 ethnicity == 6   ~ "Unknown"))
df_input$ethnicity_6 <- as.factor(df_input$ethnicity_6)

# count of GP consultations in 12m before random index date
df_input$gp_count <- ifelse(df_input$gp_count > 0, 
                            df_input$gp_count, 0)

### flu vac in 12m before random index date
#summary(df_one_pat$flu_vaccine)
df_input$flu_vaccine <- as.factor(df_input$flu_vaccine)

### smoking status
df_input <- df_input %>% 
  mutate(smoking_cat = case_when(smoking_status=="S" ~ "current",
                                 smoking_status=="E" ~ "former",
                                 smoking_status=="N" ~ "never",
                                 smoking_status=="M"| smoking_status=="" ~ "unknown"))
df_input$smoking_cat<- as.factor(df_input$smoking_cat)

## any covid vaccine

df_input$covrx1=ifelse(is.na(df_input$covrx1_dat),0,1)
df_input$covrx2=ifelse(is.na(df_input$covrx2_dat),0,1)
df_input$covrx=ifelse(df_input$covrx1 >0 | df_input$covrx2 >0, 1, 0)
df_input$covrx <- as.factor(df_input$covrx)

# ever died
df_input$died_ever <- ifelse(is.na(df_input$died_date),0,1)
df_input$died_ever <- as.factor(df_input$died_ever)

## covid positive ever
df_input$Covid_test_result_sgss<- as.factor(df_input$Covid_test_result_sgss)

## 
df_input$hx_indications <- as.factor(df_input$hx_indications)
df_input$hx_antibiotics <- as.factor(df_input$hx_antibiotics)

df <- select(df_input, date, patient_id, practice, age_cat, bmi, 
             bmi_cat, ethnicity_6, #charlson_score, charlsonGrp,
             smoking_cat,Covid_test_result_sgss,hx_indications,
             hx_antibiotics,covrx,died_ever,
             flu_vaccine, imd, antibacterial_12mb4, gp_count) 
rm(df_input)

saveRDS(df, "model_variable_broad_2022_1.rds")
