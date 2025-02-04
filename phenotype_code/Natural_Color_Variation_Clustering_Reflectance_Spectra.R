#!/usr/bin/env Rscript

#Script for converting P.drummondii individual specral color data to a format that can be analyzed and plotted


library(tidyverse)
library(gridExtra)
library(ggplot2)
library(plotrix)
library(plotly)
library(ggpubr)
library(reticulate)
library(nortest)

library(cluster)    # clustering algorithms
library(factoextra) # clustering algorithms & visualization
library(mclust)

library(fossil)

library(lme4)
library(car)
library(MASS)
library(readxl)

library(pdfCluster)

Summary_Stats_Admixed_Select <- read.csv("Natural_Color_Variation.csv")

mybdev<-read.table("myb_expression.csv", header = T, sep = ",")
#Going to subset just the admixed individuals from the data 
Summary_Stats_Admixed_Select_2<-subset(Summary_Stats_Admixed_Select,Color_Class!="DR_Sym" & Color_Class!="LB_Allo")
Summary_Stats_Admixed_Select_2

#Quick plot of the data using plotly
p3 <- plot_ly(
  data = Summary_Stats_Admixed_Select_2, x = ~Av_Total_Int, y= ~Av_Adjust_Hue_degrees, z= ~Av_Chroma,
  mode = 'markers',
  opacity = 0.8,
  text=(~Sample),
  sector = c(315,45))
p3



#  Part 2) Describing/Quantifying color


#first ask about distributions along axes using anderson darling test. basically says does the distribution look normal?

#Anderson-Darling normality test
ad.test(Summary_Stats_Admixed_Select_2$Av_Total_Int)
#Anderson-Darling normality test
#data:  Summary_Stats_Admixed_Select_2$Av_Total_Int
#A = 2.8911, p-value = 2.631e-07 -- significantly not normal 

ad.test(Summary_Stats_Admixed_Select_2$Av_Chroma)
#Anderson-Darling normality test
#data:  Summary_Stats_Admixed_Select_2$Av_Chroma
#A = 6.2338, p-value = 2.152e-15 -- significantly not normal 

ad.test(Summary_Stats_Admixed_Select_2$Av_Hue_degrees)
#Anderson-Darling normality test
#data:  Summary_Stats_Admixed_Select_2$Av_Hue_degrees
#A = 18.235, p-value < 2.2e-16 -- significantly not normal 


## Now for modeling our data's best quantitative description using an unsupervised clustering algorithm

### unsupervised clustering of data using mclust
# data is typically prepared so -- rows are observations and columns are variables
# no missing data
# data is standardized

#useful mclust resources / resources on model-based clustering
# https://bradleyboehmke.github.io/HOML/model-clustering.html
# https://www.datanovia.com/en/lessons/model-based-clustering-essentials/
# https://cran.r-project.org/web/packages/mclust/vignettes/mclust.html 


#make clustering df with just variables of interest ( int, hue, chroma )
# Selects columns with the data I want to compare
cluster_df <- Summary_Stats_Admixed_Select_2[,c("Av_Total_Int","Av_Chroma","Av_Adjust_Hue_degrees")]
#drop missing values
cluster_df <- na.omit(cluster_df)
#rescale the data 
cluster_df <- scale(cluster_df)
summary(cluster_df)



#run mclust on scaled data
fit <- Mclust(cluster_df)
summary(fit, parameters=TRUE) # display the best model
#best model identifies 4 components (clusters) under optimal model EEV

#plotting of BIC
fviz_mclust_bic(fit)
fit$BIC #top three results all say 4 components across three different models - that is cool!

pal_friendly_4 <-c("#ffd7d1","#b29ff9","#5605cb","#ec3c30")
# Classification: plot showing clustering and classificvation to clusters based on top probability of membership
#color pal
fviz_mclust(fit, "classification", geom = "point", 
            pointsize = 1.5,palette=pal_friendly_4)
# Classification uncertainty - demonstartes by point size which points have highest uncertainty in membership 
fviz_mclust(fit, "uncertainty",palette=pal_friendly_4)
plot(fit, what = "density")
plot(fit, what = "classification", colors=pal_friendly_4)

#Returnning to the Plotly - Quick plot of the data with best mclust clusters and classification - not the plot used for final figure

plot3d_best_mclust_class <- plot_ly(
  data = Summary_Stats_Admixed_Select_2, x = ~Av_Total_Int, y= ~Av_Adjust_Hue_degrees, z= ~Av_Chroma,
  mode = 'markers',color= fit$classification, colors=pal_friendly_4, symbol=I("cross"),
  opacity = 0.8,
  text=(~Sample),
  sector = c(315,45))
plot3d_best_mclust_class



# calculating rand index to compare group assignments

#getting model assignments together in one spot 

#randindex wants numerical distinctions for clusters- give 7-10 to not overlap with mclust
Summary_Stats_Admixed_Select_Qualitative_Assignments <- Summary_Stats_Admixed_Select_2[,c("Color_Class","Intensity_Class","Av_Total_Int","Av_Chroma","Av_Adjust_Hue_degrees")]
  Summary_Stats_Admixed_Select_Qualitative_Assignments[Summary_Stats_Admixed_Select_Qualitative_Assignments == 'LR'] <- "7"
  Summary_Stats_Admixed_Select_Qualitative_Assignments[Summary_Stats_Admixed_Select_Qualitative_Assignments == 'DB'] <- "9"
  Summary_Stats_Admixed_Select_Qualitative_Assignments[Summary_Stats_Admixed_Select_Qualitative_Assignments == 'LB'] <- "8"
  Summary_Stats_Admixed_Select_Qualitative_Assignments[Summary_Stats_Admixed_Select_Qualitative_Assignments == 'DR'] <- "10"

Fit_Cluster_Assignment <- as.data.frame(fit$classification)
Rand_Assignments <-merge(Fit_Cluster_Assignment,Summary_Stats_Admixed_Select_Qualitative_Assignments, by="row.names")
Rand_Assignments$Color_Class <- as.numeric(Rand_Assignments$Color_Class)

#compare assignemnts between mclust and my eyes
#visual comparison of similarity between clusters
table(Rand_Assignments$`fit$classification`, Rand_Assignments$Color_Class)
#adjusted rand index adjusts for the number of potential groups
adj.rand.index(Rand_Assignments$`fit$classification`, Rand_Assignments$Color_Class) #0.979465

# chi squared test - testing our by eye categorical assignment to clustering assignment 
# create a new dataframe 

Summary_Stats_Admixed_Select_Qualitative_Assignments <- Summary_Stats_Admixed_Select_2[,c("Color_Class","Intensity_Class","Av_Total_Int","Av_Chroma","Av_Adjust_Hue_degrees")]
Fit_Cluster_Assignment <- as.data.frame(fit$classification)
  Fit_Cluster_Assignment[Fit_Cluster_Assignment == 1] <- "LR"
  Fit_Cluster_Assignment[Fit_Cluster_Assignment == 2] <- "LB"
  Fit_Cluster_Assignment[Fit_Cluster_Assignment == 3] <- "DB"
  Fit_Cluster_Assignment[Fit_Cluster_Assignment == 4] <- "DR"
  
Fit_Cluster_Assignment_Intensity <- as.data.frame(fit$classification)
  Fit_Cluster_Assignment_Intensity[Fit_Cluster_Assignment_Intensity == 1] <- "L"
  Fit_Cluster_Assignment_Intensity[Fit_Cluster_Assignment_Intensity == 2] <- "L"
  Fit_Cluster_Assignment_Intensity[Fit_Cluster_Assignment_Intensity == 3] <- "D"
  Fit_Cluster_Assignment_Intensity[Fit_Cluster_Assignment_Intensity == 4] <- "D"
  
Fit_Cluster_Assignment_Hue <- as.data.frame(fit$classification)
  Fit_Cluster_Assignment_Hue[Fit_Cluster_Assignment_Hue  == 1] <- "R"
  Fit_Cluster_Assignment_Hue[Fit_Cluster_Assignment_Hue  == 2] <- "B"
  Fit_Cluster_Assignment_Hue[Fit_Cluster_Assignment_Hue  == 3] <- "B"
  Fit_Cluster_Assignment_Hue[Fit_Cluster_Assignment_Hue  == 4] <- "R"

Assignments <-merge(Fit_Cluster_Assignment,Summary_Stats_Admixed_Select_Qualitative_Assignments, by="row.names")
table(Assignments$`fit$classification`, Assignments$Color_Class)

chisq.test(Assignments$`fit$classification`, Assignments$Color_Class, correct=FALSE)

# get values of each component
# change the assignment in color_Class for 678_09_09 individual [row 125] who was reclassified by the model as being LB and not DB.
Assignments_Updated <-merge(Fit_Cluster_Assignment,Summary_Stats_Admixed_Select_Qualitative_Assignments, by="row.names")
Assignments_Updated[125, "Color_Class"] <- "LB"
Assignments_Updated

#stats for LR group #component 1
comp1<- (subset(Assignments_Updated, Assignments_Updated$Color_Class=='LR'))
mean(comp1$Av_Total_Int)
std.error(comp1$Av_Total_Int)
mean(comp1$Av_Chroma)
std.error(comp1$Av_Chroma)
mean(comp1$Av_Adjust_Hue_degrees)
std.error(comp1$Av_Adjust_Hue_degrees)

#stats for DB group #component 3
comp2<-(subset(Assignments_Updated, Assignments_Updated$Color_Class=='DB'))
mean(comp2$Av_Total_Int)
std.error(comp2$Av_Total_Int)
mean(comp2$Av_Chroma)
std.error(comp2$Av_Chroma)
mean(comp2$Av_Adjust_Hue_degrees)
std.error(comp2$Av_Adjust_Hue_degrees)

#stats for LB group #component 2
comp3<-(subset(Assignments_Updated, Assignments_Updated$Color_Class=='LB'))
mean(comp3$Av_Total_Int)
std.error(comp3$Av_Total_Int)
mean(comp3$Av_Chroma)
std.error(comp3$Av_Chroma)
mean(comp3$Av_Adjust_Hue_degrees)
std.error(comp3$Av_Adjust_Hue_degrees)

#stats for LB group #component 4
comp4<-(subset(Assignments_Updated, Assignments_Updated$Color_Class=='DR'))
mean(comp4$Av_Total_Int)
std.error(comp4$Av_Total_Int)
mean(comp4$Av_Chroma)
std.error(comp4$Av_Chroma)
mean(comp4$Av_Adjust_Hue_degrees)
std.error(comp4$Av_Adjust_Hue_degrees)





#############################
#regressions for how much variance is explained by categorical dark v light, red v blue

#categorical regressions are tricky - data must be recoded
#looking at structure of the data 
str(Assignments_Updated)
#Updating a new dataframe so we have columns with just two binary levels - Intensity - L v. D and Hue R v. B. 
#Doing this by asking the case of the component assignment 
Assignments_Updated_2 <- Assignments_Updated %>% 
  mutate(Int_Regression =
           case_when(Color_Class == "LR" ~"1",
                     Color_Class == "DR" ~"2",
                     Color_Class == "LB" ~"1",
                     Color_Class == "DB" ~"2")) %>% 
  mutate(Hue_Regression =
           case_when(Color_Class == "LR" ~"1",
                     Color_Class == "DR" ~"1",
                     Color_Class == "LB" ~"2",
                     Color_Class == "DB" ~"2"))

# testing regressions for intensity 
Reg_AvTotalInt_x_AssignedIntensity <- lm(Assignments_Updated_2$Av_Total_Int~Assignments_Updated_2$Int_Regression)
print(summary(Reg_AvTotalInt_x_AssignedIntensity)) # Multiple R-squared:  0.7924,	Adjusted R-squared:  0.7908 
Reg_AvChroma_x_AssignedIntensity <- lm(Assignments_Updated_2$Av_Chroma~Assignments_Updated_2$Int_Regression)
print(summary(Reg_AvChroma_x_AssignedIntensity)) # Multiple R-squared:  0.7299,	Adjusted R-squared:  0.7278
Reg_AvHue_x_AssignedIntensity <- lm(Assignments_Updated_2$Av_Adjust_Hue_degrees~Assignments_Updated_2$Int_Regression)
print(summary(Reg_AvHue_x_AssignedIntensity)) # Multiple R-squared:  0.1958,	Adjusted R-squared:  0.1896 

boxplot1<- ggplot(Assignments_Updated_2, aes(Int_Regression, Av_Total_Int)) +
  geom_boxplot() + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#5605cb","#ec3c30","#b29ff9","#ffd7d1"))) +
  geom_smooth(method = "rlm", formula = y ~ x, aes(group = 1),linetype = "dashed", color="black") +
  theme_minimal()+ theme(legend.position = "none")

boxplot2<- ggplot(Assignments_Updated_2, aes(Int_Regression, Av_Chroma)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#5605cb","#ec3c30","#b29ff9","#ffd7d1"))) +
  geom_smooth(method = "rlm", formula = y ~ x, aes(group = 1),linetype = "dashed", color="black") +
  theme_minimal()+ theme(legend.position = "none")

boxplot3<- ggplot(Assignments_Updated_2, aes(Int_Regression, Av_Adjust_Hue_degrees)) +
  geom_boxplot() + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#5605cb","#ec3c30","#b29ff9","#ffd7d1"))) +
  geom_smooth(method = "rlm", formula = y ~ x, aes(group = 1),linetype = "dashed", color="black") +
  theme_minimal()+ theme(legend.position = "none") 


Reg_AvTotalInt_x_AssignedHue <- lm(Assignments_Updated_2$Av_Total_Int~Assignments_Updated_2$Hue_Regression)
print(summary(Reg_AvTotalInt_x_AssignedHue)) # Multiple R-squared:  0.1062,	Adjusted R-squared:  0.09929 
Reg_AvChroma_x_AssignedHue <- lm(Assignments_Updated_2$Av_Chroma~Assignments_Updated_2$Hue_Regression)
print(summary(Reg_AvChroma_x_AssignedHue)) # Multiple R-squared:  0.2993,	Adjusted R-squared:  0.2939 
Reg_AvHue_x_AssignedHue <- lm(Assignments_Updated_2$Av_Adjust_Hue_degrees~Assignments_Updated_2$Hue_Regression)
print(summary(Reg_AvHue_x_AssignedHue)) # Multiple R-squared:  0.8677,	Adjusted R-squared:  0.8667  


boxplot4<- ggplot(Assignments_Updated_2, aes(Hue_Regression, Av_Total_Int)) +
  geom_boxplot() + geom_jitter(aes(color=Color_Class,),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#5605cb","#ec3c30","#b29ff9","#ffd7d1"))) +
  geom_smooth(method = "rlm", formula = y ~ x, aes(group = 1),linetype = "dashed", color="black") +
  theme_minimal() + theme(legend.position = "none")
boxplot5<- ggplot(Assignments_Updated_2, aes(Hue_Regression, Av_Chroma)) +
  geom_boxplot() + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#5605cb","#ec3c30","#b29ff9","#ffd7d1"))) +
  geom_smooth(method = "rlm", formula = y ~ x, aes(group = 1),linetype = "dashed", color="black") +
  theme_minimal() + theme(legend.position = "none")
boxplot6 <- ggplot(Assignments_Updated_2, aes(Hue_Regression, Av_Adjust_Hue_degrees)) +
  geom_boxplot() + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#5605cb","#ec3c30","#b29ff9","#ffd7d1"))) +
  geom_smooth(method = "rlm", formula = y ~ x, aes(group = 1),linetype = "dashed", color="black") +
  theme_minimal() + theme(legend.position = "none")
ggarrange(boxplot1,boxplot2,boxplot3,boxplot4,boxplot5,boxplot6, ncol = 3, nrow = 2)



#ANOVAs to compare groups
#get the model classified data together with the Allo and Sym data 

#Going to subset just the allo and sym individuals from the data 
Summary_Stats_Admixed_Select_4<-subset(Summary_Stats_Admixed_Select,Color_Class!="DR" & Color_Class!="LB" & Color_Class!="DB" & Color_Class!="LR")
Summary_Stats_Admixed_Select_4

#change the assignment in color_Class for 678_09_09 individual [row 125] who was reclassified by the model as being LB and not DB.
Assignments_Updated <-merge(Fit_Cluster_Assignment,Summary_Stats_Admixed_Select_Qualitative_Assignments, by="row.names")
Assignments_Updated[125, "Color_Class"] <- "LB"
Assignments_Updated

#put updated assignments with allo sym data
All_Individuals <- bind_rows(Assignments_Updated,Summary_Stats_Admixed_Select_4)
# All_Individuals 

#messy but does the job 
#Now for the Anovas
# Assumption 1: All Samples are independent - Yes
# Assumption 2: Dependent variable (expression) is continuous - Yes
# Assumption 3: Normal distribution within each group, not the whole data

#can do this by looking at the measurements in each group 
All_Individuals.DR <- All_Individuals[All_Individuals$Color_Class=="DR",]
All_Individuals.LR <- All_Individuals[All_Individuals$Color_Class=="LR",]
All_Individuals.DB <- All_Individuals[All_Individuals$Color_Class=="DB",]
All_Individuals.LB <- All_Individuals[All_Individuals$Color_Class=="LB",]
All_Individuals.DR_Sym <- All_Individuals[All_Individuals$Color_Class=="DR_Sym",]
All_Individuals.LB_Allo <- All_Individuals[All_Individuals$Color_Class=="LB_Allo",]


qqp(All_Individuals.DR$Av_Total_Int, "norm") # good
qqp(All_Individuals.LR$Av_Total_Int, "norm") # good
qqp(All_Individuals.DB$Av_Total_Int, "norm") # good
qqp(All_Individuals.LB$Av_Total_Int, "norm") # good
qqp(All_Individuals.DR_Sym$Av_Total_Int, "norm") # good
qqp(All_Individuals.LB_Allo$Av_Total_Int, "norm") # good
#Simply just dont want any clear trends/patterns/ noticeable grouped outliers

# ANOVA - just because its "robust to violations"
All_Individuals_Color_Class_Int_ANOVA<-aov(All_Individuals$Av_Total_Int~All_Individuals$Color_Class)
summary(All_Individuals_Color_Class_Int_ANOVA)
plot(All_Individuals_Color_Class_Int_ANOVA$residuals)
All_Individuals_Color_Class_Int_ANOVA_tuk <-TukeyHSD(All_Individuals_Color_Class_Int_ANOVA)
All_Individuals_Color_Class_Int_ANOVA_tuk

All_Individuals_Color_Class_Chroma_ANOVA<-aov(All_Individuals$Av_Chroma~All_Individuals$Color_Class)
summary(All_Individuals_Color_Class_Chroma_ANOVA)
plot(All_Individuals_Color_Class_Int_ANOVA$residuals)
All_Individuals_Color_Class_Chroma_ANOVA_tuk <-TukeyHSD(All_Individuals_Color_Class_Chroma_ANOVA)
All_Individuals_Color_Class_Chroma_ANOVA_tuk

All_Individuals_Color_Class_Hue_ANOVA<-aov(All_Individuals$Av_Adjust_Hue_degrees~All_Individuals$Color_Class)
summary(All_Individuals_Color_Class_Hue_ANOVA)
plot(All_Individuals_Color_Class_Hue_ANOVA$residuals)
All_Individuals_Color_Class_Hue_ANOVA_tuk <-TukeyHSD(All_Individuals_Color_Class_Hue_ANOVA)
All_Individuals_Color_Class_Hue_ANOVA_tuk


#plotting all 6 groups together for boxplots
#to get specific order for plotting
All_Individuals$Color_Class <- factor(All_Individuals$Color_Class , levels=c("LB_Allo", "LB", "LR", "DB", "DR","DR_Sym"))


### "#b29ff9","#b29ff9","#ffd7d1","#5605cb","#ec3c30","#ec3c30"

boxplot10 <- ggplot(All_Individuals, aes(Color_Class, Av_Total_Int)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#b29ff9","#b29ff9","#ffd7d1","#5605cb","#ec3c30","#ec3c30"))) +
  theme_minimal() + theme(legend.position = "none")

boxplot11 <- ggplot(All_Individuals, aes(Color_Class, Av_Chroma)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#b29ff9","#b29ff9","#ffd7d1","#5605cb","#ec3c30","#ec3c30"))) +
  theme_minimal() + theme(legend.position = "none")

boxplot12 <- ggplot(All_Individuals, aes(Color_Class, Av_Adjust_Hue_degrees)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter(aes(color=Color_Class),width=0.25, alpha=1) + 
  scale_color_manual(values=(c("#b29ff9","#b29ff9","#ffd7d1","#5605cb","#ec3c30","#ec3c30"))) +
  theme_minimal() + theme(legend.position = "none")

ggarrange(boxplot10,boxplot11,boxplot12, ncol = 1, nrow = 3)


#Plotting all 6 groups in 3D plot


pal_friendly <-c("#F9D8D2","#AEA2F3","#4B23C3","#DB4B3C")
###"#b29ff9","#ffd7d1","#5605cb","#ec3c30","#ec3c30"


plot3d_best_mclust_class <- plot_ly(
  data = Summary_Stats_Admixed_Select_2, x = ~Av_Total_Int, y= ~Av_Adjust_Hue_degrees, z= ~Av_Chroma,
  mode = 'markers',color= fit$classification, colors=pal_friendly, symbol=I("circle"),
  opacity = 0.9,
  text=(~Sample),
  sector = c(315,45))
plot3d_best_mclust_class


#plotting by axis xategory, first few are smooth density plots but bottom plot is figure1 D

Summary_Stats_Admixed_Select_2

p1<-ggplot(Summary_Stats_Admixed_Select_2, aes(x=Av_Total_Int, fill=Intensity_Class)) +
  geom_density(alpha=0.8) + scale_fill_manual(values=c("#C7C7C7","#666666")) +
  theme_minimal() + theme(legend.position = "none")
p1
p2<-ggplot(Summary_Stats_Admixed_Select_2, aes(x=Av_Chroma, fill=Intensity_Class)) +
  geom_density(alpha=0.8) + scale_fill_manual(values=c("#C7C7C7","#666666")) +
  theme_minimal() + theme(legend.position = "none")
p2
p3<-ggplot(Assignments_Updated_2, aes(x=Av_Adjust_Hue_degrees, fill=Hue_Regression)) +
  geom_density(alpha=0.8) + scale_fill_manual(values=c("#ec3c30","#5605cb")) +
  theme_minimal() + theme(legend.position = "none")
p3
p3<-ggplot(Summary_Stats_Admixed_Select_2, aes(x=Av_Adjust_Hue_degrees, fill=Intensity_Class)) +
  geom_density(alpha=0.8) + scale_fill_manual(values=c("#C7C7C7","#666666")) +
  theme_minimal() + theme(legend.position = "none")
p3



p1<-ggplot(Assignments_Updated_2, aes(x=Av_Total_Int, fill=Color_Class)) +
  geom_density(alpha=0.9) + scale_fill_manual(values=c("#5605cb","#ec3c30","#b29ff9","#ffaba7")) +
  theme_minimal() + theme(legend.position = "none")
p1
p2<-ggplot(Assignments_Updated_2, aes(x=Av_Chroma, fill=Color_Class)) +
  geom_density(alpha=0.9) + scale_fill_manual(values=c("#5605cb","#ec3c30","#b29ff9","#ffaba7")) +
  theme_minimal() + theme(legend.position = "none")
p2

p3<-ggplot(Assignments_Updated_2, aes(x=Av_Adjust_Hue_degrees, fill=Color_Class)) +
  geom_density(alpha=0.9) + scale_fill_manual(values=c("#5605cb","#ec3c30","#b29ff9","#ffaba7")) +
  theme_minimal() + theme(legend.position = "none")
p3

ggarrange(p1,p2,p3, ncol = 1, nrow = 3) #saved as 4x6





p1<-ggplot(Assignments_Updated_2, aes(x=Av_Total_Int, fill=Hue_Regression)) +
  geom_density(alpha=0.8) + coord_cartesian(ylim=c(0, 0.0003)) +  scale_fill_manual(values=c("#5605cb","#ec3c30")) +
  theme_minimal() + theme(legend.position = "none")
p1
p2<-ggplot(Assignments_Updated_2, aes(x=Av_Chroma, fill=Hue_Regression)) +
  geom_density(alpha=0.8) + coord_cartesian(ylim=c(0, 8)) + scale_fill_manual(values=c("#5605cb","#ec3c30")) +
  theme_minimal() + theme(legend.position = "none")
p2
p3<-ggplot(Assignments_Updated_2, aes(x=Av_Adjust_Hue_degrees, fill=Hue_Regression)) +
  geom_density(alpha=0.8) + coord_cartesian(ylim=c(0,0.12))+ scale_fill_manual(values=c("#5605cb","#ec3c30")) +
  theme_minimal() + theme(legend.position = "none")
p3
p4<-ggplot(Assignments_Updated_2, aes(x=Av_Total_Int, fill=Int_Regression)) +
  geom_density(alpha=0.8)+ coord_cartesian(ylim=c(0, 0.0004))  + scale_fill_manual(values=c("#C7C7C7","#666666")) +
  theme_minimal() + theme(legend.position = "none")
p4
p5<-ggplot(Assignments_Updated_2, aes(x=Av_Chroma, fill=Int_Regression)) +
  geom_density(alpha=0.8) + coord_cartesian(ylim=c(0, 8))+ scale_fill_manual(values=c("#C7C7C7","#666666")) +
  theme_minimal() + theme(legend.position = "none")
p5
p6<-ggplot(Assignments_Updated_2, aes(x=Av_Adjust_Hue_degrees, fill=Int_Regression)) +
  geom_density(alpha=0.8) + coord_cartesian(ylim=c(0,0.12))+ scale_fill_manual(values=c("#C7C7C7","#666666")) +
  theme_minimal() + theme(legend.position = "none")
p6
ggarrange(p4,p1,p5,p2,p6,p3, ncol = 2, nrow = 3) #saved as 4x6


#### FIGURE 1 D Plot

p1<-gghistogram(Assignments_Updated_2, bins=30, rug = FALSE, x="Av_Total_Int", Color="Int_Regression", fill="Int_Regression", palette=c("#C7C7C7","#666666")) + theme(legend.position = "none")
p2<-gghistogram(Assignments_Updated_2, bins=30, rug = FALSE, x="Av_Chroma", Color="Int_Regression", fill="Int_Regression", palette=c("#C7C7C7","#666666")) + theme(legend.position = "none")
p3<-gghistogram(Assignments_Updated_2, bins=30, rug = FALSE, x="Av_Adjust_Hue_degrees", Color="Int_Regression", fill="Int_Regression", palette=c("#C7C7C7","#666666")) + theme(legend.position = "none")

p4<-gghistogram(Assignments_Updated_2, bins=30,rug = FALSE, x="Av_Total_Int", Color="Int_Regression", fill="Hue_Regression", palette=c("#5605cb","#ec3c30")) + theme(legend.position = "none")
p5<-gghistogram(Assignments_Updated_2, bins=30,rug = FALSE, x="Av_Chroma", Color="Int_Regression", fill="Hue_Regression", palette=c("#5605cb","#ec3c30")) + theme(legend.position = "none")
p6<-gghistogram(Assignments_Updated_2, bins=30,rug = FALSE, x="Av_Adjust_Hue_degrees", Color="Int_Regression", fill="Hue_Regression", palette=c("#5605cb","#ec3c30")) + theme(legend.position = "none")
ggarrange(p4,p1,p5,p2,p6,p3, ncol = 2, nrow = 3)



#print 3d coordinate plot out as PDF - this is just the admixed
plot3d_best_mclust_class <- plot_ly(data = Summary_Stats_Admixed_Select_2, x = ~Av_Total_Int, y= ~Av_Adjust_Hue_degrees, z= ~Av_Chroma,
             mode = 'markers',color= fit$classification, colors=pal_friendly, symbol=I("circle"),
             opacity = 0.8,
             text=(~Sample),
             sector = c(315,45))
# without the type parameter the help page example gives warning
reticulate::py_run_string("import sys") # not loaded by default?
reticulate::py_run_string("import plotly") # Also needed?
save_image(plot3d_best_mclust_class, "./plot3d_best_mclust_class.png")
save_image(plot3d_best_mclust_class, "./plot3d_best_mclust_class.pdf")  # checked; both were created



####### FIGURE 1 C - 3D PLOT WITH POINTS COLORED BY MODEL ASSIGNMENT PLUS SYM AND ALLO

#print 3d coordinate plot out as PDF - admixed plus allopatry and sympatry

#### instead of plotting from Summary_Stats_Admixed_Select_2 with All_individuals which has updated modelk assignemnts and allo & sym inds. 
All_Individuals

# adding a new column just to get all points to plot by color in same variable. Copying over color best fit from model for admixed individuals and ther natursal color assignment for all and sym individuals to new variable. 
All_Individuals$plotcolassign <- All_Individuals$`fit$classification` #writing over values from model classification for admixed
All_Individuals$plotcolassign[135:187] <- All_Individuals$Color_Class[135:187] #getting values from a group value copied from color class for allo and sym to plot distinctly from admixed color groups


write.csv(All_Individuals, "results/All_Individuals.csv")

#option1
pal_friendly <-c("grey50","grey20","#4B23C3","#DB4B3C","#AEA2F3","#F9D8D2")
plot3d_test_best_mclust_class_allo_sym <- plot_ly(data = All_Individuals, 
                                                  type="scatter3d",
                                                  x = ~Av_Total_Int, y= ~Av_Adjust_Hue_degrees, z= ~Av_Chroma,
                                                  mode = 'markers',color= All_Individuals$plotcolassign, 
                                                  colors=pal_friendly, 
                                                  symbol = All_Individuals$plotcolassign, 
                                                  symbols = c('square',"square","circle","circle","circle","circle"),
                                                  opacity = .7,
                                                  text=(~Sample))

plot3d_test_best_mclust_class_allo_sym



plot3d_best_mclust_class <- plot_ly(data = Summary_Stats_Admixed_Select_2, x = ~Av_Total_Int, y= ~Av_Adjust_Hue_degrees, z= ~Av_Chroma,
                                    mode = 'markers',color= fit$classification, colors=pal_friendly, symbol=I("circle"),
                                    opacity = 0.8,
                                    text=(~Sample),
                                    sector = c(315,45))
# without the type parameter the help page example gives warning
reticulate::py_run_string("import sys") # not loaded by default?
reticulate::py_run_string("import plotly") # Also needed?
save_image(plot3d_best_mclust_class, "results/plot3d_best_mclust_class.png")
save_image(plot3d_best_mclust_class, "results/plot3d_best_mclust_class.pdf")  # checked; both were created

