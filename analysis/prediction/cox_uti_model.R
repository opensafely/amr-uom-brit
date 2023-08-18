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

## model evaluation ##

model_selected <- coxph(Surv(training$TEVENT,training$EVENT)~training$sex+ age3_spline + training$region + training$imd + training$ethnicity + training$bmi +
                      training$smoking_status_comb + training$charlsonGrp + training$ab_30d)


pred_LP <- model_selected$linear.predictors
mean(pred_LP)
sd(pred_LP)
min(pred_LP)
max(pred_LP)

concordance(model_selected)
pm <- data.frame()
pm[nrow(pm)+1,1] <- "C-Statistic"
pm[nrow(pm),2] <- round(concordance(model_selected)$concordance,3)
pm[nrow(pm)+1,1] <- "C-Statistic-lower"
pm[nrow(pm),2] <-round(concordance(model_selected)$concordance - 1.96*sqrt((concordance(model_selected))$var),3)
pm[nrow(pm)+1,1] <- "C-Statistic-upper"
pm[nrow(pm),2] <- round(concordance(model_selected)$concordance + 1.96*sqrt((concordance(model_selected))$var),3)

##################################################
# Part 3.  assess the models apparent calibration#
##################################################

## Calibration slope
model_selected<- cph(Surv(training$TEVENT,training$EVENT)~pred_LP,
                     x=TRUE, y=TRUE)
pm[nrow(pm)+1,1] <- "Calibration slope"
pm[nrow(pm),2] <- round(model_selected$coef,3)

print("Part 3. Assess the models apparent calibration is completed successfully!")

centile_LP <- cut(pred_LP,breaks=quantile(pred_LP, prob = c(0,0.25,0.50,0.75,1), na.rm=T),
                  labels=c(1:4),include.lowest=TRUE)
# Graph the KM curves in the 4 risk groups to visually assess separation
jpeg(here::here("output", "KM_Curves.jpeg"))
plot(survfit(Surv(training$TEVENT,training$EVENT)~centile_LP),
     # main="Kaplan-Meier survival estimates",
     xlab="Days", ylab = "Survival probability", col=c(1:4))
legend(1,0.5,c("Low risk group","Low to medium risk group","Medium to high risk group","High risk group"),col=c(1:4),lty=1,bty="n")
dev.off()

###############################
# Part 5. Assess for Optimism #
###############################

## assessment of optimism in the model development process

## Obtain chi-square value: compare fitted model and the null model

chi2_fit_cox_model = model_selected$stats["Model L.R."] 
df_fit_cox_model = model_selected$stats["d.f."]

names(model_selected)

# obtain the heuristic shrinkage of Van Houwelingen 

vanH <- (chi2_fit_cox_model - df_fit_cox_model)/chi2_fit_cox_model
vanH
pm[nrow(pm)+1, 1] <- "Heuristic shrinkage"
pm[nrow(pm), 2] <- round(vanH,3)

# revise the final model
heuristic_lp = vanH*pred_LP

# summarise the original & shrunken lp and compare the mean/SD/range
mean(pred_LP)
sqrt(var(pred_LP))
min(pred_LP)
max(pred_LP)

mean(heuristic_lp)
sqrt(var(heuristic_lp))
min(heuristic_lp)
max(heuristic_lp)

# Now recalculate the calibration slope using the shrunken linear predictor
fit_cox_model3 <- cph(Surv(training$TEVENT,training$EVENT)~heuristic_lp)
# calibration slope
fit_cox_model3$coef
pm[nrow(pm)+1, 1] <- "reculated calibration slope using the shrunken linear predictor"
pm[nrow(pm), 2] <- round(fit_cox_model3$coef,3)

write_csv(pm, here::here("output", "uti_model_evaluation.csv"))

## plot original predictions (before shrinkage) versus our shrunken model predictions
## To do this we can plot the KM curve for one high risk patient, and one low risk patient using the original and shrunken model lp
lpdat <- cbind(training,pred_LP)
patient_high <- subset(lpdat, pred_LP == max(pred_LP))
patient_low <- subset(lpdat,pred_LP == min(pred_LP))

# # Calculate shrunken LP for these patients
patient_high_shrunk <- patient_high
patient_high_shrunk$pred_LP <- patient_high$pred_LP*vanH
patient_low_shrunk <- patient_low
patient_low_shrunk$pred_LP <- patient_low$pred_LP*vanH

jpeg(here::here("output", "High_Low_Risk_Patients.jpeg"))
plot(survfit(model_selected,newdata=data.frame(patient_high)),main="Cox proportional hazards regression",xlab="Days",ylab="Survival",col=1,conf.int=FALSE)
lines(survfit(model_selected,newdata=data.frame(patient_high_shrunk)),col=2,conf.int=FALSE)
lines(survfit(model_selected,newdata=data.frame(patient_low)),col=3,conf.int=FALSE)
lines(survfit(model_selected,newdata=data.frame(patient_low_shrunk)),col=4,conf.int=FALSE)
legend(1,0.3,c("Original LP - High risk","Shrunken LP - High risk","Original LP - Low risk","Shrunken LP - Low risk"),col=c(1:4),lty=1,bty="n")
dev.off()
  
# # Linear predictor values
patient_high$pred_LP
patient_high_shrunk$pred_LP

# # obtain an estimate of the baseline survival at a specific time point, for the shrunken model
# # First obtain an estimate of the baseline survival at 30 days for the original model
day30_Cox <- summary(survfit(model_selected),time=30)$surv
day30_Cox

# Now calculate the shrunken models baseline survival prob at 30 days by setting the shrunken lp as a offset and predicting the baseline survival
shrunk_mod <- coxph(Surv(training$TEVENT,training$EVENT)~offset(heuristic_lp))
day30_Cox_shrunk <- summary(survfit(shrunk_mod),time=30)$surv
day30_Cox_shrunk

# # Estimate the predicted survival probability at 180 days for the high risk patient above
prob_HR <- day30_Cox^exp(patient_high$pred_LP)
prob_HR
prob_HR <- day30_Cox^exp(patient_high$pred_LP)
prob_HR
prob_HR_shrunk <- day30_Cox_shrunk^exp(patient_high_shrunk$pred_LP)
prob_HR_shrunk

jpeg(here::here("output", "survival_plot_baseline_survival_curves.jpeg"))
plot(survfit(model_selected),main="Cox proportional hazards regression",xlab="Days",ylab="Survival",col=1,conf.int=FALSE)
lines(survfit(shrunk_mod),col=2,lty=2,conf.int=FALSE)
legend(7.5,0.3,c("Original LP - High risk","Shrunken LP - High risk"),col=c(1:2),lty=1,bty="n")
  
# abline(h=) adds a line crossing the y-axis at the baseline survival probabilities
abline(h=day30_Cox,col="black")
abline(h=day30_Cox_shrunk,col="red")
abline(v=30,col="red")
dev.off()
# # Re-plot the high risk patient curves & draw on lines corresponding to the patients survival probability
# as calculated above to check they match the predicted survival curves
jpeg(here::here("output", "survival_plot_baseline_survival_curves2.jpeg"))
plot(survfit(model_selected,newdata=data.frame(patient_high)),main="Cox proportional hazards regression",xlab="Days",ylab="Survival",col=1,conf.int=FALSE)
lines(survfit(model_selected,newdata=data.frame(patient_high_shrunk)),col=2,conf.int=FALSE)
legend(10,0.3,c("Original LP - High risk","Shrunken LP - High risk"),col=c(1:2),lty=1,bty="n")
abline(h=prob_HR,col="black")
abline(h=prob_HR_shrunk,col="red")
abline(v=30,col="red")
dev.off()