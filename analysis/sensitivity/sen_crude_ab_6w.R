

## Import libraries---

require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)


df <- readRDS("output/processed/input_model_c_h.rds")
### fit crude model by variables
df$ab_frequency_6w= relevel(as.factor(df$ab_frequency_6w), ref="0")
mod25=clogit(case ~ ab_frequency_6w + strata(set_id), df)
sum.mod25=summary(mod25)
result=data.frame(sum.mod25$conf.int)

DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

df <- readRDS("output/processed/input_model_c.rds")
### fit crude model by variables
df$ab_frequency_6w= relevel(as.factor(df$ab_frequency_6w), ref="0")
mod25=clogit(case ~ ab_frequency_6w + strata(set_id), df)
sum.mod25=summary(mod25)
result=data.frame(sum.mod25$conf.int)

DF1=result[,-2]
names(DF1)[1]="OR"
names(DF1)[2]="CI_L"
names(DF1)[3]="CI_U"
setDT(DF1, keep.rownames = TRUE)[]
names(DF1)[1]="type"

df <- readRDS("output/processed/input_model_h.rds")
### fit crude model by variables
df$ab_frequency_6w= relevel(as.factor(df$ab_frequency_6w), ref="0")
mod25=clogit(case ~ ab_frequency_6w + strata(set_id), df)
sum.mod25=summary(mod25)
result=data.frame(sum.mod25$conf.int)

DF2=result[,-2]
names(DF2)[1]="OR"
names(DF2)[2]="CI_L"
names(DF2)[3]="CI_U"
setDT(DF2, keep.rownames = TRUE)[]
names(DF2)[1]="type"

dfch <- DF
dfc <- DF1
dfh <- DF2

DF <- dfch
Antibiotic <- DF[1:3,]

Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency_6w1" ~ "Antibiotic count(6 weeks): 1",
  Antibiotic$type == "ab_frequency_6w2-3" ~ "Antibiotic count(6 weeks): 2-3",
  Antibiotic$type == "ab_frequency_6w>3" ~ "Antibiotic count(6 weeks): 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot1 <- Antibiotic


DF <- dfc
Antibiotic <- DF[1:3,]

Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency_6w1" ~ "Antibiotic count(6 weeks): 1",
  Antibiotic$type == "ab_frequency_6w2-3" ~ "Antibiotic count(6 weeks): 2-3",
  Antibiotic$type == "ab_frequency_6w>3" ~ "Antibiotic count(6 weeks): 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot2 <- Antibiotic

DF <- dfh
Antibiotic <- DF[1:3,]

Antibiotic$type = case_when(
  Antibiotic$type == "ab_frequency_6w1" ~ "Antibiotic count(6 weeks): 1",
  Antibiotic$type == "ab_frequency_6w2-3" ~ "Antibiotic count(6 weeks): 2-3",
  Antibiotic$type == "ab_frequency_6w>3" ~ "Antibiotic count(6 weeks): 3+",
  Antibiotic$type == "ab_type_num1" ~ "Antibiotic type: 1",
  Antibiotic$type == "ab_type_num2-3" ~ "Antibiotic type: 2-3",
  Antibiotic$type == "ab_type_num>3" ~ "Antibiotic type: 3+")

plot3 <- Antibiotic

label1 <- as.vector(c("Antibiotic count(6 weeks): 1","Antibiotic count(6 weeks): 2-3","Antibiotic count(6 weeks): 3+"))


plot1$type <- factor(plot1$type, levels = label1)
plot2$type <- factor(plot2$type, levels = label1)
plot3$type <- factor(plot3$type, levels = label1)

plot1$group <- "H+C"
plot2$group <- "C"
plot3$group <- "H"
plot <- bind_rows(plot1,plot2,plot3)
write_csv(plot, here::here("output", "sen_crude_ab_6w_plot.csv"))

