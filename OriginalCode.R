# Graphs of modified interaction plots for the GSS data set


#setwd("C:/Users/tbodner/Dropbox/Current Work/Graphing Interactions/Examples/GSS/gss spss interaction")

library(foreign)
SPSSdata <- read.spss("gssspssreduced.sav", to.data.frame=TRUE)

attach(SPSSdata)

DV = prestg80
tarpred = educ
modpred = maeduc

#Step 1
mmr <- lm(DV ~ tarpred + modpred + tarpred*modpred)

#Step 2
lowmod <- mean(modpred)-sqrt(var(modpred))
highmod <- mean(modpred)+sqrt(var(modpred))

#Step 3
reg <- lm(tarpred ~ modpred)
predst3 <- summary.lm(reg)
tmlm <- predst3$coeff[1,1] + predst3$coeff[2,1]*lowmod
tmhm <- predst3$coeff[1,1] + predst3$coeff[2,1]*highmod

#Step 4
tresid <- sqrt(anova(reg)[2,3])
hthm <- tmhm+tresid
lthm <- tmhm-tresid
htlm <- tmlm+tresid
ltlm <- tmlm-tresid

#Step 5
predhr <- summary.lm(mmr)
hhhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*hthm + 
  predhr$coeff[3,1]*highmod + predhr$coeff[4,1]*hthm*highmod
hlhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*htlm + 
  predhr$coeff[3,1]*lowmod + predhr$coeff[4,1]*htlm*lowmod
lhhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*lthm + 
  predhr$coeff[3,1]*highmod + predhr$coeff[4,1]*lthm*highmod
llhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*ltlm + 
  predhr$coeff[3,1]*lowmod + predhr$coeff[4,1]*ltlm*lowmod

#Step 6
prep <- t(matrix(c(hthm,hhhr,htlm,hlhr,lthm,lhhr,ltlm,llhr),2,4))
plot(prep[,1],prep[,2],ann=FALSE, ylim=c(20,60),xlim=c(5,20))
segments(hthm,hhhr,lthm,lhhr)
segments(htlm,hlhr,ltlm,llhr,lty="dashed")
mtext("Respondent's Years of Education", side=1, line=2.5, cex=1)
mtext("Predicted Occupational Prestige", side=2, line=2.5, cex=1)
legend(6,55,c("14.2 Years (1 SD Above Mean)","7.3 Years (1 SD Below Mean)"),cex=.8, 
       lty=c("solid","dashed"), title="Mother's Years of Education")

# Standard interaction Graph

mtar <- mean(tarpred)
sdtar <- sqrt(var(tarpred))
htar <- mtar + sdtar
ltar <- mtar - sdtar
shhhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*htar + 
  predhr$coeff[3,1]*highmod + predhr$coeff[4,1]*htar*highmod
shlhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*htar + 
  predhr$coeff[3,1]*lowmod + predhr$coeff[4,1]*htar*lowmod
slhhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*ltar + 
  predhr$coeff[3,1]*highmod + predhr$coeff[4,1]*ltar*highmod
sllhr <- predhr$coeff[1,1] + predhr$coeff[2,1]*ltar + 
  predhr$coeff[3,1]*lowmod + predhr$coeff[4,1]*ltar*lowmod
sprep <- t(matrix(c(htar,shhhr,htar,shlhr,ltar,slhhr,ltar,sllhr),2,4))

plot(sprep[,1],sprep[,2],ann=FALSE, ylim=c(20,60),xlim=c(5,20))
segments(htar,shhhr,ltar,slhhr,lty="dashed")
segments(htar,shlhr,ltar,sllhr)
mtext("Respondent's Years of Education", side=1, line=2.5, cex=1)
mtext("Predicted Occupational Prestige", side=2, line=2.5, cex=1)
legend(6,55,c("14.2 Years (1 SD Above Mean)","7.3 Years (1 SD Below Mean)"),cex=.8, 
       lty=c("solid","dashed"), title="Mother's Years of Education")

# Both together

pdf("gssinteract.pdf", width = 8, height = 10 )
par(mfrow=c(2,1))
plot(sprep[,1],sprep[,2],ann=FALSE, ylim=c(30,60),xlim=c(8,18),pch=21)
segments(htar,shhhr,ltar,slhhr)
segments(htar,shlhr,ltar,sllhr,lty="dashed")
mtext("Years of Education", side=1, line=2.5, cex=1)
mtext("Predicted Occupational Prestige", side=2, line=2.5, cex=1)
legend(7.7,60,c("14.2 Years (1 SD Above Mean)","7.3 Years (1 SD Below Mean)"),cex=.8, 
       lty=c("solid","dashed"), title="Mother's Years of Education")
plot(prep[,1],prep[,2],ann=FALSE, ylim=c(30,60),xlim=c(8,18),pch=24)
segments(hthm,hhhr,lthm,lhhr)
segments(htlm,hlhr,ltlm,llhr,lty="dashed")
mtext("Years of Education", side=1, line=2.5, cex=1)
mtext("Predicted Occupational Prestige", side=2, line=2.5, cex=1)
legend(7.7,60,c("14.2 Years (1 SD Above Mean)","7.3 Years (1 SD Below Mean)"),cex=.8, 
       lty=c("solid","dashed"), title="Mother's Years of Education")
dev.off()

# Bivariate Distribution of Target and Moderator

pdf("gssbivariate.pdf", width = 8, height = 10)
plot(jitter(educ, factor=.4),jitter(maeduc,factor=.8),ann=FALSE,pch=20,cex=.6)
mtext("Years of Education", side=1, line=2.5, cex=1)
mtext("Mother's Years of Education", side=2, line=2.5, cex=1)
abline(v = ltar, lty="dashed")
abline(v = htar)
abline(h = lowmod, lty="dashed")
abline(h = highmod)
legend(0,20,c("1 SD Below Mean","1 SD Above Mean"),cex=.8, lty=c("dashed","solid"), title="Reference Lines")
points(hthm,highmod,pch=24)
points(htlm,lowmod,pch=24)
points(lthm,highmod,pch=24)
points(ltlm,lowmod,pch=24)
points(htar,highmod,pch=21)
points(htar,lowmod,pch=21)
points(ltar,highmod,pch=21)
points(ltar,lowmod,pch=21)
dev.off()



pdf("gssbivariate.pdf", width = 8, height = 10)
plot(jitter(educ, factor=.4),jitter(maeduc,factor=.4),ann=FALSE,pch=20)
mtext("Years of Education", side=1, line=2.5, cex=1)
mtext("Mother's Years of Education", side=2, line=2.5, cex=1)
abline(v = ltar, lty="dashed")
abline(v = htar)
abline(h = lowmod, lty="dashed")
abline(h = highmod)
legend(0,20,c("1 SD Below Mean","1 SD Above Mean"),cex=.8, lty=c("dashed","solid"), title="Reference Lines")
points(hthm,highmod,pch=24)
points(htlm,lowmod,pch=24)
points(lthm,highmod,pch=24)
points(ltlm,lowmod,pch=24)
points(htar,highmod,pch=21)
points(htar,lowmod,pch=21)
points(ltar,highmod,pch=21)
points(ltar,lowmod,pch=21)
dev.off()







