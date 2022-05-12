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

all_files <- list.files(here::here("output"), pattern = "mon_incident_")
outcomes <- stringr::str_remove_all(all_files, c("mon_incident_|.csv"))
outcome_of_interest_namematch <- bind_cols("outcome" = outcomes, 
                                           "outcome_name" = (c("Broad spectrum","Repeat prescription"))
)
bkg_colour <- "gray99"

# load data ---------------------------------------------------------------
for(ii in 1:length(outcomes)){
  load_file <- read.csv(here::here("output", paste0("mon_incident_", outcomes[ii], ".csv")))
  assign(outcomes[ii], load_file)
}

its_function <- function(outcomes_vec = outcomes,
                         display_from = as.Date("2019-01-01")){
  plot_its <- function(outcome){
    df_outcome <- get(outcome)
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
    
    ## fit model with lagged residuals 
    binom_model2 <- glm(as.matrix(cbind(numOutcome, numEligible)) ~ covid + timeC + timeC:covid + as.factor(mon)  + binom_lagres, family=binomial, data = filter(model_data, !is.na(covid)))
    ci.exp(binom_model2)
    summary.glm(binom_model2)
    
    ## calculate dispersion adjustment parameter -- https://online.stat.psu.edu/stat504/node/162/
    #Pearson Goodness-of-fit statistic
    pearson_gof <- sum(residuals(binom_model2, type = "pearson")^2)
    df <- binom_model2$df.residual
    deviance_adjustment <- pearson_gof/df
    
    ## some manual manipulation to merge the lagged residuals varaible back with the original data
    missing_data_start <- min(which(is.na(model_data$covid)))
    missing_data_end <- max(which(is.na(model_data$covid)))
    missing_data_restart <- max(which(is.na(model_data$covid)))
    binom_lagres_timing <- bind_cols("time" = model_data$time[!is.na(model_data$covid)],
                                     "binom_lagres" = binom_lagres)
    
    ## set up data frame to calculate linear predictions
    outcome_pred <- model_data %>%
      left_join(binom_lagres_timing, by = "time") %>%
      mutate_at("binom_lagres", ~(. = 0)) 
    
    ## predict values adjusted for overdispersion
    pred1 <- predict(binom_model2, newdata = outcome_pred, se.fit = TRUE, interval="confidence", dispersion = deviance_adjustment)
    predicted_vals <- pred1$fit
    stbp <- pred1$se.fit
    
    ## set up data frame to calculate linear predictions with no covid and predict values
    outcome_pred_nointervention <- outcome_pred %>%
      mutate_at("covid", ~(.=0))
    pred_noCovid <- predict(binom_model2, newdata = outcome_pred_nointervention, se.fit = TRUE, interval="confidence", dispersion = deviance_adjustment) 
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
    outcome_plot <- bind_cols(outcome_pred, df_se) %>%
      mutate(var = outcome)
    
    ## Get ORs for effect of covid
    paramter_estimates <- as.data.frame(ci.exp(binom_model2))
    vals_to_print <- paramter_estimates %>%
      mutate(var = rownames(paramter_estimates)) %>%
      filter(var == "covid") %>%
      mutate(var = outcome)
    
  	## Get ORs for effect of time on outcome after covid happened (time + interaction of time:covid)
		interaction_lincom <- glht(binom_model2, linfct = c("timeC + covid:timeC = 0"))
		summary(interaction_lincom)
			
		out <- confint(interaction_lincom)
		time_grad_postCov <- out$confint[1,] %>% exp() %>% t() %>% as.data.frame() 
		interaction_to_print <- time_grad_postCov %>%
			mutate(var = outcome)
			
		## output
		return(list(df_1 = outcome_plot, vals_to_print = vals_to_print, interaction_to_print = interaction_to_print))
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
    forest_plot_data <- forest_plot_data %>%
      bind_rows(
        plot_its(outcomes_vec[ii])$vals_to_print
      )
		interaction_tbl_data <- interaction_tbl_data %>%
			bind_rows(
				plot_its(outcomes_vec[ii])$interaction_to_print
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
  
  write_csv(main_plot_data, here::here("output", "incident_1_table.csv"))
  main_plot_data$monPlot <- as.Date(main_plot_data$monPlot)
  plot1 <- ggplot(main_plot_data, aes(x = monPlot, y = pc_broad, group = outcome_name)) +
    # the data
    geom_line(col = "gray60") +
    ### the probability if therer was no Covid
    geom_line(data = main_plot_data, aes(y = probline_noCov), col = 2, lty = 2) +
    geom_ribbon(data = main_plot_data, aes(ymin = lci_noCov, ymax=uci_noCov), fill = alpha(2,0.4), lty = 0) +
    ### probability with model (inc. std. error)
    geom_line(aes(y = predicted_vals), col = 4, lty = 2) +
    geom_ribbon(aes(ymin = lci, ymax=uci), fill = alpha(4,0.4), lty = 0) +
    ### format the plot
    facet_wrap(~outcome_name, scales = "free", ncol = 4) +
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
    filename="incident_1.jpeg", path=here::here("output"),
  )    

		# Forest plot of interaction terms ------------------------------------------------------
		## clean up the names
		interaction_tbl_data <- interaction_tbl_data %>%
			rename("Est" = "Estimate", lci = lwr, uci = upr) %>%
			left_join(outcome_of_interest_namematch, by = c("var" = "outcome"))
		
		# changes the names of outcomes to full names
		interaction_tbl_data$outcome_name <- factor(interaction_tbl_data$outcome_name, levels = outcome_of_interest_namematch$outcome_name)
    write_csv(interaction_tbl_data, here::here("output", "incident_plot_B_table.csv"))
  
		# forest plot of estiamtes
		fp2 <- ggplot(data=interaction_tbl_data, aes(x=outcome_name, y=Est, ymin=lci, ymax=uci)) +
			geom_point(size = 2.5, pch = 16, colour = "orange") +
			geom_linerange(lwd = 1.5, colour = "orange") +
			geom_hline(yintercept=1, lty=2) +  # add a dotted line at x=1 after flip
			coord_flip() +  # flip coordinates (puts labels on y axis)
			labs(x = "", y = '95% CI', title = "C") +
			theme_classic() +
			theme(axis.title = element_text(size = 16),
						#axis.text.x = element_text(angle = 45),
						axis.line.y.left = element_blank(),
						axis.line.y.right = element_line(),
						axis.text.y = element_blank(),
						legend.position = "top",
						plot.background = element_rect(fill = bkg_colour, colour =  NA),
						panel.background = element_rect(fill = bkg_colour, colour =  NA),
						legend.background = element_rect(fill = bkg_colour, colour = NA),
						strip.background = element_rect(fill = bkg_colour, colour =  NA),
						panel.grid.major = element_blank(),
						panel.grid.minor.x = element_blank(),
						panel.grid.minor.y = element_line(size=.2, color=rgb(0,0,0,0.2)) ,
						panel.grid.major.y = element_line(size=.2, color=rgb(0,0,0,0.3))) +
			scale_x_discrete(limits = rev(levels(as.factor(interaction_tbl_data$outcome_name))))

  fp2
  ggsave(
    plot= fp2,
    filename="incident_plot_B.jpeg", path=here::here("output"),
  )  


  # Forest plot of ORs ------------------------------------------------------
  ## clean up the names
  forest_plot_df <- forest_plot_data %>%
    rename("Est" = "exp(Est.)", "lci" = "2.5%", "uci" = "97.5%") %>%
    left_join(outcome_of_interest_namematch, by = c("var" = "outcome"))
  
  # changes the names of outcomes to full names
  forest_plot_df$outcome_name <- factor(forest_plot_df$outcome_name, levels = outcome_of_interest_namematch$outcome_name)
  # export table of results for the appendix 
  write_csv(forest_plot_df, here::here("output", "incident_plot_A_table.csv"))
  
  
  forest_plot_df <- forest_plot_df %>%
    mutate(dummy_facet = "A")
  ## Forest plot
  fp <- ggplot(data=forest_plot_df, aes(x=dummy_facet, y=Est, ymin=lci, ymax=uci)) +
    geom_point(size = 2.5, pch = 16, colour = "darkred") +
    geom_linerange(lwd = 1.5, colour = "darkred") +
    geom_hline(yintercept=1, lty=2) +  # add a dotted line at x=1 after flip
    coord_flip() +  # flip coordinates (puts labels on y axis)
    labs(x = "", y = "95% CI", title = "B") +
    facet_wrap(~outcome_name, ncol = 1, dir = "h", strip.position = "right") +
    theme_classic() +
    theme(axis.title = element_text(size = 16),
          axis.text.y = element_blank(),
          axis.line.y.left = element_blank(),
          axis.line.y.right = element_line(),
          axis.ticks.y = element_blank(),
          axis.text.x = element_text(angle = 0),
          legend.position = "top",
          plot.background = element_rect(fill = bkg_colour, colour =  NA),
          panel.background = element_rect(fill = bkg_colour, colour =  NA),
          legend.background = element_rect(fill = bkg_colour, colour = NA),
          strip.background = element_rect(fill = bkg_colour, colour =  NA),
          strip.text.y = element_text(hjust=0.5, vjust = 0, angle=0, size = 10),
          panel.grid.major = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_line(size=.2, color=rgb(0,0,0,0.2)) ,
          panel.grid.major.y = element_line(size=.2, color=rgb(0,0,0,0.3)))
  fp
  ggsave(
    plot= fp,
    filename="incident_plot_A.jpeg", path=here::here("output"),
  )  

		layout = "
			AAAAAA
			AAAAAA
			AAAAAA
			AAAAAA
			BBBCCC
			BBBCCC
		"
  ggsave(
    plot= 		plot1 + fp + fp2 + 
			plot_layout(design = layout) ,
    filename="incident_plot_combined.jpeg", path=here::here("output"),
  ) 

}    

its_function(outcomes_vec = outcomes,
             display_from <- as.Date("2019-01-01")
)
