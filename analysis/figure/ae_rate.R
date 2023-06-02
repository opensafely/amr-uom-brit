
library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")

rm(list=ls())
setwd(here::here("output", "measures"))

col_spec1 <-cols_only( admitted = col_number(),
                       population = col_number(),
                       date = col_date(format = "")
)
## ae
col_spec2 <-cols_only( ae_admitted = col_number(),
                       antibiotic_treatment = col_number(),
                       population = col_number(),
                       date = col_date(format = "")
)

## infection
col_spec3 <-cols_only( uti_record = col_number(),
                       antibiotic_treatment = col_number(),
                       ae_admitted = col_number(),
                       date = col_date(format = "")
)
col_spec4 <-cols_only( lrti_record = col_number(),
                       antibiotic_treatment = col_number(),
                       ae_admitted = col_number(),
                       date = col_date(format = "")
)
col_spec5 <-cols_only( urti_record = col_number(),
                       antibiotic_treatment = col_number(),
                       ae_admitted = col_number(),
                       date = col_date(format = "")
)
col_spec6 <-cols_only( sinusitis_record = col_number(),
                       antibiotic_treatment = col_number(),
                       ae_admitted = col_number(),
                       date = col_date(format = "")
)
col_spec7 <-cols_only( ot_externa_record = col_number(),
                       antibiotic_treatment = col_number(),
                       ae_admitted = col_number(),
                       date = col_date(format = "")
)
col_spec8 <-cols_only( ot_media_record = col_number(),
                       antibiotic_treatment = col_number(),
                       ae_admitted = col_number(),
                       date = col_date(format = "")
)
col_spec9 <-cols_only( pneumonia_record = col_number(),
                       antibiotic_treatment = col_number(),
                       ae_admitted = col_number(),
                       date = col_date(format = "")
)

lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")

df1 <- read_csv("measure_admission_overall.csv",
                col_types = col_spec1)
df2 <- read_csv("measure_ae_admission.csv",
                col_types = col_spec2)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)
## select and filter infection patient
df3 <- read_csv("measure_uti_ae_admission.csv",
                col_types = col_spec3)%>%filter(uti_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)
# Rename 'ae_admitted' column for each dataset
df3 <- read_csv("measure_uti_ae_admission.csv", col_types = col_spec3) %>%filter(uti_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)%>%
  rename(uti_ae = ae_admitted)

df4 <- read_csv("measure_lrti_ae_admission.csv", col_types = col_spec4) %>%filter(lrti_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)%>%
  rename(lrti_ae = ae_admitted)

df5 <- read_csv("measure_urti_ae_admission.csv", col_types = col_spec5) %>%filter(urti_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)%>%
  rename(urti_ae = ae_admitted)

df6 <- read_csv("measure_sinusitis_ae_admission.csv", col_types = col_spec6) %>%filter(sinusitis_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)%>%
  rename(sinusitis_ae = ae_admitted)

df7 <- read_csv("measure_ot_externa_ae_admission.csv", col_types = col_spec7) %>%filter(ot_externa_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)%>%
  rename(ot_externa_ae = ae_admitted)

df8 <- read_csv("measure_ot_media_ae_admission.csv", col_types = col_spec8) %>%filter(ot_media_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)%>%
  rename(ot_media_ae = ae_admitted)

df9 <- read_csv("measure_pneumonia_ae_admission.csv", col_types = col_spec9) %>%filter(pneumonia_record==1)%>%filter(antibiotic_treatment==1)%>%select(ae_admitted,date)%>%
  rename(pneumonia_ae = ae_admitted)

df <- merge(df1,df2,by="date")
df <- merge(df,df3,by="date")
df <- merge(df,df4,by="date")
df <- merge(df,df5,by="date")
df <- merge(df,df6,by="date")
df <- merge(df,df7,by="date")
df <- merge(df,df8,by="date")
df <- merge(df,df9,by="date")

df$admitted <- plyr::round_any(df$admitted, 5)
df$ae_admitted <- plyr::round_any(df$ae_admitted, 5)
df$uti_ae <- plyr::round_any(df$uti_ae, 5)
df$lrti_ae <- plyr::round_any(df$lrti_ae, 5)
df$urti_ae <- plyr::round_any(df$urti_ae, 5)
df$sinusitis_ae <- plyr::round_any(df$sinusitis_ae, 5)
df$ot_externa_ae <- plyr::round_any(df$ot_externa_ae, 5)
df$ot_media_ae <- plyr::round_any(df$ot_media_ae, 5)
df$pneumonia_ae <- plyr::round_any(df$pneumonia_ae, 5)
df$population <- plyr::round_any(df$population, 5)

# Calculate rate per 10000 person
df$admitted_rate <- round((df$admitted*10000/df$population), 3)
df$ae_admitted_rate <- round((df$ae_admitted*10000/df$population), 3)
df$uti_ae_rate <- round((df$uti_ae*10000/df$population), 3)
df$lrti_ae_rate <- round((df$lrti_ae*10000/df$population), 3)
df$urti_ae_rate <- round((df$urti_ae*10000/df$population), 3)
df$sinusitis_ae_rate <- round((df$sinusitis_ae*10000/df$population), 3)
df$ot_externa_ae_rate <- round((df$ot_externa_ae*10000/df$population), 3)
df$ot_media_ae_rate <- round((df$ot_media_ae*10000/df$population), 3)
df$pneumonia_ae_rate <- round((df$pneumonia_ae*10000/df$population), 3)

write_csv(df, here::here("output", "ae_rate_table.csv"))

df <- df %>% select(date,uti_ae_rate,lrti_ae_rate,urti_ae_rate,
                    sinusitis_ae_rate,ot_externa_ae_rate,ot_media_ae_rate,pneumonia_ae_rate) %>%pivot_longer(
    cols = c(uti_ae_rate,lrti_ae_rate,urti_ae_rate,
             sinusitis_ae_rate,ot_externa_ae_rate,ot_media_ae_rate,pneumonia_ae_rate),
    names_to = "InfectionType",
    values_to = "Value"
  )%>%mutate(InfectionType = recode(InfectionType, 
                                 uti_ae_rate = "UTI", 
                                 lrti_ae_rate = "LRTI", 
                                 urti_ae_rate = "URTI",
                                 sinusitis_ae_rate = "Sinusitis",
                                 ot_externa_ae_rate = "Otitis externa",
                                 ot_media_ae_rate = "Otitis media",
                                 pneumonia_ae_rate = "Pneumonia"
                                ))


write_csv(df, here::here("output", "ae_rate_forplot.csv"))


p<-ggplot(df, aes(x = date, y = Value)) +
  geom_rect(aes(xmin = lockdown_1_start, xmax = lockdown_1_end, ymin = -Inf, ymax = Inf), fill = 'grey', alpha = 0.5) +
  geom_rect(aes(xmin = lockdown_2_start, xmax = lockdown_2_end, ymin = -Inf, ymax = Inf), fill = 'grey', alpha = 0.5) +
  geom_rect(aes(xmin = lockdown_3_start, xmax = lockdown_3_end, ymin = -Inf, ymax = Inf), fill = 'grey', alpha = 0.5) +
  geom_line(aes(color = InfectionType, linetype = InfectionType)) +
  labs(x = "Date", y = "Monthly admission rates per 10000 person", color = "", linetype = "", shape = "") +
  theme_bw() +
  theme(legend.position = "bottom", text = element_text(background = "white"))  + 
  scale_color_nejm()

ggsave(p, width = 10, height = 6, dpi = 640,
       filename="figure_ae_rate.jpeg", path=here::here("output"),
)  