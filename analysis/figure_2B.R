rm(list=ls())
setwd(here::here("output", "measures"))

library("dplyr")
library("tidyverse")
library("lubridate")
library("ggsci")

df.19 <- read_rds("abtype_2019.rds") %>% select(date,type,infection)
df.20 <- read_rds("abtype_2020.rds") %>% select(date,type,infection)
df.21 <- read_rds("abtype_2021.rds") %>% select(date,type,infection)

DF <- bind_rows(df.19,df.20,df.21)
DF$date = as.Date(DF$date)

DF$infection=recode(DF$infection,
                      asthma ="Asthma",
                      cold="Cold",
                      cough="Cough",
                      copd="COPD",
                      pneumonia="Pneumonia",
                      renal="Renal",
                      sepsis="Sepsis",
                      throat="Sore throat",
                      uti = "UTI",
                      lrti = "LRTI",
                      urti = "URTI",
                      sinusits = "Sinusitis",
                      otmedia = "Otitis media",
                      ot_externa = "Otitis externa")
DF$infection[DF$infection == ""] <- NA
DF$indication <- ifelse(is.na(DF$infection),0,1)
DF <- DF %>% filter(!is.na(date))


DF$cal_year <- year(DF$date)
DF$cal_mon <- month(DF$date)
DF$time <- as.numeric(DF$cal_mon+(DF$cal_year-2019)*12)

broadtype <- c("Co-amoxiclav","Cefaclor","Cefadroxil","Cefixime","Cefotaxime","Ceftriaxone",
"Ceftazidime","Cefuroxime","Cefalexin","Cefradine","Ciprofloxacin","Levofloxacin",
"Moxifloxacin","Nalidixic acid","Norfloxacin","Ofloxacin")

       
lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")

### Broad spectrum coded/uncoded ###

df.broad <- DF %>% filter(type %in% broadtype)
df.broad_total <- df.broad %>% group_by(indication,time) %>% summarise(
  numOutcome = n(),
)

df.all <-  DF %>% group_by(indication,time) %>% summarise(
  numEligible = n(),
)
df.model <- merge(df.broad_total,df.all,by=c("indication","time"))
df.model <- df.model %>% mutate(mon = case_when(time>=1 & time<=12 ~ time,
                                                time>=13 & time<=24 ~ time-12,
                                                time>=24 & time<=36 ~ time-24,
                                                time>36 ~ time-36)) %>% 
  mutate(year = case_when(time>=1 & time<=12 ~ 2019,
                          time>=13 & time<=24 ~ 2020,
                          time>=24 & time<=36 ~ 2021,
                          time>36 ~ 2022)) %>% 
  mutate(day = 1) 
df.model$monPlot <- as.Date(with(df.model,paste(year,mon,day,sep="-")),"%Y-%m-%d")
df.model$indication <- recode(df.model$indication,
       "1" = "coded: with same-day infection record", 
       "0"= "uncoded: without same-day infection record")


df.model$numOutcome <- plyr::round_any(df.model$numOutcome, 5)
df.model$numEligible <- plyr::round_any(df.model$numEligible, 5)
df.model$value <- df.model$numOutcome/df.model$numEligible
df.model$value <- round(df.model$value,digits = 3)

### broad-spectrum rate by indication

figure_indication_strata <- ggplot(df.model, aes(x = as.Date("2019-01-01"), y = value, group = factor(indication), col = factor(indication), fill = factor(indication))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = monPlot, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  ylim(0, max(df.model$value)) +
  labs(x = "", y = "rate of broad-sepctrum antibiotic", title = "", colour = "Indication", fill = "Indication") +
  theme_bw() +
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.text.x = element_text(angle = 60, hjust = 1),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.position = "top",
        strip.background = element_rect(fill = "grey", colour =  NA),
        strip.text = element_text(size = 12, hjust = 0)) +
  theme(axis.text.x=element_text(angle=60,hjust=1))+ scale_color_aaas()+ scale_fill_aaas()
figure_indication_strata


ggsave(figure_indication_strata, width = 10, height = 6, dpi = 640,
       filename="figure_2B.jpeg", path=here::here("output"),
)  
write_csv(df.model, here::here("output", "figure_2B_table.csv"))
