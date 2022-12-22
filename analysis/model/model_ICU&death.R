require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(finalfit)


df <- read_rds(here::here("output","matched_outcome_2.rds"))


## define variables
df$case=as.numeric(df$case) #1/0

df$subclass=as.factor(df$subclass)#pair id

df$level=as.character(df$level) #category

df$CCI= relevel(as.factor(df$CCI), ref="Zero")
df$covrx_ever= relevel(as.factor(df$covrx_ever), ref="0")

df$bmi_cat=relevel(as.factor(df$bmi_cat),ref="Healthy weight")
df$care_home=relevel(as.factor(df$care_home),ref = "0")

df$flu_vaccine=relevel(as.factor(df$flu_vaccine),ref= "0")

df$smoking_cat_3=relevel(as.factor(df$smoking_cat_3),ref="Never")
df$imd=relevel(as.factor(df$imd),ref="1")
df$ethnicity_6=relevel(as.factor(df$ethnicity_6),ref = "White")





#### crude model

model=df%>%
  summary_factorlist("case", c("level"), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level + strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_1_crude_2.csv"))




#### adjusted model
rm(model)
model=df%>%
  summary_factorlist("case", c("level" ,"CCI" ,"covrx_ever", "bmi_cat", "care_home",  "flu_vaccine", "smoking_cat_3", "imd", "ethnicity_6" ), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level + CCI + covrx_ever + bmi_cat + care_home + flu_vaccine + smoking_cat_3 + imd+ ethnicity_6 + strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_1_adjusted_2.csv"))
