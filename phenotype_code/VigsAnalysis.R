#!/usr/bin/env Rscript

library(viridis)
library(lme4)
library(car)
library(MASS)
library(readxl)
library(multcompView)
library(extrafont)
library(ggpubr)
library(tidyverse)
library(gridExtra)
library(ggplot2)
library(plotrix)
library(plotly)
library(ggpubr)
library(rstatix)
library(FSA)


out_fn <- "results/VigsAnalysis.pdf"
pdf(out_fn, width = 10, height = 10, onefile=TRUE)

#read in data

Summary_Stats_VIGS<-read.csv('Summary_Stats_VIGS.csv',header=TRUE)
#just vigs and natural colors
VIGS_4Treatments <- Summary_Stats_VIGS[Summary_Stats_VIGS$Treatment!="PDS_Silenced",]

# VIGS 4 Independent Treatments Analyses  --------------------------------------------------------------

express<-VIGS_4Treatments_boxplot_expression <- ggplot(VIGS_4Treatments,aes(x=Treatment, y=ddct, fill=Treatment)) +
  geom_boxplot(outlier.shape = NA, alpha=0.6, fill=c("#5605cb","#b29ff9","#666666","#C7C7C7")) +
  coord_cartesian(y=c(0,2)) + labs(x = "Treatment", y="ddcT") +
  geom_jitter(shape=21,fill="white",width=0.1, alpha=0.7)+
  theme_classic()+
  theme(axis.title.x = element_text(vjust = -2))
express

bright<-VIGS_4Treatments_boxplot_expression <- ggplot(VIGS_4Treatments,aes(x=Treatment, y=Av_Total_Int, fill=Treatment)) +
  geom_boxplot(outlier.shape = NA, alpha=0.6, fill=c("#5605cb","#b29ff9","#666666","#C7C7C7")) +
  coord_cartesian(y=c(0,18000)) + labs(x = "Treatment", y="Brightness") +
  geom_jitter(shape=21,fill="white",width=0.1, alpha=0.7)+
  theme_classic()+
  theme(axis.title.x = element_text(vjust = -2))
bright

chroma<-VIGS_4Treatments_boxplot_expression <- ggplot(VIGS_4Treatments,aes(x=Treatment, y=Av_Chroma, fill=Treatment)) +
  geom_boxplot(outlier.shape = NA, alpha=0.6, fill=c("#5605cb","#b29ff9","#666666","#C7C7C7")) +
  coord_cartesian(y=c(0,1)) + labs(x = "Treatment", y="Chroma") +
  geom_jitter(shape=21,fill="white",width=0.1, alpha=0.7)+
  theme_classic()+
  theme(axis.title.x = element_text(vjust = -2))
chroma

#read in HPLC data
Summary_Stats_HPLC<-read.csv('HPLC_data.csv',header=TRUE)
#remove pds
HPLC_4Treatments <- Summary_Stats_HPLC[Summary_Stats_HPLC$Gene_silenced!="PDS",]

HPLC<-HPLC_4Treatments_boxplot_expression <- ggplot(HPLC_4Treatments,aes(x=VIGS_trt, y=anthos.sum, fill=VIGS_trt)) +
  geom_boxplot(outlier.shape = NA, alpha=0.6, fill=c("#5605cb","#b29ff9","#666666","#C7C7C7")) +
  coord_cartesian(y=c(0,2.5)) + labs(x = "Treatment", y="Anthocyanins") +
  geom_jitter(shape=21,fill="white",width=0.1, alpha=0.7)+
  theme_classic()+
  theme(axis.title.x = element_text(vjust = -2))
HPLC

#remove red

HPLCblue_4Treatments <- HPLC_4Treatments[HPLC_4Treatments$Floral_color!="DR",]
HPLC<-HPLCblue_4Treatments_boxplot_expression <- ggplot(HPLCblue_4Treatments,aes(x=VIGS_trt, y=anthos.sum, fill=VIGS_trt)) +
  geom_boxplot(outlier.shape = NA, alpha=0.6, fill=c("#5605cb","#b29ff9","#666666","#C7C7C7")) +
  coord_cartesian(y=c(0,2)) + labs(x = "Treatment", y="Anthocyanins") +
  geom_jitter(shape=21,fill="white",width=0.1, alpha=0.7)+
  theme_classic()+
  theme(axis.title.x = element_text(vjust = -2))
HPLC

ggarrange(express,bright,chroma,HPLC, ncol = 2, nrow = 2, align = "h",widths = c(1, 1))

### anovas
#Brightness silenced/unsilenced
VIGS_unTreatments <- Summary_Stats_VIGS[Summary_Stats_VIGS$Treatment!="Myb1_Unsilenced",]
VIGS_sTreatments <- Summary_Stats_VIGS[Summary_Stats_VIGS$Treatment!="Myb1_Silenced",]


VIGS_unTreatments_brightness_ANOVA<-aov(VIGS_unTreatments$Av_Total_Int~VIGS_unTreatments$Treatment)
summary(VIGS_unTreatments_brightness_ANOVA)

VIGS_sTreatments_brightness_ANOVA<-aov(VIGS_sTreatments$Av_Total_Int~VIGS_sTreatments$Treatment)
summary(VIGS_sTreatments_brightness_ANOVA)



#Hplc anoths
Summary_StatsB_HPLC <- Summary_Stats_HPLC[Summary_Stats_HPLC$Floral_color!="DR",]

HPLC_sTreatments<-Summary_StatsB_HPLC[Summary_StatsB_HPLC$VIGS_trt!="Auninfected",]
HPLC_unTreatments<-Summary_StatsB_HPLC[Summary_StatsB_HPLC$VIGS_trt!="Binfected",]


HPLC_unTreatments_HPLC_ANOVA<-aov(HPLC_unTreatments$anthos.sum~HPLC_unTreatments$VIGS_trt)
summary(HPLC_unTreatments_HPLC_ANOVA)
HPLC_sTreatments_HPLC_ANOVA<-aov(HPLC_sTreatments$anthos.sum~HPLC_sTreatments$VIGS_trt)
summary(HPLC_sTreatments_HPLC_ANOVA)

HPLC_sTreatments_HPLC_ANOVA_tuk <-TukeyHSD(HPLC_sTreatments_HPLC_ANOVA)
HPLC_sTreatments_HPLC_ANOVA_tuk
HPLC_unTreatments_HPLC_ANOVA_tuk <-TukeyHSD(HPLC_unTreatments_HPLC_ANOVA)
HPLC_unTreatments_HPLC_ANOVA_tuk

#paired silence vs unsilenced:
VIGS_2Paired.3<-VIGS_4Treatments[VIGS_4Treatments$Treatment != "Dark",]
VIGS_2Paired.3<-VIGS_2Paired.3[VIGS_2Paired.3$Treatment != "Light",]
VIGS_2Paired_expression_ANOVA <- aov(VIGS_2Paired.3$ddct~VIGS_2Paired.3$Treatment+Error(factor(VIGS_2Paired.3$Individual)))
summary(VIGS_2Paired_expression_ANOVA)

VIGS_2Paired_ddct_ANOVA <- aov(VIGS_2Paired.3$ddct~VIGS_2Paired.3$Treatment+Error(factor(VIGS_2Paired.3$Individual)))
summary(VIGS_2Paired_ddct_ANOVA)
express2anova<-lmer(VIGS_2Paired.3$ddct~VIGS_2Paired.3$Treatment + (1|VIGS_2Paired.3$Individual))
Anova(express2anova)

VIGS_2Paired_int_ANOVA <- aov((VIGS_2Paired.3$Intensity_Axis* 1e6)~VIGS_2Paired.3$Treatment+Error(factor(VIGS_2Paired.3$Individual)))
summary(VIGS_2Paired_int_ANOVA)
Bright2anova<-lmer(VIGS_2Paired.3$Intensity_Axis~VIGS_2Paired.3$Treatment + (1|VIGS_2Paired.3$Individual))
Anova(Bright2anova)

VIGS_2Paired_Color_ANOVA <- aov((VIGS_2Paired.3$Av_Chroma)~VIGS_2Paired.3$Treatment+Error(factor(VIGS_2Paired.3$Individual))) 
summary(VIGS_2Paired_Color_ANOVA)
chrom2anova<-lmer(VIGS_2Paired.3$Av_Chroma~VIGS_2Paired.3$Treatment + (1|VIGS_2Paired.3$Individual))
Anova(chrom2anova)

#HPLC
HPLC_2treat<-HPLC_4Treatments[HPLC_4Treatments$VIGS_trt != "DNatlight",]
HPLC_2treat<-HPLC_2treat[HPLC_2treat$VIGS_trt != "CNatdark",]
HPLC_2treat<-HPLC_2treat[HPLC_2treat$Floral_color != "DR",]

HPLC_2treat_ANOVA <- aov(HPLC_2treat$anthos.sum~HPLC_2treat$VIGS_trt+Error(factor(HPLC_2treat$Plant_ID)))
summary(HPLC_2treat_ANOVA)

hplcvig<-lmer(HPLC_2treat$anthos.sum~HPLC_2treat$VIGS_trt+ (1|HPLC_2treat$Plant_ID))
Anova(hplcvig)

##### PDS analysis in supplemental data

VIGS_4Treatments_brightness_ANOVA<-aov(VIGS_4Treatments$Av_Total_Int~VIGS_4Treatments$Treatment)
summary(VIGS_4Treatments_brightness_ANOVA)
plot(VIGS_4Treatments_brightness_ANOVA$residuals)
VIGS_4Treatments_brightness_ANOVA_tuk <-TukeyHSD(VIGS_4Treatments_brightness_ANOVA)
VIGS_4Treatments_brightness_ANOVA_tuk

#                                 diff       lwr         upr     p adj
# Light-Dark                  6890.836  5700.762  8080.91030 0.0000000
# Myb1_Silenced-Dark          3025.106  1920.764  4129.44837 0.0000000
# PDS_Silenced-Dark          -1319.069 -2595.282   -42.85651 0.0402869
# Myb1_Silenced-Light        -3865.730 -4970.072 -2761.38759 0.0000000
# PDS_Silenced-Light         -8209.905 -9486.118 -6933.69246 0.0000000
# PDS_Silenced-Myb1_Silenced -4344.175 -5540.843 -3147.50757 0.0000000

# ANOVA - just because its "robust to violations"
VIGS_4Treatments_chroma_ANOVA<-aov(VIGS_4Treatments$Av_Chroma~VIGS_4Treatments$Treatment)
summary(VIGS_4Treatments_chroma_ANOVA)
plot(VIGS_4Treatments_chroma_ANOVA$residuals)
VIGS_4Treatments_chroma_ANOVA_tuk <-TukeyHSD(VIGS_4Treatments_chroma_ANOVA)
VIGS_4Treatments_chroma_ANOVA_tuk

#                             diff        lwr        upr     p adj
#Light-Dark                 -0.35083165 -0.4366847 -0.2649786 0.0000000
#Myb1_Silenced-Dark         -0.20127589 -0.2809441 -0.1216076 0.0000001
#PDS_Silenced-Dark           0.04103464 -0.0510325  0.1331018 0.6393515
#Myb1_Silenced-Light         0.14955576  0.0698875  0.2292240 0.0000448
#PDS_Silenced-Light          0.39186629  0.2997992  0.4839334 0.0000000
#PDS_Silenced-Myb1_Silenced  0.24231053  0.1559818  0.3286392 0.0000000

# ANOVA - just because its "robust to violations"
VIGS_4Treatments_color_ANOVA<-aov(VIGS_4Treatments$Intensity_Axis~VIGS_4Treatments$Treatment)
summary(VIGS_4Treatments_color_ANOVA)
plot(VIGS_4Treatments_color_ANOVA$residuals)
VIGS_4Treatments_color_ANOVA_tuk <-TukeyHSD(VIGS_4Treatments_color_ANOVA)
VIGS_4Treatments_color_ANOVA_tuk

# here we see we call all groups as sig different

#                             Df    Sum Sq  Mean Sq F value Pr(>F)    
#  VIGS_4Treatments$Treatment  3 4.290e-08 1.43e-08   64.64 <2e-16 ***
#  Residuals                  50 1.106e-08 2.21e-10     

#Fit: aov(formula = VIGS_4Treatments$Intensity_Axis ~ VIGS_4Treatments$Treatment)

#$`VIGS_4Treatments$Treatment`
#                                diff           lwr           upr     p adj
# Light-Dark                 -5.812049e-05 -7.362544e-05 -4.261555e-05 0.0000000 ***
# Myb1_Silenced-Dark         -3.791581e-05 -5.230379e-05 -2.352784e-05 0.0000000 ***
# PDS_Silenced-Dark           1.699748e-05  3.702846e-07  3.362468e-05 0.0433553 ***
# Myb1_Silenced-Light         2.020468e-05  5.816706e-06  3.459266e-05 0.0026594 ***
# PDS_Silenced-Light          7.511798e-05  5.849078e-05  9.174517e-05 0.0000000 ***
# PDS_Silenced-Myb1_Silenced  5.491329e-05  3.932245e-05  7.050414e-05 0.0000000 ***

# according to the internet, unequal variances tends to lead to type I error in an ANOVA, 
# rejecting the null when it came about by pure chance ( false positive )

VIGS_4Treatments_Expression_ANOVA<-aov(VIGS_4Treatments$ddct~VIGS_4Treatments$Treatment)
summary(VIGS_4Treatments_Expression_ANOVA)
plot(VIGS_4Treatments_Expression_ANOVA$residuals)

# Tukey Test
VIGS_4Treatments_Expression_ANOVA_tuk <-TukeyHSD(VIGS_4Treatments_Expression_ANOVA)
VIGS_4Treatments_Expression_ANOVA_tuk
# Lovely!
# Says Light and Myb Silenced and Dark and PDS are two similar groups distinct from each other by ***

#     $`VIGS_4Treatments$Category`
#                             diff       lwr        upr       p adj
# Light-Dark                 -0.5937174 -0.9057304 -0.2817044 0.0000354
# Myb1_Silenced-Dark         -0.7153714 -1.0049072 -0.4258356 0.0000002
# PDS_Silenced-Dark           0.2300090 -0.1045876  0.5646057 0.2730453
# Myb1_Silenced-Light        -0.1216540 -0.4111898  0.1678818 0.6810898
# PDS_Silenced-Light          0.8237264  0.4891298  1.1583231 0.0000002
# PDS_Silenced-Myb1_Silenced  0.9453804  0.6316388  1.2591220 0.0000000


# Expression Boxplot

# get letters for sig differences between tratments from our anova and tukey 
VIGS_4Treatments_Expression_ANOVA_cld <- multcompLetters4(VIGS_4Treatments_Expression_ANOVA, VIGS_4Treatments_Expression_ANOVA_tuk)
#making a new dataframe based on letter displays for VIGS_4Treatments$Category
VIGS_4Treatments_Expression_ANOVA_cld2<- as.data.frame.list(VIGS_4Treatments_Expression_ANOVA_cld$`VIGS_4Treatments$Treatment`)
VIGS_4Treatments_Expression_ANOVA_cld2

#make a dataframe for annotations, this will be called separately latter, get the 3rd quantile for plotting location
VIGS_4_annot <- group_by(VIGS_4Treatments, Treatment) %>%
  summarise(q3 = (quantile(ddct, prob=c(0.75), type=1))) %>%
  arrange(Treatment)
VIGS_4_annot
VIGS_4_annot$group <-VIGS_4Treatments_Expression_ANOVA_cld2$Letters[match(VIGS_4_annot$Treatment,row.names(VIGS_4Treatments_Expression_ANOVA_cld2))];
VIGS_4_annot

#plot again but with significance
VIGS_4Treatments_boxplot_expression <- ggplot(VIGS_4Treatments,aes(x=Treatment, y=ddct, fill=Treatment)) +
  geom_boxplot(outlier.shape = NA, alpha=0.6, fill=c("darkslateblue","lightslateblue","white","mediumseagreen")) +
  coord_cartesian(y=c(0,2)) + labs(x = "Treatment", y="ddcT") +
  theme_classic()+
  theme(axis.title.x = element_text(vjust = -2))
A <- VIGS_4Treatments_boxplot_expression
A <- VIGS_4Treatments_boxplot_expression +  geom_text(data = VIGS_4_annot , 
                                                      aes(x = factor(Treatment), y = q3 + 0.05, label = group), 
                                                      nudge_x = .25)
A 


# get letters for sig differences between tratments from our anova and tukey 
VIGS_4Treatments_color_ANOVA_cld <- multcompLetters4(VIGS_4Treatments_color_ANOVA, VIGS_4Treatments_color_ANOVA_tuk)
#making a new dataframe based on letter displays for VIGS_4Treatments$Category
VIGS_4Treatments_color_ANOVA_cld2<- as.data.frame.list(VIGS_4Treatments_color_ANOVA_cld$`VIGS_4Treatments$Treatment`)
VIGS_4Treatments_color_ANOVA_cld2

#make a dataframe for annotations, this will be called separately latter, get the 3rd quantile for plotting location
VIGS_4_annot_color <- group_by(VIGS_4Treatments, Treatment) %>%
  summarise(q3 = (quantile(Intensity_Axis, prob=c(0.75), type=1))) %>%
  arrange(Treatment)
VIGS_4_annot_color
VIGS_4_annot_color$group <-VIGS_4Treatments_color_ANOVA_cld2$Letters[match(VIGS_4_annot_color$Treatment,row.names(VIGS_4Treatments_color_ANOVA_cld2))];
VIGS_4_annot_color

VIGS_4Treatments_boxplot_color <- ggplot(VIGS_4Treatments, aes(x=Treatment, y=(Intensity_Axis*10000), fill=Treatment)) + 
  geom_boxplot(outlier.shape = NA, alpha=0.6, col="black",fill=c("darkslateblue","lightslateblue","white","mediumseagreen")) +
  theme_classic()  + labs(x = "Treatment", y="Intensity Axis - chroma/brightness x10000 for scale") + 
  theme(axis.title.x = element_text(vjust = -2))
VIGS_4Treatments_boxplot_color 
B <- VIGS_4Treatments_boxplot_color +  geom_text(data = VIGS_4_annot_color , 
                                                 aes(x = factor(Treatment), y = (q3*10000+ 0.05), label = group), 
                                                 nudge_x = .25)
B 


# get letters for sig differences between tratments from our anova and tukey 
VIGS_4Treatments_brightness_ANOVA_cld <- multcompLetters4(VIGS_4Treatments_brightness_ANOVA, VIGS_4Treatments_brightness_ANOVA_tuk)
#making a new dataframe based on letter displays for VIGS_4Treatments$Category
VIGS_4Treatments_brightness_ANOVA_cld2<- as.data.frame.list(VIGS_4Treatments_brightness_ANOVA_cld$`VIGS_4Treatments$Treatment`)
VIGS_4Treatments_brightness_ANOVA_cld2

#make a dataframe for annotations, this will be called separately latter, get the 3rd quantile for plotting location
VIGS_4_annot_brightness <- group_by(VIGS_4Treatments, Treatment) %>%
  summarise(q3 = (quantile(Av_Total_Int, prob=c(0.75), type=1))) %>%
  arrange(Treatment)
VIGS_4_annot_brightness
VIGS_4_annot_brightness$group <-VIGS_4Treatments_brightness_ANOVA_cld2$Letters[match(VIGS_4_annot_color$Treatment,row.names(VIGS_4Treatments_brightness_ANOVA_cld2))];
VIGS_4_annot_brightness

VIGS_4Treatments_boxplot_brightness <- ggplot(VIGS_4Treatments, aes(x=Treatment, y=(Av_Total_Int/1000), fill=Treatment)) + 
  geom_boxplot(outlier.shape = NA, alpha=0.6, col="black",fill=c("darkslateblue","lightslateblue","white","mediumseagreen")) +
  theme_classic() + coord_cartesian(y=c(5,20))+ labs(x = "Treatment", y=" Total Brightness ( /1000)") + 
  theme(axis.title.x = element_text(vjust = -2))
M<- VIGS_4Treatments_boxplot_brightness 
M <- VIGS_4Treatments_boxplot_brightness+  geom_text(data = VIGS_4_annot_brightness , 
                                                     aes(x = factor(Treatment), y = (q3/1000 + 0.5), label = group), 
                                                     nudge_x = .25)
M



# get letters for sig differences between tratments from our anova and tukey 
VIGS_4Treatments_chroma_ANOVA_cld <- multcompLetters4(VIGS_4Treatments_chroma_ANOVA, VIGS_4Treatments_chroma_ANOVA_tuk)
#making a new dataframe based on letter displays for VIGS_4Treatments$Category
VIGS_4Treatments_chroma_ANOVA_cld2<- as.data.frame.list(VIGS_4Treatments_chroma_ANOVA_cld$`VIGS_4Treatments$Treatment`)
VIGS_4Treatments_chroma_ANOVA_cld2

#make a dataframe for annotations, this will be called separately latter, get the 3rd quantile for plotting location
VIGS_4_annot_chroma <- group_by(VIGS_4Treatments, Treatment) %>%
  summarise(q3 = (quantile(Av_Chroma, prob=c(0.75), type=1))) %>%
  arrange(Treatment)
VIGS_4_annot_chroma
VIGS_4_annot_chroma$group <-VIGS_4Treatments_chroma_ANOVA_cld2$Letters[match(VIGS_4_annot_color$Treatment,row.names(VIGS_4Treatments_chroma_ANOVA_cld2))];
VIGS_4_annot_chroma

VIGS_4Treatments_boxplot_chroma <- ggplot(VIGS_4Treatments, aes(x=Treatment, y=Av_Chroma, fill=Treatment)) + 
  geom_boxplot(outlier.shape = NA, alpha=0.6, col="black",fill=c("darkslateblue","lightslateblue","white","mediumseagreen")) +
  theme_classic() + coord_cartesian(y=c(0.2,1))+ labs(x = "Treatment") + 
  theme(axis.title.x = element_text(vjust = -2))
N <- VIGS_4Treatments_boxplot_chroma 
N <- VIGS_4Treatments_boxplot_chroma+  geom_text(data = VIGS_4_annot_chroma , 
                                                 aes(x = factor(Treatment), y = q3 + 0.05, label = group), 
                                                 nudge_x = .25)
N

ggarrange(A,B,M,N, ncol = 2, nrow = 2, align = "h",widths = c(1, 1))
dev.off()


