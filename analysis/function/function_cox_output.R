## Purpose: to extract and save cox model output--------------------------------                                 
# function for small number suppression
cox_output2 <- function(fit_cox_model, which_model, output_file, save_output){
  
  # ## assess proportional hazards assumption
  # ph_test_result <- cox.zph(fit_cox_model, "rank")$table
  # ph_test_result[,c(1,3)] <- round(ph_test_result[,c(1,3)], 3)
  # write.csv(ph_test_result, file=paste0("output/review/model/PH_test_", which_model, "_", analysis, ".csv"), row.names=F)
  # print(paste0("Results from proportional hazards test are saved successfully for ", which_model, " ", analysis, "!"))
  # 
  print("Get robust estimation")
  ## get robust variance-covariance matrix so that robust standard errors can be used in constructing CI's
  robust_fit_cox_model=rms::robcov(fit_cox_model, cluster = input$practice_id)
  
  print("completed robust estimation")
  
  ## Result
  results=as.data.frame(names(fit_cox_model$coefficients))
  colnames(results)="term"
  
  # Hazard ratio and 95% CI, P-value and S.E.
  results$hazard_ratio=exp(fit_cox_model$coefficients)
  # Determine which S.E. to use
  if(all.equal(input$weight,1)==T){
    # if all weights equal 1, use standard method for S.E.
    results$conf.low = exp(fit_cox_model$coefficients - 1.96* sqrt(diag(vcov(fit_cox_model))))
    results$conf.high = exp(fit_cox_model$coefficients + 1.96* sqrt(diag(vcov(fit_cox_model))))                                                   
    results$p.value = round(pnorm(abs(fit_cox_model$coefficients/sqrt(diag(fit_cox_model$var))),lower.tail=F)*2,3)
    results$std.error=exp(sqrt(diag(vcov(fit_cox_model))))
  }else{
    # if not all weights equal 1, i.e. sampling in use, use robust S.E.
    # Hazard ratio and robust estimation for variance, and the resulting 95% CI, P-value and S.E.
    results$robust.conf.low=exp(confint(robust_fit_cox_model,level=0.95)[,1]) #use robust standard errors to calculate 95% CI
    results$robust.conf.high=exp(confint(robust_fit_cox_model,level=0.95)[,2])
    results$robust.p.value = round(pnorm(abs(robust_fit_cox_model$coefficients/sqrt(diag(robust_fit_cox_model$var))),lower.tail=F)*2,3)
    results$robust.se=round(exp(sqrt(diag(vcov(robust_fit_cox_model)))),3)
  }
  
  
  results$concordance <- results$concordance.lower <- results$concordance.upper <- NA
  
  results$concordance[1] <- round(concordance(fit_cox_model)$concordance,3) #
  results$concordance.lower[1] <- round(concordance(fit_cox_model)$concordance - 1.96*sqrt((concordance(fit_cox_model))$var),3)
  results$concordance.upper[1] <- round(concordance(fit_cox_model)$concordance + 1.96*sqrt((concordance(fit_cox_model))$var),3)
  
  results[,2:ncol(results)] <- round(results[,2:ncol(results)], 3)
  print("Print results")
  print(results) 
  
  # remove results from robust estimation
  #results <-results %>% dplyr::select(-contains("robust"))
  
  if(save_output==TRUE){
  write.csv(results, file=paste0(output_file,".csv"), row.names=F)
  # rmarkdown::render(paste0("analysis/compilation/compiled_HR_results",".Rmd"), 
  #                   output_file=output_file,
  #                   output_dir="output/review/model")
  }
  print(paste0("Hazard ratio estimates are saved successfully for ", which_model, " ", analysis, "!"))
  return(results)
}