library("dplyr")
library("tidyverse")
library("lubridate")



all_files <- list.files(here::here("output"), pattern = "input_ab_extraction_")
months <- stringr::str_remove_all(all_files, c("input_ab_extraction_|.csv.gz"))
# load data ---------------------------------------------------------------
for(ii in 1:length(months)){
  load_file <- read.csv(here::here("output", paste0("input_ab_extraction_", months[ii], ".csv.gz")))
  assign(c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")[ii], load_file)
}

Jan_count <- Jan %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Jan_practice <- as.numeric(length(unique(Jan$practice)))
Jan_count$count_per_gp <- Jan_count$count/Jan_practice
Jan_count$mon <- 1

Feb_count <- Feb %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Feb_practice <- as.numeric(length(unique(Feb$practice)))
Feb_count$count_per_gp <- Feb_count$count/Feb_practice
Feb_count$mon <- 2

Mar_count <- Mar %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Mar_practice <- as.numeric(length(unique(Mar$practice)))
Mar_count$count_per_gp <- Mar_count$count/Mar_practice
Mar_count$mon <- 3

Apr_count <- Apr %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Apr_practice <- as.numeric(length(unique(Apr$practice)))
Apr_count$count_per_gp <- Apr_count$count/Apr_practice
Apr_count$mon <- 4

May_count <- May %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
May_practice <- as.numeric(length(unique(May$practice)))
May_count$count_per_gp <- May_count$count/May_practice
May_count$mon <- 5

Jun_count <- Jun %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Jun_practice <- as.numeric(length(unique(Jun$practice)))
Jun_count$count_per_gp <- Jun_count$count/Jun_practice
Jun_count$mon <- 6

Jul_count <- Jul %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Jul_practice <- as.numeric(length(unique(Jul$practice)))
Jul_count$count_per_gp <- Jul_count$count/Jul_practice
Jul_count$mon <- 7

Aug_count <- Aug %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Aug_practice <- as.numeric(length(unique(Aug$practice)))
Aug_count$count_per_gp <- Aug_count$count/Aug_practice
Aug_count$mon <- 8

Sep_count <- Sep %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Sep_practice <- as.numeric(length(unique(Sep$practice)))
Sep_count$count_per_gp <- Sep_count$count/Sep_practice
Sep_count$mon <- 9

Oct_count <- Oct %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Oct_practice <- as.numeric(length(unique(Oct$practice)))
Oct_count$count_per_gp <- Oct_count$count/Oct_practice
Oct_count$mon <- 10

Nov_count <- Nov %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Nov_practice <- as.numeric(length(unique(Nov$practice)))
Nov_count$count_per_gp <- Nov_count$count/Nov_practice
Nov_count$mon <- 11

Dec_count <- Dec %>% group_by(antibacterial_brit_abtype) %>% summarise(count=sum(antibacterial_brit))
Dec_practice <- as.numeric(length(unique(Dec$practice)))
Dec_count$count_per_gp <- Dec_count$count/Dec_practice
Dec_count$mon <- 12

data_plot <- rbind(Jan_count,Feb_count,Mar_count,Apr_count,May_count,Jun_count,Jul_count,Aug_count,Sep_count,Oct_count,Nov_count,Dec_count)


data_plot_Co_TRI <- data_plot %>% filter(antibacterial_brit_abtype==c("CO-TRIMOXAZOLE 160MG/800MG TABLETS","CO-TRIMOXAZOLE 40MG/200MG/5ML ORAL SUSPENSION SUGAR FREE",
                                                                      "CO-TRIMOXAZOLE 80MG/400MG TABLETS","CO-TRIMOXAZOLE 80MG/400MG/5ML ORAL SUSPENSION",
                                                                      "CO-TRIMOXAZOLE 80MG/400MG/5ML SOLUTION FOR INFUSION AMPOULES"))
data_plot_Co_TRI$type <- "Co-Tri"
data_plot_TRI <- data_plot %>% filter(antibacterial_brit_abtype==c("MONOTRIM 50MG/5ML ORAL SUSPENSION","SEPTRIN FORTE 160MG/800MG TABLETS",
                                                                      "SEPTRIN PAEDIATRIC 40MG/200MG/5ML ORAL SUSPENSION","TRIMETHOPRIM 100MG TABLETS",
                                                                      "TRIMETHOPRIM 200MG TABLETS","TRIMETHOPRIM 50MG/5ML ORAL SUSPENSION SUGAR FREE"))
data_plot_TRI$type <- "Tri"
data_plot_NIT <- data_plot %>% filter(antibacterial_brit_abtype==c("NITROFURANTOIN 100MG CAPSULES","NITROFURANTOIN 100MG TABLETS",
                                                                   "NITROFURANTOIN 25MG/5ML ORAL SUSPENSION SUGAR FREE","NITROFURANTOIN 50MG CAPSULES",
                                                                   "NITROFURANTOIN 50MG TABLETS","GENFURA 100MG TABLETS",
                                                                   "GENFURA 50MG TABLETS","MACROBID 100MG MODIFIED-RELEASE CAPSULES",
                                                                   "MACRODANTIN 100MG CAPSULES"))
data_plot_NIT$type <- "NIT"
plot <- rbind(data_plot_Co_TRI,data_plot_TRI,data_plot_NIT)

write_csv(plot, here::here("output", "TPP_ab_month_2019.csv"))




