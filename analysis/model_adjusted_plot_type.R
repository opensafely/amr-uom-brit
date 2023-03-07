
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")

mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_type_num + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfch <- DF

df <- readRDS("output/processed/input_model_c.rds")

mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_type_num + 
             strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfc <- DF

df <- readRDS("output/processed/input_model_h.rds")

mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_type_num + 
             strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfh <- DF

DF <- dfch

IMD <- DF[1:4,]
Ethnicity <- DF[5:9,]
BMI <- DF[10:15,]
Smoking <- DF[16:18,]
CKD <- DF[42:47,]
CHT <- DF[41,]
Other1 <- DF[c(19:20,23,27:32),]
Asthma <- DF[21:22,]
Diabetes <- DF[24:26,]
Organ<- DF[33:34,]
Other2 <-DF[35:40,]
Antibiotic <- DF[48:50,]

IMD$type <-  case_when(
  IMD$type == "imd1" ~ "IMD 1(Most deprived)",
  IMD$type == "imd2" ~ "IMD 2",
  IMD$type == "imd3" ~ "IMD 3",
  IMD$type == "imd4" ~ "IMD 4")

Ethnicity$type = case_when(
  Ethnicity$type == "ethnicityMixed" ~ "Mixed",
  Ethnicity$type == "ethnicitySouth Asian" ~ "South Asian",
  Ethnicity$type == "ethnicityBlack" ~ "Black",
  Ethnicity$type == "ethnicityOther" ~ "Other",
  Ethnicity$type == "ethnicityUnknown" ~ "Ethnicity unknown")

BMI$type = case_when(
  BMI$type == "bmi_adultMissing" ~ "BMI Missing",
  BMI$type == "bmi_adultOverweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
  BMI$type == "bmi_adultUnderweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
  BMI$type == "bmi_adultObese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
  BMI$type == "bmi_adultObese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
  BMI$type == "bmi_adultObese III (40+)" ~ "Obese III (40+ kg/m2)")

Smoking$type = case_when(
  Smoking$type == "smoking_statusMissing" ~ "Smoking unknown",
  Smoking$type == "smoking_statusFormer" ~ "Former",
  Smoking$type == "smoking_statusCurrent" ~ "Current")

CKD$type = case_when(
  CKD$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  CKD$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  CKD$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  CKD$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  CKD$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  CKD$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)")

CHT$type = case_when(
  CHT$type == "care_home_type_baTRUE" ~ "Potential Care Home")

Other1$type = case_when(
  Other1$type == "hypertensionTRUE" ~ "Hypertension",
  Other1$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  Other1$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  Other1$type == "cancerTRUE" ~ "Cancer (non haematological)",
  Other1$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  Other1$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  Other1$type == "strokeTRUE" ~ "Stroke",
  Other1$type == "dementiaTRUE" ~ "Dementia",
  Other1$type == "other_neuroTRUE" ~ "Other neurological disease")

Asthma$type = case_when(
  Asthma$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  Asthma$type == "asthmaWith oral steroid use" ~ "With oral steroid use")

Diabetes$type = case_when(
  Diabetes$type == "diabetes_controlledControlled" ~ "Controlled",
  Diabetes$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  Diabetes$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure")

Organ$type = case_when(
  Organ$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  Organ$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant")

Other2$type = case_when(
  Other2$type == "aspleniaTRUE" ~ "Asplenia",
  Other2$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  Other2$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  Other2$type == "learning_disabilityTRUE" ~ "Learning disability",
  Other2$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  Other2$type == "alcohol_problemsTRUE" ~ "Alcohol problems")

Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency1" ~ "Antibiotic count: 1",
  Antibiotic$type == "ab_frequency2-3" ~ "Antibiotic count: 2-3",
  Antibiotic$type == "ab_frequency>3" ~ "Antibiotic count: 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot0.1 <- IMD
plot1.1 <- bind_rows(Ethnicity,BMI,Smoking,CHT)
plot2.1 <- bind_rows(CKD,Asthma,Diabetes,Organ)
plot3.1 <- Other1
plot4.1 <- Other2
plot5.1 <- Antibiotic


DF <- dfc

IMD <- DF[1:4,]
Ethnicity <- DF[5:9,]
BMI <- DF[10:15,]
Smoking <- DF[16:18,]
CKD <- DF[42:47,]
CHT <- DF[41,]
Other1 <- DF[c(19:20,23,27:32),]
Asthma <- DF[21:22,]
Diabetes <- DF[24:26,]
Organ<- DF[33:34,]
Other2 <-DF[35:40,]
Antibiotic <- DF[48:50,]

IMD$type <-  case_when(
  IMD$type == "imd1" ~ "IMD 1(Most deprived)",
  IMD$type == "imd2" ~ "IMD 2",
  IMD$type == "imd3" ~ "IMD 3",
  IMD$type == "imd4" ~ "IMD 4")

Ethnicity$type = case_when(
  Ethnicity$type == "ethnicityMixed" ~ "Mixed",
  Ethnicity$type == "ethnicitySouth Asian" ~ "South Asian",
  Ethnicity$type == "ethnicityBlack" ~ "Black",
  Ethnicity$type == "ethnicityOther" ~ "Other",
  Ethnicity$type == "ethnicityUnknown" ~ "Ethnicity unknown")

BMI$type = case_when(
  BMI$type == "bmi_adultMissing" ~ "BMI Missing",
  BMI$type == "bmi_adultOverweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
  BMI$type == "bmi_adultUnderweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
  BMI$type == "bmi_adultObese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
  BMI$type == "bmi_adultObese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
  BMI$type == "bmi_adultObese III (40+)" ~ "Obese III (40+ kg/m2)")

Smoking$type = case_when(
  Smoking$type == "smoking_statusMissing" ~ "Smoking unknown",
  Smoking$type == "smoking_statusFormer" ~ "Former",
  Smoking$type == "smoking_statusCurrent" ~ "Current")

CKD$type = case_when(
  CKD$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  CKD$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  CKD$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  CKD$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  CKD$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  CKD$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)")

CHT$type = case_when(
  CHT$type == "care_home_type_baTRUE" ~ "Potential Care Home")

Other1$type = case_when(
  Other1$type == "hypertensionTRUE" ~ "Hypertension",
  Other1$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  Other1$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  Other1$type == "cancerTRUE" ~ "Cancer (non haematological)",
  Other1$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  Other1$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  Other1$type == "strokeTRUE" ~ "Stroke",
  Other1$type == "dementiaTRUE" ~ "Dementia",
  Other1$type == "other_neuroTRUE" ~ "Other neurological disease")

Asthma$type = case_when(
  Asthma$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  Asthma$type == "asthmaWith oral steroid use" ~ "With oral steroid use")

Diabetes$type = case_when(
  Diabetes$type == "diabetes_controlledControlled" ~ "Controlled",
  Diabetes$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  Diabetes$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure")

Organ$type = case_when(
  Organ$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  Organ$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant")

Other2$type = case_when(
  Other2$type == "aspleniaTRUE" ~ "Asplenia",
  Other2$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  Other2$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  Other2$type == "learning_disabilityTRUE" ~ "Learning disability",
  Other2$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  Other2$type == "alcohol_problemsTRUE" ~ "Alcohol problems")

Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency1" ~ "Antibiotic count: 1",
  Antibiotic$type == "ab_frequency2-3" ~ "Antibiotic count: 2-3",
  Antibiotic$type == "ab_frequency>3" ~ "Antibiotic count: 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot0.2 <- IMD
plot1.2 <- bind_rows(Ethnicity,BMI,Smoking,CHT)
plot2.2 <- bind_rows(CKD,Asthma,Diabetes,Organ)
plot3.2 <- Other1
plot4.2 <- Other2
plot5.2 <- Antibiotic

DF <- dfh

IMD <- DF[1:4,]
Ethnicity <- DF[5:9,]
BMI <- DF[10:15,]
Smoking <- DF[16:18,]
CKD <- DF[42:47,]
CHT <- DF[41,]
Other1 <- DF[c(19:20,23,27:32),]
Asthma <- DF[21:22,]
Diabetes <- DF[24:26,]
Organ<- DF[33:34,]
Other2 <-DF[35:40,]
Antibiotic <- DF[48:50,]

IMD$type <-  case_when(
  IMD$type == "imd1" ~ "IMD 1(Most deprived)",
  IMD$type == "imd2" ~ "IMD 2",
  IMD$type == "imd3" ~ "IMD 3",
  IMD$type == "imd4" ~ "IMD 4")

Ethnicity$type = case_when(
  Ethnicity$type == "ethnicityMixed" ~ "Mixed",
  Ethnicity$type == "ethnicitySouth Asian" ~ "South Asian",
  Ethnicity$type == "ethnicityBlack" ~ "Black",
  Ethnicity$type == "ethnicityOther" ~ "Other",
  Ethnicity$type == "ethnicityUnknown" ~ "Ethnicity unknown")

BMI$type = case_when(
  BMI$type == "bmi_adultMissing" ~ "BMI Missing",
  BMI$type == "bmi_adultOverweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
  BMI$type == "bmi_adultUnderweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
  BMI$type == "bmi_adultObese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
  BMI$type == "bmi_adultObese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
  BMI$type == "bmi_adultObese III (40+)" ~ "Obese III (40+ kg/m2)")

Smoking$type = case_when(
  Smoking$type == "smoking_statusMissing" ~ "Smoking unknown",
  Smoking$type == "smoking_statusFormer" ~ "Former",
  Smoking$type == "smoking_statusCurrent" ~ "Current")

CKD$type = case_when(
  CKD$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  CKD$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  CKD$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  CKD$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  CKD$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  CKD$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)")

CHT$type = case_when(
  CHT$type == "care_home_type_baTRUE" ~ "Potential Care Home")

Other1$type = case_when(
  Other1$type == "hypertensionTRUE" ~ "Hypertension",
  Other1$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  Other1$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  Other1$type == "cancerTRUE" ~ "Cancer (non haematological)",
  Other1$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  Other1$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  Other1$type == "strokeTRUE" ~ "Stroke",
  Other1$type == "dementiaTRUE" ~ "Dementia",
  Other1$type == "other_neuroTRUE" ~ "Other neurological disease")

Asthma$type = case_when(
  Asthma$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  Asthma$type == "asthmaWith oral steroid use" ~ "With oral steroid use")

Diabetes$type = case_when(
  Diabetes$type == "diabetes_controlledControlled" ~ "Controlled",
  Diabetes$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  Diabetes$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure")

Organ$type = case_when(
  Organ$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  Organ$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant")

Other2$type = case_when(
  Other2$type == "aspleniaTRUE" ~ "Asplenia",
  Other2$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  Other2$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  Other2$type == "learning_disabilityTRUE" ~ "Learning disability",
  Other2$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  Other2$type == "alcohol_problemsTRUE" ~ "Alcohol problems")

Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency1" ~ "Antibiotic count: 1",
  Antibiotic$type == "ab_frequency2-3" ~ "Antibiotic count: 2-3",
  Antibiotic$type == "ab_frequency>3" ~ "Antibiotic count: 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot0.3 <- IMD
plot1.3 <- bind_rows(Ethnicity,BMI,Smoking,CHT)
plot2.3 <- bind_rows(CKD,Asthma,Diabetes,Organ)
plot3.3 <- Other1
plot4.3 <- Other2
plot5.3 <- Antibiotic

label0 <- as.vector(plot0.1$type)
label1 <- as.vector(plot1.1$type)
label2 <- as.vector(plot2.1$type)
label3 <- as.vector(plot3.1$type)
label4 <- as.vector(plot4.1$type)
label5 <- as.vector(plot5.1$type)

plot0.1$type <- factor(plot0.1$type, levels = label0)
plot1.1$type <- factor(plot1.1$type, levels = label1)
plot2.1$type <- factor(plot2.1$type, levels = label2)
plot3.1$type <- factor(plot3.1$type, levels = label3)
plot4.1$type <- factor(plot4.1$type, levels = label4)
plot5.1$type <- factor(plot5.1$type, levels = label5)

plot0.2$type <- factor(plot0.2$type, levels = label0)
plot1.2$type <- factor(plot1.2$type, levels = label1)
plot2.2$type <- factor(plot2.2$type, levels = label2)
plot3.2$type <- factor(plot3.2$type, levels = label3)
plot4.2$type <- factor(plot4.2$type, levels = label4)
plot5.2$type <- factor(plot5.2$type, levels = label5)

plot0.3$type <- factor(plot0.3$type, levels = label0)
plot1.3$type <- factor(plot1.3$type, levels = label1)
plot2.3$type <- factor(plot2.3$type, levels = label2)
plot3.3$type <- factor(plot3.3$type, levels = label3)
plot4.3$type <- factor(plot4.3$type, levels = label4)
plot5.3$type <- factor(plot5.3$type, levels = label5)

plot0.1$group <- "H+C"
plot1.1$group <- "H+C"
plot2.1$group <- "H+C"
plot3.1$group <- "H+C"
plot4.1$group <- "H+C"
plot5.1$group <- "H+C"

plot0.2$group <- "C"
plot1.2$group <- "C"
plot2.2$group <- "C"
plot3.2$group <- "C"
plot4.2$group <- "C"
plot5.2$group <- "C"

plot0.3$group <- "H"
plot1.3$group <- "H"
plot2.3$group <- "H"
plot3.3$group <- "H"
plot4.3$group <- "H"
plot5.3$group <- "H"

plotimd <- bind_rows(plot0.1,plot0.2,plot0.3)
plota <- bind_rows(plot1.1,plot1.2,plot1.3)
plotb <- bind_rows(plot2.1,plot2.2,plot2.3)
plotc <- bind_rows(plot3.1,plot3.2,plot3.3)
plotd <- bind_rows(plot4.1,plot4.2,plot4.3)
plote <- bind_rows(plot5.1,plot5.2,plot5.3)

write_csv(plotimd, here::here("output", "adjusted_type_plotimd.csv"))
write_csv(plota, here::here("output", "adjusted_type_plota.csv"))
write_csv(plotb, here::here("output", "adjusted_type_plotb.csv"))
write_csv(plotc, here::here("output", "adjusted_type_plotc.csv"))
write_csv(plotd, here::here("output", "adjusted_type_plotd.csv"))
write_csv(plote, here::here("output", "adjusted_type_plote.csv"))