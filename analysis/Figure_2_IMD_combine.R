
require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library("forestploter")

# import data
rm(list=ls())
setwd(here::here("output"))
df1 <- read_csv("imd_model.csv")
df1$Model <- "Unadjusted"
df2 <- read_csv("imd_model_covid.csv")
df2$Model <- "Model 1"
df3 <- read_csv("imd_model_cardiometabolic.csv")
df3$Model <- "Model 2"
df4 <- read_csv("adjusted_plotimd.csv")
df4$Model <- "Model 3 (fully adjusted)"

df1$type <-  case_when(
  df1$type == "imd1" ~ "IMD 1(Most deprived)",
  df1$type == "imd2" ~ "IMD 2",
  df1$type == "imd3" ~ "IMD 3",
  df1$type == "imd4" ~ "IMD 4")
df2$type <-  case_when(
  df2$type == "imd1" ~ "IMD 1(Most deprived)",
  df2$type == "imd2" ~ "IMD 2",
  df2$type == "imd3" ~ "IMD 3",
  df2$type == "imd4" ~ "IMD 4")
df3$type <-  case_when(
  df3$type == "imd1" ~ "IMD 1(Most deprived)",
  df3$type == "imd2" ~ "IMD 2",
  df3$type == "imd3" ~ "IMD 3",
  df3$type == "imd4" ~ "IMD 4")

df <- bind_rows(df1,df2,df3,df4)
## IMD = 1
write_csv(df, here::here("output", "Figure_2_IMD_combine.csv"))

df1 <-  df %>% filter(df$type == "IMD 1(Most deprived)")

plot.a1 <- df1 %>% filter(df1$group == "H+C")
plot.a2 <- df1 %>% filter(df1$group == "C")
plot.a3 <- df1 %>% filter(df1$group == "H")

plot.a1$OR2 <- plot.a2$OR
plot.a1$CI_L2 <- plot.a2$CI_L
plot.a1$CI_U2 <- plot.a2$CI_U

plot.a1$OR3 <- plot.a3$OR
plot.a1$CI_L3 <- plot.a3$CI_L
plot.a1$CI_U3 <- plot.a3$CI_U

tm <- forest_theme(base_size = 10,
                   refline_lty = "solid",
                   ci_pch = 15,
                   ci_col = c("#003C67FF", "#EFC000FF","#CD534CFF"),
                   legend_name = "Outcome",
                   legend_value = c("Community + Hospital","Community","Hospital"),
                   footnote_col = "blue",
                   vertline_lty = c("dashed", "dotted"),
                   vertline_col = c("#d6604d", "#bababa"))

plot.a1 <- plot.a1[-c(1:2),]

plot.a1<- plot.a1 %>% add_row(type = "IMD 1(Most deprived)", .before = 1,)

plot.a1$type <- ifelse(is.na(plot.a1$OR), 
                      plot.a1$type,
                      paste0("   ", plot.a1$type))

dt <-plot.a1
# Add blank column for the forest plot to display CI.
# Adjust the column width with space. 
dt$` ` <- paste(rep(" ", 20), collapse = " ")

# Create confidence interval column to display
dt$`OR (95% CI)` <- ifelse(is.na(dt$OR), "",
                           sprintf("%.2f (%.2f to %.2f)",
                                   dt$OR, dt$CI_L, dt$CI_U))

dt$`OR2 (95% CI)` <- ifelse(is.na(dt$OR2), "",
                           sprintf("%.2f (%.2f to %.2f)",
                                   dt$OR2, dt$CI_L2, dt$CI_U2))

dt$`OR3 (95% CI)` <- ifelse(is.na(dt$OR3), "",
                           sprintf("%.2f (%.2f to %.2f)",
                                   dt$OR3, dt$CI_L3, dt$CI_U3))


p <- forest(dt[,c(1,12:15)],  
            est = list(dt$OR,
                       dt$OR2,
                       dt$OR3),
            lower =list(dt$CI_L, 
                        dt$CI_L2,
                        dt$CI_L3),
            upper =list(dt$CI_U,
                        dt$CI_U2,
                        dt$CI_U3),
            ci_column = 2,
            ref_line = 1,
            nudge_y = 0.2,
            theme = tm)

Figure <- plot(p)

ggsave(Figure, width = 12, height = 4,dpi = 700,
       filename="Figure_2_IMD_combine_1.jpeg", path=here::here("output"),
)  

