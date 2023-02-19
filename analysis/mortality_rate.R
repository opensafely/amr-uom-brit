#### This script is for calculating mortality rate and draw the table ####

require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")
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
mod <- glm(died_any_30d~ imd+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result4 <- result[2:5,]

### Other ###
mod <- glm(died_any_30d~ ethnicity+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result5 <- result[2:6,]


mod <- glm(died_any_30d~ bmi_adult+ rcs(age, 4) + sex + strata(region),family="binomial",data = df)
result <-data.frame(exp(cbind(OR = coef(mod), confint(mod))))
result6 <- result[2:6,]


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

write_csv(result, here::here("output", "model_mortality.csv"))