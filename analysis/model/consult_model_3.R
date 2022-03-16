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
m01 <- glm.nb(counts~ offset(log(population))+ covid + month +times , data = df1)
## URTI
m02 <- glm.nb(counts~ offset(log(population))+ covid + month +times , data = df2)
## LRTI
m03 <- glm.nb(counts~ offset(log(population))+ covid + month +times , data = df3)
## Sinusitis
m04 <- glm.nb(counts~ offset(log(population))+ covid + month +times , data = df4)
## otitis externa
m05 <- glm.nb(counts~ offset(log(population))+ covid + month +times , data = df5)
## otitis media
m06 <- glm.nb(counts~ offset(log(population))+ covid + month +times , data = df6)


# updated models plus residuals
m1 <- glm.nb(counts~ offset(log(population))+ covid + month +times + m01$residuals, data = df1)
## URTI
m2 <- glm.nb(counts~ offset(log(population))+ covid + month +times + m02$residuals, data = df2)
## LRTI
m3 <- glm.nb(counts~ offset(log(population))+ covid + month +times + m03$residuals, data = df3)
## Sinusitis
m4 <- glm.nb(counts~ offset(log(population))+ covid + month +times + m04$residuals, data = df4)
## otitis externa
m5 <- glm.nb(counts~ offset(log(population))+ covid + month +times + m05$residuals, data = df5)
## otitis media
m6 <- glm.nb(counts~ offset(log(population))+ covid + month +times + m06$residuals, data = df6)

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


### select covid predictor(IRR, 95%CI)
est1=as.data.frame(est1)
est1=est1[2,]
est1$Infection="UTI"

est2=as.data.frame(est2)
est2=est2[2,]
est2$Infection="LRTI"

est3=as.data.frame(est3)
est3=est3[2,]
est3$Infection="URTI"

est4=as.data.frame(est4)
est4=est4[2,]
est4$Infection="Sinusitis"

est5=as.data.frame(est5)
est5=est5[2,]
est5$Infection="Otitis externa"

est6=as.data.frame(est6)
est6=est6[2,]
est6$Infection="Otitis media"

# combine results and remove null 
DF <- vector("list", 6)
DF[[1]]= est1
DF[[2]]= est2
DF[[3]]= est3
DF[[4]]= est4
DF[[5]]= est5
DF[[6]]= est6
DF <- DF[!sapply(DF,is.null)]

#### combined results
DF=bind_rows(DF)


#reorder
DF=DF%>%arrange(Infection)

names(DF)[1]="IRR"
names(DF)[2]="ci_l"
names(DF)[3]="ci_u"


### result_model1
#setting up the basic plot
p3 <- ggplot(data=DF, aes(y=Infection, x=IRR, xmin=ci_l, xmax=ci_u))+ 
  
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

saveRDS(p1,here::here("output","consult_model3.jpeg"))

# each32 list
model=c(m1,m2,m3,m4,m5,m6)
saveRDS(model,here::here("output","consult_model3.rds"))

