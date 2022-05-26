# # # # # # # # # # # # # # # # # # # # #
# This script:
# merge case and control groups & sort variables for analysis
# 
# 
# # # # # # # # # # # # # # # # # # # # #

library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')

setwd(here::here("output"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output")
# extracted dataset after matching
df=read_csv("input_outcome_6w.csv")


######## antibiotics exposure ##########
##antibiotic type
# select ab types columns
col=c("Rx_6w_Amikacin", "Rx_6w_Amoxicillin", "Rx_6w_Ampicillin", "Rx_6w_Azithromycin", "Rx_6w_Aztreonam", "Rx_6w_Benzylpenicillin", "Rx_6w_Cefaclor", "Rx_6w_Cefadroxil", "Rx_6w_Cefalexin", "Rx_6w_Cefamandole", "Rx_6w_Cefazolin", "Rx_6w_Cefepime", "Rx_6w_Cefixime", "Rx_6w_Cefotaxime", "Rx_6w_Cefoxitin", "Rx_6w_Cefpirome", "Rx_6w_Cefpodoxime", "Rx_6w_Cefprozil", "Rx_6w_Cefradine", "Rx_6w_Ceftazidime", "Rx_6w_Ceftriaxone", "Rx_6w_Cefuroxime", "Rx_6w_Chloramphenicol", "Rx_6w_Cilastatin", "Rx_6w_Ciprofloxacin", "Rx_6w_Clarithromycin", "Rx_6w_Clindamycin", "Rx_6w_Co_amoxiclav", "Rx_6w_Co_fluampicil", "Rx_6w_Colistimethate", "Rx_6w_Dalbavancin", "Rx_6w_Dalfopristin", "Rx_6w_Daptomycin", "Rx_6w_Demeclocycline", "Rx_6w_Doripenem", "Rx_6w_Doxycycline", "Rx_6w_Ertapenem", "Rx_6w_Erythromycin", "Rx_6w_Fidaxomicin", "Rx_6w_Flucloxacillin", "Rx_6w_Fosfomycin", "Rx_6w_Fusidate", "Rx_6w_Gentamicin", "Rx_6w_Levofloxacin", "Rx_6w_Linezolid", "Rx_6w_Lymecycline", "Rx_6w_Meropenem", "Rx_6w_Methenamine", "Rx_6w_Metronidazole", "Rx_6w_Minocycline", "Rx_6w_Moxifloxacin", "Rx_6w_Nalidixic_acid", "Rx_6w_Neomycin", "Rx_6w_Netilmicin", "Rx_6w_Nitazoxanid", "Rx_6w_Nitrofurantoin", "Rx_6w_Norfloxacin", "Rx_6w_Ofloxacin", "Rx_6w_Oxytetracycline", "Rx_6w_Phenoxymethylpenicillin", "Rx_6w_Piperacillin", "Rx_6w_Pivmecillinam", "Rx_6w_Pristinamycin", "Rx_6w_Rifaximin", "Rx_6w_Sulfadiazine", "Rx_6w_Sulfamethoxazole", "Rx_6w_Sulfapyridine", "Rx_6w_Taurolidin", "Rx_6w_Tedizolid", "Rx_6w_Teicoplanin", "Rx_6w_Telithromycin", "Rx_6w_Temocillin", "Rx_6w_Tetracycline", "Rx_6w_Ticarcillin", "Rx_6w_Tigecycline", "Rx_6w_Tinidazole", "Rx_6w_Tobramycin", "Rx_6w_Trimethoprim", "Rx_6w_Vancomycin")

df[col]=df[col]%>%mutate_all(~replace(., is.na(.), 0)) # recode NA -> 0
df$total_ab_6w=rowSums(df[col])# total types number -> total ab prescription

df$ab_6w=ifelse(df$total_ab_6w>0,1,0)

df[col]=ifelse(df[col]>0,1,0) # number of matches-> binary flag(1,0)
df$ab_types_6w=rowSums(df[col]>0)# count number of types
df=df[ ! names(df) %in% col]

df$ab_types_6w=ifelse(is.na(df$ab_types_6w),0,df$ab_types_6w) # no ab 

##antibiotic prescribing frequency

df$ab_last_date_6w=as.Date(df$ab_last_date_6w)
df$ab_first_date_6w=as.Date(df$ab_first_date_6w)

# # use AB more than once
# df$interval=as.integer(difftime(df$ab_last_date,df$ab_first_date,unit="day"))
# df$interval=ifelse(df$interval==0,1,df$interval)#less than 1 day (first=last) ~ record to 1

df$lastABtime_6w=as.integer(difftime(df$patient_index_date,df$ab_last_date_6w,unit="day"))
df$lastABtime_6w=ifelse(is.na(df$lastABtime_6w),0,df$lastABtime_6w)

## quintile category
 #quintile<-function(x){
  # ifelse(is.na(x)|x==0,"0",
   #       ifelse(x>quantile(x,.8),"5",
    #             ifelse(x>quantile(x,.6),"4",
     #                   ifelse(x>quantile(x,.4),"3",
      #                         ifelse(x>quantile(x,.2),"2","1")))))}

 
# df$ab_qn=quintile(df$ab_prescriptions)
# df$br_ab_qn=quintile(df$broad_ab_prescriptions)


df2 <- read_rds("matched_outcome.rds")
#df=merge(DF1,DF2,by=c("patient_id","age","sex","stp"),all.x=T) can't merge with dummy data
DF=merge(df,df2,by=c("patient_id","sex","stp","patient_index_date"),all=T)
write_rds(DF, here::here("output", "matched_outcome_6w.rds"))
