
rm(list=ls())
library(tidyverse)

###############################
#### Simulation Parameters ####
###############################

n <- 1000 # Sample size for simulation

trials <- 1000  # Number of trials for simulation


###############################
#### Simulate Example Data ####
###############################

## Simulate example study population -------------------------------------------

## For this problem model a binary outcome and a binary exposure/treatment (e.g.,
## smoking and risk for lung cancer)

## Generate a dataset of n individuals and randomly assign treatment/exposure, 
## then randomly assign an outcome. First, randomly assign exposure to some of 
## the n=1,000 individuals. Second, compute the probability of the outcome based
## on the assigned exposure. Third, randomly generate the outcome based on the 
## computed probability of exposure

## Assume roughly 50% of people are exposed 

## Assume the probability of the outcome being 1 is 50% on average and assume
## the exposure/treatment increases the probability of the outcome being 1 by
## 0.05 (i.e., the corresponding probability for exposed and unexposed are 0.475
## and 0.525).





## Estimate p-value ------------------------------------------------------------

## Select some sort of statistical model to compute a p-value corresponding to
## a statistical test comparing the difference in outcomes between exposed and 
## non-exposed individuals.


#########################################
#### Simulate P-Value Interpretation ####
#########################################

## Develop a simulation that can demonstrate the correct interpretation of a 
## p-value. To do this, you should repeatedly generate data under the null 
## hypothesis then compute a corresponding p-value to test for differences 
## between groups






#######################################
#### Simulate Assumption Violation ####
#######################################

## Develop a simulation to demonstrate that the correct interpretation of a 
## p-value fails when the assumptions of the statistical model/test are 
## violated. Reason from this simulation what this tells us about the validity 
## of a p-value when a test is inappropriately applied.

## Hint: One way to approach this term is to add a correlated error component,
##       that is correlated with the exposure. Similarly you could add an 
##       omitted confounding variable that is correlated with exposure.
