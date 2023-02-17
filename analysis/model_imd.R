

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
df$imd= relevel(as.factor(df$imd), ref="5")
### fit crude model by variables

mod=clogit(case ~ imd + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfch <- DF

df <- readRDS("output/processed/input_model_c.rds")
df$imd= relevel(as.factor(df$imd), ref="5")
### fit crude model by variables

mod=clogit(case ~ imd + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfc <- DF

df <- readRDS("output/processed/input_model_h.rds")
df$imd= relevel(as.factor(df$imd), ref="5")
### fit crude model by variables

mod=clogit(case ~ imd + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfh <- DF

dfch$group <- "H+C"
dfc$group <- "C"
dfh$group <- "H"

plot <- bind_rows(dfch,dfc,dfh)

write_csv(plot, here::here("output", "imd_model.csv"))