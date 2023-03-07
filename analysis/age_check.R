
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")


p <- ggplot(df, aes(x=age, color=case)) +
    geom_histogram( color="#e9ecef", alpha=0.6, position = 'identity') +
    scale_fill_manual(values=c("#69b3a2", "#404080")) 

  ggsave(p,dpi = 400,
       filename="age_check.jpeg", path=here::here("output"),
)  