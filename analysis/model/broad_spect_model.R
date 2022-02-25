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

df_input <- read_rds('basic_record_2019.rds')

df_input <- df_input %>% select(died_date,age,age_cat,sex,practice,msoa,bmi,region,
                                ethnicity,gp_count,flu_vaccine,antibacterial_12mb4,             
                                patient_id,date,imd)

# df_input$cancer<- ifelse(df_input$cancer_comor == 1, 2, 0)
# df_input<-df_input%>%select(-cancer_comor)
# df_input$cvd <- ifelse(df_input$cardiovascular_comor == 1, 1, 0)
# df_input<-df_input%>%select(-cardiovascular_comor)
# df_input$copd <- ifelse(df_input$chronic_obstructive_pulmonary_comor == 1, 1, 0)
# df_input<-df_input%>%select(-chronic_obstructive_pulmonary_comor)
# df_input$heart_failure <- ifelse(df_input$heart_failure_comor == 1, 1, 0)
# df_input<-df_input%>%select(-heart_failure_comor)
# df_input$connective_tissue <- ifelse(df_input$connective_tissue_comor == 1, 1, 0)
# df_input<-df_input%>%select(-connective_tissue_comor)
# df_input$dementia <- ifelse(df_input$dementia_comor == 1, 1, 0)
# df_input<-df_input%>%select(-dementia_comor)
# df_input$diabetes <- ifelse(df_input$diabetes_comor == 1, 1, 0)
# df_input<-df_input%>%select(-diabetes_comor)
# df_input$diabetes_complications <- ifelse(df_input$diabetes_complications_comor == 1, 2, 0)
# df_input<-df_input%>%select(-diabetes_complications_comor)
# df_input$hemiplegia <- ifelse(df_input$hemiplegia_comor == 1, 2, 0)
# df_input<-df_input%>%select(-hemiplegia_comor)
# df_input$hiv <- ifelse(df_input$hiv_comor == 1, 6, 0)
# df_input<-df_input%>%select(-hiv_comor)
# df_input$metastatic_cancer <- ifelse(df_input$metastatic_cancer_comor == 1, 6, 0)
# df_input<-df_input%>%select(-metastatic_cancer_comor)
# df_input$mild_liver <- ifelse(df_input$mild_liver_comor == 1, 1, 0)
# df_input<-df_input%>%select(-mild_liver_comor)
# df_input$mod_severe_liver <- ifelse(df_input$mod_severe_liver_comor == 1, 3, 0)
# df_input<-df_input%>%select(-mod_severe_liver_comor)
# df_input$mod_severe_renal <- ifelse(df_input$mod_severe_renal_comor == 1, 2, 0)
# df_input<-df_input%>%select(-mod_severe_renal_comor)
# df_input$mi <- ifelse(df_input$mi_comor == 1, 1, 0)
# df_input<-df_input%>%select(-mi_comor)
# df_input$peptic_ulcer <- ifelse(df_input$peptic_ulcer_comor == 1, 1, 0)
# df_input<-df_input%>%select(-peptic_ulcer_comor)
# df_input$peripheral_vascular <- ifelse(df_input$peripheral_vascular_comor == 1, 1, 0)
# df_input<-df_input%>%select(-peripheral_vascular_comor)


# ## total charlson for each patient 
# charlson=c("cancer","cvd", "copd", "heart_failure", "connective_tissue",
#            "dementia", "diabetes", "diabetes_complications", "hemiplegia",
#            "hiv", "metastatic_cancer", "mild_liver", "mod_severe_liver", 
#            "mod_severe_renal", "mi", "peptic_ulcer", "peripheral_vascular")
# df_input$charlson_score=rowSums(df_input[charlson])

# ## Charlson - as a catergorical group variable
# df_input <- df_input %>%
#   mutate(charlsonGrp = case_when(charlson_score >0 & charlson_score <=2 ~ 2,
#                                  charlson_score >2 & charlson_score <=4 ~ 3,
#                                  charlson_score >4 & charlson_score <=6 ~ 4,
#                                  charlson_score >=7 ~ 5,
#                                  charlson_score == 0 ~ 1))

# df_input$charlsonGrp <- as.factor(df_input$charlsonGrp)
# df_input$charlsonGrp <- factor(df_input$charlsonGrp, 
#                                labels = c("zero", "low", "medium", "high", "very high"))

# df_input <- df_input%>%select(died_date,age,age_cat,sex,practice,msoa,bmi,region,
#                               ethnicity,gp_count,flu_vaccine,antibacterial_12mb4,
#                               patient_id,date,charlson_score,charlsonGrp,imd)

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



df <- select(df_input, date, patient_id, practice, age_cat, bmi, 
             bmi_cat, ethnicity_6, #charlson_score, charlsonGrp,
             flu_vaccine, imd, antibacterial_12mb4, gp_count) 
rm(df_input)

##outcome check
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))
num_pats <- length(unique(df$patient_id))
num_pracs <- length(unique(df$practice))

overall_counts <- as.data.frame(cbind(first_mon, last_mon, num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "model_varibale_overall_count_2019.csv"))

rm(first_mon,last_mon,num_pats,num_pracs,overall_counts)

colsfortab <- colnames(df)[-c(2:3)] # patient ID, practice id
df %>% summary_factorlist(explanatory = colsfortab) -> t
#str(t)
write_csv(t, here::here("output", "model_varibale_table_2019.csv"))

##Merge the dataset
# rds <- read_rds('recorded_ab_broad_2019.rds')
# dat=dplyr::bind_rows(rds)
# rm(rds)
# dat$infection=dplyr::recode(dat$infection,
#                             asthma ="Other infection",
#                             cold="Other infection",
#                             cough="Other infection",
#                             copd="Other infection",
#                             pneumonia="Other infection",
#                             renal="Other infection",
#                             sepsis="Other infection",
#                             throat="Other infection",
#                             uti = "UTI",
#                             lrti = "LRTI",
#                             urti = "URTI",
#                             sinusits = "Sinusitis",
#                             otmedia = "Otitis media",
#                             ot_externa = "Otitis externa")


# modeldf <- merge(df,dat,by=c('patient_id','date'))
# rm(df,dat)

# ##Crude Model
# m1 <- glm(broad_spectrum ~ age_cat + sex, family = binomial(link = "logit"),data = modeldf)

# saveRDS(m1, "m1.rds")

# rm(m1)
# ##Fully Adjusted Model
# m2 <- clogit(broad_spectrum ~ as.factor(date) + age_cat + sex + charlsonGrp + bmi_cat + 
#                ethnicity_6 + flu_vaccine + imd +  antibacterial_12mb4 + gp_count +prevalent +strata(infection), modeldf)

# saveRDS(m2, "m2.rds")




