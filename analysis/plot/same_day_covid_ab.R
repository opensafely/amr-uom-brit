library("dplyr")
library("tidyverse")
library('lubridate')
library("finalfit")

df <- read_csv(
  here::here("output", "input_sameday_ab.csv.gz"),
  col_types = cols_only(
    age = col_number(),
    age_cat = col_factor(),
    sex = col_factor(),
    practice = col_number(),#
    first_positive_test_date = col_date(format = ""),
    sgss_ab_prescribed = col_integer(),
    second_positive_test_date = col_date(format = ""),
    sgss_ab_prescribed_2 = col_integer(),
    pg_first_positive_test_date = col_date(format = ""),
    gp_ab_prescribed_1 = col_integer(),
    pg_second_positive_test_date = col_date(format = ""),
    gp_ab_prescribed_2 = col_integer(),
    patient_id = col_number())
)

### transfer date into covid positive outcome (binary_flag)

df$covid_positive_1_sgss=ifelse(is.na(df$first_positive_test_date),0,1)
df$covid_positive_1_pg=ifelse(is.na(df$pg_first_positive_test_date),0,1)
df$covid_positive_2_sgss=ifelse(is.na(df$second_positive_test_date),0,1)
df$covid_positive_2_pg=ifelse(is.na(df$pg_second_positive_test_date),0,1)

## select covid group from sgss record
df1 <- df %>% filter(covid_positive_1_sgss == 1)
df2 <- df1 %>% filter(covid_positive_2_sgss == 1)

num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sameday_positive_1_sgss.csv"))
rm(overall_counts,num_pats,num_pracs)

num_pats <- length(unique(df2$patient_id))
num_pracs <- length(unique(df2$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sameday_positive_2_sgss.csv"))
rm(overall_counts,num_pats,num_pracs)

df1<- select(df1, age, age_cat, sex,sgss_ab_prescribed)
# # columns for baseline table
colsfortab <- colnames(df1)
df1 %>% summary_factorlist(explanatory = colsfortab) -> t1
write_csv(t1, here::here("output", "sameday_ab_1_sgss.csv"))

df2<- select(df2, age, age_cat, sex, sgss_ab_prescribed_2)
# # columns for baseline table
colsfortab <- colnames(df2)
df2 %>% summary_factorlist(explanatory = colsfortab) -> t2
write_csv(t2, here::here("output", "sameday_ab_2_sgss.csv"))
rm(df1,df2,t1,t2)

## select covid group from gp record (from 2020-03-01 to 2022-02-28)
df1 <- df %>% filter(covid_positive_1_pg == 1)

df1$date <- as.Date(df1$pg_first_positive_test_date)
df1 <- df1 %>% filter(date<="2022-02-28")
df1 <- df1 %>% filter(date>="2020-03-01")

df2 <- df1 %>% filter(covid_positive_2_pg == 1)

num_pats <- length(unique(df1$patient_id))
num_pracs <- length(unique(df1$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sameday_positive_1_gp.csv"))
rm(overall_counts,num_pats,num_pracs)

num_pats <- length(unique(df2$patient_id))
num_pracs <- length(unique(df2$practice))

overall_counts <- as.data.frame(cbind(num_pats, num_pracs))
write_csv(overall_counts, here::here("output", "sameday_positive_2_gp.csv"))
rm(overall_counts,num_pats,num_pracs)

df1<- select(df1, age, age_cat, sex,gp_ab_prescribed_1)
# # columns for baseline table
colsfortab <- colnames(df1)
df1 %>% summary_factorlist(explanatory = colsfortab) -> t1
write_csv(t1, here::here("output", "sameday_ab_1_gp.csv"))

df2<- select(df2, age, age_cat, sex, gp_ab_prescribed_2)
# # columns for baseline table
colsfortab <- colnames(df2)
df2 %>% summary_factorlist(explanatory = colsfortab) -> t2
write_csv(t2, here::here("output", "sameday_ab_2_gp.csv"))

rm(df1,df2,t1,t2)




### Sgss same day ab
df1 <- df %>% filter(covid_positive_1_sgss == 1)
df1$date <- as.Date(df1$first_positive_test_date)

df1$cal_mon <- month(df1$date)
df1$cal_year <- year(df1$date)

plot1 <- df1 %>% group_by(cal_mon,cal_year) %>%
  summarise(total_count = sum(covid_positive_1_sgss),
            ab_count = sum(sgss_ab_prescribed))
plot1 <- plot1 %>% mutate(prop = ab_count/total_count)
plot1$cal_day <- 1


plot1$Date <- as.Date(paste(plot1$cal_year, plot1$cal_mon,plot1$cal_day, sep="-"), "%Y-%m-%d")
first_mon=format(min(plot1$Date),"%m-%Y")
last_mon= format(max(plot1$Date),"%m-%Y")



plot <-ggplot(data = plot1, aes(x = Date, y = prop))+
  geom_line(color = "coral2", size = 0.5)+ 
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 0.05, by = 0.005))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  labs(
    title = "Same day Covid diagnosis and antibiotics prescription-sgss",
    subtitle = paste(first_mon,"-",last_mon),
    x = "Time",
    y = "Same day antibiotics prescribing %")+
    theme(axis.text.x=element_text(angle=60,hjust=1))+
    scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")

plot

ggsave(
  plot= plot,
  filename="same_day_ab_prop_line_sgss.jpeg", path=here::here("output"),
)  
write_csv(plot1, here::here("output", "same_day_ab_prop_line_sgss_table.csv"))

rm(df1,plot1,plot)
### Gp same day ab

df2 <- df %>% filter(covid_positive_1_pg == 1)

df2$date <- as.Date(df2$pg_first_positive_test_date)
df2 <- df2 %>% filter(date<="2022-02-28")
df2 <- df2 %>% filter(date>="2020-03-01")

df2$cal_mon <- month(df2$date)
df2$cal_year <- year(df2$date)


plot2 <- df2 %>% group_by(cal_mon,cal_year) %>%
  summarise(total_count = sum(covid_positive_1_pg),
            ab_count = sum(gp_ab_prescribed_1))
plot2 <- plot2 %>% mutate(prop = ab_count/total_count)
plot2$cal_day <- 1


plot2$Date <- as.Date(paste(plot2$cal_year, plot2$cal_mon,plot2$cal_day, sep="-"), "%Y-%m-%d")
first_mon=format(min(plot2$Date),"%m-%Y")
last_mon= format(max(plot2$Date),"%m-%Y")

plot <-ggplot(data = plot2, aes(x = Date, y = prop))+
  geom_line(color = "coral2", size = 0.5)+ 
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 0.05, by = 0.005))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  labs(
    title = "Same day Covid diagnosis and antibiotics prescription-gp",
    subtitle = paste(first_mon,"-",last_mon),
    x = "Time",
    y = "Same day antibiotics prescribing %")+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")

plot

ggsave(
  plot= plot,
  filename="same_day_ab_prop_line_gp.jpeg", path=here::here("output"),
)  
write_csv(plot2, here::here("output", "same_day_ab_prop_line_gp_table.csv"))
