
# update: UTI, LRTI,

library("data.table")
library("dplyr")
library('here')
library("tidyverse")

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
    uti_ab_count_1  = col_double(),
    uti_ab_count_2  = col_double(),
    uti_ab_count_3  = col_double(),
    uti_ab_count_4  = col_double(),
    uti_counts  = col_double(),
    lrti_ab_count_1  = col_double(),
    lrti_ab_count_2  = col_double(),
    lrti_ab_count_3  = col_double(),
    lrti_ab_count_4  = col_double(),
    lrti_counts  = col_double(),
    
    # Date
    uti_date_1 = col_date(format="%Y-%m-%d"),
    uti_date_2 = col_date(format="%Y-%m-%d"),
    uti_date_3 = col_date(format="%Y-%m-%d"),
    uti_date_4 = col_date(format="%Y-%m-%d"),
    lrti_date_1 = col_date(format="%Y-%m-%d"),
    lrti_date_2 = col_date(format="%Y-%m-%d"),
    lrti_date_3 = col_date(format="%Y-%m-%d"),
    lrti_date_4 = col_date(format="%Y-%m-%d")
    
  ),
  na = character()
  )

# combine list of data.table/data.frame
df_input <- rbindlist(temp)
# remove temopary list
rm(temp,csvFiles,i)

# select valid practice number
df_input <- df_input %>% filter(practice >0)


## sum up total number of uti antibiotics within each patient in one month & extract year-month for group data
df_input=df_input%>%
  mutate(
  uti_ab_counts_all= uti_ab_count_1 + uti_ab_count_2 + uti_ab_count_3 + uti_ab_count_4,
  lrti_ab_counts_all= lrti_ab_count_1 + lrti_ab_count_2 + lrti_ab_count_3 + lrti_ab_count_4) %>%
  mutate(date=format(as.Date(uti_date_1) , "%Y-%m"))

## remove date=NA (no antibiotics prescribed date)
df_input <- df_input %>% filter(!is.na(df_input$date))


# -----UTI
## summarize patient-level data to paractice-level
## population = number of patients with UTI (not all population)
df_measure_uti=df_input%>%  
  group_by(date, practice) %>%
  summarize(population=n(), ab_counts=sum(uti_ab_counts_all)) %>%
  mutate(value=ab_counts/population)


#boxplot -describe percentage(value) of each practice

overallbox_uti <- ggplot(df_measure_uti, aes(group=date,x=date,y=value)) + 
  geom_boxplot()+
  xlab("time") +
  ylab("prescribing rate by infection") +
  geom_dotplot(binaxis = 'y',     
               stackdir = 'center', 
               dotsize = 0.2)+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))



ggsave(
  plot= overallbox_uti,
  filename="uti_prescribing_rate_box.png", path=here::here("output")
)



# -----LRTI
## summarize patient-level data to paractice-level
df_measure_lrti=df_input%>%  
  group_by(date, practice) %>%
  summarize(population=n(), ab_counts=sum(lrti_ab_counts_all)) %>%
  mutate(value=ab_counts/population)


#boxplot -describe percentage(value) of each practice

overallbox_lrti <- ggplot(df_measure_lrti, aes(group=date,x=date,y=value)) + 
  geom_boxplot()+
  xlab("time") +
  ylab("prescribing rate by infection") +
  geom_dotplot(binaxis = 'y',     
               stackdir = 'center', 
               dotsize = 0.2)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 


ggsave(
  plot= overallbox_lrti,
  filename="lrti_prescribing_rate_box.png", path=here::here("output")
)
