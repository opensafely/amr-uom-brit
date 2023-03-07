
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
  geom_histogram(fill="white", position="dodge")+
  theme(legend.position="top")+scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"))

  ggsave(p,dpi = 400,
       filename="age_check.jpeg", path=here::here("output"),
)  