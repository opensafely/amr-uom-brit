library("tidyverse") 
library(foreign)
library(tsModel)
library(lmtest)
library(Epi)
library(multcomp)
library(splines)
library(vcd)
library(here)
library(lubridate)
library(stringr)
library(ggplot2)
library(patchwork)
library(dplyr)
library(tidyr)

start_covid = as.Date("2020-04-01")
covid_adjustment_period_from = as.Date("2020-03-01")
plot_order <- c(1:11)

all_files <- list.files(here::here("output"), pattern = "mon_")
outcomes <- stringr::str_remove_all(all_files, c("mon_|.csv"))
outcome_of_interest_namematch <- bind_cols("outcome" = outcomes, 
                                           "outcome_name" = (c("Overall","Coded","Uncoded","Cold","COPD",
                                           "Cough","LRTI","Otitis externa","Otitis media",
                                           "Sinusitis","Sore throat","URTI","UTI"))
)

for(ii in 1:length(outcomes)){
  load_file <- read.csv(here::here("output", paste0("mon_", outcomes[ii], ".csv")))
  assign(outcomes[ii], load_file)
}

tab3_function <- function(outcome){
  df_outcome <- get(outcome)
  # start of post-lockdown period
  ldn_centre <- df_outcome$time[min(which(df_outcome$covid == 1))]
  
  ## model Poisson 
  po_model1 <- glm(numOutcome ~ offset(log(numEligible)) + covid + time + I(time-ldn_centre):covid + as.factor(mon) , family=quasipoisson, data = filter(df_outcome, !is.na(covid)))
  # get lagged residuals
  lagres1 <- lag(residuals(po_model1))
  
  ## full model with lagged residuals
  po_model2 <- glm(numOutcome ~ offset(log(numEligible)) + covid + time + I(time-ldn_centre):covid + as.factor(mon)   + lagres1, family=quasipoisson, data = filter(df_outcome, !is.na(covid)))
  
  ## adjust predicted values
  pearson_gof <- sum(residuals(po_model2, type = "pearson")^2)
  df <- po_model2$df.residual
  deviance_adjustment <- pearson_gof/df
  
  po_lagres_timing <- bind_cols("time" = df_outcome$time[!is.na(df_outcome$covid)],
                                "lagres1" = lagres1)
  
  ## data frame to predict values from 
  outcome_pred <- df_outcome %>%
    left_join(po_lagres_timing, by = "time") %>%
    mutate_at("lagres1", ~(. = 0))
  
  ## predict values
  pred1 <- predict(po_model2, newdata = outcome_pred, se.fit = TRUE, interval="confidence", dispersion = deviance_adjustment)
  predicted_vals <- pred1$fit
  stbp <- pred1$se.fit
  
  ## predict values if no covid 
  outcome_pred_nointervention <- outcome_pred %>%
    mutate_at("covid", ~(.=0))
  predicted_vals_noCov <- predict(po_model2, newdata = outcome_pred_nointervention, se.fit = TRUE, dispersion = deviance_adjustment) 
  stbp_noCov <- predicted_vals_noCov$se.fit	
  predicted_vals_noCov <- predicted_vals_noCov$fit	
  ## standard errors
  df_se <- bind_cols(stbp = stbp, 
                     pred = predicted_vals, 
                     stbp_noCov = stbp_noCov, 
                     pred_noCov = predicted_vals_noCov, 
                     denom = df_outcome$numEligible) %>%
    mutate(
      #CIs
      upp = pred + (1.96*stbp),
      low = pred - (1.96*stbp),
      upp_noCov = pred_noCov + (1.96*stbp_noCov),
      low_noCov = pred_noCov - (1.96*stbp_noCov),
      # probline
      predicted_vals = exp(pred)/denom,
      probline_noCov = exp(pred_noCov)/denom,
      #
      uci = exp(upp)/denom,
      lci = exp(low)/denom,
      uci_noCov = exp(upp_noCov)/denom,
      lci_noCov = exp(low_noCov)/denom
    )
  
  mo1_post_Cov <- start_covid + 30
  mo3_post_Cov <- start_covid + 92
  
  sigdig <- 2
  model_out <- signif(ci.exp(po_model2)[2,], sigdig)
  
  tab3_dates <- bind_cols("monPlot" = df_outcome$monPlot, df_se) %>%
    mutate(target_1mo = mo1_post_Cov,
           target_3mo = mo3_post_Cov,
           days2 = abs(target_1mo - as.Date(monPlot)),
           days3 = abs(target_3mo - as.Date(monPlot)),
           # estimated number of montly outcomes with NO COVID-19
           col1 = paste0(prettyNum(probline_noCov*1e6,big.mark=",",digits = 0, scientific=FALSE), 
                         " (", prettyNum(lci_noCov*1e6,big.mark=",",digits = 0, scientific=FALSE), 
                         " - ", prettyNum(uci_noCov*1e6,big.mark=",",digits = 0, scientific=FALSE),")"),
           # estimated number of montly ooutcomes with COVID-19
           col3 = paste0(prettyNum(predicted_vals*1e6,big.mark=",",digits = 0, scientific=FALSE), 
                         " (", prettyNum(lci*1e6,big.mark=",",digits = 0, scientific=FALSE), 
                         " - ", prettyNum(uci*1e6,big.mark=",",digits = 0, scientific=FALSE),")")
    ) %>%
    ## filter to post-lockdown data only
    filter(monPlot >= start_covid) %>%
    ## calculate cumulative sum of predicted vals with/without lockdown 
    mutate(cumsum_Cov = cumsum(predicted_vals*1e6),
           lci_cumsum_Cov = cumsum(lci*1e6),
           uci_cumsum_Cov = cumsum(uci*1e6),
           cumsum_noCov = cumsum(probline_noCov*1e6),
           lci_cumsum_noCov = cumsum(low_noCov*1e6),
           uci_cumsum_noCov = cumsum(upp_noCov*1e6),
           prettyNum(uci*1e6,big.mark=",",digits = 0, scientific=FALSE),
           ## Monthly difference in Covid vs No Covid
           col5 = prettyNum(signif((probline_noCov*1e6) - (predicted_vals*1e6),3), big.mark=",", digits = 0, scientific=FALSE),
           ## cumulative sum of Covid vs No Covid
           col6 = prettyNum(signif((cumsum_noCov) - (cumsum_Cov),3), big.mark=",", digits = 0, scientific=FALSE)
    )  %>%
    ## censor data if it is too small
    mutate(diff_predicted = (probline_noCov*1e6) - (predicted_vals*1e6),
           cumsum_diff_predicted = (cumsum_noCov) - (cumsum_Cov)) %>%
    mutate_at(.vars = c("col5"), ~ifelse(diff_predicted < 10 & diff_predicted > 0,
                                         "<10", 
                                         ifelse(diff_predicted < 100 & diff_predicted > 0,
                                                "<100",
                                                ifelse(diff_predicted > -10 & diff_predicted < 0,
                                                       ">-10",
                                                       ifelse(diff_predicted > -100 & diff_predicted < 0,
                                                              ">-100",
                                                              .)
                                                )))
    ) %>%
    mutate_at(.vars = c("col6"), ~ifelse(cumsum_diff_predicted < 10 & cumsum_diff_predicted > 0,
                                         "<10", 
                                         ifelse(cumsum_diff_predicted < 100 & cumsum_diff_predicted > 0,
                                                "<100",
                                                ifelse(cumsum_diff_predicted > -10 & cumsum_diff_predicted < 0,
                                                       ">-10",
                                                       ifelse(cumsum_diff_predicted > -100 & cumsum_diff_predicted < 0,
                                                              ">-100",
                                                              .)
                                                )))
    ) %>%
    ## only keep the data for 1 month and 2 months post lockdown
    filter(days2 == min(days2) | 
             days3 == min(days3)) 
  
  rate_diff <- tab3_dates %>% 
    mutate(rate_diff = (exp(pred)/denom) - (exp(pred_noCov)/denom),
           chisq_stat = (exp(pred) - (((exp(pred)+exp(pred_noCov))*denom)/(denom+denom)))^2 / (((exp(pred)+exp(pred_noCov))*denom*denom)/(denom^2)),
           lci_rd = rate_diff - 1.96*(sqrt((rate_diff^2)/chisq_stat)),
           uci_rd = rate_diff + 1.96*(sqrt((rate_diff^2)/chisq_stat))
    ) %>% dplyr::select(rate_diff, lci_rd, uci_rd)
  
  
  tab3_fmt <- tab3_dates %>% 
    bind_cols(rate_diff) %>%
    mutate(outcome = outcome_of_interest_namematch$outcome_name[outcome_of_interest_namematch$outcome == outcome]) %>%
    dplyr::select(outcome, monPlot, starts_with("col")) %>%
    pivot_wider(values_from = starts_with("col")) %>%
    mutate_at("monPlot", ~as.character(format.Date(., "%d-%b"))) %>%
    mutate_at("outcome", ~ifelse(row_number(.)==2, "", .))
  return(tab3_fmt) 
}

tab3 <- NULL
for(ii in plot_order){
  tab3 <- bind_rows(tab3,
                    tab3_function(outcomes[ii]))
  tab3[nrow(tab3)+1,] <- ""
}
tab3

write_csv(tab3, here::here("output", "table2.csv"))