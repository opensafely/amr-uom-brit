##############
## count number of prescriptions per antibiotic type, use bar chart to show the probation of types
##############
#source("analysis/plot/types_ab_prescriptions.R", encoding = "utf-8")
#Sys.setlocale(category = "LC_ALL", locale = "us")
#stri_enc_toutf8(str, is_unknown_8bit = FALSE, validate = FALSE)
### 1. import patient-level data to summarize antibiotics counts ###
library("data.table")
library("dplyr")
library("here")
library("tidyverse")
rm(list=ls())

setwd(here::here("output", "measures"))
#setwd("/Users/yayang/Documents/GitHub/amr-uom-brit/output/measures")

# read flie list from input.csv
csvFiles = list.files(pattern="input_20", full.names = TRUE)
data <- vector("list", length(csvFiles))

for (i in seq_along(csvFiles)){
  data[[i]] <- read_csv(csvFiles[i],
                        
                        col_types = cols_only(
                          
                          # Identifier
                          practice = col_integer(),
                          
                          # Outcomes
                          Rx_Amikacin=col_double(),
                          Rx_Amoxicillin=col_double(),
                          Rx_Ampicillin=col_double(),
                          Rx_Azithromycin=col_double(),
                          Rx_Aztreonam=col_double(),
                          Rx_Benzylpenicillin=col_double(),
                          Rx_Cefaclor=col_double(),
                          Rx_Cefadroxil=col_double(),
                          Rx_Cefalexin=col_double(),
                          Rx_Cefamandole=col_double(),
                          Rx_Cefazolin=col_double(),
                          Rx_Cefepime=col_double(),
                          Rx_Cefixime=col_double(),
                          Rx_Cefotaxime=col_double(),
                          Rx_Cefoxitin=col_double(),
                          Rx_Cefpirome=col_double(),
                          Rx_Cefpodoxime=col_double(),
                          Rx_Cefprozil=col_double(),
                          Rx_Cefradine=col_double(),
                          Rx_Ceftazidime=col_double(),
                          Rx_Ceftriaxone=col_double(),
                          Rx_Cefuroxime=col_double(),
                          Rx_Chloramphenicol=col_double(),
                          Rx_Cilastatin=col_double(),
                          Rx_Ciprofloxacin=col_double(),
                          Rx_Clarithromycin=col_double(),
                          Rx_Clindamycin=col_double(),
                          Rx_Co_amoxiclav=col_double(),
                          Rx_Co_fluampicil=col_double(),
                          Rx_Colistimethate=col_double(),
                          Rx_Dalbavancin=col_double(),
                          Rx_Dalfopristin=col_double(),
                          Rx_Daptomycin=col_double(),
                          Rx_Demeclocycline=col_double(),
                          Rx_Doripenem=col_double(),
                          Rx_Doxycycline=col_double(),
                          Rx_Ertapenem=col_double(),
                          Rx_Erythromycin=col_double(),
                          Rx_Fidaxomicin=col_double(),
                          Rx_Flucloxacillin=col_double(),
                          Rx_Fosfomycin=col_double(),
                          Rx_Fusidate=col_double(),
                          Rx_Gentamicin=col_double(),
                          Rx_Levofloxacin=col_double(),
                          Rx_Linezolid=col_double(),
                          Rx_Lymecycline=col_double(),
                          Rx_Meropenem=col_double(),
                          Rx_Methenamine=col_double(),
                          Rx_Metronidazole=col_double(),
                          Rx_Minocycline=col_double(),
                          Rx_Moxifloxacin=col_double(),
                          Rx_Nalidixic_acid=col_double(),
                          Rx_Neomycin=col_double(),
                          Rx_Netilmicin=col_double(),
                          Rx_Nitazoxanid=col_double(),
                          Rx_Nitrofurantoin=col_double(),
                          Rx_Norfloxacin=col_double(),
                          Rx_Ofloxacin=col_double(),
                          Rx_Oxytetracycline=col_double(),
                          Rx_Phenoxymethylpenicillin=col_double(),
                          Rx_Piperacillin=col_double(),
                          Rx_Pivmecillinam=col_double(),
                          Rx_Pristinamycin=col_double(),
                          Rx_Rifaximin=col_double(),
                          Rx_Sulfadiazine=col_double(),
                          Rx_Sulfamethoxazole=col_double(),
                          Rx_Sulfapyridine=col_double(),
                          Rx_Taurolidin=col_double(),
                          Rx_Tedizolid=col_double(),
                          Rx_Teicoplanin=col_double(),
                          Rx_Telithromycin=col_double(),
                          Rx_Temocillin=col_double(),
                          Rx_Tetracycline=col_double(),
                          Rx_Ticarcillin=col_double(),
                          Rx_Tigecycline=col_double(),
                          Rx_Tinidazole=col_double(),
                          Rx_Tobramycin=col_double(),
                          Rx_Trimethoprim=col_double(),
                          Rx_Vancomycin=col_double()
                          
                        ),
                        na = character()
  )
}

# total months to input
n=length(csvFiles) 
# remove temopary list
rm(csvFiles,i)

# select valid practice number
#data2 <- data %>% filter(practice >0)



### 2. summarise total number of Rx per month ###
## crosstable: month X Rx ##

# #empty tables to paste 
data.summary=data.frame(matrix(ncol=n,nrow=79))
#totalRxcross-tables
for(i in 1:n){
data.summary[1,i]=data[[i]]%>%summarise(sum(Rx_Amikacin,na.rm=T))
data.summary[2,i]=data[[i]]%>%summarise(sum(Rx_Amoxicillin,na.rm=T))
data.summary[3,i]=data[[i]]%>%summarise(sum(Rx_Ampicillin,na.rm=T))
data.summary[4,i]=data[[i]]%>%summarise(sum(Rx_Azithromycin,na.rm=T))
data.summary[5,i]=data[[i]]%>%summarise(sum(Rx_Aztreonam,na.rm=T))
data.summary[6,i]=data[[i]]%>%summarise(sum(Rx_Benzylpenicillin,na.rm=T))
data.summary[7,i]=data[[i]]%>%summarise(sum(Rx_Cefaclor,na.rm=T))
data.summary[8,i]=data[[i]]%>%summarise(sum(Rx_Cefadroxil,na.rm=T))
data.summary[9,i]=data[[i]]%>%summarise(sum(Rx_Cefalexin,na.rm=T))
data.summary[10,i]=data[[i]]%>%summarise(sum(Rx_Cefamandole,na.rm=T))
data.summary[11,i]=data[[i]]%>%summarise(sum(Rx_Cefazolin,na.rm=T))
data.summary[12,i]=data[[i]]%>%summarise(sum(Rx_Cefepime,na.rm=T))
data.summary[13,i]=data[[i]]%>%summarise(sum(Rx_Cefixime,na.rm=T))
data.summary[14,i]=data[[i]]%>%summarise(sum(Rx_Cefotaxime,na.rm=T))
data.summary[15,i]=data[[i]]%>%summarise(sum(Rx_Cefoxitin,na.rm=T))
data.summary[16,i]=data[[i]]%>%summarise(sum(Rx_Cefpirome,na.rm=T))
data.summary[17,i]=data[[i]]%>%summarise(sum(Rx_Cefpodoxime,na.rm=T))
data.summary[18,i]=data[[i]]%>%summarise(sum(Rx_Cefprozil,na.rm=T))
data.summary[19,i]=data[[i]]%>%summarise(sum(Rx_Cefradine,na.rm=T))
data.summary[20,i]=data[[i]]%>%summarise(sum(Rx_Ceftazidime,na.rm=T))
data.summary[21,i]=data[[i]]%>%summarise(sum(Rx_Ceftriaxone,na.rm=T))
data.summary[22,i]=data[[i]]%>%summarise(sum(Rx_Cefuroxime,na.rm=T))
data.summary[23,i]=data[[i]]%>%summarise(sum(Rx_Chloramphenicol,na.rm=T))
data.summary[24,i]=data[[i]]%>%summarise(sum(Rx_Cilastatin,na.rm=T))
data.summary[25,i]=data[[i]]%>%summarise(sum(Rx_Ciprofloxacin,na.rm=T))
data.summary[26,i]=data[[i]]%>%summarise(sum(Rx_Clarithromycin,na.rm=T))
data.summary[27,i]=data[[i]]%>%summarise(sum(Rx_Clindamycin,na.rm=T))
data.summary[28,i]=data[[i]]%>%summarise(sum(Rx_Co_amoxiclav,na.rm=T))
data.summary[29,i]=data[[i]]%>%summarise(sum(Rx_Co_fluampicil,na.rm=T))
data.summary[30,i]=data[[i]]%>%summarise(sum(Rx_Colistimethate,na.rm=T))
data.summary[31,i]=data[[i]]%>%summarise(sum(Rx_Dalbavancin,na.rm=T))
data.summary[32,i]=data[[i]]%>%summarise(sum(Rx_Dalfopristin,na.rm=T))
data.summary[33,i]=data[[i]]%>%summarise(sum(Rx_Daptomycin,na.rm=T))
data.summary[34,i]=data[[i]]%>%summarise(sum(Rx_Demeclocycline,na.rm=T))
data.summary[35,i]=data[[i]]%>%summarise(sum(Rx_Doripenem,na.rm=T))
data.summary[36,i]=data[[i]]%>%summarise(sum(Rx_Doxycycline,na.rm=T))
data.summary[37,i]=data[[i]]%>%summarise(sum(Rx_Ertapenem,na.rm=T))
data.summary[38,i]=data[[i]]%>%summarise(sum(Rx_Erythromycin,na.rm=T))
data.summary[39,i]=data[[i]]%>%summarise(sum(Rx_Fidaxomicin,na.rm=T))
data.summary[40,i]=data[[i]]%>%summarise(sum(Rx_Flucloxacillin,na.rm=T))
data.summary[41,i]=data[[i]]%>%summarise(sum(Rx_Fosfomycin,na.rm=T))
data.summary[42,i]=data[[i]]%>%summarise(sum(Rx_Fusidate,na.rm=T))
data.summary[43,i]=data[[i]]%>%summarise(sum(Rx_Gentamicin,na.rm=T))
data.summary[44,i]=data[[i]]%>%summarise(sum(Rx_Levofloxacin,na.rm=T))
data.summary[45,i]=data[[i]]%>%summarise(sum(Rx_Linezolid,na.rm=T))
data.summary[46,i]=data[[i]]%>%summarise(sum(Rx_Lymecycline,na.rm=T))
data.summary[47,i]=data[[i]]%>%summarise(sum(Rx_Meropenem,na.rm=T))
data.summary[48,i]=data[[i]]%>%summarise(sum(Rx_Methenamine,na.rm=T))
data.summary[49,i]=data[[i]]%>%summarise(sum(Rx_Metronidazole,na.rm=T))
data.summary[50,i]=data[[i]]%>%summarise(sum(Rx_Minocycline,na.rm=T))
data.summary[51,i]=data[[i]]%>%summarise(sum(Rx_Moxifloxacin,na.rm=T))
data.summary[52,i]=data[[i]]%>%summarise(sum(Rx_Nalidixic_acid,na.rm=T))
data.summary[53,i]=data[[i]]%>%summarise(sum(Rx_Neomycin,na.rm=T))
data.summary[54,i]=data[[i]]%>%summarise(sum(Rx_Netilmicin,na.rm=T))
data.summary[55,i]=data[[i]]%>%summarise(sum(Rx_Nitazoxanid,na.rm=T))
data.summary[56,i]=data[[i]]%>%summarise(sum(Rx_Nitrofurantoin,na.rm=T))
data.summary[57,i]=data[[i]]%>%summarise(sum(Rx_Norfloxacin,na.rm=T))
data.summary[58,i]=data[[i]]%>%summarise(sum(Rx_Ofloxacin,na.rm=T))
data.summary[59,i]=data[[i]]%>%summarise(sum(Rx_Oxytetracycline,na.rm=T))
data.summary[60,i]=data[[i]]%>%summarise(sum(Rx_Phenoxymethylpenicillin,na.rm=T))
data.summary[61,i]=data[[i]]%>%summarise(sum(Rx_Piperacillin,na.rm=T))
data.summary[62,i]=data[[i]]%>%summarise(sum(Rx_Pivmecillinam,na.rm=T))
data.summary[63,i]=data[[i]]%>%summarise(sum(Rx_Pristinamycin,na.rm=T))
data.summary[64,i]=data[[i]]%>%summarise(sum(Rx_Rifaximin,na.rm=T))
data.summary[65,i]=data[[i]]%>%summarise(sum(Rx_Sulfadiazine,na.rm=T))
data.summary[66,i]=data[[i]]%>%summarise(sum(Rx_Sulfamethoxazole,na.rm=T))
data.summary[67,i]=data[[i]]%>%summarise(sum(Rx_Sulfapyridine,na.rm=T))
data.summary[68,i]=data[[i]]%>%summarise(sum(Rx_Taurolidin,na.rm=T))
data.summary[69,i]=data[[i]]%>%summarise(sum(Rx_Tedizolid,na.rm=T))
data.summary[70,i]=data[[i]]%>%summarise(sum(Rx_Teicoplanin,na.rm=T))
data.summary[71,i]=data[[i]]%>%summarise(sum(Rx_Telithromycin,na.rm=T))
data.summary[72,i]=data[[i]]%>%summarise(sum(Rx_Temocillin,na.rm=T))
data.summary[73,i]=data[[i]]%>%summarise(sum(Rx_Tetracycline,na.rm=T))
data.summary[74,i]=data[[i]]%>%summarise(sum(Rx_Ticarcillin,na.rm=T))
data.summary[75,i]=data[[i]]%>%summarise(sum(Rx_Tigecycline,na.rm=T))
data.summary[76,i]=data[[i]]%>%summarise(sum(Rx_Tinidazole,na.rm=T))
data.summary[77,i]=data[[i]]%>%summarise(sum(Rx_Tobramycin,na.rm=T))
data.summary[78,i]=data[[i]]%>%summarise(sum(Rx_Trimethoprim,na.rm=T))
data.summary[79,i]=data[[i]]%>%summarise(sum(Rx_Vancomycin,na.rm=T))
}


rm(data)

# add colname & rowname
list.ab=c("codes_ab_type_Amikacin.csv", "codes_ab_type_Amoxicillin.csv", "codes_ab_type_Ampicillin.csv", "codes_ab_type_Azithromycin.csv", "codes_ab_type_Aztreonam.csv", "codes_ab_type_Benzylpenicillin.csv", "codes_ab_type_Cefaclor.csv", "codes_ab_type_Cefadroxil.csv", "codes_ab_type_Cefalexin.csv", "codes_ab_type_Cefamandole.csv", "codes_ab_type_Cefazolin.csv", "codes_ab_type_Cefepime.csv", "codes_ab_type_Cefixime.csv", "codes_ab_type_Cefotaxime.csv", "codes_ab_type_Cefoxitin.csv", "codes_ab_type_Cefpirome.csv", "codes_ab_type_Cefpodoxime.csv", "codes_ab_type_Cefprozil.csv", "codes_ab_type_Cefradine.csv", "codes_ab_type_Ceftazidime.csv", "codes_ab_type_Ceftriaxone.csv", "codes_ab_type_Cefuroxime.csv", "codes_ab_type_Chloramphenicol.csv", "codes_ab_type_Cilastatin.csv", "codes_ab_type_Ciprofloxacin.csv", "codes_ab_type_Clarithromycin.csv", "codes_ab_type_Clindamycin.csv", "codes_ab_type_Co_amoxiclav.csv", "codes_ab_type_Co_fluampicil.csv", "codes_ab_type_Colistimethate.csv", "codes_ab_type_Dalbavancin.csv", "codes_ab_type_Dalfopristin.csv", "codes_ab_type_Daptomycin.csv", "codes_ab_type_Demeclocycline.csv", "codes_ab_type_Doripenem.csv", "codes_ab_type_Doxycycline.csv", "codes_ab_type_Ertapenem.csv", "codes_ab_type_Erythromycin.csv", "codes_ab_type_Fidaxomicin.csv", "codes_ab_type_Flucloxacillin.csv", "codes_ab_type_Fosfomycin.csv", "codes_ab_type_Fusidate.csv", "codes_ab_type_Gentamicin.csv", "codes_ab_type_Levofloxacin.csv", "codes_ab_type_Linezolid.csv", "codes_ab_type_Lymecycline.csv", "codes_ab_type_Meropenem.csv", "codes_ab_type_Methenamine.csv", "codes_ab_type_Metronidazole.csv", "codes_ab_type_Minocycline.csv", "codes_ab_type_Moxifloxacin.csv", "codes_ab_type_Nalidixic_acid.csv", "codes_ab_type_Neomycin.csv", "codes_ab_type_Netilmicin.csv", "codes_ab_type_Nitazoxanid.csv", "codes_ab_type_Nitrofurantoin.csv", "codes_ab_type_Norfloxacin.csv", "codes_ab_type_Ofloxacin.csv", "codes_ab_type_Oxytetracycline.csv", "codes_ab_type_Phenoxymethylpenicillin.csv", "codes_ab_type_Piperacillin.csv", "codes_ab_type_Pivmecillinam.csv", "codes_ab_type_Pristinamycin.csv", "codes_ab_type_Rifaximin.csv", "codes_ab_type_Sulfadiazine.csv", "codes_ab_type_Sulfamethoxazole.csv", "codes_ab_type_Sulfapyridine.csv", "codes_ab_type_Taurolidin.csv", "codes_ab_type_Tedizolid.csv", "codes_ab_type_Teicoplanin.csv", "codes_ab_type_Telithromycin.csv", "codes_ab_type_Temocillin.csv", "codes_ab_type_Tetracycline.csv", "codes_ab_type_Ticarcillin.csv", "codes_ab_type_Tigecycline.csv", "codes_ab_type_Tinidazole.csv", "codes_ab_type_Tobramycin.csv", "codes_ab_type_Trimethoprim.csv", "codes_ab_type_Vancomycin.csv")
list.ab=sub("\\.csv", "", list.ab)
list.ab=sub("codes_ab_type_", "", list.ab)

# start month to last month (n month)
list.month=c(seq(as.Date("2019-01-01"), by = "month", length.out = n))

row.names(data.summary)=list.ab
colnames(data.summary)=list.month

# remove temporary list
#rm(i, list, list2, list.month)
#rm(data)


###### 3. transfer to data frame  ########
# gather Rx value per month 
DF=data.summary%>%
  gather(data.summary)%>%
  rename(date=data.summary) #rename colname_data.summary

# create column: ab name
list.ab.n=rep(list.ab,n)
ab.type=data.frame(list.ab.n)

# add ab type to DF
DF=cbind(DF,ab.type)
colnames(DF)[3]="type"


rm(ab.type,data.summary,i,n,list.ab,list.ab.n, list.month)




### select most common ab ###
DF.top10=DF%>%
  group_by(type)%>%
  summarise(value=mean(value))%>% # RX: average per month
  arrange(desc(value))%>%
  slice(1:10)

DF$types=ifelse(DF$type %in% DF.top10$type, DF$type, "others")

### stacked bar chart ###
DF$types <- factor(DF$types, levels=c(DF.top10$type,"others"))# reorder

stackedbar <- 
  ggplot(DF, aes(x=date, y=value, fill=types))+
  geom_bar(position="stack", stat="identity") +
  geom_vline(xintercept = "2020-03-01", linetype="dashed",color = "grey", size=0.5)+
  geom_vline(xintercept = "2020-11-01", linetype="dashed",color = "grey", size=0.5)+
  geom_vline(xintercept = "2021-01-01", linetype="dashed",color = "grey", size=0.5)+
  labs(
    title = "Propotion of antibiotics types",
    x = "Time", 
    y = "number of antibiotic prescriptions")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  scale_fill_brewer(palette = "RdYlBu")



ggsave(
  plot= stackedbar,
  filename="types_ab_barchart.png", path=here::here("output"),
)
