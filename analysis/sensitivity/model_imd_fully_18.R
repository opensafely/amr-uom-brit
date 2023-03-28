require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")
df <- df%>%filter(df$age >=18)
df$imd= relevel(as.factor(df$imd), ref="5")
mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
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

dfch <- DF

df <- readRDS("output/processed/input_model_c.rds")
df <- df%>%filter(df$age >=18)
df$imd= relevel(as.factor(df$imd), ref="5")
mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + 
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
df <- df%>%filter(df$age >=18)
df$imd= relevel(as.factor(df$imd), ref="5")
mod=clogit(case ~ imd + ethnicity + bmi_adult + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + ab_frequency + 
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

IMD$type <-  case_when(
  IMD$type == "imd1" ~ "IMD 1(Most deprived)",
  IMD$type == "imd2" ~ "IMD 2",
  IMD$type == "imd3" ~ "IMD 3",
  IMD$type == "imd4" ~ "IMD 4")

plot0.1 <- IMD

DF <- dfc

IMD <- DF[1:4,]

IMD$type <-  case_when(
  IMD$type == "imd1" ~ "IMD 1(Most deprived)",
  IMD$type == "imd2" ~ "IMD 2",
  IMD$type == "imd3" ~ "IMD 3",
  IMD$type == "imd4" ~ "IMD 4")

plot0.2 <- IMD

DF <- dfh

IMD <- DF[1:4,]

IMD$type <-  case_when(
  IMD$type == "imd1" ~ "IMD 1(Most deprived)",
  IMD$type == "imd2" ~ "IMD 2",
  IMD$type == "imd3" ~ "IMD 3",
  IMD$type == "imd4" ~ "IMD 4")

plot0.3 <- IMD

label0 <- as.vector(plot0.1$type)

plot0.1$type <- factor(plot0.1$type, levels = label0)
plot0.2$type <- factor(plot0.2$type, levels = label0)
plot0.3$type <- factor(plot0.3$type, levels = label0)

plot0.1$group <- "H+C"
plot0.2$group <- "C"
plot0.3$group <- "H"

plotimd <- bind_rows(plot0.1,plot0.2,plot0.3)
write_csv(plotimd, here::here("output", "model_imd_fully_18.csv"))
