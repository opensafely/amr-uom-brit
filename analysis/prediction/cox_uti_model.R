################################################################################
# Part 1: UTI model development process                                        #
################################################################################

library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)
library(reshape2)
library(ggplot2)
library(survival)
library(rms)
library(MASS)

## Load data

input_data <- readRDS(here::here("output", "data_for_cox_model.rds"))

data <- input_data %>% filter(has_uti)

# Data Partition 
set.seed(666)
ind <- sample(2,nrow(data),
              replace = TRUE,
              prob = c(0.75,0.25))

training <- data[ind==1,]
testing <- data[ind==2,]


## Age sex model - age spline
age3_spline <- rcs(training$age,3)

k10 <- qchisq(0.10,1,lower.tail=FALSE) # this gives the change in AIC we consider to be significant in our stepwise selection

# Forward selection (by AIC)
empty_mod_2 <- coxph(Surv(training$TEVENT,training$EVENT)~1)
forward_mod_2 <- stepAIC(empty_mod_2,k=k10,scope=list(upper=~training$sex+ age3_spline + training$region + training$imd + training$ethnicity + training$bmi +
                                                        training$smoking_status_comb + training$charlsonGrp + training$ab_3yr + training$ab_30d,lower=~1),direction="forward",trace=TRUE)
# Backward selection (by AIC)
full_mod_2 <- coxph(Surv(training$TEVENT,training$EVENT)~training$sex+ age3_spline + training$region + training$imd + training$ethnicity + training$bmi +
                      training$smoking_status_comb + training$charlsonGrp + training$ab_3yr + training$ab_30d)
backward_mod_2 <- stepAIC(full_mod_2,k=k10,scope=list(upper=~training$sex+ age3_spline + training$region + training$imd + training$ethnicity + training$bmi +
                                                        training$smoking_status_comb + training$charlsonGrp + training$ab_3yr + training$ab_30d,lower=~1),direction="backward",trace=TRUE)


model_selected <- coxph(Surv(training$TEVENT,training$EVENT)~training$sex+ age3_spline + training$region + training$imd + training$ethnicity + training$bmi +
                      training$smoking_status_comb + training$charlsonGrp + training$ab_30d)
