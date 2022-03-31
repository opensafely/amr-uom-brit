library("tidyverse") 
library('dplyr')
library('lubridate')


df19_ab = read_rds(here::here("output","measures","recorded_ab_type_2019.rds"))
df19_ab=dplyr::bind_rows(df19_ab)

df20_ab = read_rds(here::here("output","measures","recorded_ab_type_2020.rds"))
df20_ab=dplyr::bind_rows(df20_ab)

df21_ab = read_rds(here::here("output","measures","recorded_ab_type_2021.rds"))
df21_ab=dplyr::bind_rows(df21_ab)

df22_ab = read_rds(here::here("output","measures","recorded_ab_type_2022.rds"))
df22_ab=dplyr::bind_rows(df22_ab)


df <- rbind(df19_ab,df20_ab,df21_ab,df22_ab)
rm(df19_ab,df20_ab,df21_ab,df22_ab)

df <- df %>% group_by(date,type) %>% summarise(
  abcount = sum(count, na.rm = TRUE)
)

## openprescribing 
broad_type_op <- c("Co-amoxiclav", "Cefaclor", 
                   "Cefadroxil", "Cefixime", "Cefotaxime", "Ceftriaxone", "Ceftazidime", 
                   "Cefuroxime", "Cefalexin", "Cefradine", "Moxifloxacin", "Ciprofloxacin", 
                   "Nalidixic acid", "Levofloxacin", "Norfloxacin", "Ofloxacin")

overall_type_op <- c("Amoxicillin", "Ampicillin", "Co-amoxiclav", 
                                   "Benzylpenicillin", "Co-fluampicil", "Flucloxacillin", "Temocillin", 
                                   "Phenoxymethylpenicillin", "Piperacillin", "Pivmecillinam", "Ticarcillin", 
                                   "Cefaclor", "Cefadroxil", "Cefixime", "Cefotaxime", "Ceftriaxone", 
                                   "Ceftazidime", "Cefuroxime", "Cefalexin", "Cefradine", "Tetracycline", 
                                   "Minocycline", "Demeclocycline", "Doxycycline", "Lymecycline", 
                                   "Oxytetracycline", "Tigecycline", "Azithromycin", "Clarithromycin", 
                                   "Erythromycin", "Telithromycin", "Trimethoprim", "Sulfadiazine", 
                                   "Sulfamethoxazole", "Sulfapyridine", "Tinidazole", "Metronidazole", 
                                   "Moxifloxacin", "Ciprofloxacin", "Nalidixic acid", "Levofloxacin", 
                                   "Norfloxacin", "Ofloxacin", "Fosfomycin", "Nitrofurantoin", "Methenamine")

df_total_op <- df %>% filter(type %in% overall_type_op )
df_total_op <-  df_total_op %>% group_by(date) %>% summarise(
  ab_total = sum(abcount, na.rm = TRUE)
)

df_broad_op <- df %>% filter(type %in% broad_type_op )

df_broad_op <- df_broad_op %>% group_by(date) %>% summarise(
  b_total = sum(abcount, na.rm = TRUE)
)

plot <- merge(df_broad_op,df_total_op, by = 'date')
last.date=max(plot$date)
plot=plot%>% filter(date!=last.date)
first_mon=format(min(plot$date),"%m-%Y")
last_mon= format(max(plot$date),"%m-%Y")

plot$cal_mon <- month(plot$date)
plot$cal_year <- year(plot$date)
plot$year <- as.factor(plot$cal_year)
plot$mon <- as.factor(plot$cal_mon)
plot <- plot %>% mutate(prop = b_total/ab_total)


p <- ggplot(plot, aes(x=mon, y=prop, group=year)) +
  geom_line(aes(color=year))+
  geom_point(aes(color=year))+
  scale_color_brewer(palette="Paired")+
  theme_minimal()+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.001))+
  labs(
    title = "Proportion of broad-spectrum antibiotics prescribed",
    subtitle = paste(first_mon,"-",last_mon),
    x = "Month",
    y = "broad-spectrum antibiotics prescribing %")
p

ggsave(
  plot= p,
  filename="broad_percentage_op.jpeg", path=here::here("output"),
)
