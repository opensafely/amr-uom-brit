###This script use the cci records in Jan 2019 to calculate the cci score

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

df_input <- df_input %>% select(practice,cancer_comor,cardiovascular_comor,
                                chronic_obstructive_pulmonary_comor,heart_failure_comor,
                                connective_tissue_comor,dementia_comor,diabetes_comor,
                                diabetes_complications_comor,hemiplegia_comor,hiv_comor,
                                metastatic_cancer_comor,mild_liver_comor,mod_severe_liver_comor,
                                mod_severe_renal_comor,mi_comor,peptic_ulcer_comor,
                                peripheral_vascular_comor,       
                                patient_id,date)

last.date=max(df_input$date)
df=df_input%>% filter(date!=last.date)

df_input$cancer<- ifelse(df_input$cancer_comor == 1, 2, 0)
df_input<-df_input%>%select(-cancer_comor)
df_input$cvd <- ifelse(df_input$cardiovascular_comor == 1, 1, 0)
df_input<-df_input%>%select(-cardiovascular_comor)
df_input$copd <- ifelse(df_input$chronic_obstructive_pulmonary_comor == 1, 1, 0)
df_input<-df_input%>%select(-chronic_obstructive_pulmonary_comor)
df_input$heart_failure <- ifelse(df_input$heart_failure_comor == 1, 1, 0)
df_input<-df_input%>%select(-heart_failure_comor)
df_input$connective_tissue <- ifelse(df_input$connective_tissue_comor == 1, 1, 0)
df_input<-df_input%>%select(-connective_tissue_comor)
df_input$dementia <- ifelse(df_input$dementia_comor == 1, 1, 0)
df_input<-df_input%>%select(-dementia_comor)
df_input$diabetes <- ifelse(df_input$diabetes_comor == 1, 1, 0)
df_input<-df_input%>%select(-diabetes_comor)
df_input$diabetes_complications <- ifelse(df_input$diabetes_complications_comor == 1, 2, 0)
df_input<-df_input%>%select(-diabetes_complications_comor)
df_input$hemiplegia <- ifelse(df_input$hemiplegia_comor == 1, 2, 0)
df_input<-df_input%>%select(-hemiplegia_comor)
df_input$hiv <- ifelse(df_input$hiv_comor == 1, 6, 0)
df_input<-df_input%>%select(-hiv_comor)
df_input$metastatic_cancer <- ifelse(df_input$metastatic_cancer_comor == 1, 6, 0)
df_input<-df_input%>%select(-metastatic_cancer_comor)
df_input$mild_liver <- ifelse(df_input$mild_liver_comor == 1, 1, 0)
df_input<-df_input%>%select(-mild_liver_comor)
df_input$mod_severe_liver <- ifelse(df_input$mod_severe_liver_comor == 1, 3, 0)
df_input<-df_input%>%select(-mod_severe_liver_comor)
df_input$mod_severe_renal <- ifelse(df_input$mod_severe_renal_comor == 1, 2, 0)
df_input<-df_input%>%select(-mod_severe_renal_comor)
df_input$mi <- ifelse(df_input$mi_comor == 1, 1, 0)
df_input<-df_input%>%select(-mi_comor)
df_input$peptic_ulcer <- ifelse(df_input$peptic_ulcer_comor == 1, 1, 0)
df_input<-df_input%>%select(-peptic_ulcer_comor)
df_input$peripheral_vascular <- ifelse(df_input$peripheral_vascular_comor == 1, 1, 0)
df_input<-df_input%>%select(-peripheral_vascular_comor)


## total charlson for each patient 
charlson=c("cancer","cvd", "copd", "heart_failure", "connective_tissue",
           "dementia", "diabetes", "diabetes_complications", "hemiplegia",
           "hiv", "metastatic_cancer", "mild_liver", "mod_severe_liver", 
           "mod_severe_renal", "mi", "peptic_ulcer", "peripheral_vascular")
df_input$charlson_score=rowSums(df_input[charlson])

df_input <- df_input%>%select(charlson_score,practice, patient_id,date)
## Charlson - as a catergorical group variable
df_input <- df_input %>%
  mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
                                 charlson_score >2 & charlson_score <=4 ~ 3,
                                 charlson_score >4 & charlson_score <=6 ~ 4,
                                 charlson_score >=7 ~ 5,
                                 charlson_score == 0 ~ 1))

df_input$charlsonGrp <- as.factor(df_input$charlsonGrp)
df_input$charlsonGrp <- factor(df_input$charlsonGrp, 
                               labels = c("zero", "low", "medium", "high", "very high"))

saveRDS(df_input, "model_variable_broad_2022_2.rds")

colsfortab <- colnames(df_input)[-c(2:3)] # patient ID, practice id
df_input %>% summary_factorlist(explanatory = colsfortab) -> t

write_csv(t, here::here("output", "model_varibale_table_charlson_2022.csv"))