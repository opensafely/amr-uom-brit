

## Import libraries---

require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)
library(here)


df <- readRDS("output/processed/input_model_h.rds")
### fit crude model by variables

mod1=clogit(case ~ region + strata(set_id), df)
sum.mod1=summary(mod1)
result1=data.frame(sum.mod1$conf.int)

mod2=clogit(case ~ ethnicity + strata(set_id), df)
sum.mod2=summary(mod2)
result2=data.frame(sum.mod2$conf.int)

mod3=clogit(case ~ bmi_adult + strata(set_id), df)
sum.mod3=summary(mod3)
result3=data.frame(sum.mod3$conf.int)

mod4=clogit(case ~ smoking_status + strata(set_id), df)
sum.mod4=summary(mod4)
result4=data.frame(sum.mod4$conf.int)

mod5=clogit(case ~ hypertension + strata(set_id), df)
sum.mod5=summary(mod5)
result5=data.frame(sum.mod5$conf.int)

mod6=clogit(case ~ chronic_respiratory_disease + strata(set_id), df)
sum.mod6=summary(mod6)
result6=data.frame(sum.mod6$conf.int)

mod7=clogit(case ~ asthma + strata(set_id), df)
sum.mod7=summary(mod7)
result7=data.frame(sum.mod7$conf.int)

mod8=clogit(case ~ chronic_cardiac_disease + strata(set_id), df)
sum.mod8=summary(mod8)
result8=data.frame(sum.mod8$conf.int)

mod9=clogit(case ~ diabetes_controlled + strata(set_id), df)
sum.mod9=summary(mod9)
result9=data.frame(sum.mod9$conf.int)

mod10=clogit(case ~ cancer + strata(set_id), df)
sum.mod10=summary(mod10)
result10=data.frame(sum.mod10$conf.int)

mod11=clogit(case ~ haem_cancer + strata(set_id), df)
sum.mod11=summary(mod11)
result11=data.frame(sum.mod11$conf.int)

mod12=clogit(case ~ chronic_liver_disease + strata(set_id), df)
sum.mod12=summary(mod12)
result12=data.frame(sum.mod12$conf.int)

mod13=clogit(case ~ stroke + strata(set_id), df)
sum.mod13=summary(mod13)
result13=data.frame(sum.mod13$conf.int)

mod14=clogit(case ~ dementia + strata(set_id), df)
sum.mod14=summary(mod14)
result14=data.frame(sum.mod14$conf.int)

mod15=clogit(case ~ other_neuro + strata(set_id), df)
sum.mod15=summary(mod15)
result15=data.frame(sum.mod15$conf.int)

mod16=clogit(case ~ organ_kidney_transplant + strata(set_id), df)
sum.mod16=summary(mod16)
result16=data.frame(sum.mod16$conf.int)

mod17=clogit(case ~ asplenia + strata(set_id), df)
sum.mod17=summary(mod17)
result17=data.frame(sum.mod17$conf.int)

mod18=clogit(case ~ ra_sle_psoriasis + strata(set_id), df)
sum.mod18=summary(mod18)
result18=data.frame(sum.mod18$conf.int)

mod19=clogit(case ~ immunosuppression + strata(set_id), df)
sum.mod19=summary(mod19)
result19=data.frame(sum.mod19$conf.int)

mod20=clogit(case ~ learning_disability + strata(set_id), df)
sum.mod20=summary(mod20)
result20=data.frame(sum.mod20$conf.int)

mod21=clogit(case ~ sev_mental_ill + strata(set_id), df)
sum.mod21=summary(mod21)
result21=data.frame(sum.mod21$conf.int)

mod22=clogit(case ~ alcohol_problems + strata(set_id), df)
sum.mod22=summary(mod22)
result22=data.frame(sum.mod22$conf.int)

mod23=clogit(case ~ care_home_type_ba + strata(set_id), df)
sum.mod23=summary(mod23)
result23=data.frame(sum.mod23$conf.int)

mod24=clogit(case ~ ckd_rrt + strata(set_id), df)
sum.mod24=summary(mod24)
result24=data.frame(sum.mod24$conf.int)

mod25=clogit(case ~ ab_frequency + strata(set_id), df)
sum.mod25=summary(mod25)
result25=data.frame(sum.mod25$conf.int)

mod26=clogit(case ~ ab_type_num + strata(set_id), df)
sum.mod26=summary(mod26)
result26=data.frame(sum.mod26$conf.int)

result <- bind_rows(result1,result2,result3,result4,result5,result6,result7,result8,result9,
result10,result11,result12,result13,result14,result15,result16,result17,result18,result19,
result20,result21,result22,result23,result24,result25,result26)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"

write_csv(DF, here::here("output", "crude_model_result_h.csv"))

output_dir <- here("output", "processed")
fs::dir_create(output_dir)
saveRDS(object = DF,
        file = paste0(output_dir, "/input_", "crude_model_h", ".rds"),
        compress = TRUE)