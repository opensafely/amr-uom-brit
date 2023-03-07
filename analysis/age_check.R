
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

df <- readRDS("output/processed/input_model_c_h.rds")
df$case <- as.factor(df$case)

p1 <- ggplot(df, aes(x=age, fill=case)) +
    geom_histogram( color="#e9ecef", alpha=0.6, position = 'identity') +
    scale_fill_manual(values=c("#69b3a2", "#404080")) 

p2 <- ggplot(data=df, aes(x=age, group=case, fill=case)) +
    geom_density(adjust=1.5, alpha=.4) 

  ggsave(p1,dpi = 400,
       filename="age_check_1.jpeg", path=here::here("output"),
)  

  ggsave(p2,dpi = 400,
       filename="age_check_2.jpeg", path=here::here("output"),
)  