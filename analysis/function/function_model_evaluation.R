library(rms)
function_model_evaluation <- function(input,fit_cox_model, which_model, analysis, subset_vars, graphics_output, save_output){
  # create output table for performance measures
  
  pm <- data.frame()
  
  ##########################################################
  # Part 2: calculate apparent discrimination performance  #
  ##########################################################
  
  # Calculate apparent discrimination performance
  
  ## Obtain the linear predictor
  #pred_LP <- predict(fit_cox_model,type="lp",reference="sample", na.rm=T)
  pred_LP <- fit_cox_model$linear.predictors
  
  mean(pred_LP)
  sd(pred_LP)
  min(pred_LP)
  max(pred_LP)
  
  # C statistic
  concordance(fit_cox_model)
  pm[nrow(pm)+1,1] <- "C-Statistic"
  pm[nrow(pm),2] <- round(concordance(fit_cox_model)$concordance,3)
  pm[nrow(pm)+1,1] <- "C-Statistic-lower"
  pm[nrow(pm),2] <-round(concordance(fit_cox_model)$concordance - 1.96*sqrt((concordance(fit_cox_model))$var),3)
  pm[nrow(pm)+1,1] <- "C-Statistic-upper"
  pm[nrow(pm),2] <- round(concordance(fit_cox_model)$concordance + 1.96*sqrt((concordance(fit_cox_model))$var),3)
  
  # D statistic needs library(survcomp)
  
  print("Part 2. Calculate apparent discrimination performance is completed successfully!")
  
  ##################################################
  # Part 3.  assess the models apparent calibration#
  ##################################################
  
  ## Calibration slope
  fit_cox_model2<- cph(Surv(input$lcovid_surv,input$lcovid_cens)~pred_LP,
                       x=TRUE, y=TRUE)
  pm[nrow(pm)+1,1] <- "Calibration slope"
  pm[nrow(pm),2] <- round(fit_cox_model2$coef,3)
  
  print("Part 3. Assess the models apparent calibration is completed successfully!")
  
  ####################
  # Part 4. Plotting #
  ####################
  
  print("Stage4_model_evaluation.R, starting Part 4 Plotting!")
  # Compare the bootstrap shrinkage estimate to the heuristic shrinkage previously calculated
  
  if(graphics_output==TRUE){
  #Plot of apparent separation across 4 groups
  svglite::svglite(file = paste0("output/not_for_review/model/survival_plot_by_risk_groups_", subset_vars,which_model, "_", analysis, ".svg"))
  if(which_model == "full"){
    centile_LP <- cut(pred_LP,breaks=quantile(pred_LP, prob = c(0,0.25,0.50,0.75,1), na.rm=T),
                      labels=c(1:4),include.lowest=TRUE)
    
    # Graph the KM curves in the 4 risk groups to visually assess separation
    plot(survfit(Surv(input$lcovid_surv,input$lcovid_cens)~centile_LP),
         #main="Kaplan-Meier survival estimates",
         xlab="Days",ylab = "Survival probability",col=c(1:4))
    legend(1,0.5,c("Low risk group","Low to medium risk group","Medium to high risk group","High risk group"),col=c(1:4),lty=1,bty="n")
  }
  
  if(which_model == "selected"){
    # if(selected_covariate_names != "cov_cat_ie.status" | length(selected_covariate_names)>2){
    if(length(selected_covariate_names)>4){
      centile_LP <- cut(pred_LP,breaks=quantile(pred_LP, prob = c(0,0.25,0.50,0.75,1), na.rm=T),
                        labels=c(1:4),include.lowest=TRUE)
      # Graph the KM curves in the 4 risk groups to visually assess separation
      plot(survfit(Surv(input$lcovid_surv,input$lcovid_cens)~centile_LP),
           # main="Kaplan-Meier survival estimates",
           xlab="Days", ylab = "Survival probability", col=c(1:4))
      legend(1,0.5,c("Low risk group","Low to medium risk group","Medium to high risk group","High risk group"),col=c(1:4),lty=1,bty="n")
      # dev.off()
    }
  }
  dev.off()
  }
  
  print(paste0("Part 4. Survival plot by risk groups have been saved successfully for ", which_model, " ", analysis, "!" ))
  
  ###############################
  # Part 5. Assess for Optimism #
  ###############################
  
  ## assessment of optimism in the model development process
  
  ## Obtain chi-square value: compare fitted model and the null model
  
  chi2_fit_cox_model = fit_cox_model$stats["Model L.R."] 
  df_fit_cox_model = fit_cox_model$stats["d.f."]
  
  names(fit_cox_model)
  
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
  fit_cox_model3 <- cph(Surv(input$lcovid_surv,input$lcovid_cens)~heuristic_lp)
  # calibration slope
  fit_cox_model3$coef
  pm[nrow(pm)+1, 1] <- "reculated calibration slope using the shrunken linear predictor"
  pm[nrow(pm), 2] <- round(fit_cox_model3$coef,3)
  
  ## plot original predictions (before shrinkage) versus our shrunken model predictions
  ## To do this we can plot the KM curve for one high risk patient, and one low risk patient using the original and shrunken model lp
  lpdat <- cbind(input,pred_LP)
  patient_high <- subset(lpdat, pred_LP == max(pred_LP))
  patient_low <- subset(lpdat,pred_LP == min(pred_LP))
  
  # # Calculate shrunken LP for these patients
  patient_high_shrunk <- patient_high
  patient_high_shrunk$pred_LP <- patient_high$pred_LP*vanH
  patient_low_shrunk <- patient_low
  patient_low_shrunk$pred_LP <- patient_low$pred_LP*vanH
  
  if(graphics_output==TRUE){
  svglite::svglite(file = paste0("output/not_for_review/model/surival_plot_with_shrunken_LP_",subset_vars, which_model, ".svg"))
  
  plot(survfit(fit_cox_model,newdata=data.frame(patient_high)),main="Cox proportional hazards regression",xlab="Days",ylab="Survival",col=1,conf.int=FALSE)
  lines(survfit(fit_cox_model,newdata=data.frame(patient_high_shrunk)),col=2,conf.int=FALSE)
  lines(survfit(fit_cox_model,newdata=data.frame(patient_low)),col=3,conf.int=FALSE)
  lines(survfit(fit_cox_model,newdata=data.frame(patient_low_shrunk)),col=4,conf.int=FALSE)
  legend(1,0.3,c("Original LP - High risk","Shrunken LP - High risk","Original LP - Low risk","Shrunken LP - Low risk"),col=c(1:4),lty=1,bty="n")
  dev.off()
  }
  #
  # # Linear predictor values
  patient_high$pred_LP
  patient_high_shrunk$pred_LP
  
  # # obtain an estimate of the baseline survival at a specific time point, for the shrunken model
  # # First obtain an estimate of the baseline survival at 180 days for the original model
  day180_Cox <- summary(survfit(fit_cox_model),time=180)$surv
  day180_Cox
  
  # Now calculate the shrunken models baseline survival prob at 180 days by setting the shrunken lp as a offset and predicting the baseline survival
  shrunk_mod <- coxph(Surv(input$lcovid_surv,input$lcovid_cens)~offset(heuristic_lp))
  day180_Cox_shrunk <- summary(survfit(shrunk_mod),time=180)$surv
  day180_Cox_shrunk
  
  # # Estimate the predicted survival probability at 180 days for the high risk patient above
  prob_HR <- day180_Cox^exp(patient_high$pred_LP)
  prob_HR
  prob_HR <- day180_Cox^exp(patient_high$pred_LP)
  prob_HR
  prob_HR_shrunk <- day180_Cox_shrunk^exp(patient_high_shrunk$pred_LP)
  prob_HR_shrunk
  
  if(graphics_output==TRUE){
  svglite::svglite(file = paste0("output/review/model/survival_plot_baseline_survival_curves_", subset_vars, which_model,"_", analysis, ".svg"))
  # We can plot the two baseline survival curves
  plot(survfit(fit_cox_model),main="Cox proportional hazards regression",xlab="Days",ylab="Survival",col=1,conf.int=FALSE)
  lines(survfit(shrunk_mod),col=2,lty=2,conf.int=FALSE)
  legend(7.5,0.3,c("Original LP - High risk","Shrunken LP - High risk"),col=c(1:2),lty=1,bty="n")
  
  # abline(h=) adds a line crossing the y-axis at the baseline survival probabilities
  abline(h=day180_Cox,col="black")
  abline(h=day180_Cox_shrunk,col="red")
  abline(v=180,col="red")
  dev.off()
  
  svglite::svglite(file = paste0("output/review/model/survival_plot_baseline_survival_curves2_", subset_vars, which_model, "_", analysis, ".svg"))
  # # Re-plot the high risk patient curves & draw on lines corresponding to the patients survival probability
  # as calculated above to check they match the predicted survival curves
  plot(survfit(fit_cox_model2,newdata=data.frame(patient_high)),main="Cox proportional hazards regression",xlab="Days",ylab="Survival",col=1,conf.int=FALSE)
  lines(survfit(fit_cox_model2,newdata=data.frame(patient_high_shrunk)),col=2,conf.int=FALSE)
  legend(10,0.3,c("Original LP - High risk","Shrunken LP - High risk"),col=c(1:2),lty=1,bty="n")
  abline(h=prob_HR,col="black")
  abline(h=prob_HR_shrunk,col="red")
  abline(v=180,col="red")
  dev.off()
  }
  print(paste0("Part 5. Assess for optimism is completed successfully for ", which_model, " ", analysis, "!"))
  
  ###########################################################
  # Part 6. Internal validation using bootstrap validation  #
  ###########################################################
  
  #  perform internal validation using bootstrap validation.

  set.seed(12345) # to ensure reproducibility
  boot_1 <- validate(fit_cox_model,B=100, u=365,dxy=TRUE) # u must be specified if strata is used
  # cal <-calibrate(fit_cox_model,B=100,bw=TRUE) # also repeats fastbw
  # plot(cal)
  boot_1

  # Note that this gives Dxy rather than c, however Dxy = 2*(c-0.5), i.e. c=(Dxy/2)+0.5
  pm[nrow(pm)+1,1] <- "c-statistic-boostrap-validation-original"
  pm[nrow(pm),2] <- round((boot_1[1,1]+1)/2,3)
  pm[nrow(pm)+1,1] <- "c-statistic-boostrap-validation-optimism"
  pm[nrow(pm),2] <- round((boot_1[1,4]+1)/2,3)
  pm[nrow(pm)+1,1] <- "c-statistic-boostrap-validation-corrected"
  pm[nrow(pm),2] <- round((boot_1[1,5]+1)/2,3)

  # Calibration slope
  pm[nrow(pm)+1,1] <- "calibration-slope-boostrap-validation-original"
  pm[nrow(pm),2] <- round((boot_1[3,1]+1)/2,3)
  pm[nrow(pm)+1,1] <- "calibration-slope-boostrap-validation-optimism"
  pm[nrow(pm),2] <- round((boot_1[3,4]+1)/2,3)
  pm[nrow(pm)+1,1] <- "calibration-slope-boostrap-validation-corrected"
  pm[nrow(pm),2] <- round((boot_1[3,5]+1)/2,3)

  print(paste0("Part 6. Internal validation using bootstrap validation is completed successfully for ",
               which_model, " ", analysis, "!"))
  
  ###############################################################
  # Part 7. Shrinkage & Optimism adjusted performance measures #
  ###############################################################
  
  # Shrinkage & optimism adjusted AUC, CITL etc. using bootstrapping with predictor selection methods
  k10 <- qchisq(0.20,1,lower.tail=FALSE)
  set.seed(12345) # to ensure reproducibility
  boot_2 <- validate(fit_cox_model,B=100,rule="aic",aics=k10, u=365, dxy=TRUE)
  boot_2
  
  # Convert Dxy to c-index
  # (boot_2[1,1]+1)/2
  # (boot_2[1,5]+1)/2
  
  pm[nrow(pm)+1,1] <- "c-statistic-boostrap-validation-original"
  pm[nrow(pm),2] <- round((boot_2[1,1]+1)/2,3)
  pm[nrow(pm)+1,1] <- "c-statistic-boostrap-validation-optimism"
  pm[nrow(pm),2] <- round((boot_2[1,4]+1)/2,3)
  pm[nrow(pm)+1,1] <- "c-statistic-boostrap-validation-corrected"
  pm[nrow(pm),2] <- round((boot_2[1,5]+1)/2,3)
  
  # Calibration slope
  pm[nrow(pm)+1,1] <- "calibration-slope-boostrap-validation-original"
  pm[nrow(pm),2] <- round((boot_2[3,1]+1)/2,3)
  pm[nrow(pm)+1,1] <- "calibration-slope-boostrap-validation-optimism"
  pm[nrow(pm),2] <- round((boot_2[3,4]+1)/2,3)
  pm[nrow(pm)+1,1] <- "calibration-slope-boostrap-validation-corrected"
  pm[nrow(pm),2] <- round((boot_2[3,5]+1)/2,3)
  
  names(pm) <- c("performance measure", "value")
  
  if(save_output==TRUE){
  write.csv(pm, file=paste0("output/review/model/PM_", subset_vars,which_model, "_", analysis, ".csv"), 
            row.names=F)
  
  # rmarkdown::render(paste0("analysis/compilation/compiled_performance_measure_table",".Rmd"), 
  #                   output_file=paste0("performance_measures_", subset_vars, which_model,"_", analysis),
  #                   output_dir="output/review/model")
  }
  print(paste0("Part 7. Shrinkage & Optimism adjusted performance measures is completed successfully for",
               which_model, " ", analysis, "!"))
  return(pm)
}