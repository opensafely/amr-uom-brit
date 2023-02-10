
library('tidyverse')
library("ggplot2")
library('dplyr')
library('lubridate')
library("here")

setwd(here::here("output"))
df191=read_csv("input_control_ab_191.csv")
df192=read_csv("input_control_ab_192.csv")
df201=read_csv("input_control_ab_201.csv")
df202=read_csv("input_control_ab_202.csv")
df211=read_csv("input_control_ab_211.csv")
df212=read_csv("input_control_ab_212.csv")
df221=read_csv("input_control_ab_221.csv")
df <- bind_rows(df191,df192,df201,df202,df211,df212,df221)

col=c("Rx_Amikacin", "Rx_Amoxicillin", "Rx_Ampicillin", "Rx_Azithromycin", "Rx_Aztreonam", "Rx_Benzylpenicillin", "Rx_Cefaclor", "Rx_Cefadroxil", "Rx_Cefalexin", "Rx_Cefamandole", "Rx_Cefazolin", "Rx_Cefepime", "Rx_Cefixime", "Rx_Cefotaxime", "Rx_Cefoxitin", "Rx_Cefpirome", "Rx_Cefpodoxime", "Rx_Cefprozil", "Rx_Cefradine", "Rx_Ceftazidime", "Rx_Ceftriaxone", "Rx_Cefuroxime", "Rx_Chloramphenicol", "Rx_Cilastatin", "Rx_Ciprofloxacin", "Rx_Clarithromycin", "Rx_Clindamycin", "Rx_Co_amoxiclav", "Rx_Co_fluampicil", "Rx_Colistimethate", "Rx_Dalbavancin", "Rx_Dalfopristin", "Rx_Daptomycin", "Rx_Demeclocycline", "Rx_Doripenem", "Rx_Doxycycline", "Rx_Ertapenem", "Rx_Erythromycin", "Rx_Fidaxomicin", "Rx_Flucloxacillin", "Rx_Fosfomycin", "Rx_Fusidate", "Rx_Gentamicin", "Rx_Levofloxacin", "Rx_Linezolid", "Rx_Lymecycline", "Rx_Meropenem", "Rx_Methenamine", "Rx_Metronidazole", "Rx_Minocycline", "Rx_Moxifloxacin", "Rx_Nalidixic_acid", "Rx_Neomycin", "Rx_Netilmicin", "Rx_Nitazoxanid", "Rx_Nitrofurantoin", "Rx_Norfloxacin", "Rx_Ofloxacin", "Rx_Oxytetracycline", "Rx_Phenoxymethylpenicillin", "Rx_Piperacillin", "Rx_Pivmecillinam", "Rx_Pristinamycin", "Rx_Rifaximin", "Rx_Sulfadiazine", "Rx_Sulfamethoxazole", "Rx_Sulfapyridine", "Rx_Taurolidin", "Rx_Tedizolid", "Rx_Teicoplanin", "Rx_Telithromycin", "Rx_Temocillin", "Rx_Tetracycline", "Rx_Ticarcillin", "Rx_Tigecycline", "Rx_Tinidazole", "Rx_Tobramycin", "Rx_Trimethoprim", "Rx_Vancomycin")

df[col]=df[col]%>%mutate_all(~replace(., is.na(.), 0)) # recode NA -> 0
df$total_ab_6w=rowSums(df[col])# total types number -> total ab prescription

df$ab_6w=ifelse(df$total_ab_6w>0,1,0)

df[col]=ifelse(df[col]>0,1,0) # number of matches-> binary flag(1,0)
df$ab_types_6w=rowSums(df[col]>0)# count number of types
df=df[ ! names(df) %in% col]

df$ab_types_6w=ifelse(is.na(df$ab_types_6w),0,df$ab_types_6w) # no ab 

  
df$ab_frequency = case_when(
  df$ab_prescriptions == 0 ~ "0",
  df$ab_prescriptions == 1 ~ "1",
  df$ab_prescriptions >1 & df$ab_prescriptions <4 ~ "2-3",
  df$ab_prescriptions > 3 ~ ">3",)

df$ab_type_num = case_when(
  df$ab_types_6w == 0 ~ "0",
  df$ab_types_6w == 1 ~ "1",
  df$ab_types_6w >1 & df$ab_types_6w <4 ~ "2-3",
  df$ab_types_6w > 3 ~ ">3",)

output <- select(df,patient_id,patient_index_date,ab_frequency,ab_type_num)

# Save output ---
output_dir <- here("output", "processed")
fs::dir_create(output_dir)
saveRDS(object = output,
        file = paste0(output_dir, "/input_", "control_ab", ".rds"),
        compress = TRUE)