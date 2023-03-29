#### This script is for calculating mortality rate and draw the table ####

require('tidyverse')
require("gtsummary")
library(car)
library(data.table)
library(gridExtra)
library(purrr)
library(dplyr)
library(survival)
library(rms)

df <- readRDS("output/processed/input_model_h.rds")
df <- df %>% filter(case==1)
df$agegroup = case_when(
  df$age < 18 ~ "<18",
  df$age >= 18 & df$age < 40 ~ "18-39",
  df$age >= 40 & df$age < 50 ~ "40-49",
  df$age >= 50 & df$age < 60 ~ "50-59",
  df$age >= 60 & df$age < 70 ~ "60-69",
  df$age >= 70 & df$age < 80 ~ "70-79",
  df$age >= 80 ~ "80+")

###Age###

df$agegroup= relevel(as.factor(df$agegroup), ref="50-59")

df1 <- df %>% filter (covid == 1)
df2 <- df %>% filter (covid == 2)
df3 <- df %>% filter (covid == 3)

df <-df1
###Age###
mod <- glm(died_any_30d~agegroup + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result1 <- result[2:7,]

###Sex###
mod <- glm(died_any_30d~rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result2 <- result[5,]

### Region ###
mod <- glm(died_any_30d~rcs(age, 4) + sex + region,family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result3 <- result[6:13,]

### IMD ###
mod <- glm(died_any_30d~ imd+ rcs(age, 4) + sex,family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result4 <- result[2:5,]

### Other ###
mod <- glm(died_any_30d~ ethnicity+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result5 <- result[2:6,]


mod <- glm(died_any_30d~ bmi_adult+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result6 <- result[2:7,]


mod <- glm(died_any_30d~ smoking_status+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result7 <- result[2:4,]


#############
mod <- glm(died_any_30d~ hypertension+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result8 <- result[2,]

mod <- glm(died_any_30d~ chronic_respiratory_disease+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result9 <- result[2,]

mod <- glm(died_any_30d~ asthma+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result10 <- result[2:3,]

mod <- glm(died_any_30d~ chronic_cardiac_disease+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result11 <- result[2,]

mod <- glm(died_any_30d~ diabetes_controlled+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result12 <- result[2:4,]

mod <- glm(died_any_30d~ cancer+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result13 <- result[2,]

mod <- glm(died_any_30d~ haem_cancer + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result14 <- result[2,]

mod <- glm(died_any_30d~ chronic_liver_disease + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result15 <- result[2,]

mod <- glm(died_any_30d~ stroke + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result16 <- result[2,]

mod <- glm(died_any_30d~ dementia + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result17 <- result[2,]

mod <- glm(died_any_30d~ other_neuro + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result18 <- result[2,]

mod <- glm(died_any_30d~ organ_kidney_transplant + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result19 <- result[2:3,]

mod <- glm(died_any_30d~ asplenia + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result20 <- result[2,]

mod <- glm(died_any_30d~ ra_sle_psoriasis + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result21 <- result[2,]

mod <- glm(died_any_30d~ immunosuppression + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result22 <- result[2,]

mod <- glm(died_any_30d~ learning_disability + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result23 <- result[2,]

mod <- glm(died_any_30d~ sev_mental_ill + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result24 <- result[2,]

mod <- glm(died_any_30d~ alcohol_problems + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result25 <- result[2,]

mod <- glm(died_any_30d~ care_home_type_ba + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result26 <- result[2,]

mod <- glm(died_any_30d~ ckd_rrt + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result27 <- result[2:7,]

mod <- glm(died_any_30d~ ab_frequency + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result28 <- result[2:4,]

mod <- glm(died_any_30d~ ab_type_num + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result29 <- result[2:4,]

result <- bind_rows(result1,result2,result3,result4,result5,result6,result7,result8,result9,result10,
                    result11,result12,result13,result14,result15,result16,result17,result18,result19,result20,
                    result21,result22,result23,result24,result25,result26,result27,result28,result29)

setDT(result, keep.rownames = TRUE)
names(result)[1]="type"

result$type <-  case_when(
  result$type == "agegroup<18" ~ "<18",
  result$type == "agegroup18-39" ~ "18-39",
  result$type == "agegroup40-49" ~ "40-49",
  result$type == "agegroup60-69" ~ "60-69",
  result$type == "agegroup70-79" ~ "70-79",
  result$type == "agegroup80+" ~ "80+",
  result$type == "sexM" ~ "Male",
  result$type == "imd1" ~ "IMD1(most deprived)",
  result$type == "imd2" ~ "IMD2",
  result$type == "imd3" ~ "IMD3",
  result$type == "imd4" ~ "IMD4",
  result$type == "regionNorth East" ~ "North East",
  result$type == "regionNorth West" ~ "North West",
  result$type == "regionYorkshire and The Humber" ~ "Yorkshire and the Humber",
  result$type == "regionEast Midlands" ~ "East Midlands",
  result$type == "regionWest Midlands" ~ "West Midlands",
  result$type == "regionEast" ~ "East of England",
  result$type == "regionLondon" ~ "London",
  result$type == "regionSouth East" ~ "South East",
  result$type == "regionSouth West" ~ "South West",
  result$type == "ethnicityMixed" ~ "Mixed",
  result$type == "ethnicitySouth Asian" ~ "South Asian",
  result$type == "ethnicityBlack" ~ "Black",
  result$type == "ethnicityOther" ~ "Other",
  result$type == "ethnicityUnknown" ~ "Ethnicity unknown",
  result$type == "bmi_adultMissing" ~ "BMI Missing",
  result$type == "bmi_adultOverweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
  result$type == "bmi_adultUnderweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
  result$type == "bmi_adultObese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
  result$type == "bmi_adultObese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
  result$type == "bmi_adultObese III (40+)" ~ "Obese III (40+ kg/m2)",
  result$type == "smoking_statusMissing" ~ "Smoking unknown",
  result$type == "smoking_statusFormer" ~ "Former",
  result$type == "smoking_statusCurrent" ~ "Current",
  result$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  result$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  result$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  result$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  result$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  result$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)",
  result$type == "care_home_type_baTRUE" ~ "Potential Care Home",
  result$type == "hypertensionTRUE" ~ "Hypertension",
  result$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  result$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  result$type == "cancerTRUE" ~ "Cancer (non haematological)",
  result$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  result$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  result$type == "strokeTRUE" ~ "Stroke",
  result$type == "dementiaTRUE" ~ "Dementia",
  result$type == "other_neuroTRUE" ~ "Other neurological disease",
  result$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  result$type == "asthmaWith oral steroid use" ~ "With oral steroid use",
  result$type == "diabetes_controlledControlled" ~ "Controlled",
  result$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  result$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure",
  result$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  result$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant",
  result$type == "aspleniaTRUE" ~ "Asplenia",
  result$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  result$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  result$type == "learning_disabilityTRUE" ~ "Learning disability",
  result$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  result$type == "alcohol_problemsTRUE" ~ "Alcohol problems",
  result$type == "ab_frequency1" ~ "Antibiotic count: 1",
  result$type == "ab_frequency2-3" ~ "Antibiotic count: 2-3",
  result$type == "ab_frequency>3" ~ "Antibiotic count: 3+",
  result$type == "ab_type_num1" ~ "Antibiotic type: 1",
  result$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  result$type == "ab_type_num>3" ~ "Antibiotic type: 3+")


names(result)[1]="Plot_category"
names(result)[2]="OR.1"
names(result)[3]="LowerCI.1"
names(result)[4]="UpperCI.1"

result <-result[c(1:19,22,20,23,21,30,29,26:28,33,32,36,37,39:41,48,49,57:62,64,65,63,34,35,38,42:47,50:56),]

result$Plot_group <-c("Age","Age","Age","Age","Age","Age","Sex",
                      "Region","Region","Region","Region","Region","Region","Region","Region",
                      "IMD","IMD","IMD","IMD","Ethnicity","Ethnicity","Ethnicity","Ethnicity",
                      "BMI","BMI","BMI","BMI","BMI","Smoking","Smoking","Asthma","Asthma",
                      "Diabetes","Diabetes","Diabetes","Tx","Tx","CKD/RRT","CKD/RRT","CKD/RRT","CKD/RRT","CKD/RRT",
                      "CKD/RRT","Antibiotic count","Antibiotic count","Antibiotic count","Others","Others","Others","Others","Others",
                      "Others","Others","Others","Others","Others","Others","Others","Others","Others",
                      "Others","Others")

relrisks1 <- result
write_csv(relrisks1, here::here("output", "sen_mortality_model_hospital_1.csv"))

df <-df2
###Age###
mod <- glm(died_any_30d~agegroup + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result1 <- result[2:7,]

###Sex###
mod <- glm(died_any_30d~rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result2 <- result[5,]

### Region ###
mod <- glm(died_any_30d~rcs(age, 4) + sex + region,family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result3 <- result[6:13,]

### IMD ###
mod <- glm(died_any_30d~ imd+ rcs(age, 4) + sex,family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result4 <- result[2:5,]

### Other ###
mod <- glm(died_any_30d~ ethnicity+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result5 <- result[2:6,]


mod <- glm(died_any_30d~ bmi_adult+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result6 <- result[2:7,]


mod <- glm(died_any_30d~ smoking_status+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result7 <- result[2:4,]


#############
mod <- glm(died_any_30d~ hypertension+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result8 <- result[2,]

mod <- glm(died_any_30d~ chronic_respiratory_disease+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result9 <- result[2,]

mod <- glm(died_any_30d~ asthma+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result10 <- result[2:3,]

mod <- glm(died_any_30d~ chronic_cardiac_disease+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result11 <- result[2,]

mod <- glm(died_any_30d~ diabetes_controlled+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result12 <- result[2:4,]

mod <- glm(died_any_30d~ cancer+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result13 <- result[2,]

mod <- glm(died_any_30d~ haem_cancer + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result14 <- result[2,]

mod <- glm(died_any_30d~ chronic_liver_disease + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result15 <- result[2,]

mod <- glm(died_any_30d~ stroke + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result16 <- result[2,]

mod <- glm(died_any_30d~ dementia + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result17 <- result[2,]

mod <- glm(died_any_30d~ other_neuro + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result18 <- result[2,]

mod <- glm(died_any_30d~ organ_kidney_transplant + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result19 <- result[2:3,]

mod <- glm(died_any_30d~ asplenia + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result20 <- result[2,]

mod <- glm(died_any_30d~ ra_sle_psoriasis + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result21 <- result[2,]

mod <- glm(died_any_30d~ immunosuppression + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result22 <- result[2,]

mod <- glm(died_any_30d~ learning_disability + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result23 <- result[2,]

mod <- glm(died_any_30d~ sev_mental_ill + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result24 <- result[2,]

mod <- glm(died_any_30d~ alcohol_problems + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result25 <- result[2,]

mod <- glm(died_any_30d~ care_home_type_ba + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result26 <- result[2,]

mod <- glm(died_any_30d~ ckd_rrt + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result27 <- result[2:7,]

mod <- glm(died_any_30d~ ab_frequency + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result28 <- result[2:4,]

mod <- glm(died_any_30d~ ab_type_num + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result29 <- result[2:4,]

result <- bind_rows(result1,result2,result3,result4,result5,result6,result7,result8,result9,result10,
                    result11,result12,result13,result14,result15,result16,result17,result18,result19,result20,
                    result21,result22,result23,result24,result25,result26,result27,result28,result29)

setDT(result, keep.rownames = TRUE)
names(result)[1]="type"

result$type <-  case_when(
  result$type == "agegroup<18" ~ "<18",
  result$type == "agegroup18-39" ~ "18-39",
  result$type == "agegroup40-49" ~ "40-49",
  result$type == "agegroup60-69" ~ "60-69",
  result$type == "agegroup70-79" ~ "70-79",
  result$type == "agegroup80+" ~ "80+",
  result$type == "sexM" ~ "Male",
  result$type == "imd1" ~ "IMD1(most deprived)",
  result$type == "imd2" ~ "IMD2",
  result$type == "imd3" ~ "IMD3",
  result$type == "imd4" ~ "IMD4",
  result$type == "regionNorth East" ~ "North East",
  result$type == "regionNorth West" ~ "North West",
  result$type == "regionYorkshire and The Humber" ~ "Yorkshire and the Humber",
  result$type == "regionEast Midlands" ~ "East Midlands",
  result$type == "regionWest Midlands" ~ "West Midlands",
  result$type == "regionEast" ~ "East of England",
  result$type == "regionLondon" ~ "London",
  result$type == "regionSouth East" ~ "South East",
  result$type == "regionSouth West" ~ "South West",
  result$type == "ethnicityMixed" ~ "Mixed",
  result$type == "ethnicitySouth Asian" ~ "South Asian",
  result$type == "ethnicityBlack" ~ "Black",
  result$type == "ethnicityOther" ~ "Other",
  result$type == "ethnicityUnknown" ~ "Ethnicity unknown",
  result$type == "bmi_adultMissing" ~ "BMI Missing",
  result$type == "bmi_adultOverweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
  result$type == "bmi_adultUnderweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
  result$type == "bmi_adultObese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
  result$type == "bmi_adultObese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
  result$type == "bmi_adultObese III (40+)" ~ "Obese III (40+ kg/m2)",
  result$type == "smoking_statusMissing" ~ "Smoking unknown",
  result$type == "smoking_statusFormer" ~ "Former",
  result$type == "smoking_statusCurrent" ~ "Current",
  result$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  result$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  result$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  result$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  result$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  result$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)",
  result$type == "care_home_type_baTRUE" ~ "Potential Care Home",
  result$type == "hypertensionTRUE" ~ "Hypertension",
  result$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  result$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  result$type == "cancerTRUE" ~ "Cancer (non haematological)",
  result$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  result$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  result$type == "strokeTRUE" ~ "Stroke",
  result$type == "dementiaTRUE" ~ "Dementia",
  result$type == "other_neuroTRUE" ~ "Other neurological disease",
  result$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  result$type == "asthmaWith oral steroid use" ~ "With oral steroid use",
  result$type == "diabetes_controlledControlled" ~ "Controlled",
  result$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  result$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure",
  result$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  result$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant",
  result$type == "aspleniaTRUE" ~ "Asplenia",
  result$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  result$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  result$type == "learning_disabilityTRUE" ~ "Learning disability",
  result$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  result$type == "alcohol_problemsTRUE" ~ "Alcohol problems",
  result$type == "ab_frequency1" ~ "Antibiotic count: 1",
  result$type == "ab_frequency2-3" ~ "Antibiotic count: 2-3",
  result$type == "ab_frequency>3" ~ "Antibiotic count: 3+",
  result$type == "ab_type_num1" ~ "Antibiotic type: 1",
  result$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  result$type == "ab_type_num>3" ~ "Antibiotic type: 3+")


names(result)[1]="Plot_category"
names(result)[2]="OR.2"
names(result)[3]="LowerCI.2"
names(result)[4]="UpperCI.2"

result <-result[c(1:19,22,20,23,21,30,29,26:28,33,32,36,37,39:41,48,49,57:62,64,65,63,34,35,38,42:47,50:56),]

result$Plot_group <-c("Age","Age","Age","Age","Age","Age","Sex",
                      "Region","Region","Region","Region","Region","Region","Region","Region",
                      "IMD","IMD","IMD","IMD","Ethnicity","Ethnicity","Ethnicity","Ethnicity",
                      "BMI","BMI","BMI","BMI","BMI","Smoking","Smoking","Asthma","Asthma",
                      "Diabetes","Diabetes","Diabetes","Tx","Tx","CKD/RRT","CKD/RRT","CKD/RRT","CKD/RRT","CKD/RRT",
                      "CKD/RRT","Antibiotic count","Antibiotic count","Antibiotic count","Others","Others","Others","Others","Others",
                      "Others","Others","Others","Others","Others","Others","Others","Others","Others",
                      "Others","Others")

relrisks2 <- result
write_csv(relrisks2, here::here("output", "sen_mortality_model_hospital_2.csv"))

df <-df3

###Age###
mod <- glm(died_any_30d~agegroup + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result1 <- result[2:7,]

###Sex###
mod <- glm(died_any_30d~rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result2 <- result[5,]

### Region ###
mod <- glm(died_any_30d~rcs(age, 4) + sex + region,family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result3 <- result[6:13,]

### IMD ###
mod <- glm(died_any_30d~ imd+ rcs(age, 4) + sex,family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result4 <- result[2:5,]

### Other ###
mod <- glm(died_any_30d~ ethnicity+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result5 <- result[2:6,]


mod <- glm(died_any_30d~ bmi_adult+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result6 <- result[2:7,]


mod <- glm(died_any_30d~ smoking_status+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result7 <- result[2:4,]


#############
mod <- glm(died_any_30d~ hypertension+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result8 <- result[2,]

mod <- glm(died_any_30d~ chronic_respiratory_disease+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result9 <- result[2,]

mod <- glm(died_any_30d~ asthma+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result10 <- result[2:3,]

mod <- glm(died_any_30d~ chronic_cardiac_disease+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result11 <- result[2,]

mod <- glm(died_any_30d~ diabetes_controlled+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result12 <- result[2:4,]

mod <- glm(died_any_30d~ cancer+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result13 <- result[2,]

mod <- glm(died_any_30d~ haem_cancer + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result14 <- result[2,]

mod <- glm(died_any_30d~ chronic_liver_disease + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result15 <- result[2,]

mod <- glm(died_any_30d~ stroke + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result16 <- result[2,]

mod <- glm(died_any_30d~ dementia + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result17 <- result[2,]

mod <- glm(died_any_30d~ other_neuro + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result18 <- result[2,]

mod <- glm(died_any_30d~ organ_kidney_transplant + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result19 <- result[2:3,]

mod <- glm(died_any_30d~ asplenia + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result20 <- result[2,]

mod <- glm(died_any_30d~ ra_sle_psoriasis + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result21 <- result[2,]

mod <- glm(died_any_30d~ immunosuppression + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result22 <- result[2,]

mod <- glm(died_any_30d~ learning_disability + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result23 <- result[2,]

mod <- glm(died_any_30d~ sev_mental_ill + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result24 <- result[2,]

mod <- glm(died_any_30d~ alcohol_problems + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result25 <- result[2,]

mod <- glm(died_any_30d~ care_home_type_ba + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result26 <- result[2,]

mod <- glm(died_any_30d~ ckd_rrt + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result27 <- result[2:7,]

mod <- glm(died_any_30d~ ab_frequency + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result28 <- result[2:4,]

mod <- glm(died_any_30d~ ab_type_num + rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result29 <- result[2:4,]

result <- bind_rows(result1,result2,result3,result4,result5,result6,result7,result8,result9,result10,
                    result11,result12,result13,result14,result15,result16,result17,result18,result19,result20,
                    result21,result22,result23,result24,result25,result26,result27,result28,result29)

setDT(result, keep.rownames = TRUE)
names(result)[1]="type"

result$type <-  case_when(
  result$type == "agegroup<18" ~ "<18",
  result$type == "agegroup18-39" ~ "18-39",
  result$type == "agegroup40-49" ~ "40-49",
  result$type == "agegroup60-69" ~ "60-69",
  result$type == "agegroup70-79" ~ "70-79",
  result$type == "agegroup80+" ~ "80+",
  result$type == "sexM" ~ "Male",
  result$type == "imd1" ~ "IMD1(most deprived)",
  result$type == "imd2" ~ "IMD2",
  result$type == "imd3" ~ "IMD3",
  result$type == "imd4" ~ "IMD4",
  result$type == "regionNorth East" ~ "North East",
  result$type == "regionNorth West" ~ "North West",
  result$type == "regionYorkshire and The Humber" ~ "Yorkshire and the Humber",
  result$type == "regionEast Midlands" ~ "East Midlands",
  result$type == "regionWest Midlands" ~ "West Midlands",
  result$type == "regionEast" ~ "East of England",
  result$type == "regionLondon" ~ "London",
  result$type == "regionSouth East" ~ "South East",
  result$type == "regionSouth West" ~ "South West",
  result$type == "ethnicityMixed" ~ "Mixed",
  result$type == "ethnicitySouth Asian" ~ "South Asian",
  result$type == "ethnicityBlack" ~ "Black",
  result$type == "ethnicityOther" ~ "Other",
  result$type == "ethnicityUnknown" ~ "Ethnicity unknown",
  result$type == "bmi_adultMissing" ~ "BMI Missing",
  result$type == "bmi_adultOverweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
  result$type == "bmi_adultUnderweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
  result$type == "bmi_adultObese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
  result$type == "bmi_adultObese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
  result$type == "bmi_adultObese III (40+)" ~ "Obese III (40+ kg/m2)",
  result$type == "smoking_statusMissing" ~ "Smoking unknown",
  result$type == "smoking_statusFormer" ~ "Former",
  result$type == "smoking_statusCurrent" ~ "Current",
  result$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  result$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  result$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  result$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  result$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  result$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)",
  result$type == "care_home_type_baTRUE" ~ "Potential Care Home",
  result$type == "hypertensionTRUE" ~ "Hypertension",
  result$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  result$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  result$type == "cancerTRUE" ~ "Cancer (non haematological)",
  result$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  result$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  result$type == "strokeTRUE" ~ "Stroke",
  result$type == "dementiaTRUE" ~ "Dementia",
  result$type == "other_neuroTRUE" ~ "Other neurological disease",
  result$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  result$type == "asthmaWith oral steroid use" ~ "With oral steroid use",
  result$type == "diabetes_controlledControlled" ~ "Controlled",
  result$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  result$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure",
  result$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  result$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant",
  result$type == "aspleniaTRUE" ~ "Asplenia",
  result$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  result$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  result$type == "learning_disabilityTRUE" ~ "Learning disability",
  result$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  result$type == "alcohol_problemsTRUE" ~ "Alcohol problems",
  result$type == "ab_frequency1" ~ "Antibiotic count: 1",
  result$type == "ab_frequency2-3" ~ "Antibiotic count: 2-3",
  result$type == "ab_frequency>3" ~ "Antibiotic count: 3+",
  result$type == "ab_type_num1" ~ "Antibiotic type: 1",
  result$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  result$type == "ab_type_num>3" ~ "Antibiotic type: 3+")


names(result)[1]="Plot_category"
names(result)[2]="OR.3"
names(result)[3]="LowerCI.3"
names(result)[4]="UpperCI.3"

result <-result[c(1:19,22,20,23,21,30,29,26:28,33,32,36,37,39:41,48,49,57:62,64,65,63,34,35,38,42:47,50:56),]

result$Plot_group <-c("Age","Age","Age","Age","Age","Age","Sex",
                      "Region","Region","Region","Region","Region","Region","Region","Region",
                      "IMD","IMD","IMD","IMD","Ethnicity","Ethnicity","Ethnicity","Ethnicity",
                      "BMI","BMI","BMI","BMI","BMI","Smoking","Smoking","Asthma","Asthma",
                      "Diabetes","Diabetes","Diabetes","Tx","Tx","CKD/RRT","CKD/RRT","CKD/RRT","CKD/RRT","CKD/RRT",
                      "CKD/RRT","Antibiotic count","Antibiotic count","Antibiotic count","Others","Others","Others","Others","Others",
                      "Others","Others","Others","Others","Others","Others","Others","Others","Others",
                      "Others","Others")

relrisks3 <- result
write_csv(relrisks3, here::here("output", "sen_mortality_model_hospital_3.csv"))

relrisks <- merge(relrisks1,relrisks2,by = "Plot_category")
relrisks <- merge(relrisks,relrisks3,by = "Plot_category")

write_csv(relrisks, here::here("output", "sen_mortality_model_hospital.csv"))