require('tidyverse')
require("gtsummary")
require("ggplot2")
library("survival")
library(car)
library(data.table)
library(gridExtra)

# import data
col_spec <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

df1<- read_csv(here::here("output", "matched_combined_191.csv"), col_types = col_spec)
df2<- read_csv(here::here("output", "matched_combined_192.csv"), col_types = col_spec)
df<-bind_rows(df1,df2)


# outcome
df$case=as.numeric(df$case) #1/0
df$set_id=as.factor(df$set_id)#pair id
df$imd= relevel(as.factor(df$imd), ref="5")

mod=clogit(case ~ imd + strata(set_id), df)
sum.mod=summary(mod)
sum.mod
vif(mod)


result=data.frame(sum.mod$conf.int)
DF=result[1:5,-2]
DF
write_csv(DF, here::here("output", "2019_imd_model.csv"))





