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
library(Hmisc)

## Load data

input_data <- readRDS(here::here("output", "data_for_cox_model_all.rds"))

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

# Fit a Cox model for each spline function
cox_age3 <- coxph(Surv(training$TEVENT,training$EVENT)~age3_spline,data=training,ties="breslow")
cox_age3
lp_age3 <- predict(cox_age3)

cox_age <- coxph(Surv(training$TEVENT,training$EVENT)~training$age)
summary(cox_age)
lp_age1 <- predict(cox_age)

data_part6 <- data.frame(age = training$age, 
                         lp_age1 = lp_age1, 
                         lp_age3 = lp_age3)
data_part6_m <- melt(data_part6, id.vars = 'age')
plot_part6 <- ggplot(data_part6_m, aes(x = age, y = value, colour = variable)) +
  geom_line() +
  scale_colour_manual(labels = c("linear", "3 knots"), 
                      values = c("gray", "green")) +
  theme_bw() +
  labs(x = "Age (years)", y = "Linear Predictor (log odds)", color = "") +
  theme(legend.position = c(0.2, 0.8))
plot_part6

ggsave(plot_part6, dpi = 700,
       filename = "spline_age_uti_all.jpeg", path = here::here("output"))

age_spline_check <- matrix(c(AIC(cox_age),
         BIC(cox_age),
         AIC(cox_age3),
         BIC(cox_age3)), ncol=2, byrow=TRUE)

colnames(age_spline_check) <- c("AIC", "BIC")
rownames(age_spline_check) <- c("age_mod","age3_mod")
age_spline_check


## model evaluation ##
age3_spline_train <- rcs(training$age, 3)
knots <- attr(age3_spline_train, "knots")
age3_spline_test <- rcs(testing$age, 3, knots=knots)
# Bind to training
training$age3_spline <- age3_spline_train
# Bind to testing
testing$age3_spline <- age3_spline_test

model_selected <- coxph(Surv(TEVENT, EVENT) ~ sex + age3_spline + region + imd + ethnicity + bmi + smoking_status_comb + charlsonGrp + ab_30d + covid, data = training)


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
jpeg(here::here("output", "uti_KM_Curves_all.jpeg"))
plot(survfit(Surv(training$TEVENT,training$EVENT)~centile_LP),
     # main="Kaplan-Meier survival estimates",
     xlab="Days", ylab = "Survival probability", col=c(1:4), ylim=c(0.9,1))
legend(x=0.1, y=0.92, 
       c("Low risk group","Low to medium risk group","Medium to high risk group","High risk group"),
       col=c(1:4), lty=1, bty="n")
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

write_csv(pm, here::here("output", "uti_model_evaluation_all.csv"))

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

jpeg(here::here("output", "uti_High_Low_Risk_Patients_all.jpeg"))
plot(survfit(model_selected,newdata=data.frame(patient_high)),
     main="Cox proportional hazards regression",
     xlab="Days", ylab="Survival", col=1, conf.int=FALSE, ylim=c(0.8, 1))
lines(survfit(model_selected,newdata=data.frame(patient_high_shrunk)),col=2,conf.int=FALSE)
lines(survfit(model_selected,newdata=data.frame(patient_low)),col=3,conf.int=FALSE)
lines(survfit(model_selected,newdata=data.frame(patient_low_shrunk)),col=4,conf.int=FALSE)
legend(x=0.1, y=0.84, 
       c("Original LP - High risk","Shrunken LP - High risk","Original LP - Low risk","Shrunken LP - Low risk"),
       col=c(1:4), lty=1, bty="n")
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

# # Estimate the predicted survival probability at 30 days for the high risk patient above
prob_HR <- day30_Cox^exp(patient_high$pred_LP)
prob_HR
prob_HR <- day30_Cox^exp(patient_high$pred_LP)
prob_HR
prob_HR_shrunk <- day30_Cox_shrunk^exp(patient_high_shrunk$pred_LP)
prob_HR_shrunk

jpeg(here::here("output", "uti_survival_plot_baseline_survival_curves_all.jpeg"))

plot(survfit(model_selected),
     main="Cox proportional hazards regression",
     xlab="Days", ylab="Survival", col=1, conf.int=FALSE, ylim=c(0.8, 1))
lines(survfit(shrunk_mod), col=2, lty=2, conf.int=FALSE)
legend(x=0.1, y=0.83, c("Original LP - High risk","Shrunken LP - High risk"), col=c(1:2), lty=1, bty="n")

# abline(h=) adds a line crossing the y-axis at the baseline survival probabilities
abline(h=day30_Cox, col="black")
abline(h=day30_Cox_shrunk, col="red")
abline(v=30, col="red")

dev.off()


# # Re-plot the high risk patient curves & draw on lines corresponding to the patients survival probability
# as calculated above to check they match the predicted survival curves
jpeg(here::here("output", "uti_survival_plot_baseline_survival_curves2_all.jpeg"))

plot(survfit(model_selected, newdata=data.frame(patient_high)),
     main="Cox proportional hazards regression",
     xlab="Days", ylab="Survival", col=1, conf.int=FALSE, ylim=c(0.8, 1))
lines(survfit(model_selected, newdata=data.frame(patient_high_shrunk)), col=2, conf.int=FALSE)
legend("bottomleft", c("Original LP - High risk","Shrunken LP - High risk"), col=c(1:2), lty=1, bty="n")

# Adding the horizontal and vertical lines
abline(h=prob_HR, col="black")
abline(h=prob_HR_shrunk, col="red")
abline(v=30, col="red")

dev.off()



## Result
model_selected <- coxph(Surv(TEVENT, EVENT) ~ sex + age3_spline + region + imd + ethnicity + bmi + smoking_status_comb + charlsonGrp + ab_30d, data = training)
results=as.data.frame(names(model_selected$coefficients))
colnames(results)="term"

# Hazard ratio and 95% CI, P-value and S.E.
results$hazard_ratio=exp(model_selected$coefficients)


  # if all weights equal 1, use standard method for S.E.
  results$conf.low = exp(model_selected$coefficients - 1.96* sqrt(diag(vcov(model_selected))))
  results$conf.high = exp(model_selected$coefficients + 1.96* sqrt(diag(vcov(model_selected))))                                                   
  results$p.value = round(pnorm(abs(model_selected$coefficients/sqrt(diag(model_selected$var))),lower.tail=F)*2,3)
  results$std.error=exp(sqrt(diag(vcov(model_selected))))


results$concordance <- results$concordance.lower <- results$concordance.upper <- NA

results$concordance[1] <- round(concordance(model_selected)$concordance,3) #
results$concordance.lower[1] <- round(concordance(model_selected)$concordance - 1.96*sqrt((concordance(model_selected))$var),3)
results$concordance.upper[1] <- round(concordance(model_selected)$concordance + 1.96*sqrt((concordance(model_selected))$var),3)

results[,2:ncol(results)] <- round(results[,2:ncol(results)], 3)
print("Print results")
print(results) 

write_csv(results, here::here("output", "uti_model_HR_all.csv"))

###### external validation ########

input_test <- testing

input_test$lin_pred <- predict(model_selected, newdata=input_test, type="lp")
test_cox_model <- cph(Surv(TEVENT,EVENT)~lin_pred,data = input_test, method="breslow")
c_stat = round(concordance(test_cox_model)$concordance,3)
c_stat_lower = round(concordance(test_cox_model)$concordance - 1.96*sqrt((concordance(test_cox_model))$var),3)
c_stat_upper = round(concordance(test_cox_model)$concordance + 1.96*sqrt((concordance(test_cox_model))$var),3)
c_stat_var = round((concordance(test_cox_model))$var,6)

# Calibration slope
cal_slope = round(test_cox_model$coef,3)

print("Calculation for the C-statistic is completed!")
pm_ext <- data.frame(
  c_stat = c_stat,
  c_stat_var = c_stat_var,
  c_stat_lower = c_stat_lower,
  c_stat_upper = c_stat_upper,
  cal_slope = cal_slope
)
write_csv(pm_ext, here::here("output", "uti_model_external_all.csv"))

# Calibration plot for the validation data
# Calculate predicted survival probability at 30 day
time_point = 30
y1_cox <- summary(survfit(model_selected),time=time_point)$surv
y1_cox

pred_surv_prob = y1_cox^exp(input_test$lin_pred)

pred_risk = 1 - pred_surv_prob

val_ests <- val.surv(est.surv = pred_surv_prob,
                     S = Surv(input_test$TEVENT,input_test$EVENT), 
                     u=time_point,fun=function(p)log(-log(p)),pred = sort(runif(100, 0, 1)))
print("val_ests is now specified!")

jpeg(here::here("output", "uti_30day_calibration_all.jpeg"))
plot(val_ests,xlab="Expected Survival Probability",ylab="Observed Survival Probability") 
groupkm(pred_surv_prob, S = Surv(input_test$TEVENT,input_test$EVENT), 
        g=10,u=time_point, pl=T, add=T,lty=0,cex.subtitle=FALSE)
legend(0.0,0.8,c("Risk groups","Reference line","95% CI"),lty=c(0,2,1),pch=c(19,NA,NA),bty="n")
dev.off()


print("Calibration plot is created successfully!")
# Recalibration of the baseline survival function
recal_mod <- coxph(Surv(input_test$TEVENT,input_test$EVENT)~offset(input_test$lin_pred))
y_recal_30d <- summary(survfit(recal_mod),time=time_point)$surv
y_recal_30d

# Calculate new predicted probabilities at 30 days (linear predictor stays the same but needs centering)
pred_surv_prob2=y_recal_30d^exp(input_test$lin_pred-mean(input_test$lin_pred))
mean(pred_surv_prob2)
sd(pred_surv_prob2)

# Redo calibration plot
val_ests2 <- val.surv(est.surv = pred_surv_prob2,
                      S = Surv(input_test$TEVENT,input_test$EVENT), 
                      u=time_point,fun=function(p)log(-log(p)),pred = sort(runif(100, 0, 1)))

jpeg(here::here("output", "uti_30day_re-calibration_all.jpeg"))
plot(val_ests2,xlab="Expected Survival Probability",ylab="Observed Survival Probability") 
groupkm(pred_surv_prob2, S = Surv(input_test$TEVENT,input_test$EVENT), 
        g=10,u=time_point, pl=T, add=T,lty=0,cex.subtitle=FALSE)
legend(0.0,0.9,c("Risk groups","Reference line","95% CI"),lty=c(0,2,1),pch=c(19,NA,NA),bty="n")
dev.off()


print("Re-calibration plot is created successfully!")