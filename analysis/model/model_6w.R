require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(finalfit)


df <- read_rds(here::here("output","matched_outcome_6w.rds"))


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


df$lastABtime=as.numeric(df$lastABtime)

df$total_ab_6w=ifelse(is.na(df$total_ab_6w),0,df$total_ab_6w)
df$total_ab_6w=as.numeric(df$total_ab_6w)

df$ab_6w=ifelse(is.na(df$ab_6w),0,df$ab_6w)
df$ab_6w=as.factor(df$ab_6w)

df$ab_types_6w=ifelse(is.na(df$ab_types_6w),0,df$ab_types_6w)
df$ab_types_6w=as.numeric(df$ab_types_6w)

df$lastABtime_6w=as.numeric(df$lastABtime_6w)




#### adjusted model

## ab_6w
model=df%>%
  summary_factorlist("case", c("level","ab_6w"), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level +ab_6w+strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_6w_binary_adj1.csv"))

rm(model)
## ab_6w
model=df%>%
  summary_factorlist("case", c("level","total_ab_6w"), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level + total_ab_6w + strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_6w_total_adj1.csv"))



rm(model)
## ab_types
model=df%>%
  summary_factorlist("case", c("level","ab_types_6w"), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level + ab_types_6w + strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_6w_types_adj1.csv"))





#### full adjusted model

# ab_6w
rm(model)
model=df%>%
  summary_factorlist("case", c("level" ,"ab_6w","CCI" ,"covrx_ever", "bmi_cat", "care_home",  "flu_vaccine", "smoking_cat_3", "imd", "ethnicity_6" ), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level+ ab_6w +CCI + covrx_ever + bmi_cat + care_home + flu_vaccine + smoking_cat_3 + imd+ ethnicity_6 + strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_6w_binary_adj2.csv"))



# total ab_6w
rm(model)
model=df%>%
  summary_factorlist("case", c("level" ,"total_ab_6w","CCI" ,"covrx_ever", "bmi_cat", "care_home",  "flu_vaccine", "smoking_cat_3", "imd", "ethnicity_6" ), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level+ total_ab_6w + CCI + covrx_ever + bmi_cat + care_home + flu_vaccine + smoking_cat_3 + imd+ ethnicity_6 + strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_6w_total_adj2.csv"))



# ab_types
rm(model)
model=df%>%
  summary_factorlist("case", c("level" ,"ab_types_6w","CCI" ,"covrx_ever", "bmi_cat", "care_home",  "flu_vaccine", "smoking_cat_3", "imd", "ethnicity_6" ), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level+ ab_types_6w + CCI + covrx_ever + bmi_cat + care_home + flu_vaccine + smoking_cat_3 + imd+ ethnicity_6 + strata(subclass),df) %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_6w_types_adj2.csv"))