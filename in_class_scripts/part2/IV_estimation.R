

rm(list=ls())
library(tidyverse)
library(MASS)


########################
##### IV ESTIMATION ####
########################

# For this problem we are going to be simulating a scenario where there is an
# omitted/unobserved variable

# Suppose our true data generating process can be represented by the following
#
# y = beta0 + beta1 * x1 + beta2 * x2 + error 
#
# where x1 is observable and x2 is not. Also assume that x1 and x2 are correlated
# with one another. Thus, in the following model which we could estimate, x1 would
# be correlated with the error term 
#
# y = beta0 + beta1 * x1 + error'
#
# Finally assume there exists some exogenous instrumental variable z which is 
# correlated with x1, but is not correlated with x2 (i.e., not correlated 
# error'). One way this might be expressed is with the following:
#
# x1 = alpha0 + alpha1 * x1_star + alpha2 * z
#
# where x1_star is the part of x1 that is correlated with x2, and z is assumed to
# be uncorrelated with the error' (i.e., uncorrelated with x2)

# Note to perform this simulation, we will first need to generate x1_star and x2
# that are correlated along with z that is uncorrelated with z1_star or x2. Then 
# we can generate x1 from the last equation above

## Generate Simulated Data -----------------------------------------------------

# Study Sample size
n <- 1000

# Next, describe the mean for x1 and x2 and the correlation matrix between x1 
# and x2
var_means <- c(30,20)
cov_matrix <- matrix(c(1, 0.6, 0.6, 1), 2, 2)

# Next generate random nomal correlated variables for x1_star and x2
tmp <- mvrnorm(n = n, mu = var_means, Sigma = cov_matrix)
x1_star <- tmp[, 1]
x2 <- tmp[, 2]

# generate random instrument z
z <- rnorm(n)

# finally generate x1
x1 <- x1_star + z

# check that x1 and x2 are correlated (meaning x1 and error' will be correlated)
cor(x1, x2)

# check that x2 and z are uncorrelated (meaning z and error' will be uncorrelated)
cor(x2, z)

# Note: x1 and z are correlated by construction
cor(x1, z)

# Finally, we can generate the outcome variable of interest
y <- 2 + x1 + x2 + rnorm(n)


## estimate the full model -----------------------------------------------------
fit_true <- lm(y ~ x1 + x2)

summary(fit_true)
confint(fit_true)


# Estimate what we would get if c was unobserved
fit_observed <- lm(y ~ x1)

summary(fit_observed)
confint(fit_observed)


#########################
#### 2SLS Estimation ####
#########################

## Manually perform 2SLS -------------------------------------------------------

stage1_fit <- lm(x1 ~ z)

stage2_fit <- lm(y ~ stage1_fit$fitted.values)

summary(stage2_fit)

confint(stage2_fit)

# Note: The parameter estimates will be correct by doing this manually, however
# the errors will not be

## Using the AER package -------------------------------------------------------
#install.packages("AER")
library(AER)

iv_fit <- ivreg(y ~ x1 | z)

summary(iv_fit)
confint(iv_fit)

####################################
#### Bootstrap to Estimate Bias ####
####################################

## The above provided one example to demonstrate the problem with an endogenous
## regressor

## Use bootstrapping to estimate the bias in the standard OLS estimate and show
## the consistency in the 2SLS IV estimator

## Write a function to generate a dataset with endogeneity, then estimate the
## treatment effect using a standard regression model, finally generate the 
## Estimate using the 2SLS estimation approach.

