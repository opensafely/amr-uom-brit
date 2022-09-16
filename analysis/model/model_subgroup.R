require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(finalfit)


df <- read_rds(here::here("output","matched_outcome.rds"))


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


## age grp
df=df%>%mutate(age_group=case_when(case==1 & age<40 ~1,
                                   case==1 & age>=40 & age<60 ~2,
                                   case==1 & age>=60 & age<80 ~3,
                                   case==1 & age>=80 ~4))
df=df%>% group_by(subclass)%>%mutate(age_grp=sum(age_group,na.rm = T))
DF=df
rm(df)



###################### male ################
df=DF%>%filter(sex=="M")

#### ab level summary

DF1=summary(df[df$level==0,]$total_ab)
DF2=summary(df[df$level==1,]$total_ab)
DF3=summary(df[df$level==2,]$total_ab)
DF4=summary(df[df$level==3,]$total_ab)
DF5=summary(df[df$level==4,]$total_ab)
DF6=summary(df[df$level==5,]$total_ab)
DF=data.frame(rbind(DF1,DF2,DF3,DF4,DF5,DF6))
rownames(DF)=c("level0","level1","level2","level3","level4","level5")

write.csv("DF",here::here("output","model_3_male_ab.csv"))
rm(DF)

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


write.csv(model,here::here("output","model_3_male_crude.csv"))




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


write.csv(model,here::here("output","model_3_male_adjusted.csv"))








###################### female ################
df=DF%>%filter(sex=="F")

#### ab level summary

DF1=summary(df[df$level==0,]$total_ab)
DF2=summary(df[df$level==1,]$total_ab)
DF3=summary(df[df$level==2,]$total_ab)
DF4=summary(df[df$level==3,]$total_ab)
DF5=summary(df[df$level==4,]$total_ab)
DF6=summary(df[df$level==5,]$total_ab)
DF=data.frame(rbind(DF1,DF2,DF3,DF4,DF5,DF6))
rownames(DF)=c("level0","level1","level2","level3","level4","level5")

write.csv("DF",here::here("output","model_3_female_ab.csv"))
rm(DF)

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


write.csv(model,here::here("output","model_3_female_crude.csv"))




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


write.csv(model,here::here("output","model_3_female_adjusted.csv"))





###################### age group 1 ################
df=DF%>%filter(age_grp=="1") #18-39

#### ab level summary

DF1=summary(df[df$level==0,]$total_ab)
DF2=summary(df[df$level==1,]$total_ab)
DF3=summary(df[df$level==2,]$total_ab)
DF4=summary(df[df$level==3,]$total_ab)
DF5=summary(df[df$level==4,]$total_ab)
DF6=summary(df[df$level==5,]$total_ab)
DF=data.frame(rbind(DF1,DF2,DF3,DF4,DF5,DF6))
rownames(DF)=c("level0","level1","level2","level3","level4","level5")

write.csv("DF",here::here("output","model_3_age1_ab.csv"))
rm(DF)

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


write.csv(model,here::here("output","model_3_age1_crude.csv"))




#### adjusted model
rm(model)
model=df%>%
  summary_factorlist("case", c("level" ,"CCI" ,"covrx_ever", "bmi_cat", "care_home",  "flu_vaccine", "smoking_cat_3", "imd", "ethnicity_6" ), fit_id = TRUE) %>% 
  ff_merge(
    survival::clogit(case ~ level + CCI + covrx_ever + bmi_cat + care_home + flu_vaccine + smoking_cat_3 + imd+ ethnicity_6 + strata(subclass),df,method="approximate") %>% 
      fit2df(estimate_name = "OR (95% CI; case-control)"),
    last_merge = TRUE
  )%>% select(-c("unit","value"))

# sort columns
model[,c("OR","95%CI","p")]<- str_split_fixed(model[,3], " ",3)
model=model[,-3]

model[,4]=gsub("[(*)]"," ",model[,4])
model[,5]=gsub("[(*)]"," ",model[,5])
model[,4]=gsub(","," ",model[,4])


write.csv(model,here::here("output","model_3_age1_adjusted.csv"))




###################### age group 2 ################
df=DF%>%filter(age_grp=="2") #40-59

#### ab level summary

DF1=summary(df[df$level==0,]$total_ab)
DF2=summary(df[df$level==1,]$total_ab)
DF3=summary(df[df$level==2,]$total_ab)
DF4=summary(df[df$level==3,]$total_ab)
DF5=summary(df[df$level==4,]$total_ab)
DF6=summary(df[df$level==5,]$total_ab)
DF=data.frame(rbind(DF1,DF2,DF3,DF4,DF5,DF6))
rownames(DF)=c("level0","level1","level2","level3","level4","level5")

write.csv("DF",here::here("output","model_3_age2_ab.csv"))
rm(DF)

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


write.csv(model,here::here("output","model_3_age2_crude.csv"))




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


write.csv(model,here::here("output","model_3_age2_adjusted.csv"))






###################### age group 3 ################
df=DF%>%filter(age_grp=="3") #60-79

#### ab level summary

DF1=summary(df[df$level==0,]$total_ab)
DF2=summary(df[df$level==1,]$total_ab)
DF3=summary(df[df$level==2,]$total_ab)
DF4=summary(df[df$level==3,]$total_ab)
DF5=summary(df[df$level==4,]$total_ab)
DF6=summary(df[df$level==5,]$total_ab)
DF=data.frame(rbind(DF1,DF2,DF3,DF4,DF5,DF6))
rownames(DF)=c("level0","level1","level2","level3","level4","level5")

write.csv("DF",here::here("output","model_3_age3_ab.csv"))
rm(DF)

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


write.csv(model,here::here("output","model_3_age3_crude.csv"))




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


write.csv(model,here::here("output","model_3_age3_adjusted.csv"))






###################### age group 4 ################
df=DF%>%filter(age_grp=="4") #80+

#### ab level summary

DF1=summary(df[df$level==0,]$total_ab)
DF2=summary(df[df$level==1,]$total_ab)
DF3=summary(df[df$level==2,]$total_ab)
DF4=summary(df[df$level==3,]$total_ab)
DF5=summary(df[df$level==4,]$total_ab)
DF6=summary(df[df$level==5,]$total_ab)
DF=data.frame(rbind(DF1,DF2,DF3,DF4,DF5,DF6))
rownames(DF)=c("level0","level1","level2","level3","level4","level5")

write.csv("DF",here::here("output","model_4_age3_ab.csv"))
rm(DF)

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


write.csv(model,here::here("output","model_3_age4_crude.csv"))




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


write.csv(model,here::here("output","model_3_age4_adjusted.csv"))