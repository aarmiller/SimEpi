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
  ggplot(aes(tempF_new)) +
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

tmp_sample_size <- 200
tmp_frac_fever <- 0.05

## 1) Construct study population - sample() to draw temperatures from febrile 
##   group and non-febrile, where we draw sample_size*(fraction SSI) from febrile
##   group and sample_size*(1-fraction SSI) from non_febrile

SSI_cases <- round(tmp_sample_size*tmp_frac_fever)

nonSSI_cases <- tmp_sample_size-SSI_cases

# draw SSIs
SSI_patients <- sample(febrile_episodes$tempF_new, 
                       size = SSI_cases,
                       replace = TRUE)

# draw non SSIs
nonSSI_patients <- sample(non_febrile_episodes$tempF, 
                          size = nonSSI_cases,
                          replace = TRUE)


## 2) Compare mean difference between the two study groups - use the function
##    t.test() to give us this value
?t.test()
SSI_patients
nonSSI_patients

tmp_dat <- bind_rows(tibble(temp = SSI_patients,
                 SSI = 1L),
          tibble(temp = nonSSI_patients,
                 SSI = 0L))


tmp_res <- t.test(temp ~ SSI, data = tmp_dat)


## 3) Return the test statistic (in some form) - p-value (could also keep track 
##    of means for other purposes)

tmp_res$p.value

tmp_res$estimate


## Write the simulation function -----------------------------------------------

sample_sim <- function(sample_size, frac_fever = 0.05){
  
  # compute sample sizes
  SSI_cases <- round(sample_size*frac_fever)
  nonSSI_cases <- sample_size-SSI_cases
  
  # draw SSIs
  SSI_patients <- sample(febrile_episodes$tempF_new, 
                         size = SSI_cases,
                         replace = TRUE)
  # draw non SSIs
  nonSSI_patients <- sample(non_febrile_episodes$tempF, 
                            size = nonSSI_cases,
                            replace = TRUE)
  
  # assemble data
  tmp_dat <- bind_rows(tibble(temp = SSI_patients,
                              SSI = 1L),
                       tibble(temp = nonSSI_patients,
                              SSI = 0L))
  
  # run test
  tmp_res <- t.test(temp ~ SSI, data = tmp_dat)
  
  # output results
  c(tmp_res$p.value,tmp_res$estimate)
  
  
}


sample_sim(200)

sum(map_lgl(1:100, ~sample_sim(200)[1]<0.05))/200

## Write the simulation for multiple trials ------------------------------------

multi_sim <- function(sample_size,frac_fever=.1,trials=100,alpha = 0.05){

  # repeat sample_sim
  sum(map_lgl(1:trials, ~sample_sim(sample_size)[1]<0.05))/trials
  # calculate power - (count # sig p-value)/trials
  
}


multi_sim(sample_size = 200, frac_fever = 0.05, trials = 100)


###############################################
#### Iteration over different sample sizes ####
###############################################

## Write a function to iterate over multiple sample sizes ----------------------

sim_sample_sizes <- function(sample_sizes,frac_fever = 0.05, trials = 100){
  tibble(sample_size = sample_sizes) %>% 
    mutate(power = map_dbl(sample_size, ~multi_sim(sample_size = ., 
                                               frac_fever = frac_fever, 
                                               trials = trials)))
}

power_vals <- sim_sample_sizes(seq(from=50, to=310, by = 20), 
                               frac_fever = 0.05,
                               trials = 500)

# plot power results

power_vals %>% 
  ggplot(aes(sample_size,power)) +
  geom_line() +
  geom_hline(aes(yintercept = 0.8), color = "red", linetype = 2)
