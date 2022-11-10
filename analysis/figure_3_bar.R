library("dplyr")
library("tidyverse")
library("lubridate")
library("patchwork")
library("scales")
library("ggsci")

rm(list=ls())
setwd(here::here("output", "measures"))

col_spec1 <-cols_only(AB_given_14D_window = col_number(),
                       Positive_test_event = col_number(),
                       value = col_number(),
                       date = col_date(format = "")
)

col_spec2 <-cols_only(Broad_given_14D_window = col_number(),
                       date = col_date(format = "")
)



lockdown_1_start = as.Date("2020-03-26")
lockdown_1_end = as.Date("2020-06-01")
lockdown_2_start = as.Date("2020-11-05")
lockdown_2_end = as.Date("2020-12-02")
lockdown_3_start = as.Date("2021-01-06")
lockdown_3_end = as.Date("2021-03-08")




df1.20 <- read_csv("measure_covid_window_14D_window_ab.csv",
               col_types = col_spec1) %>% filter(date >=as.Date("2020-03-01"))
df1.21 <- read_csv("measure_21_covid_window_14D_window_ab.csv",
               col_types = col_spec1)
df1 <- bind_rows(df1.20,df1.21)

df2.20 <- read_csv("measure_covid_window_14D_window_broad.csv",
               col_types = col_spec2) %>% filter(date >=as.Date("2020-03-01"))
df2.21 <- read_csv("measure_21_covid_window_14D_window_broad.csv",
               col_types = col_spec2)
df2 <- bind_rows(df2.20,df2.21)


df <- left_join(df1,df2,by = "date")
df$ab_rate <- round(df$value,digits = 3)

df$Broad_given_14D_window <- plyr::round_any(df$Broad_given_14D_window, 5)
df$AB_given_14D_window <- plyr::round_any(df$AB_given_14D_window, 5)
df$broad_rate <- round(df$Broad_given_14D_window/df$AB_given_14D_window,digits = 3)

df$narrow_given_14_window <- df$AB_given_14D_window - df$Broad_given_14D_window
df$no_ab_given_14_window <- df$Positive_test_event - df$AB_given_14D_window

df_broad <- select(df,c("Broad_given_14D_window","date"))
df_broad$group <- "broad"
names(df_broad) <- c("count","date","group")
df_narrow <- select(df,c("narrow_given_14_window","date"))
df_narrow$group <- "narrow"
names(df_narrow) <- c("count","date","group")
df_noab <- select(df,c("no_ab_given_14_window","date"))
df_noab$group <- "noab"
names(df_noab) <- c("count","date","group")

df_plot <- bind_rows(df_broad,df_narrow,df_noab)

p <- ggplot(df_plot, aes(x = date, y = count, fill = group)) + 
  geom_rect(aes(xmin=lockdown_1_start, xmax=lockdown_1_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_2_start, xmax=lockdown_2_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_rect(aes(xmin=lockdown_3_start, xmax=lockdown_3_end, ymin=-Inf, ymax=Inf),fill = "#DEC0A0")+
  geom_bar(stat = "identity") +
  scale_x_date(date_labels = "%Y %b", breaks = "1 month") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60,hjust=1)) +
  scale_fill_manual(values = c("#DADAEB", "#9E9AC8", "#6A51A3"),
                         name="",
                         breaks=c("broad", "narrow", "noab"),
                         labels=c("broad-spectrum", "narrow-spectrum", "no antibiotic"))
p

ggsave(p, width = 12, height = 6, dpi = 640,
                   filename="figure_3_bar.jpeg", path=here::here("output"),
            )  

write_csv(df, here::here("output", "figure_3_bar_table.csv"))
