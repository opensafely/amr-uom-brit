
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

col=c("Rx_6w_Amikacin", "Rx_6w_Amoxicillin", "Rx_6w_Ampicillin", "Rx_6w_Azithromycin", "Rx_6w_Aztreonam", "Rx_6w_Benzylpenicillin", "Rx_6w_Cefaclor", "Rx_6w_Cefadroxil", "Rx_6w_Cefalexin", "Rx_6w_Cefamandole", "Rx_6w_Cefazolin", "Rx_6w_Cefepime", "Rx_6w_Cefixime", "Rx_6w_Cefotaxime", "Rx_6w_Cefoxitin", "Rx_6w_Cefpirome", "Rx_6w_Cefpodoxime", "Rx_6w_Cefprozil", "Rx_6w_Cefradine", "Rx_6w_Ceftazidime", "Rx_6w_Ceftriaxone", "Rx_6w_Cefuroxime", "Rx_6w_Chloramphenicol", "Rx_6w_Cilastatin", "Rx_6w_Ciprofloxacin", "Rx_6w_Clarithromycin", "Rx_6w_Clindamycin", "Rx_6w_Co_amoxiclav", "Rx_6w_Co_fluampicil", "Rx_6w_Colistimethate", "Rx_6w_Dalbavancin", "Rx_6w_Dalfopristin", "Rx_6w_Daptomycin", "Rx_6w_Demeclocycline", "Rx_6w_Doripenem", "Rx_6w_Doxycycline", "Rx_6w_Ertapenem", "Rx_6w_Erythromycin", "Rx_6w_Fidaxomicin", "Rx_6w_Flucloxacillin", "Rx_6w_Fosfomycin", "Rx_6w_Fusidate", "Rx_6w_Gentamicin", "Rx_6w_Levofloxacin", "Rx_6w_Linezolid", "Rx_6w_Lymecycline", "Rx_6w_Meropenem", "Rx_6w_Methenamine", "Rx_6w_Metronidazole", "Rx_6w_Minocycline", "Rx_6w_Moxifloxacin", "Rx_6w_Nalidixic_acid", "Rx_6w_Neomycin", "Rx_6w_Netilmicin", "Rx_6w_Nitazoxanid", "Rx_6w_Nitrofurantoin", "Rx_6w_Norfloxacin", "Rx_6w_Ofloxacin", "Rx_6w_Oxytetracycline", "Rx_6w_Phenoxymethylpenicillin", "Rx_6w_Piperacillin", "Rx_6w_Pivmecillinam", "Rx_6w_Pristinamycin", "Rx_6w_Rifaximin", "Rx_6w_Sulfadiazine", "Rx_6w_Sulfamethoxazole", "Rx_6w_Sulfapyridine", "Rx_6w_Taurolidin", "Rx_6w_Tedizolid", "Rx_6w_Teicoplanin", "Rx_6w_Telithromycin", "Rx_6w_Temocillin", "Rx_6w_Tetracycline", "Rx_6w_Ticarcillin", "Rx_6w_Tigecycline", "Rx_6w_Tinidazole", "Rx_6w_Tobramycin", "Rx_6w_Trimethoprim", "Rx_6w_Vancomycin")

df[col]=df[col]%>%mutate_all(~replace(., is.na(.), 0)) # recode NA -> 0
df$total_ab_6w=rowSums(df[col])# total types number -> total ab prescription

df$ab_6w=ifelse(df$total_ab_6w>0,1,0)

df[col]=ifelse(df[col]>0,1,0) # number of matches-> binary flag(1,0)
df$ab_types_6w=rowSums(df[col]>0)# count number of types
df=df[ ! names(df) %in% col]

df$ab_types_6w=ifelse(is.na(df$ab_types_6w),0,df$ab_types_6w) # no ab 

  
df$ab_frequency = case_when(
  df$ab_prescriptions_6w == 0 ~ "0",
  df$ab_prescriptions_6w == 1 ~ "1",
  df$ab_prescriptions_6w >1 & df$ab_prescriptions_6w <4 ~ "2-3",
  df$ab_prescriptions_6w > 3 ~ ">3",)

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