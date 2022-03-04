library("data.table")
library("dplyr")
library("tidyverse")

setwd(here::here("output","measures"))

### Import data
filelist=c("consult_UTI.rds","consult_URTI.rds","consult_LRTI.rds","consult_sinusitis.rds","consult_ot_externa.rds","consult_otmedia.rds")



df = read_rds(here::here("output","measures",filelist[1]))

# infection counts, population size, covid period
df = df%>% group_by(date, covid)%>% 
  summarise(counts=sum(infection_counts), 
            population=sum(population))
# month for seasonality
df$month= format(df$date,"%m")
# time elapsed(measurement time point) for linear effect of time to capture long-term behaviour trends
df$times <- as.numeric(as.factor(df$date))

saveRDS(df,"monthly_consult_UTI.rds")
rm(df)



df = read_rds(here::here("output","measures",filelist[2]))
# infection counts, population size, covid period
df = df%>% group_by(date, covid)%>% 
  summarise(counts=sum(infection_counts), 
            population=sum(population))
# month for seasonality
df$month= format(df$date,"%m")
# time elapsed(measurement time point) for linear effect of time to capture long-term behaviour trends
df$times <- as.numeric(as.factor(df$date))

saveRDS(df,"monthly_consult_URTI.rds")
rm(df)




df = read_rds(here::here("output","measures",filelist[3]))
# infection counts, population size, covid period
df = df%>% group_by(date, covid)%>% 
  summarise(counts=sum(infection_counts), 
            population=sum(population))
# month for seasonality
df$month= format(df$date,"%m")
# time elapsed(measurement time point) for linear effect of time to capture long-term behaviour trends
df$times <- as.numeric(as.factor(df$date))

saveRDS(df,"monthly_consult_LRTI.rds")
rm(df)



df = read_rds(here::here("output","measures",filelist[4]))
# infection counts, population size, covid period
df = df%>% group_by(date, covid)%>% 
  summarise(counts=sum(infection_counts), 
            population=sum(population))
# month for seasonality
df$month= format(df$date,"%m")
# time elapsed(measurement time point) for linear effect of time to capture long-term behaviour trends
df$times <- as.numeric(as.factor(df$date))

saveRDS(df,"monthly_consult_sinusitis.rds")
rm(df)





df = read_rds(here::here("output","measures",filelist[5]))
# infection counts, population size, covid period
df = df%>% group_by(date, covid)%>% 
  summarise(counts=sum(infection_counts), 
            population=sum(population))
# month for seasonality
df$month= format(df$date,"%m")
# time elapsed(measurement time point) for linear effect of time to capture long-term behaviour trends
df$times <- as.numeric(as.factor(df$date))

#temp[[i]]=df

saveRDS(df,"monthly_consult_ot_externa.rds")
rm(df)


df = read_rds(here::here("output","measures",filelist[6]))
# infection counts, population size, covid period
df = df%>% group_by(date, covid)%>% 
  summarise(counts=sum(infection_counts), 
            population=sum(population))
# month for seasonality
df$month= format(df$date,"%m")
# time elapsed(measurement time point) for linear effect of time to capture long-term behaviour trends
df$times <- as.numeric(as.factor(df$date))

saveRDS(df,"monthly_consult_otmedia.rds")
