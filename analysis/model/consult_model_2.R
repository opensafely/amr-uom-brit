library("ggplot2")
library("data.table")
library("dplyr")
library("tidyverse")
library("MASS")


setwd(here::here("output","measures"))
#setwd("/Users/user/Documents/GitHub/amr-uom-brit/output/measures")
df1=read_rds("monthly_consult_UTI.rds")
df2=read_rds("monthly_consult_LRTI.rds")
df3=read_rds("monthly_consult_URTI.rds")
df4=read_rds("monthly_consult_sinusitis.rds")
df5=read_rds("monthly_consult_otmedia.rds")
df6=read_rds("monthly_consult_ot_externa.rds")


# Negative binomial model (without interaction)_model1
##UTI
m1 <- glm.nb(counts~ offset(log(population))+ covid + month +times + covid*times  , data = df1)
## URTI
m2 <- glm.nb(counts~ offset(log(population))+ covid + month +times + covid*times , data = df2)
## LRTI
m3 <- glm.nb(counts~ offset(log(population))+ covid + month +times + covid*times  , data = df3)
## Sinusitis
m4 <- glm.nb(counts~ offset(log(population))+ covid + month +times + covid*times  , data = df4)
## otitis externa
m5 <- glm.nb(counts~ offset(log(population))+ covid + month +times + covid*times  , data = df5)
## otitis media
m6 <- glm.nb(counts~ offset(log(population))+ covid + month +times + covid*times  , data = df6)


### confidence intervals for the coefficients
(est1 <- cbind(Estimate = coef(m1), confint(m1)))
(est2 <- cbind(Estimate = coef(m2), confint(m2)))
(est3 <- cbind(Estimate = coef(m3), confint(m3)))
(est4 <- cbind(Estimate = coef(m4), confint(m4)))
(est5 <- cbind(Estimate = coef(m5), confint(m5)))
(est6 <- cbind(Estimate = coef(m6), confint(m6)))

### calculate IRR & 95%CI

est1=exp(est1)
est2=exp(est2)
est3=exp(est3)
est4=exp(est4)
est5=exp(est5)
est6=exp(est6)


#### combined results
DF=bind_rows(est1[2,],est2[2,],est3[2,],est4[2,],est5[2,],est6[2,])

DF$Infection=c("UTI","URTI","LRTI","Sinusitis","Otitis externa","Otitis media")
#reorder
DF=DF%>%arrange(Infection)

names(DF)[1]="IRR"
names(DF)[2]="ci_l"
names(DF)[3]="ci_u"


### result_model1
#setting up the basic plot
p1 <- ggplot(data=DF, aes(y=Infection, x=IRR, xmin=ci_l, xmax=ci_u))+ 
  
  #this adds the effect sizes to the plot
  geom_point()+ 
  
  #adds the CIs
  geom_errorbarh(height=.1)+
  
  #adding a vertical line at the effect = 0 mark
  geom_vline(xintercept=1, color="black", linetype="dashed", alpha=.5)+
  
  #thematic stuff
  theme_minimal()+
  theme(text=element_text(family="Times",size=18, color="black"))+
  theme(panel.spacing = unit(1, "lines"))+
  
  labs(
    title = "Consultation Reduction",
    x="IRR (95% CI)"
  )

saveRDS(p1,here::here("output","consult_model2.jpeg"))

# each32 list
model=c(m1,m2,m3,m4,m5,m6)
saveRDS(model,here::here("output","consult_model2.rds"))

