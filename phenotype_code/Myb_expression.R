#!/usr/bin/env Rscript

#Myb development series analysis and graphing. Data include ddct for pdMyb1 for light and dark flowered individuals across developmental time

out_fn <- "results/Myb_expression.pdf"
pdf(out_fn, width = 10, height = 10, onefile=TRUE)

mybdev<-read.table("myb_expression.csv", header = T, sep = ",")

library(rstatix)
library(reshape)
library(tidyverse)
library(dplyr)
library(plyr)
library(datarium)
library(car)
library(multcomp)
library(lsmeans)
library(lme4)
library(ggpubr)
library(Rmisc)


mybdev<-subset(mybdev, !is.na(time))
#repeated-measures ANOVA testing for effect of time, color and interaction
m1<-lm(ddCT~color +time+ time*color,data=mybdev)
Anova(m1,type=3)
summary(m1)
qqPlot(m1$residuals,
       id = FALSE # remove point identification
)
shapiro.test(m1$residuals)
#pairwise independent contrasts to interegate which time points show largest expression difference between colors
m2<-lm(ddCT~timeXcolor,data=mybdev)
summary(glht(m2,lsm(pairwise ~ timeXcolor)), test=adjusted(type="none"))
m2av<-aov(m2)
m2av
TukeyHSD(m2av)

t1<-subset(mybdev,time==1, select=Individual:timeXcolor)
mt1<-lm(ddCT~color,data=mybdev)
summary(mt1)

t2<-subset(mybdev,time==2, select=Individual:timeXcolor)
mt2<-lm(ddCT~color,data=mybdev)
summary(mt2)

ggline(subset(mybdev,!is.na(time)),
  x="time",
  y="ddCT",
  color="color",
  add=c("mean_se"))

summary_stat <- summarySE(mybdev,
                          measurevar = "ddCT",
                          groupvars = c("color", "time")
)

#graph results
# quartz(width = 10, height = 10)
ggplot(
  subset(summary_stat, !is.na(time)), # remove NA level for color
  aes(x = time, y = ddCT, colour = color)
) + theme_classic()+
  geom_errorbar(aes(ymin = ddCT - se, ymax = ddCT + se), # add error bars
                width = 0.1 # width of error bars
  ) +
  geom_line(size=1)+
  geom_point(size=2.5) +
  scale_color_manual(values=c("white", "#DBd0FF"))
  labs(y = "Myb ddCT)")


ggplot(
    subset(summary_stat, !is.na(time)), # remove NA level for color
    aes(x = time, y = ddCT, colour = color)
  ) + theme_classic()+
    geom_errorbar(aes(ymin = ddCT - se, ymax = ddCT + se), # add error bars
                  width = 0.1 # width of error bars
    ) +
    geom_line(size=1)+
    geom_point(size=2.5) +
    scale_color_manual(values=c("#8c67E4", "#DBd0FF"))
  labs(y = "Myb ddCT)")
dev.off()
