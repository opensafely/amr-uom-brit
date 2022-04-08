library("data.table")
# library("tidyverse")
library(jsonlite)

setwd("./output/hospitalisation_data")

dat201901 <- read.csv("input_hospitalisation_2019-01-01.csv.gz", header=TRUE)
dat201902 <- read.csv("input_hospitalisation_2019-02-01.csv.gz", header=TRUE)
dat201903 <- read.csv("input_hospitalisation_2019-03-01.csv.gz", header=TRUE)
dat201904 <- read.csv("input_hospitalisation_2019-04-01.csv.gz", header=TRUE)
dat201905 <- read.csv("input_hospitalisation_2019-05-01.csv.gz", header=TRUE)
dat201906 <- read.csv("input_hospitalisation_2019-06-01.csv.gz", header=TRUE)
dat201907 <- read.csv("input_hospitalisation_2019-07-01.csv.gz", header=TRUE)
dat201908 <- read.csv("input_hospitalisation_2019-08-01.csv.gz", header=TRUE)
dat201909 <- read.csv("input_hospitalisation_2019-09-01.csv.gz", header=TRUE)
dat201910 <- read.csv("input_hospitalisation_2019-10-01.csv.gz", header=TRUE)
dat201911 <- read.csv("input_hospitalisation_2019-11-01.csv.gz", header=TRUE)
dat201912 <- read.csv("input_hospitalisation_2019-12-01.csv.gz", header=TRUE)

# dat2019 = merge(dat201901, dat201902, dat201903, dat201904, dat201905, dat201906, dat201907, dat201908, dat201909, dat201910, dat201911, dat201912)

#put all data frames into list
dat2019 <- list(dat201901, dat201902, dat201903, dat201904, dat201905, dat201906, dat201907, dat201908, dat201909, dat201910, dat201911, dat201912)

#merge all data frames in list
Reduce(function(x, y) merge(x, y, all=TRUE), dat2019)

# toJSON(dat2019, pretty = TRUE)
# saveRDS(df_list, "dat2019.rds")
write.csv(dat2019, file=gzfile("data2019.csv.gz"))