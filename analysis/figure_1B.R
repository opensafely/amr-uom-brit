library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")

rm(list=ls())
setwd(here::here("output", "measures"))

col_spec1 <-cols_only( Positive_test_event = col_number(),
                       population = col_number(),
                      date = col_date(format = "")
)

col_spec2 <-cols_only( age_cat = col_character(),
                       sex = col_character(),
                       antibiotic_count = col_number(),
                       date = col_date(format = "")
)

lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")




df1 <- read_csv("measure_allpopulation_covid-case.csv",
               col_types = col_spec1)
df2 <- read_csv("measure_antibiotic_items_STAR-PU.csv",
                col_types = col_spec2)

measurestar <- df2 %>% group_by(date) %>%
  mutate(adabcount= case_when(age_cat=="0-4" ~ antibiotic_count*0.8,
                            age_cat =="5-14"& sex=="M"~antibiotic_count*0.3,
                            age_cat =="5-14"& sex=="F"~antibiotic_count*0.4,
                            age_cat =="15-24"& sex=="M"~antibiotic_count*0.3,
                            age_cat =="15-24"& sex=="F"~antibiotic_count*0.6,
                            age_cat =="25-34"& sex=="M"~antibiotic_count*0.2,
                            age_cat =="25-34"& sex=="F"~antibiotic_count*0.6,
                            age_cat =="35-44"& sex=="M"~antibiotic_count*0.3,
                            age_cat =="35-44"& sex=="F"~antibiotic_count*0.6,
                            age_cat =="45-54"& sex=="M"~antibiotic_count*0.3,
                            age_cat =="45-54"& sex=="F"~antibiotic_count*0.6,
                            age_cat =="55-64"& sex=="M"~antibiotic_count*0.4,
                            age_cat =="55-64"& sex=="F"~antibiotic_count*0.7,
                            age_cat =="65-74"& sex=="M"~antibiotic_count*0.7,
                            age_cat =="65-74"& sex=="F"~antibiotic_count*1.0,
                            age_cat =="75+"& sex=="M"~antibiotic_count*1.0,
                            age_cat =="75+"& sex=="F"~antibiotic_count*1.3))

measurstarpu=measurestar%>%
  group_by(date)%>%
  summarise(starpu_month=sum(adabcount,na.rm=TRUE))

df <- merge(measurstarpu,df1,by="date")
df$starpurate <- df$starpu_month*1000/df$population

train_sec <- function(primary, secondary, na.rm = TRUE) {
  # Thanks Henry Holm for including the na.rm argument!
  from <- range(secondary, na.rm = na.rm)
  to   <- range(primary, na.rm = na.rm)
  # Forward transform for the data
  forward <- function(x) {
    rescale(x, from = from, to = to)
  }
  # Reverse transform for the secondary axis
  reverse <- function(x) {
    rescale(x, from = to, to = from)
  }
  list(fwd = forward, rev = reverse)
}

sec <- with(df, train_sec(c(0, max(starpurate)),
                          c(0, max(Positive_test_event/1000))))



p <- ggplot(df, aes(x=date, y=sec$fwd(Positive_test_event/1000))) +
  geom_rect(aes(xmin=lockdown_1_start, xmax=lockdown_1_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_2_start, xmax=lockdown_2_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_3_start, xmax=lockdown_3_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_bar(stat="identity", color="#BA6A16", fill="#BA6A16", width=15) +
  geom_line(aes(y = starpurate), colour = "#0F5DC9",size = 0.8) +
  scale_x_date(date_labels = "%Y %b", breaks = "3 months") +
  scale_y_continuous(sec.axis = sec_axis(~sec$rev(.), name = "Number of cases tested positive for SARS-Cov-2 (Thousands)"))+
  labs(x = "", y = "STAR-PU adjusted antibiotic items per 1000 patient") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60,hjust=1))

ggsave(p, width = 10, height = 6, dpi = 640,
       filename="figure_1B.jpeg", path=here::here("output"),
)  

write_csv(df, here::here("output", "figure_1B_table.csv"))