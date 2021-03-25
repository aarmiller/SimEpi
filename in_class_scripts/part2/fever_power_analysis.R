rm(list=ls())
library(tidyverse)

#########################################################################
#### Sample Size Simulation - Using thermometers for early detection ####
#########################################################################

# Motivation: We would like to design a study where we use a thermometer to detect 
# the early signs of an infection. For example, suppose we want to actively monitor 
# for Surgical-Site Infections (SSIs). We might send patients home with a thermometer 
# and ask the to text (or remotely send) their temperature readings. We could then 
# try to intervene quicker on the patients where we think a fever was detected.

#### NOTE....THIS IS NOT REAL DATA. This is based on actual termpature data...but 
#### the actual data used to produce these are restricted use. However, this data 
#### was randomly generated to behave like the actual temperature data (i.e., 
#### preserve the distributional structure). We used the distribution and summary
#### statistics in prior published work to generate these data.

# load in temperature taking episodes
load("R/SimEpi/example_data/temperature_episodes.RData")

# summarize the datasets
febrile_episodes
febrile_episodes %>% summary()      # These are normal temperatures

# histogram of febrile episodes
febrile_episodes %>% 
  ggplot(aes(tempF)) +
  geom_histogram() +
  ggtitle("Readings during febrile episodes")

non_febrile_episodes
non_febrile_episodes %>% summary()  # These are illness temperatures where a fever was recorded during an episode

non_febrile_episodes %>% 
  ggplot(aes(tempF)) +
  geom_histogram() +
  ggtitle("Readings during non-febrile episodes")

# Plot histogram of temperatures by episode type
bind_rows(febrile_episodes,
          non_febrile_episodes) %>% 
  ggplot(aes(tempF)) +
  geom_histogram(bins=80) +
  geom_vline(aes(xintercept=100),color="red") +
  facet_wrap(~fever_episode,ncol = 1,scales = "free_y")


#############################################################
#### Simulation to compute power for a given sample size ####
#############################################################

# Assume we want to conduct a power analysis for a study in which we believe 5%
# of surgeries will result in a SSI.

# We will assume for this simulation that we will be comparing individuals after
# we have determined who has and has not had a SSI

# Assume we will use a t test to compare differences (just for simplicity)

t.test()


## Start by writing the pseudo code for this problem ---------------------------



## Write the simulation function -----------------------------------------------

sample_sim <- function(sample_size, frac_fever = 0.05){
  
}


## Write the simulation for multiple trials ------------------------------------

multi_sim <- function(sample_size,frac_fever=.1,trials=100){

  }


###############################################
#### Iteration over different sample sizes ####
###############################################

## Write a function to iterate over multiple sample sizes ----------------------
