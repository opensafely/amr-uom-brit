# Load the libraries
library(here)
library(dplyr)
library(survival)
library(ggplot2)
library(cmprsk)

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



fit <- survfit(Surv(TEVENT, EVENT) ~ 1, data = data)
surv_df <- data.frame(
  time = fit$time,
  survival = fit$surv,
  upper = fit$upper,
  lower = fit$lower
)



Figure1 <- ggplot(surv_df, aes(x = time, y = survival)) +
  # Confidence interval ribbon
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.3, fill = "blue") + 
  geom_line(aes(y = survival), color = "blue", size = 0.5) +
  labs(title = "Kaplan-Meier Survival Curve with Confidence Interval",
       x = "Time (days)",
       y = "Survival") +
  theme_light() +
  theme(legend.position = "topright") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1)), 
                     limits = c(0.96, 1)) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.1))) + 
  geom_blank(aes(y = 0.96))

ggsave(Figure1, dpi = 700,
       filename = "KM_overall_with_CI.jpeg", path = here::here("output"))
