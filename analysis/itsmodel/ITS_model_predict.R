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

setwd(here::here("output"))
df <- read_csv("mon_overall_predicted_table.csv")
df$monPlot <- as.Date(df$monPlot)
ad <- 0.5
abline_max <- df$monPlot[max(which(is.na(df$covid)))+1]
abline_min <- df$monPlot[min(which(is.na(df$covid)))-1]

overall_plot <- df %>% filter(outcome_name=="Overall")
overall_plot$probline_noCov <- overall_plot$probline_noCov + ad
overall_plot$predicted_vals <- overall_plot$predicted_vals +ad
overall_plot$lci <- overall_plot$lci +ad
overall_plot$uci <- overall_plot$uci +ad
uti_plot <- df %>% filter(outcome_name=="UTI")
uti_plot$probline_noCov <- uti_plot$probline_noCov + ad
uti_plot$predicted_vals <- uti_plot$predicted_vals +ad
uti_plot$lci <- uti_plot$lci +ad
uti_plot$uci <- uti_plot$uci +ad

plot1 <- ggplot(overall_plot, aes(x = monPlot, y = pc_broad)) +
  # the data
  geom_line(col = "gray60") +
  ### the probability if therer was no Covid
  geom_line(data = overall_plot, aes(y = probline_noCov), col = 2, lty = 2) +
  ### probability with model (inc. std. error)
  geom_line(aes(y = predicted_vals), col = 4, lty = 2) +
  geom_vline(xintercept = c(as.Date(abline_min), 
                            as.Date(abline_max)), col = 1, lwd = 1,linetype="dotdash") + 
  geom_ribbon(aes(ymin = lci, ymax=uci), fill = alpha(4,0.4), lty = 0) +
  theme_bw() +
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  theme(axis.text.x=element_text(angle=60,hjust=1)) +
  labs(x = "", y = "broad-spectrum prescription percentage %") 

plot1

ggsave(
  plot= plot1, width = 8, height = 6, dpi = 640,
  filename="overall_predicted.jpeg", path=here::here("output"),
)    

plot2 <- ggplot(uti_plot, aes(x = monPlot, y = pc_broad)) +
  # the data
  geom_line(col = "gray60") +
  ### the probability if therer was no Covid
  geom_line(data = uti_plot, aes(y = probline_noCov), col = 2, lty = 2) +
  ### probability with model (inc. std. error)
  geom_line(aes(y = predicted_vals), col = 4, lty = 2) +
  geom_vline(xintercept = c(as.Date(abline_min), 
                            as.Date(abline_max)), col = 1, lwd = 1,linetype="dotdash") + 
  geom_ribbon(aes(ymin = lci, ymax=uci), fill = alpha(4,0.4), lty = 0) +
  theme_bw() +
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  theme(axis.text.x=element_text(angle=60,hjust=1)) +
  labs(x = "", y = "broad-spectrum prescription percentage %") 

plot2

ggsave(
  plot= plot2, width = 8, height = 6, dpi = 640,
  filename="UTI_predicted.jpeg", path=here::here("output"),
)    