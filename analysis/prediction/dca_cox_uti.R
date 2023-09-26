################################################################################
# Part 1: UTI model development process                                        #
################################################################################

library(here)
library(dplyr)
library(readr)
library(purrr)
library(stringr)
library(reshape2)
library(ggplot2)
library(survival)
library(rms)
library(MASS)
library(Hmisc)

## Load data

input_data <- readRDS(here::here("output", "data_for_cox_model.rds"))

print ("input data success")
## Load function

utils_dir <- here("analysis", "utils")
source(paste0(utils_dir, "/stdca.R")) # function stdca()

print ("Load fuction success")

data <- input_data %>% filter(has_uti)

# Data Partition 
set.seed(666)
ind <- sample(2,nrow(data),
              replace = TRUE,
              prob = c(0.75,0.25))

training <- data[ind==1,]
testing <- data[ind==2,]


## model evaluation ##
age3_spline_train <- rcs(training$age, 3)
knots <- attr(age3_spline_train, "knots")
age3_spline_test <- rcs(testing$age, 3, knots=knots)
# Bind to training
training$age3_spline <- age3_spline_train
# Bind to testing
testing$age3_spline <- age3_spline_test

input_training <- training

model_selected <- coxph(Surv(TEVENT, EVENT) ~ sex + age3_spline + region + imd + ethnicity + bmi + smoking_status_comb + charlsonGrp + ab_30d, data = input_training)

print ("Surv model success")


input_training$lin_pred <- predict(model_selected, newdata=input_training, type="lp")

# Calculate the risk of an event by day 30
input_training$day_30_risk <- 1 - input_training$lin_pred

print ("risk of an event by day 30 calculate success")

input_training$EVENT <- as.numeric(input_training$EVENT)

# Create a table of counts for the EVENT column
event_counts <- table(input_training$EVENT, useNA = "ifany")

# Print the table
print(event_counts)

# Count the number of NA values in the EVENT column
na_count <- sum(is.na(input_training$EVENT))

# Print the number of NA values
cat("Number of NA values:", na_count, "\n")

print(length(input_training[!(input_training[EVENT]==0 | input_training[EVENT]==1),EVENT]))

dca_30d <- stdca(
  data = input_training,
  outcome = EVENT,
  ttoutcome = TEVENT,
  timepoint = 30,
  predictors = day_30_risk,
  xstop = 1.0,
  ymin = -0.01,
  graph = FALSE
)

print ("dca_30d  calculate success")

dca_smooth <- smooth(dca_30d$net.benefit$day_30_risk
                     [!is.na(dca_30d$net.benefit$day_30_risk)],
                     twiceit = TRUE)
dca_smooth <- c(dca_smooth,
                rep(NA, sum(is.na(dca_30d$net.benefit$day_30_risk))))

# Open the jpeg graphics device with the desired file path
jpeg(here::here("output", "DCA_UTI.jpeg"), width=800, height=600)
par(xaxs = "i", yaxs = "i", las = 1)
plot(dca_30d$net.benefit$threshold,
     dca_smooth,
     type = "l",
     lwd = 3,
     lty = 2,
     xlab = "Threshold probability",
     ylab = "Net Benefit",
     xlim = c(0, 1),
     ylim = c(-0.10, 0.45),
     bty = "n",
     cex.lab = 1.2,
     cex.axis = 1,
     col = 4
)
abline(h = 0,
       type = "l",
       lwd = 3,
       lty = 4,
       col = 8)
lines(dca_30d$net.benefit$threshold,
      dca_30d$net.benefit$all,
      type = "l",
      lwd = 3,
      lty = 5,
      col = 2)
legend("topright",
       c(
         "Treat All",
         "UTI model",
         "Treat None"
       ),
       lty = c(4, 5, 4),
       lwd = 3,
       col = c(2, 4, 8),
       bty = "n"
)
title("Development data", cex = 1.5)

# Close the graphics device
dev.off()