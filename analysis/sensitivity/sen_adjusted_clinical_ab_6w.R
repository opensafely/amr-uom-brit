require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")
df$ab_frequency_6w= relevel(as.factor(df$ab_frequency_6w), ref="0")
mod=clogit(case ~  hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency_6w + strata(set_id), df)
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
df$ab_frequency_6w= relevel(as.factor(df$ab_frequency_6w), ref="0")
mod=clogit(case ~  hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency_6w + strata(set_id), df)
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
df$ab_frequency_6w= relevel(as.factor(df$ab_frequency_6w), ref="0")
mod=clogit(case ~ hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency_6w + strata(set_id), df)
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
Antibiotic <- DF[30:32,]
Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency_6w1" ~ "Antibiotic count(6 weeks): 1",
  Antibiotic$type == "ab_frequency_6w2-3" ~ "Antibiotic count(6 weeks): 2-3",
  Antibiotic$type == "ab_frequency_6w>3" ~ "Antibiotic count(6 weeks): 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot1 <- Antibiotic


DF <- dfc

Antibiotic <- DF[30:32,]
Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency_6w1" ~ "Antibiotic count(6 weeks): 1",
  Antibiotic$type == "ab_frequency_6w2-3" ~ "Antibiotic count(6 weeks): 2-3",
  Antibiotic$type == "ab_frequency_6w>3" ~ "Antibiotic count(6 weeks): 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot2 <- Antibiotic

DF <- dfh
Antibiotic <- DF[30:32,]
Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency_6w1" ~ "Antibiotic count(6 weeks): 1",
  Antibiotic$type == "ab_frequency_6w2-3" ~ "Antibiotic count(6 weeks): 2-3",
  Antibiotic$type == "ab_frequency_6w>3" ~ "Antibiotic count(6 weeks): 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot3 <- Antibiotic

label1 <- as.vector(c("Antibiotic count(6 weeks): 1","Antibiotic count(6 weeks): 2-3","Antibiotic count(6 weeks): 3+"))


plot1$type <- factor(plot1$type, levels = label1)
plot2$type <- factor(plot2$type, levels = label1)
plot3$type <- factor(plot3$type, levels = label1)


plot1$group <- "H+C"
plot2$group <- "C"
plot3$group <- "H"

write_csv(plot1, here::here("output", "sen_adjusted_clinical_ab_6w_1.csv"))
write_csv(plot2, here::here("output", "sen_adjusted_clinical_ab_6w_2.csv"))
write_csv(plot3, here::here("output", "sen_adjusted_clinical_ab_6w_3.csv"))
