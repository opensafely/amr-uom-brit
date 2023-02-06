
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
                        sepsis_type = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

col_spec1 <-cols_only(patient_index_date = col_date(format = ""),
                        age = col_number(),
                        sex = col_character(),
                        region = col_character(),
                        imd = col_integer(),
                        set_id = col_number(),
                        case = col_number(),
                        patient_id = col_number()
)

df1.1<- read_csv(here::here("output", "matched_cases_191.csv"), col_types = col_spec)
df2.1<- read_csv(here::here("output", "matched_cases_192.csv"), col_types = col_spec)
df1.2<- read_csv(here::here("output", "matched_cases_201.csv"), col_types = col_spec)
df2.2<- read_csv(here::here("output", "matched_cases_202.csv"), col_types = col_spec)
df1.3<- read_csv(here::here("output", "matched_cases_211.csv"), col_types = col_spec)
df2.3<- read_csv(here::here("output", "matched_cases_212.csv"), col_types = col_spec)
df3.1<- read_csv(here::here("output", "matched_cases_221.csv"), col_types = col_spec)
case<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)

df1.1<- read_csv(here::here("output", "matched_matches_191.csv"), col_types = col_spec1)
df2.1<- read_csv(here::here("output", "matched_matches_192.csv"), col_types = col_spec1)
df1.2<- read_csv(here::here("output", "matched_matches_201.csv"), col_types = col_spec1)
df2.2<- read_csv(here::here("output", "matched_matches_202.csv"), col_types = col_spec1)
df1.3<- read_csv(here::here("output", "matched_matches_211.csv"), col_types = col_spec1)
df2.3<- read_csv(here::here("output", "matched_matches_212.csv"), col_types = col_spec1)
df3.1<- read_csv(here::here("output", "matched_matches_221.csv"), col_types = col_spec1)

control<-bind_rows(df1.1,df2.1,df1.2,df2.2,df1.3,df2.3,df3.1)
control <- control[,-6]
case_date <-select(case,set_id,patient_index_date,sepsis_type)
control <- merge(control,case_date,by = "set_id")
df <- bind_rows(case,control)

control_var <- readRDS("output/processed/input_control_data.rds")
case_var <- readRDS("output/processed/input_case_data.rds")
control_var <-control_var[,-(3:7)]
case_var <-case_var[,-(3:7)]

case <-merge(case,case_var,by=c("patient_id","patient_index_date"))
control <-merge(control,control_var,by=c("patient_id","patient_index_date"))
df <- bind_rows(case,control)


# outcome

df$care_home_type_ba <- df %>% mutate() 
df$care_home_type_ba<-  case_when(
  df$care_home_type == "U" ~ "FALSE",
  df$care_home_type == "NA" ~ "FALSE",
  df$care_home_type == "PC" ~ "TRUE",
  df$care_home_type == "PN" ~ "TRUE",
  df$care_home_type == "PS" ~ "TRUE")

df$case=as.numeric(df$case) #1/0
df$set_id=as.factor(df$set_id)#pair id
df$imd= relevel(as.factor(df$imd), ref="5")
df$smoking_status= relevel(as.factor(df$smoking_status), ref="Never")
df <- df %>% mutate(covid = case_when(patient_index_date < as.Date("2020-03-26") ~ "1",
                                      patient_index_date >=as.Date("2020-03-26")&patient_index_date < as.Date("2021-03-08") ~ "2",
                                      patient_index_date >= as.Date("2021-03-08") ~ "3"))
df$covid=relevel(as.factor(df$covid), ref="1")
df1 <- df %>% filter(sepsis_type=="1")
df2 <- df %>% filter(sepsis_type=="2")




mod=clogit(case ~ region + ethnicity + bmi + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + strata(set_id), df)
sum.mod=summary(mod)
sum.mod



result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"
Region <- DF[1:8,]
Ethnicity <- DF[9:13,]
BMI <- DF[14:16,]
Smoking <- DF[17:19,]
CKD <- DF[43:48,]
CHT <- DF[42,]
Other1 <- DF[c(20:21,24,28:33),]
Asthma <- DF[22:23,]
Diabetes <- DF[25:27,]
Organ<- DF[34:35,]
Other2 <-DF[36:41,]


Region$type <-  case_when(
  Region$type == "regionNorth East" ~ "North East",
  Region$type == "regionNorth West" ~ "North West",
  Region$type == "regionYorkshire and The Humber" ~ "Yorkshire and the Humber",
  Region$type == "regionEast Midlands" ~ "East Midlands",
  Region$type == "regionWest Midlands" ~ "West Midlands",
  Region$type == "regionEast" ~ "East of England",
  Region$type == "regionLondon" ~ "London",
  Region$type == "regionSouth East" ~ "South East",
  Region$type == "regionSouth West" ~ "South West")

Ethnicity$type = case_when(
  Ethnicity$type == "ethnicityMixed" ~ "Mixed",
  Ethnicity$type == "ethnicitySouth Asian" ~ "South Asian",
  Ethnicity$type == "ethnicityBlack" ~ "Black",
  Ethnicity$type == "ethnicityOther" ~ "Other",
  Ethnicity$type == "ethnicityUnknown" ~ "Ethnicity unknown")

BMI$type = case_when(
  BMI$type == "bmiObese I (30-34.9 kg/m2)" ~ "Obese I (30-34.9 kg/m2)",
  BMI$type == "bmiObese II (35-39.9 kg/m2)" ~ "Obese II (35-39.9 kg/m2)",
  BMI$type == "bmiObese III (40+ kg/m2)" ~ "Obese III (40+ kg/m2)")

Smoking$type = case_when(
  Smoking$type == "smoking_statusMissing" ~ "Smoking unknown",
  Smoking$type == "smoking_statusFormer" ~ "Former",
  Smoking$type == "smoking_statusCurrent" ~ "Current")

CKD$type = case_when(
  CKD$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  CKD$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  CKD$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  CKD$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  CKD$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  CKD$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)")

CHT$type = case_when(
  CHT$type == "care_home_type_baTRUE" ~ "Potential Care Home")

Other1$type = case_when(
  Other1$type == "hypertensionTRUE" ~ "Hypertension",
  Other1$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  Other1$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  Other1$type == "cancerTRUE" ~ "Cancer (non haematological)",
  Other1$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  Other1$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  Other1$type == "strokeTRUE" ~ "Stroke",
  Other1$type == "dementiaTRUE" ~ "Dementia",
  Other1$type == "other_neuroTRUE" ~ "Other neurological disease")

Asthma$type = case_when(
  Asthma$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  Asthma$type == "asthmaWith oral steroid use" ~ "With oral steroid use")

Diabetes$type = case_when(
  Diabetes$type == "diabetes_controlledControlled" ~ "Controlled",
  Diabetes$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  Diabetes$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure")

Organ$type = case_when(
  Organ$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  Organ$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant")

Other2$type = case_when(
  Other2$type == "aspleniaTRUE" ~ "Asplenia",
  Other2$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  Other2$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  Other2$type == "learning_disabilityTRUE" ~ "Learning disability",
  Other2$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  Other2$type == "alcohol_problemsTRUE" ~ "Alcohol problems")


plot1 <- bind_rows(Region,Ethnicity,BMI,Smoking,CHT)
plot2 <- bind_rows(CKD,Other1,Asthma,Diabetes,Organ,Other2)



mod=clogit(case ~ region + ethnicity + bmi + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + strata(set_id), df1)
sum.mod=summary(mod)
sum.mod

result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"
Region <- DF[1:8,]
Ethnicity <- DF[9:13,]
BMI <- DF[14:16,]
Smoking <- DF[17:19,]
CKD <- DF[43:48,]
CHT <- DF[42,]
Other1 <- DF[c(20:21,24,28:33),]
Asthma <- DF[22:23,]
Diabetes <- DF[25:27,]
Organ<- DF[34:35,]
Other2 <-DF[36:41,]

Region$type <-  case_when(
  Region$type == "regionNorth East" ~ "North East",
  Region$type == "regionNorth West" ~ "North West",
  Region$type == "regionYorkshire and The Humber" ~ "Yorkshire and the Humber",
  Region$type == "regionEast Midlands" ~ "East Midlands",
  Region$type == "regionWest Midlands" ~ "West Midlands",
  Region$type == "regionEast" ~ "East of England",
  Region$type == "regionLondon" ~ "London",
  Region$type == "regionSouth East" ~ "South East",
  Region$type == "regionSouth West" ~ "South West")

Ethnicity$type = case_when(
  Ethnicity$type == "ethnicityMixed" ~ "Mixed",
  Ethnicity$type == "ethnicitySouth Asian" ~ "South Asian",
  Ethnicity$type == "ethnicityBlack" ~ "Black",
  Ethnicity$type == "ethnicityOther" ~ "Other",
  Ethnicity$type == "ethnicityUnknown" ~ "Ethnicity unknown")

BMI$type = case_when(
  BMI$type == "bmiObese I (30-34.9 kg/m2)" ~ "Obese I (30-34.9 kg/m2)",
  BMI$type == "bmiObese II (35-39.9 kg/m2)" ~ "Obese II (35-39.9 kg/m2)",
  BMI$type == "bmiObese III (40+ kg/m2)" ~ "Obese III (40+ kg/m2)")

Smoking$type = case_when(
  Smoking$type == "smoking_statusMissing" ~ "Smoking unknown",
  Smoking$type == "smoking_statusFormer" ~ "Former",
  Smoking$type == "smoking_statusCurrent" ~ "Current")

CKD$type = case_when(
  CKD$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  CKD$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  CKD$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  CKD$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  CKD$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  CKD$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)")

CHT$type = case_when(
  CHT$type == "care_home_type_baTRUE" ~ "Potential Care Home")

Other1$type = case_when(
  Other1$type == "hypertensionTRUE" ~ "Hypertension",
  Other1$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  Other1$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  Other1$type == "cancerTRUE" ~ "Cancer (non haematological)",
  Other1$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  Other1$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  Other1$type == "strokeTRUE" ~ "Stroke",
  Other1$type == "dementiaTRUE" ~ "Dementia",
  Other1$type == "other_neuroTRUE" ~ "Other neurological disease")

Asthma$type = case_when(
  Asthma$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  Asthma$type == "asthmaWith oral steroid use" ~ "With oral steroid use")

Diabetes$type = case_when(
  Diabetes$type == "diabetes_controlledControlled" ~ "Controlled",
  Diabetes$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  Diabetes$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure")

Organ$type = case_when(
  Organ$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  Organ$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant")

Other2$type = case_when(
  Other2$type == "aspleniaTRUE" ~ "Asplenia",
  Other2$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  Other2$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  Other2$type == "learning_disabilityTRUE" ~ "Learning disability",
  Other2$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  Other2$type == "alcohol_problemsTRUE" ~ "Alcohol problems")

plot1.1 <- bind_rows(Region,Ethnicity,BMI,Smoking,CHT)
plot2.1 <- bind_rows(CKD,Other1,Asthma,Diabetes,Organ,Other2)


mod=clogit(case ~ region + ethnicity + bmi + smoking_status + hypertension + chronic_respiratory_disease +
             asthma + chronic_cardiac_disease + diabetes_controlled + cancer + haem_cancer + chronic_liver_disease +
             stroke + dementia + other_neuro + organ_kidney_transplant + asplenia + ra_sle_psoriasis + immunosuppression +
             learning_disability + sev_mental_ill + alcohol_problems + care_home_type_ba + ckd_rrt + strata(set_id), df2)
sum.mod=summary(mod)
sum.mod


result=data.frame(sum.mod$conf.int)
DF=result[,-2]
names(DF)[1]="OR"
names(DF)[2]="CI_L"
names(DF)[3]="CI_U"
setDT(DF, keep.rownames = TRUE)[]
names(DF)[1]="type"
Region <- DF[1:8,]
Ethnicity <- DF[9:13,]
BMI <- DF[14:16,]
Smoking <- DF[17:19,]
CKD <- DF[43:48,]
CHT <- DF[42,]
Other1 <- DF[c(20:21,24,28:33),]
Asthma <- DF[22:23,]
Diabetes <- DF[25:27,]
Organ<- DF[34:35,]
Other2 <-DF[36:41,]

Region$type <-  case_when(
  Region$type == "regionNorth East" ~ "North East",
  Region$type == "regionNorth West" ~ "North West",
  Region$type == "regionYorkshire and The Humber" ~ "Yorkshire and the Humber",
  Region$type == "regionEast Midlands" ~ "East Midlands",
  Region$type == "regionWest Midlands" ~ "West Midlands",
  Region$type == "regionEast" ~ "East of England",
  Region$type == "regionLondon" ~ "London",
  Region$type == "regionSouth East" ~ "South East",
  Region$type == "regionSouth West" ~ "South West")

Ethnicity$type = case_when(
  Ethnicity$type == "ethnicityMixed" ~ "Mixed",
  Ethnicity$type == "ethnicitySouth Asian" ~ "South Asian",
  Ethnicity$type == "ethnicityBlack" ~ "Black",
  Ethnicity$type == "ethnicityOther" ~ "Other",
  Ethnicity$type == "ethnicityUnknown" ~ "Ethnicity unknown")

BMI$type = case_when(
  BMI$type == "bmiObese I (30-34.9 kg/m2)" ~ "Obese I (30-34.9 kg/m2)",
  BMI$type == "bmiObese II (35-39.9 kg/m2)" ~ "Obese II (35-39.9 kg/m2)",
  BMI$type == "bmiObese III (40+ kg/m2)" ~ "Obese III (40+ kg/m2)")

Smoking$type = case_when(
  Smoking$type == "smoking_statusMissing" ~ "Smoking unknown",
  Smoking$type == "smoking_statusFormer" ~ "Former",
  Smoking$type == "smoking_statusCurrent" ~ "Current")

CKD$type = case_when(
  CKD$type == "ckd_rrtCKD stage 3a" ~ "CKD stage 3a",
  CKD$type == "ckd_rrtCKD stage 3b" ~ "CKD stage 3b",
  CKD$type == "ckd_rrtCKD stage 4" ~ "CKD stage 4",
  CKD$type == "ckd_rrtCKD stage 5" ~ "CKD stage 5",
  CKD$type == "ckd_rrtRRT (dialysis)" ~ "RRT (dialysis)",
  CKD$type == "ckd_rrtRRT (transplant)" ~ "RRT (transplant)")

CHT$type = case_when(
  CHT$type == "care_home_type_baTRUE" ~ "Potential Care Home")

Other1$type = case_when(
  Other1$type == "hypertensionTRUE" ~ "Hypertension",
  Other1$type == "chronic_respiratory_diseaseTRUE" ~ "Chronic respiratory disease",
  Other1$type == "chronic_cardiac_diseaseTRUE" ~ "Chronic cardiac disease",
  Other1$type == "cancerTRUE" ~ "Cancer (non haematological)",
  Other1$type == "haem_cancerTRUE" ~ "Haematological malignancy",
  Other1$type == "chronic_liver_diseaseTRUE" ~ "Chronic liver disease",
  Other1$type == "strokeTRUE" ~ "Stroke",
  Other1$type == "dementiaTRUE" ~ "Dementia",
  Other1$type == "other_neuroTRUE" ~ "Other neurological disease")

Asthma$type = case_when(
  Asthma$type == "asthmaWith no oral steroid use" ~ "With no oral steroid use",
  Asthma$type == "asthmaWith oral steroid use" ~ "With oral steroid use")

Diabetes$type = case_when(
  Diabetes$type == "diabetes_controlledControlled" ~ "Controlled",
  Diabetes$type == "diabetes_controlledNot controlled" ~ "Not controlled",
  Diabetes$type == "diabetes_controlledWithout recent Hb1ac measure" ~ "Without recent Hb1ac measure")

Organ$type = case_when(
  Organ$type == "organ_kidney_transplantKidney transplant" ~ "Kidney transplant",
  Organ$type == "organ_kidney_transplantOther organ transplant" ~ "Other organ transplant")

Other2$type = case_when(
  Other2$type == "aspleniaTRUE" ~ "Asplenia",
  Other2$type == "ra_sle_psoriasisTRUE" ~ "Rheumatoid arthritis/ lupus/ psoriasis",
  Other2$type == "immunosuppressionTRUE" ~ "Immunosuppressive condition",
  Other2$type == "learning_disabilityTRUE" ~ "Learning disability",
  Other2$type == "sev_mental_illTRUE" ~ "Severe mental illness",
  Other2$type == "alcohol_problemsTRUE" ~ "Alcohol problems")

plot1.2 <- bind_rows(Region,Ethnicity,BMI,Smoking,CHT)
plot2.2 <- bind_rows(CKD,Other1,Asthma,Diabetes,Organ,Other2)

label1 <- as.vector(plot1$type)
label2 <- as.vector(plot2$type)
plot1$type <- factor(plot1$type, levels = label1)
plot2$type <- factor(plot2$type, levels = label2)
plot1.1$type <- factor(plot1.1$type, levels = label1)
plot2.1$type <- factor(plot2.1$type, levels = label2)
plot1.2$type <- factor(plot1.2$type, levels = label1)
plot2.2$type <- factor(plot2.2$type, levels = label2)

plot1$group <- "H+C"
plot2$group <- "H+C"
plot1.1$group <- "C"
plot2.1$group <- "C"
plot1.2$group <- "H"
plot2.2$group <- "H"
plota <- bind_rows(plot1,plot1.1,plot1.2)
plotb <- bind_rows(plot2,plot2.1,plot2.2)

write_csv(plota, here::here("output", "plota.csv"))
write_csv(plotb, here::here("output", "plotb.csv"))

p1 <- ggplot(data=plotb, aes(y=type, x=OR, xmin=CI_L, xmax=CI_U,col=group,fill=group)) +
  geom_point() + 
  geom_errorbarh(height=.1) +
  geom_vline(xintercept=1, color='black', linetype='dashed', alpha=.5) +
  theme_minimal()

p2 <- ggplot(data=plotb, aes(y=type, x=OR, xmin=CI_L, xmax=CI_U,col=group,fill=group)) +
  geom_point() + 
  geom_errorbarh(height=.1) +
  geom_vline(xintercept=1, color='black', linetype='dashed', alpha=.5) +
  theme_minimal()

ggsave(p1, width = 6, height = 12, dpi = 640,
       filename="plota.jpeg", path=here::here("output"),
)  

ggsave(p2, width = 6, height = 12, dpi = 640,
       filename="plotb.jpeg", path=here::here("output"),
)  