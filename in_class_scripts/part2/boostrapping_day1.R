
rm(list=ls())
# Bootstrapping Examples - Day 1

## load packages
library(tidyverse)
#install.packages("epitools")
library(epitools)


########################################
#### Manually perform bootstrapping ####
########################################

# Example: Aspirin use and heart attack risk


dat <- matrix(c(10845,10933,189,104), 2, 2,
              dimnames = list(c("Placebo","Aspirin"),
                              c("No Heart Attack","Heart Attack")))

dat

# compute odds ratio
or <- (dat[2,2]/dat[2,1])/(dat[1,2]/dat[1,1])

or2 <- oddsratio.wald(dat)

or2$measure

## bootstrap ci ----------------------------------------------------------------

# Construct datasets to draw from (ami and no ami)
aspirin_group <- rep(c(TRUE,FALSE), times = c(dat[2,2],dat[2,1]))
placebo_group <- rep(c(TRUE,FALSE), times = c(dat[1,2],dat[1,1]))


# write function to sample heart attacks for the two groups then compute the 
# odds ratio
boot_aspirin <- function(){
  
  # sample groups
  aspirin_sample <- sample(aspirin_group, 
                           size = length(aspirin_group),
                           replace = TRUE)
  
  placebo_sample <- sample(placebo_group, 
                           size = length(placebo_group),
                           replace = TRUE)
 
  # compute
  (sum(aspirin_sample==TRUE)/sum(aspirin_sample==FALSE))/(sum(placebo_sample==TRUE)/sum(placebo_sample==FALSE))
  
}

boot_aspirin()

# repeatedly resample
boot_sample <- replicate(1000,boot_aspirin())
#boot_sample <- sapply(1:1000,function(x) boot_aspirin())

# compute CI bounds
quantile(boot_sample,probs = c(0.025,0.975))

# compare to the original odds ratio
or2$measure


##########################################
#### Bootstrapping using boot package ####
##########################################

rm(list = ls())

# load example dataset
load("R/SimEpi/example_data/cholostyramine.RData")

cholostyramine %>% 
  ggplot(aes(compliance,cholesterol.decrease)) +
  geom_point() +
  geom_smooth() +
  geom_smooth(method = "lm",color = "red")


## compute  correlation coefficient --------------------------------------------

cor(cholostyramine)
cor(cholostyramine$compliance,cholostyramine$cholesterol.decrease)


## Manually compute CI ---------------------------------------------------------

# write a function to manually create a bootstrap and calculate correlation
boot_cor <- function(){
  # draw resample index values
  indices <- sample(nrow(cholostyramine),replace = TRUE)
  # subsample data
  boot_sample <- cholostyramine[indices,]
  # compute correlation
  cor(boot_sample$compliance,boot_sample$cholesterol.decrease)
}

# test the function
boot_cor()

# generate multiple (1,000) replicates of bootstapped correlation values
boot_cholostyramine <- replicate(1000,boot_cor())

# compute quantiles for CI bounds
quantile(boot_cholostyramine,probs = c(0.025,0.975))

# should also check to see if the distribution appears symetric
hist(boot_cholostyramine)


## Using Boot Package ----------------------------------------------------------

compute_cor <- function(data, indices) {
  boot_sample <- data[indices,]
  cor(boot_sample$compliance,boot_sample$cholesterol.decrease)
}

# generate output for bootstrapped samples
boot_out <- boot(
  cholostyramine,
  R = 1000,
  statistic = compute_cor
)

boot_out

sd(boot_out$t)

mean(boot_out$t)-boot_out$t0

# all CIs
boot.ci(boot_out)

## Normal CI -------------------------------------------------------------------

boot.ci(boot_out, type = "norm")

# look at what is produced above
boot_out$t0
boot_out$t

cor_est <- boot_out$t0
bias <- mean(boot_out$t)-boot_out$t0
se_boot <- sd(boot_out$t)

boot_out

z_val <- qnorm(0.975)

# 95 CI
c(cor_est-bias-z_val*se_boot, cor_est-bias+z_val*se_boot)

boot.ci(boot_out, type = "norm")

## Percentile ------------------------------------------------------------------

boot.ci(boot_out, type = "perc")

quantile(boot_out$t, probs = c(0.025,0.975))
quantile(boot_out$t, probs = c(0.025,0.975), type = 6)

?quantile

## Basic -----------------------------------------------------------------------

boot.ci(boot_out, type = "basic")

cor_est <- boot_out$t0


quantile(2*cor_est-boot_out$t, probs = c(0.025,0.975), type = 6)
round(quantile(2*cor_est-boot_out$t, probs = c(0.025,0.975), type = 6),4)

## Bias corrected-accelerated --------------------------------------------------

# see here: DiCiccio, T.J. and Efron B. (1996) Bootstrap confidence intervals 
#           (with Discussion). Statistical Science, 11, 189–228.

boot.ci(boot_out, type = "bca")


## Students --------------------------------------------------------------------


compute_cor_var <- function(data, indices, iter) {
  
  sample <- data[indices,]
  r <- cor(sample$compliance,sample$cholesterol.decrease)
  n <- nrow(sample)
  
  v <- boot(
    R = iter,
    data = sample,
    statistic = compute_cor
  )
  
  v <- var(v$t,na.rm = TRUE)
  
  c(r, v)
}


boot_t_out <- boot(iter = 200,
                   R = 1000, 
                   data = cholostyramine, 
                   statistic = compute_cor_var)

tmp <- quantile((boot_t_out$t[,1]-boot_t_out$t0[1])/sqrt(boot_t_out$t[,2]), 
                probs=c(0.975,0.025),type = 6)

boot_t_out$t0[1]-sqrt(boot_t_out$t0[2])*tmp

boot.ci(boot_t_out, type = "stud")




##########################
#### Example Question ####
##########################

load("R/SimEpi/example_data/cholostyramine.RData")

# plot from above
cholostyramine %>% 
  ggplot(aes(compliance,cholesterol.decrease)) +
  geom_point() +
  geom_smooth() 

?geom_smooth

# how to fit a loess model
fit <- loess(cholesterol.decrease~compliance,data = cholostyramine)
# generate predictions
predict(fit)

# manually produce the same plot
cholostyramine %>% 
  mutate(pred=predict(fit)) %>% 
  ggplot(aes(compliance,cholesterol.decrease)) +
  geom_point() +
  geom_line(aes(y=pred), color = "blue")


# How could we manually bootstrap a CI around the LOESS model

# Hint: you may need to use something like the following
predict(fit,newdata = seq(from=-2, to = 2, length = 50))
