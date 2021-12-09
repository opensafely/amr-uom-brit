
# # # # # # # # # # # # # # # # # # # # #
# This script:
# Generate a plot to show proportion of patients with 0, 1-3, 4-6, 7+ antibiotics in the 12m before. 
# By practice, by month, per 1000 patient
# mean 25th and 75th percentile
# # # # # # # # # # # # # # # # # # # # #

## Import libraries---
library("ggplot2")
library('dplyr')
library('lubridate')
library('stringr')
library("data.table")
library("ggpubr")

setwd(here::here("output", "measures"))

### read data  ###
### 1.1 import patient-level data(study definition input.csv) to summarize antibiotics counts
############ loop reading multiple CSV files ################
# read file list from input.csv
csvFiles = list.files(pattern="input_", full.names = TRUE)
temp <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles)){
  filename <- csvFiles[i]
  temp_df <- read_csv(filename)
  
  filename <-str_remove(filename, "./input_")
  filename <-str_remove(filename, ".csv.gz")
  
  #add to per-month temp df
  temp_df$date <- filename
  mutate(temp_df, date = as.Date(date, "%Y-%m-%d"))
  
  #add df to list
  temp[[i]] <- temp_df
}

# combine list -> data.table/data.frame
df_input <- rbindlist(temp, fill=TRUE)
rm(temp,csvFiles,i)# remove temporary list

## select rows of interest
#df_input <- select(df_input, age, sex, region, ethnicity, antibacterial_12mb4, date)

df_input$date <- as.Date(df_input$date)
df_input$cal_mon <- month(df_input$date)
df_input$cal_year <- year(df_input$date)
 
# remove last month data
last.date=max(df_input$date)
df=df_input%>% filter(date!=last.date)
first_mon <- (format(min(df$date), "%m-%Y"))
last_mon <- (format(max(df$date), "%m-%Y"))
num_pats <- as.numeric(dim(df)[1])
 
### replace NA in number of abs 12 months before to 0
# df$antibacterial_12mb4[is.na(df$antibacterial_12mb4)] <- 0
 
### make variable for categorising num ABs in 12m before
### group_by  month --- removed grouping by practice!!!
df_gp <- df %>% group_by(cal_mon, cal_year) %>%
   mutate(ab_cat = case_when(antibacterial_12mb4 >0 & antibacterial_12mb4 <4 ~ 2,
                             antibacterial_12mb4 >3 & antibacterial_12mb4 <7 ~ 3,
                             antibacterial_12mb4 >=7 ~ 4,
                             antibacterial_12mb4 == 0 ~1)) 
df_gp$ab_cat <- as.factor(df_gp$ab_cat)

### add labels to levels
df_gp$`Prior ABs` <- factor(df_gp$ab_cat, labels=c("0", "1-3", "4-6", "7+"))

### calculate % for each ab_category in each  
### by dividing by 'nrows' in groups to get population by month
df_percent <- df_gp %>% group_by(cal_mon, cal_year) %>%
   mutate(mon_listsize = n())
### group by ab cat to work out percentage by category using practice listsize
df_per_abgp <- df_percent %>% group_by(cal_mon, cal_year, `Prior ABs`) %>%
   mutate(num_abcats = n()) %>%
   mutate(percentgp = (num_abcats/mon_listsize)*100)

prior12m_line <- ggplot(df_per_abgp, aes(x=date, y=percentgp, group=`Prior ABs`)) +
                  geom_line(aes(linetype=`Prior ABs`, colour=`Prior ABs`))+
                  scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
                  scale_y_continuous(limits = c(0,100))+
                  theme(axis.text.x=element_text(angle=60,hjust=1))+
                  labs(title = "Distribution of population level of prior antibiotic use (12m before) over time",
                       x = "", y = "Percentage",
                       caption = paste("Data from", num_pats,"patients"),)
ggsave(
  plot= prior12m_line,
  filename="AB_1yb4_line.jpeg", path=here::here("output"),
)

## plot by sex
male_df <- filter(df_per_abgp, sex == "M")
female_df <- filter(df_per_abgp, sex == "F")

Male_prior_12m <- ggplot(male_df, aes(x=date, y=percentgp, group=`Prior ABs`)) +
        geom_line(aes(linetype=`Prior ABs`, colour=`Prior ABs`))+
        scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
        scale_y_continuous(limits = c(0,100))+
        theme(axis.text.x=element_text(angle=60,hjust=1))+
        labs(title = "Distribution of population level of prior antibiotic use (12m before) over time - Males",
             x = "", y = "Percentage")

Female_prior_12m <- ggplot(female_df, aes(x=date, y=percentgp, group=`Prior ABs`)) +
      geom_line(aes(linetype=`Prior ABs`, colour=`Prior ABs`))+
      scale_x_date(date_labels = "%m-%Y", date_breaks = "1 month")+
      scale_y_continuous(limits = c(0,100))+
      theme(axis.text.x=element_text(angle=60,hjust=1))+
      labs(title = "Distribution of population level of prior antibiotic use (12m before) over time - Females",
           x = "", y = "Percentage")

## combine plots
figure <- ggarrange(Male_prior_12m, Female_prior_12m,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)

ggsave(
  plot= figure,
  filename="AB_1yb4_SEX.jpeg", path=here::here("output"),
)
