#### this scirpt transfers the data to a prepared verson for ITS model

###  load library  ###
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
###  import data  ###

all_files <- list.files(here::here("output"), pattern = "mon_")
outcomes <- stringr::str_remove_all(all_files, c("mon_|.csv"))
outcome_of_interest_namematch <- bind_cols("outcome" = c("all","uti"), 
                                           "outcome_name" = (c("Overall","UTI"))
)
bkg_colour <- "gray99"

# load data ---------------------------------------------------------------
for(i in 1:length(outcomes)){
  load_file <- read.csv(here::here("output", paste0("mon_", outcomes[i], ".csv")))
  assign(outcomes[i], load_file)
}

its_function <- function(outcomes_vec = outcomes,
                         display_from = as.Date("2019-01-01")){
  plot_its <- function(outcome){
    df_outcome <- get(outcome)
    df_outcome <- all
    ## model binomial 
    # Change in level + slope:
    ### include interaction with time (centred at end of Lockdown adjustment period)
    ldn_centre <- df_outcome$time[min(which(df_outcome$covid == 1))]
    
    ## fit model, calculate lagged residuals to fit in final model
    binom_model1 <- glm(as.matrix(cbind(numOutcome, numEligible)) ~ covid + I(time-ldn_centre) + I(time-ldn_centre):covid + as.factor(mon) , family=binomial, data = filter(df_outcome, !is.na(covid)))
    ### confidence intervals for the coefficients
    ci.exp(binom_model1)
    binom_lagres <- lag(residuals(binom_model1)) %>% as.numeric()
    res1 <- residuals(binom_model1,type="deviance")
    
    ## manipulate data so output looks cleaner
    model_data <- df_outcome %>% 
      mutate(timeC = time - ldn_centre) %>%
      mutate_at("mon", ~as.factor(.)) 
    

    pred1 <-predict(binom_model1, newdata = model_data, se.fit = TRUE)
    predicted_vals <- pred1$fit
    stbp <- pred1$se.fit
    ## set up data frame to calculate linear predictions with no covid and predict values
    outcome_pred_nointervention <- model_data %>%
      mutate_at("covid", ~(.=0))
    pred_noCovid <- predict(binom_model1, newdata = outcome_pred_nointervention, se.fit = TRUE) 
    pred_noCov <- pred_noCovid$fit
    stbp_noCov <- pred_noCovid$se.fit
    
    ## combine all those predictions and convert from log odds to percentage reporting
    df_se <- bind_cols(stbp = stbp, stbp_noCov = stbp_noCov, 
                       pred = predicted_vals, pred_noCov = pred_noCov) %>%
      mutate(
        #CIs
        upp = pred + (1.96*stbp),
        low = pred - (1.96*stbp),
        upp_noCov = pred_noCov + (1.96*stbp_noCov),
        low0_noCov = pred_noCov - (1.96*stbp_noCov),
        # probline
        predicted_vals = exp(pred)/(1+exp(pred)),
        probline_noCov = exp(pred_noCov)/(1+exp(pred_noCov)),
        #
        uci = exp(upp)/(1+exp(upp)),
        lci = exp(low)/(1+exp(low)),
        #
        uci_noCov = exp(upp_noCov)/(1+exp(upp_noCov)),
        lci_noCov = exp(low0_noCov)/(1+exp(low0_noCov)) 
      )
    
    ## combine data set and predictions
    outcome_plot <- bind_cols(model_data, df_se) %>%
      mutate(var = outcome)
    
 
    ## output
    return(list(df_1 = outcome_plot))
  }

  # the plot ----------------------------------------------------------------
  main_plot_data <- NULL
  forest_plot_data <- NULL
  interaction_tbl_data <- NULL
  for(ii in 1:length(outcomes_vec)){
    main_plot_data <- main_plot_data %>%
      bind_rows(
        plot_its(outcomes_vec[ii])$df_1
      )
  }
  
  
  ## convert proportions into percentage 
  main_plot_data <- main_plot_data %>%
    mutate(pc_broad = (numOutcome/numEligible)*100) %>%
    mutate_at(.vars = c("predicted_vals", "lci", "uci", "probline_noCov", "uci_noCov", "lci_noCov"), 
              ~.*100) %>%
    left_join(outcome_of_interest_namematch, by = c("var" = "outcome"))
  
  ## replace outcome name with the pretty name for printing on results
  main_plot_data$outcome_name <- factor(main_plot_data$outcome_name, levels = outcome_of_interest_namematch$outcome_name)
  
  abline_max <- main_plot_data$monPlot[max(which(is.na(main_plot_data$covid)))+1]
  abline_min <- main_plot_data$monPlot[min(which(is.na(main_plot_data$covid)))-1]
  if(is.na(abline_min) & is.na(abline_max)){
    abline_min <- start_covid
    abline_max <- start_covid
  }
  
  main_plot_data$pc_broad <- round(main_plot_data$pc_broad,digits = 3)
  main_plot_data$numOutcome <- plyr::round_any(main_plot_data$numOutcome, 5)
  main_plot_data$numEligible <- plyr::round_any(main_plot_data$numEligible, 5)


  write_csv(main_plot_data, here::here("output", "predicted_line_table.csv"))
  main_plot_data$monPlot <- as.Date(main_plot_data$monPlot)
  plot1 <- ggplot(main_plot_data, aes(x = monPlot, y = pc_broad, group = outcome_name)) +
    # the data
    geom_line(col = "gray60") +
    ### the probability if therer was no Covid
    geom_line(data = main_plot_data, aes(y = probline_noCov), col = 2, lty = 2) +
    ### probability with model (inc. std. error)
    geom_line(aes(y = predicted_vals), col = 4, lty = 2) +
    geom_ribbon(aes(ymin = lci, ymax=uci), fill = alpha(4,0.4), lty = 0) +
    ### format the plot
    facet_wrap(~outcome_name, scales = "free", ncol = 3) +
    geom_vline(xintercept = c(as.Date(abline_min), 
                              as.Date(abline_max)), col = 1, lwd = 1) + # 2020-04-05 is first week/data After lockdown gap
    labs(x = "", y = "", title = "A") +
    theme_classic() +
    theme(axis.title = element_text(size =16), 
          axis.text.x = element_text(angle = 60, hjust = 1, size = 12),
          legend.position = "top",
          plot.background = element_rect(fill = bkg_colour, colour =  NA),
          panel.background = element_rect(fill = bkg_colour, colour =  NA),
          legend.background = element_rect(fill = bkg_colour, colour = NA),
          legend.text = element_text(size = 12),
          legend.title = element_text(size = 12),
          strip.text = element_text(size = 12, hjust = 0),
          strip.background = element_rect(fill = bkg_colour, colour =  NA),
          panel.grid.major = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_line(size=.2, color=rgb(0,0,0,0.2)) ,
          panel.grid.major.y = element_line(size=.2, color=rgb(0,0,0,0.3)))

  plot1
  ggsave(
    plot= plot1,
    filename="predicted_line.jpeg", path=here::here("output"),
  )    

}    

its_function(outcomes_vec = outcomes,
             display_from <- as.Date("2019-01-01")
)