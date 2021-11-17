##############
## UTI:
## event rate & prescribing rate (per 1000 patients)
## By practice, by month, per 1000 patient
##############



library("data.table")
library("dplyr")
library('here')
library("tidyverse")
library("cowplot")

setwd(here::here("output", "measures"))

# read flie list from input.csv
csvFiles = list.files(pattern="input_", full.names = TRUE)
temp <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles))
  temp[[i]] <- read_csv(csvFiles[i],
                        
                        col_types = cols_only(
                          
                          # Identifier
                          practice = col_integer(),
                          
                          # Outcomes
                          uti_ab_flag_1  = col_double(),
                          uti_ab_flag_2  = col_double(),
                          uti_ab_flag_3  = col_double(),
                          uti_ab_flag_4  = col_double(),
                          uti_counts  = col_double(),
                          
                          
                          # Date
                          uti_date_1 = col_date(format="%Y-%m-%d"),
                          uti_date_2 = col_date(format="%Y-%m-%d"),
                          uti_date_3 = col_date(format="%Y-%m-%d"),
                          uti_date_4 = col_date(format="%Y-%m-%d")
                          
                        ),
                        na = character()
  )

# combine list of data.table/data.frame
df_input <- rbindlist(temp)
# remove temopary list
rm(temp,csvFiles,i)

# select valid practice number
df_input <- df_input %>% filter(practice >0)

# sum up total number of uti antibiotics within each patient in one month & extract year-month for group data
df_input=
  df_input%>%
  mutate(ab_counts_all= uti_ab_flag_1 +  uti_ab_flag_2 +  uti_ab_flag_3 +  uti_ab_flag_4,
         date=format(as.Date( uti_date_1), "%Y-%m"))

# remove date=NA (no antibiotics prescribed date)
df_input <- df_input %>% filter(!is.na(df_input$date))

# select incident case
df_input <- df_input %>% filter(incdt_uti_pt==0)


######### check table ##########
## 4 times of records /total uti consultation counts - per patient per month
## coverage rate
df_check=df_input[,1:6]
df_check$count4times=4-rowSums(is.na(df_check))
df_check$date=format(as.Date(df_check$uti_date_1), "%Y-%m")

df_check_gp=df_check%>%
  group_by(practice,date)%>%
  summarise(total_consultations=sum(uti_counts),
             include_consultations=sum(count4times))
df_check_gp$coverage=df_check_gp$include_consultations/df_check_gp$total_consultations

write.csv(df_check_gp,here::here("output", "uti_prescrib_check.csv"))
######### check table ##########


df=df_input%>%group_by(date)%>%
  summarise(ab=sum(uti_ab_flag_1,uti_ab_flag_2,uti_ab_flag_3,uti_ab_flag_4),
            total=4*n())

df$percentage=df$ab/df$total


# bar chart

bar <- ggplot(df, aes(x=date, y=percentage))+
  geom_rect(xmin = -Inf,xmax = Inf, ymin = -Inf, ymax = Inf,fill="grey90")+
  geom_rect(xmin = -Inf,xmax = "2021-01",ymin = -Inf, ymax = Inf,fill="grey80")+
  geom_rect(xmin = -Inf,xmax = "2020-11",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_rect(xmin = -Inf,xmax = "2020-03",ymin = -Inf, ymax = Inf,fill="grey70")+
  geom_col()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(
    title = "UTI consultations",
    x = "Time", 
    y = " prescribed AB (%)")


bar

ggsave(
  plot= bar,
  filename="prescribed_percentage_UTI.png", path=here::here("output"),
)