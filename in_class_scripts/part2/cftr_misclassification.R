

rm(list=ls())
library(tidyverse)

#################################
#### Load data and functions ####
#################################

# Note: this is not the exact data that was used for the study. The actual Truven 
# MarketScan data is restricted. However, this is a simulated dataset that has 
# the same underlying distribution and will behave similarly.
load("R/SimEpi/example_data/cftr_data.RData")

# load Functions for analysis - this script contains some starter functions we 
# can use for this analysis
source("R/SimEpi/functions/cftr_functions.R")

###################
#### View Data ####
###################

# These are indicators of the different conditions that were analyzed. The 
# variable id, identifies the individual patient
dx_indicators

# These are the ids of the cases of patients with CF. Strata defines the 
# age-sex-enrollment strata they belong to and strata-size defines the size of 
# the given strata in the study population
cf_cases

# These are the matched non-CF cases. Note: this is nested for convenience in 
# future steps
non_carriers

# Unnest this data to see the actual patient IDs
non_carriers %>% 
  unnest()

carrier_strata_sizes

#################################
#### Define study parameters ####
#################################

# Case counts for the original study population and number of controls (note: 
# controls were matched 5:1 with cases)
case_count <- sum(carrier_strata_sizes$num_cases)
control_count <- case_count*5

# expected number of mis-classified cases based on standard screening panels
expected_misses <- round(0.00295*case_count) 


############################
#### Analysis Functions ####
############################

# To simplify this problem I have written a number of functions to perform the 
# statistical analysis we are interested in.

# To demonstrate how these functions work lets first build a simulated control
# cohort to match to our CF cases

# here is an example of how we might draw matched controls
cf_cases %>% 
  count(strata,name = "draw_num") %>% 
  inner_join(non_carriers) %>% 
  mutate(draw_num=draw_num*5) %>% 
  draw_non_carriers()

# store the ids of some matched controls
tmp_controls <- cf_cases %>% 
  count(strata,name = "draw_num") %>% 
  inner_join(non_carriers,by = "strata") %>% 
  mutate(draw_num=draw_num*5) %>% 
  draw_non_carriers() %>% 
  select(strata,controls) %>% 
  unnest(controls) %>% 
  rename(id = controls) %>% 
  mutate(case = 0L)

# now assemble the cf cases
tmp_cases <- cf_cases %>% 
  select(strata,id) %>% 
  mutate(case = 1L)

# combine to form a study population - then add indicators
tmp_study_pop <- bind_rows(tmp_controls,
                           tmp_cases) %>% 
  inner_join(dx_indicators, by = "id") 

# compute odds ratios for the study population
tmp_study_pop %>% 
  compute_odds_ratios() %>% 
  glimpse()

# we can also compute corresponding p-values using the epitools package. The
# alternative version of compute_odds_ratio2() does this
tmp_study_pop %>% 
  compute_odds_ratios2()

# for more complex analyses or two evaluate an empirical False Discovery Rate, 
# we may need to compute paired odds ratios using something like a conditional 
# logit model and then return the corresponding p-values or CIs. This can be 
# done using the get_paited_or() function
tmp_study_pop %>% 
  get_paired_or()


########################################
#### Write Main Simulation Function ####
########################################

# This will be the eventual function - the purpose of this function is to 
# construct a study population under the null hypothesis (of no effect) with a 
# given misclassification rate, where the argument mis_number gives the number
# of misclassified cases to include
draw_null_cohort <- function(mis_number = 0){
  
}


## Start by writing pseudo code and individual steps ---------------------------

# mis_number = 58

# 1) Draw 58 misclassified patients from those with CF (from strata in the the 
#    original population) - Identify which strata from

# 2) Draw the remaining cases from non-carriers (null assumption)


# 3) Draw the matched controls for each strata from non-carriers also


# 4) Compute statistics and store results

# 5) Repeat (10,000)

# 6) Analyze results in comparison to the original study design (misclassification - 
#    how often are results similar or more extreme; FD - how often do you get a 
#    significant result)






## Now implement function ------------------------------------------------------



####################################
#### Write Analytical Functions ####
####################################

# This function needs to simulate a null cohort, then generate results
sim_results <- function(mis_num = 0){
  
}


## Compute p-value for likelihood observed result due to misclassification -----
sim_mis_pval <- function(mis_num = 0, n_trials = 100){
  
}

## Compute number of times