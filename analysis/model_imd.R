

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

mod=clogit(case ~ covid*imd + imd + strata(set_id), df)

sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfch_2 <- DF


## Cardiometabolic comorbidities

mod=clogit(case ~ imd + hypertension + chronic_cardiac_disease + diabetes_controlled + stroke + ckd_rrt + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfch_3 <- DF

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

mod=clogit(case ~ covid*imd + imd + strata(set_id), df)

sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfc_2 <- DF

mod=clogit(case ~ imd + hypertension + chronic_cardiac_disease + diabetes_controlled + stroke + ckd_rrt + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfc_3 <- DF

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

mod=clogit(case ~ covid*imd + imd + strata(set_id), df)

sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfh_2 <- DF

mod=clogit(case ~ imd + hypertension + chronic_cardiac_disease + diabetes_controlled + stroke + ckd_rrt + strata(set_id), df)
sum.mod=summary(mod)
result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

dfh_3 <- DF

dfch$group <- "H+C"
dfc$group <- "C"
dfh$group <- "H"

plot <- bind_rows(dfch,dfc,dfh)

write_csv(plot, here::here("output", "imd_model.csv"))

dfch_2$group <- "H+C"
dfc_2$group <- "C"
dfh_2$group <- "H"

plot <- bind_rows(dfch_2,dfc_2,dfh_2)

write_csv(plot, here::here("output", "imd_model_covid.csv"))

dfch_3$group <- "H+C"
dfc_3$group <- "C"
dfh_3$group <- "H"

plot <- bind_rows(dfch_3,dfc_3,dfh_3)

write_csv(plot, here::here("output", "imd_model_cardiometabolic.csv"))



