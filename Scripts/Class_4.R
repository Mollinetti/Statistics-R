#BEFORE STARTING OUR CLASS, PLEASE RUN THIS SNIPPET TO INSTALL/LOAD OUR LIBRARIES NEEDED FOR THIS LESSON

packages_needed <- c('car', 'reshape2', 'HH', 'lme4', 'tidyr')
for (package_name in packages_needed) {      
  if (!(package_name %in% rownames(installed.packages()))){
    install.packages(package_name)
  }
}
for (i in 1:length(packages_needed))
{
  library(packages_needed[[i]],character.only=TRUE)
}

#load our dataset
hemo <- read.csv('Hemo_exp.csv')

#boxplot of the hemo data
boxplot(hemo , las = 1, xlab = 'Groups', ylab = "Hemoglobin Level (g/dL)", col = 'blue')

#we want to organize our data into independent and dependent variable
#lets get a 'molten' dataset 
m.hemo <- melt(hemo)
#change the names of the cols
colnames(m.hemo)<- c('Group', 'Bloodlv')

#run the ANOVA for our hemoglobin example
#One Way Anova (Completely Randomized Design)
group <- m.hemo$Group
aov.ex1 <- aov(m.hemo$Bloodlv~group,data = m.hemo)

#checking the result of the anova
summary(aov.ex1)

#lets see the confidence intervals generated by the anova
confint(aov.ex1, level = 0.90)
#some interesting plots for anova
plot(aov.ex1)
#pairwise confidence

#tukey post hoc
post_hoc.ex1<- TukeyHSD(aov.ex1, 'group', conf.level =0.95)
post_hoc.ex1
#plot of the tukey test
plot(post_hoc.ex1, las = 1, cex.lab=0.5, cex.axis=0.5, cex.main=0.5, cex.sub=0.5)

#set the contrasts
options(contrasts = rep ("contr.treatment", 2))

#mmc of the anova
aov.ex1.pairwise <- mmc(aov.ex1, linfct = mcp(group = "Tukey"))
aov.ex1.pairwise

#plot of the mmc of the fitted model 
mmcplot(aov.ex1.pairwise)


#EXTRA: FITTING A LINEAR REGRESSION FOR A SANITY CHECK
lm.aov1<- lm(formula = abs(aov.ex1$res) ~ group)
summary(lm.aov1) #difference in value can be stated because p<0.05

######################################################################################################
######################################################################################################

#UNBALANCED DESIGN EXPERIMENT

#load the unbalanced data
assim_hemo<- read.csv('Assimetric_Hemo_exp.csv')

#melt the unbalanced data
m.assim_hemo<- melt(assim_hemo)
#change the names of the cols
colnames(m.assim_hemo)<- c('Group', 'Bloodlv')
#remove the lines with NA
m.assim_hemo<-drop_na(m.assim_hemo)


#checking equality of variances (Levene test)
leveneTest(m.assim_hemo$Bloodlv~m.assim_hemo$Group, data = m.assim_hemo)

#we can also use fligner-Kileen when data are non-normally distributed or 
#when problems related to outliers in the dataset cannot be resolved.
fligner.test(m.assim_hemo$Bloodlv~m.assim_hemo$Group, data = m.assim_hemo)

aov.unbalanced <- aov(m.assim_hemo$Bloodlv~m.assim_hemo$Group, data = m.assim_hemo)

#normality
residuals <- resid(aov.unbalanced)
shapiro.test(residuals)

#histogram of the residuals
hist(residuals, las = 1)

summary(aov.unbalanced)

#tukey post hoc
post_hoc.unbalanced<- TukeyHSD(aov.unbalanced, conf.level =0.95)
post_hoc.unbalanced
#plot of the tukey test
plot(post_hoc.unbalanced, las = 1, cex.lab=0.5, cex.axis=0.5, cex.main=0.5, cex.sub=0.5)

      
#set the constrasts
options(contrasts = rep ("contr.treatment", 2))

######################################################################################################
######################################################################################################

#Loading the block hemo data


#load the block data
block_hemo <- read.csv('Block_Hemo_exp.csv')

#melt the data
m.block_hemo<- melt(block_hemo)
#change the names of the cols
colnames(m.block_hemo)<- c('Group', 'Bloodlv')


######################################################################################################
######################################################################################################

#RANDOM EFFECTS DESIGN EXPERIMENT

#First, visualize the residuals
group<- m.block_hemo$Group
stripchart(m.block_hemo$Bloodlv ~ group, vertical = TRUE, pch = 1, ylab = "Blood level", xlab = "Group", data = m.block_hemo)

#Fit a linear mixed-effects model (LMM) to data, via REML or maximum likelihood
#the (1| ) notation means the granularity of the random effect alpha
fit.rand<- lmer(m.block_hemo$Bloodlv ~ (1|group), data = m.block_hemo)


#get an overview of the fitted model
summary(fit.rand)

#get the  approximated confidence intervals
confint(fit.rand, oldNames = FALSE)

## "estimated" (better: conditional means of) random effects that we computed with the lmer
ranef(fit.rand)

#model validation
plot(fit.rand) # Tukey-Ascombe Plot

##qq and normalized qq plot
par(mfrow = c(1, 2))
qqnorm(ranef(fit.rand)$group[, "(Intercept)"], main = "Random effects")
qqnorm(resid(fit.rand), main = "Residuals")

######################################################################################################
######################################################################################################

#Run the ANOVA with the block design

#create a vector with the blocking factors for each element in the response
blk <- rep(seq(1:50),9)
#concatenate with the melted dataset
m.block_hemo <- data.frame(m.block_hemo, blk)

#Random block one Way Anova (Completely Randomized Design)
aov.block <- aov(m.block_hemo$Bloodlv~m.block_hemo$Group + m.block_hemo$blk,data = m.block_hemo)

#checking the result of the anova
summary(aov.block)

#lets see the confidence intervals generated by the anova
confint(aov.block, level = 0.90)
#some interesting plots for anova
plot(aov.block)

#tukey post hoc
post_hoc.block <- TukeyHSD(aov.block, 'm.block_hemo$Group', conf.level =0.95)
post_hoc.block
#plot of the tukey test
plot(post_hoc.block, las = 1, cex.lab=0.5, cex.axis=0.5, cex.main=0.5, cex.sub=0.5)


#reset the constrasts
options(contrasts = rep ("contr.treatment", 2))


#pairwise confidence
aov.block.pairwise <- mmc(aov.block)
aov.block.pairwise
mmcplot(aov.block.pairwise, ylab="Comparison of Levels")


######################################################################################################
######################################################################################################

#repeated measures anova

#read dataset
rep_hemo <- read.csv('Rep_hemo_exp.csv')
#set our vars
HemoLv <- factor(rep_hemo$HemoLv)
Subject<- factor(rep_hemo$Subject)
Month <- as.factor(rep_hemo$Month)


#set the contrasts
options(contrasts=c("contr.sum","contr.poly"))


rep.aov <- aov(HemoLv ~ Month + Error(Subject/Month), data = rep_hemo)

#print the anova summary
summary(rep.aov)

#reset the constrasts
options(contrasts = rep ("contr.treatment", 2))

#validation of our anova plot
with(rep_hemo, interaction.plot(Month, Subject, HemoLv,
                             ylim = c(14, 20), lty= c(1, 12), lwd = 3,
                             ylab = "mean of HemoLv", xlab = "time", trace.label = "group"))

#test for normality
shapiro.test(rep_hemo$HemoLv)





######################################################################################################
######################################################################################################

#Power test for ANOVA

#lets do for our one-way randomized test
hemo_means <- colMeans(hemo)
#calculate the within group variance
hemo_wvar <- anova(aov.ex1)["Residuals", "Mean Sq"]
#do the power test
p <- power.anova.test(groups = length(colMeans(hemo)),  between.var = var(hemo_means), 
                      within.var = hemo_wvar,  power=0.85, sig.level=0.05, n=NULL)
n<- ceiling(p$n)
#do the power test with sample size
p2 <- power.anova.test(groups = length(colMeans(hemo)),  between.var = var(hemo_means), within.var = hemo_wvar, sig.level=0.05, n=n)

#test with many n to check the power level

n_groups <- c(seq(2,10,by=1),seq(12,15,by=2))

p3 <- power.anova.test(groups = length(colMeans(hemo)),  between.var = var(hemo_means), within.var = hemo_wvar, sig.level=0.05, n=n_groups)

#plot to inspect the relationship between sample size and power
plot(n_groups,p3$power, ylab = 'Power', xlab = 'Sample size', las = 1)
abline(h = 0.85, col = 'red')



