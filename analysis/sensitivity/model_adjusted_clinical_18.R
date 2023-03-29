require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")
mod=clogit(case ~  hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

linear_predictors <- predict(mod, type = "lp")
predicted_probs <- exp(linear_predictors) / (1 + exp(linear_predictors))
true_outcomes <- df$case
auc_trapezoidal <- function(predicted_probs, true_outcomes) {
  data <- data.frame(predicted_probs = predicted_probs, true_outcomes = true_outcomes)
  data <- data[order(data$predicted_probs, decreasing = TRUE), ]
  
  n_pos <- sum(data$true_outcomes == 1)
  n_neg <- sum(data$true_outcomes == 0)
  
  rank_sum_pos <- sum(rank(data$predicted_probs[data$true_outcomes == 1]))
  
  auc <- (rank_sum_pos - n_pos * (n_pos + 1) / 2) / (n_pos * n_neg)
  
  return(auc)
}

c_stat <- auc_trapezoidal(predicted_probs, true_outcomes)

print(c_stat)

dfch <- DF

df <- readRDS("output/processed/input_model_c.rds")
mod=clogit(case ~  hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + strata(set_id), df)
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
mod=clogit(case ~ hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + strata(set_id), df)
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

CKD <- DF[24:29,]
CHT <- DF[23,]
Other1 <- DF[c(1:2,5,9:14),]
Asthma <- DF[3:4,]
Diabetes <- DF[6:8,]
Organ<- DF[15:16,]
Other2 <-DF[17:22,]
Antibiotic <- DF[30:32,]


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

plot1 <- bind_rows(CHT,CKD,Asthma,Diabetes,Organ,Other1,Other2,Antibiotic)


DF <- dfc

CKD <- DF[24:29,]
CHT <- DF[23,]
Other1 <- DF[c(1:2,5,9:14),]
Asthma <- DF[3:4,]
Diabetes <- DF[6:8,]
Organ<- DF[15:16,]
Other2 <-DF[17:22,]
Antibiotic <- DF[30:32,]

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

plot2 <- bind_rows(CHT,CKD,Asthma,Diabetes,Organ,Other1,Other2,Antibiotic)

DF <- dfh

CKD <- DF[24:29,]
CHT <- DF[23,]
Other1 <- DF[c(1:2,5,9:14),]
Asthma <- DF[3:4,]
Diabetes <- DF[6:8,]
Organ<- DF[15:16,]
Other2 <-DF[17:22,]
Antibiotic <- DF[30:32,]

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

plot3 <- bind_rows(CHT,CKD,Asthma,Diabetes,Organ,Other1,Other2,Antibiotic)

label1 <- as.vector(plot1$type)
label2 <- as.vector(plot2$type)
label3 <- as.vector(plot3$type)

plot1$type <- factor(plot1$type, levels = label1)
plot2$type <- factor(plot2$type, levels = label2)
plot3$type <- factor(plot3$type, levels = label3)


plot1$group <- "H+C"
plot2$group <- "C"
plot3$group <- "H"

write_csv(plot1, here::here("output", "adjusted_clinical_18_1.csv"))
write_csv(plot2, here::here("output", "adjusted_clinical_18_2.csv"))
write_csv(plot3, here::here("output", "adjusted_clinical_18_3.csv"))
