# Load the libraries
library(here)
library(dplyr)
library(survival)
library(ggplot2)
library(tidyverse)
library(survminer)
library(lubridate)
library(ggsci)
library(readr)
library(purrr)
library(stringr)
library(reshape2)
library(rms)

data <- readRDS(here::here("output", "processed_data.rds"))

# 2. Print the number of patients with chronic respiratory disease
cat("Number of patients with chronic respiratory disease:", sum(data$has_chronic_respiratory_disease, na.rm = TRUE), "\n")

# 3. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 4. Print the number of patients with infection_indicator being TRUE
cat("Number of patients with infection record:", sum(data$infection_indicator, na.rm = TRUE), "\n")

# 5. Print the number of patients where covid_6weeks is FALSE
cat("Number of patients without covid-19 positive record in six weeks:", sum(!data$covid_6weeks, na.rm = TRUE), "\n")

# Remove patients with chronic respiratory disease
data <- data %>% filter(!has_chronic_respiratory_disease)

# Remove patients without infection_indicator
data <- data %>% filter(infection_indicator)

# Exclude patients with covid_6weeks being TRUE
data <- data %>% filter(!covid_6weeks)


# 6. Create the EVENT column
data <- data %>% 
  mutate(EVENT = ifelse(!is.na(emergency_admission_date), 1, 0))

# 7. Print the number of patients where EVENT is 1 and 0
event_table <- table(data$EVENT)
cat("Number of patients where EVENT is 0:", event_table["0"], "\n")
cat("Number of patients where EVENT is 1:", event_table["1"], "\n")

# Create the variables

# TtoAB
data <- data %>%
  mutate(TtoAB = ifelse(!is.na(ab_date_next), as.numeric(ab_date_next - patient_index_date), NA))

# TtoD
data <- data %>%
  mutate(TtoD = ifelse(!is.na(died_any_date), as.numeric(died_any_date - patient_index_date), NA))

# TtoAE
data <- data %>%
  mutate(TtoAE = ifelse(!is.na(emergency_admission_date), as.numeric(emergency_admission_date - patient_index_date), NA))

# TtoEND
data <- data %>%
  mutate(TtoEND = as.numeric(as.Date("2020-03-25") - patient_index_date))

# Create TEVENT column
data <- data %>%
  rowwise() %>%
  mutate(TEVENT = min(c(TtoAB, TtoD, TtoAE, TtoEND), na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(TEVENT = ifelse(TEVENT > 30, 30, TEVENT))

data1 <- data

print("data_1 processed!")


data <- readRDS(here::here("output", "processed_data_2.rds"))

# 2. Print the number of patients with chronic respiratory disease
cat("Number of patients with chronic respiratory disease:", sum(data$has_chronic_respiratory_disease, na.rm = TRUE), "\n")

# 3. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 4. Print the number of patients with infection_indicator being TRUE
cat("Number of patients with infection record:", sum(data$infection_indicator, na.rm = TRUE), "\n")

# 5. Print the number of patients where covid_6weeks is FALSE
cat("Number of patients without covid-19 positive record in six weeks:", sum(!data$covid_6weeks, na.rm = TRUE), "\n")

# Remove patients with chronic respiratory disease
data <- data %>% filter(!has_chronic_respiratory_disease)

# Remove patients without infection_indicator
data <- data %>% filter(infection_indicator)

# Exclude patients with covid_6weeks being TRUE
data <- data %>% filter(!covid_6weeks)


# 6. Create the EVENT column
data <- data %>% 
  mutate(EVENT = ifelse(!is.na(emergency_admission_date), 1, 0))

# 7. Print the number of patients where EVENT is 1 and 0
event_table <- table(data$EVENT)
cat("Number of patients where EVENT is 0:", event_table["0"], "\n")
cat("Number of patients where EVENT is 1:", event_table["1"], "\n")

# Create the variables

# TtoAB
data <- data %>%
  mutate(TtoAB = ifelse(!is.na(ab_date_next), as.numeric(ab_date_next - patient_index_date), NA))

# TtoD
data <- data %>%
  mutate(TtoD = ifelse(!is.na(died_any_date), as.numeric(died_any_date - patient_index_date), NA))

# TtoAE
data <- data %>%
  mutate(TtoAE = ifelse(!is.na(emergency_admission_date), as.numeric(emergency_admission_date - patient_index_date), NA))

# TtoEND
data <- data %>%
  mutate(TtoEND = as.numeric(as.Date("2021-03-08") - patient_index_date))

# Create TEVENT column
data <- data %>%
  rowwise() %>%
  mutate(TEVENT = min(c(TtoAB, TtoD, TtoAE, TtoEND), na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(TEVENT = ifelse(TEVENT > 30, 30, TEVENT))

data2 <- data

print("data_2 processed!")


data <- readRDS(here::here("output", "processed_data_3.rds"))

# 2. Print the number of patients with chronic respiratory disease
cat("Number of patients with chronic respiratory disease:", sum(data$has_chronic_respiratory_disease, na.rm = TRUE), "\n")

# 3. Create the infection_indicator column
data <- data %>% 
  mutate(infection_indicator = has_uti | has_urti | has_lrti | has_sinusitis | has_ot_externa | has_otmedia)

# 4. Print the number of patients with infection_indicator being TRUE
cat("Number of patients with infection record:", sum(data$infection_indicator, na.rm = TRUE), "\n")

# 5. Print the number of patients where covid_6weeks is FALSE
cat("Number of patients without covid-19 positive record in six weeks:", sum(!data$covid_6weeks, na.rm = TRUE), "\n")

# Remove patients with chronic respiratory disease
data <- data %>% filter(!has_chronic_respiratory_disease)

# Remove patients without infection_indicator
data <- data %>% filter(infection_indicator)

# Exclude patients with covid_6weeks being TRUE
data <- data %>% filter(!covid_6weeks)


# 6. Create the EVENT column
data <- data %>% 
  mutate(EVENT = ifelse(!is.na(emergency_admission_date), 1, 0))

# 7. Print the number of patients where EVENT is 1 and 0
event_table <- table(data$EVENT)
cat("Number of patients where EVENT is 0:", event_table["0"], "\n")
cat("Number of patients where EVENT is 1:", event_table["1"], "\n")

# Create the variables

# TtoAB
data <- data %>%
  mutate(TtoAB = ifelse(!is.na(ab_date_next), as.numeric(ab_date_next - patient_index_date), NA))

# TtoD
data <- data %>%
  mutate(TtoD = ifelse(!is.na(died_any_date), as.numeric(died_any_date - patient_index_date), NA))

# TtoAE
data <- data %>%
  mutate(TtoAE = ifelse(!is.na(emergency_admission_date), as.numeric(emergency_admission_date - patient_index_date), NA))

# TtoEND
data <- data %>%
  mutate(TtoEND = as.numeric(as.Date("2023-06-30") - patient_index_date))

# Create TEVENT column
data <- data %>%
  rowwise() %>%
  mutate(TEVENT = min(c(TtoAB, TtoD, TtoAE, TtoEND), na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(TEVENT = ifelse(TEVENT > 30, 30, TEVENT))

data3 <- data

print("data_3 processed!")

data <- bind_rows(data1, data2, data3) 

## Process Data
fct_case_when <- function(...) {
  # uses dplyr::case_when but converts the output to a factor,
  # with factors ordered as they appear in the case_when's  ... argument
  args <- as.list(match.call())
  levels <- sapply(args[-1], function(f) f[[3]])  # extract RHS of formula
  levels <- levels[!is.na(levels)]
  factor(dplyr::case_when(...), levels=levels)
}


process_data <- function(data_extracted) {
  data_processed <-
    data_extracted %>%
    mutate(
      sex = fct_case_when(sex == "F" ~ "Female",
                          sex == "M" ~ "Male",
                          TRUE ~ NA_character_),
      # no missings should occur as only of
      # individuals with a female/male sex, data is extracted
      bmi = fct_case_when(
        bmi == "Underweight (<18.5)" ~ "Underweight (<18.5 kg/m2)",
        bmi == "Healthy range (18.5-24.9)" ~ "Healthy range (18.5-24.9 kg/m2)",
        bmi == "Overweight (25-29.9)" ~ "Overweight (25-29.9 kg/m2)",
        bmi == "Obese I (30-34.9)" ~ "Obese I (30-34.9 kg/m2)",
        bmi == "Obese II (35-39.9)" ~ "Obese II (35-39.9 kg/m2)",
        bmi == "Obese III (40+)" ~ "Obese III (40+ kg/m2)",
        TRUE ~ NA_character_
      ),
      
      ethnicity = fct_case_when(
        ethnicity == "1" ~ "White",
        ethnicity == "2" ~ "Mixed",
        ethnicity == "3" ~ "South Asian",
        ethnicity == "4" ~ "Black",
        ethnicity == "5" ~ "Other",
        ethnicity == "0" ~ "Unknown",
        TRUE ~ NA_character_ # no missings in real data expected 
        # (all mapped into 0) but dummy data will have missings (data is joined
        # and patient ids are not necessarily the same in both cohorts)
      ),
      
      smoking_status_comb = fct_case_when(
        smoking_status_comb == "N + M" ~ "Never and unknown",
        smoking_status_comb == "E" ~ "Former",
        smoking_status_comb == "S" ~ "Current",
        TRUE ~ NA_character_
      ),
      
      imd = fct_case_when(
        imd == "5" ~ "5 (least deprived)",
        imd == "4" ~ "4",
        imd == "3" ~ "3",
        imd == "2" ~ "2",
        imd == "1" ~ "1 (most deprived)",
        imd == "0" ~ NA_character_
      ),
      
      region = fct_case_when(
        region == "North East" ~ "North East",
        region == "North West" ~ "North West",
        region == "Yorkshire and The Humber" ~ "Yorkshire and the Humber",
        region == "East Midlands" ~ "East Midlands",
        region == "West Midlands" ~ "West Midlands",
        region == "East" ~ "East of England",
        region == "London" ~ "London",
        region == "South East" ~ "South East",
        region == "South West" ~ "South West",
        TRUE ~ NA_character_
      ))
  data_processed
}

data <- process_data(data)

# Relevel variables
data$region <- relevel(data$region, ref = "East of England")
data$imd <- relevel(data$imd, ref = "5 (least deprived)")
data$ethnicity <- relevel(data$ethnicity, ref = "White")
data$bmi <- relevel(data$bmi, ref = "Healthy range (18.5-24.9 kg/m2)")
data$bmi[is.na(data$bmi)] <- "Healthy range (18.5-24.9 kg/m2)"
data$smoking_status_comb <- relevel(data$smoking_status_comb, ref = "Never and unknown")
data$charlsonGrp <- relevel(data$charlsonGrp, ref = "zero")
data$imd <- factor(data$imd, levels = c(levels(data$imd), "Unknown"))
data$imd[is.na(data$imd)] <- "Unknown"
data$region <- factor(data$region, levels = c(levels(data$region), "Unknown"))
data$region[is.na(data$region)] <- "Unknown"
data <- data %>% filter(!is.na(sex))

# Reclassify total_ab_3yr
data$ab_3yr <- cut(data$total_ab_3yr, breaks = c(-Inf, 0, 1, 3, Inf), labels = c("0", "1", "2-3", "4+"), right = TRUE, include.lowest = TRUE)


df <- data

lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")
df$cal_year <- year(df$patient_index_date)
df$cal_mon <- month(df$patient_index_date)
df$cal_day <- 1
df$monPlot <- as.Date(with(df,paste(cal_year,cal_mon,cal_day,sep="-")),"%Y-%m-%d")


###  by IMD


df.plot <- df %>%
  group_by(monPlot, imd) %>%
  summarise(case_count = sum(EVENT == 1), population = n())

df.plot$value <- df.plot$case_count*1000 / df.plot$population
df.plot$value <- round(df.plot$value, digits = 3)

df.plot$imd <- recode(df.plot$imd,
       "1" = "1(most deprived)", 
       "2" = "2",
       "3" = "3",
       "4" = "4",
       "5" = "5(least deprived)")


figure_imd_strata <- ggplot(df.plot, aes(x = as.Date("2019-01-01"), y = value, group = factor(imd), col = factor(imd), fill = factor(imd))) +
  geom_boxplot(width=20, outlier.size=0, position="identity", alpha=.5) +
  annotate(geom = "rect", xmin = lockdown_1_start,xmax = lockdown_1_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_2_start,xmax = lockdown_2_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = lockdown_3_start,xmax = lockdown_3_end,ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(x = monPlot, y = value),size = 0.8)+ 
  scale_x_date(date_labels = "%Y %b", breaks = seq(as.Date("2019-01-01"), as.Date("2023-07-01"), by = "3 months")) +
  scale_y_continuous(limits = c(0, 0.01), breaks = seq(0, 0.01, by = 0.001), labels = function(x) sprintf("%0.3f", x)) +
  labs(x = "", y = "", title = "", colour = "IMD", fill = "IMD") +
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
figure_imd_strata


ggsave(figure_imd_strata, width = 10, height = 6, dpi = 640,
       filename="figure_rate.jpeg", path=here::here("output"),
)  
write_csv(df.plot, here::here("output", "figure_rate_table.csv"))