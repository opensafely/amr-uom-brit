library("dplyr")
library("tidyverse")
library("lubridate")

rm(list=ls())
setwd(here::here("output"))

df1 <- read_csv("mon_stratified_broad.csv")
df2 <- read_csv("mon_stratified_repeat.csv")

df1_overall_sameday <- df1 %>% group_by(monPlot,sameday_ab) %>% summarise(
  numOutcome = sum(numOutcome),
  numEligible = sum(numEligible)
) %>% mutate (value = numOutcome/numEligible) 

df1_overall_sameday$sameday_ab <- ifelse(df1_overall_sameday$sameday_ab==1,"coded","uncoded")


plot_sameday <- ggplot(df1_overall_sameday, aes(x=monPlot, y=value ,group=sameday_ab,color=sameday_ab))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=sameday_ab))+
  geom_point(aes(shape=sameday_ab))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "",
    title = "",
    y = "",
    x=""
  )+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.005))+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_shape_manual(values = c(rep(1:9))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen"))+
  scale_x_date(date_labels = "%Y", date_breaks = "1 year")
plot_sameday

ggsave(
  plot= plot_sameday,
  filename="broad_all_group.jpeg", path=here::here("output"),
)  
write_csv(df1_overall_sameday, here::here("output", "broad_all_group_table.csv"))
rm(plot_sameday,df1_overall_sameday)

### Incidental group
df1_Incidental_sameday <- df1 %>% filter(incidental == 1) %>%
  group_by(monPlot,sameday_ab) %>% summarise(
  numOutcome = sum(numOutcome),
  numEligible = sum(numEligible)
) %>% mutate (value = numOutcome/numEligible) 

df1_Incidental_sameday$sameday_ab <- ifelse(df1_Incidental_sameday$sameday_ab==1,"coded","uncoded")


plot_sameday <- ggplot(df1_Incidental_sameday, aes(x=monPlot, y=value ,group=sameday_ab,color=sameday_ab))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=sameday_ab))+
  geom_point(aes(shape=sameday_ab))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "",
    title = "",
    y = "",
    x=""
  )+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.005))+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_shape_manual(values = c(rep(1:9))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen"))+
  scale_x_date(date_labels = "%Y", date_breaks = "1 year")
plot_sameday

ggsave(
  plot= plot_sameday,
  filename="broad_incidental_group.jpeg", path=here::here("output"),
)  
write_csv(df1_Incidental_sameday, here::here("output", "broad_incidental_group_table.csv"))
rm(plot_sameday,df1_Incidental_sameday)


df2_overall_sameday <- df2 %>% group_by(monPlot,sameday_ab) %>% summarise(
  numOutcome = sum(numOutcome),
  numEligible = sum(numEligible)
) %>% mutate (value = numOutcome/numEligible) 

df2_overall_sameday$sameday_ab <- ifelse(df2_overall_sameday$sameday_ab==1,"coded","uncoded")


plot_sameday <- ggplot(df2_overall_sameday, aes(x=monPlot, y=value ,group=sameday_ab,color=sameday_ab))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=sameday_ab))+
  geom_point(aes(shape=sameday_ab))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "",
    title = "",
    y = "",
    x=""
  )+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.005))+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_shape_manual(values = c(rep(1:9))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen"))+
  scale_x_date(date_labels = "%Y", date_breaks = "1 year")
plot_sameday

ggsave(
  plot= plot_sameday,
  filename="repeat_all_group.jpeg", path=here::here("output"),
)  
write_csv(df2_overall_sameday, here::here("output", "repeat_all_group_table.csv"))
rm(plot_sameday,df2_overall_sameday)

### Incidental group
df2_Incidental_sameday <- df2 %>% filter(incidental == 1) %>%
  group_by(monPlot,sameday_ab) %>% summarise(
    numOutcome = sum(numOutcome),
    numEligible = sum(numEligible)
  ) %>% mutate (value = numOutcome/numEligible) 

df2_Incidental_sameday$sameday_ab <- ifelse(df2_Incidental_sameday$sameday_ab==1,"coded","uncoded")


plot_sameday <- ggplot(df2_Incidental_sameday, aes(x=monPlot, y=value ,group=sameday_ab,color=sameday_ab))+
  annotate(geom = "rect", xmin = as.Date("2021-01-01"),xmax = as.Date("2021-04-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-11-01"),xmax = as.Date("2020-12-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  annotate(geom = "rect", xmin = as.Date("2020-03-01"),xmax = as.Date("2020-06-01"),ymin = -Inf, ymax = Inf,fill="grey80", alpha=0.5)+
  geom_line(aes(linetype=sameday_ab))+
  geom_point(aes(shape=sameday_ab))+
  theme(legend.position = "right",legend.title =element_blank())+
  labs(
    fill = "",
    title = "",
    y = "",
    x=""
  )+
  scale_y_continuous(labels = scales::percent,breaks=seq(0, 1, by = 0.005))+
  theme(axis.text.x=element_text(angle=60,hjust=1))+
  scale_shape_manual(values = c(rep(1:9))) +
  scale_color_manual(values = c("coral2","deeppink3","darkred","darkviolet","brown3","goldenrod2","blue3","green3","forestgreen"))+
  scale_x_date(date_labels = "%Y", date_breaks = "1 year")
plot_sameday

ggsave(
  plot= plot_sameday,
  filename="repeat_incidental_group.jpeg", path=here::here("output"),
)  
write_csv(df2_Incidental_sameday, here::here("output", "repeat_incidental_group_table.csv"))