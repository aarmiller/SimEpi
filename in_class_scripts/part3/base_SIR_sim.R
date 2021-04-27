
rm(list=ls())
library(tidyverse)

###############################
#### Simulation Parameters ####
###############################

# Define parameter values for simulation

n_agents <- 1000           # Number of agents (patients or HCWs) to simulate
n_days <- 100              # Number of days to run simulation

# contact (note this usually comes from data)
daily_contacts <- 3
contact_prob <- daily_contacts/n_agents

# transmission (defined by the disease)
susceptibility <- .1
infectivity <- .65      # this should be a function of duration

# state transitions
duration <- 7  # this may need to be stochastic

# start off the simulator (seeding)
init_infect <- 2

## Parameter Data Structures ---------------------------------------------------

# contact matrix
cm <- matrix(contact_prob,n_agents,n_agents)
#cm <- matrix(rnorm(mean=contact_prob,sd = 0.00001,8*8),8,8)
# make diagonals 0
diag(cm) <- 0
# make symettric
cm[lower.tri(cm)] <- t(cm)[lower.tri(cm)]

cm[1:3,1:3]

########################################
#### Simulation Procedure Functions ####
########################################

## Build Patients --------------------------------------------------------------

# Write a function that builds a set of agents for the simulator

build_patients <- function(){
  
  infect_index <- sample(n_agents, size = init_infect)
  
  tibble(agent = 1:n_agents,
         time = 1L,
         state = ifelse(agent %in% infect_index, "I", "S"),
         days_infected = ifelse(state == "I", 1L, 0L),
         #days_infected = ifelse(state == "I", sample(1:duration,init_infect), 0L),
         susceptibility = susceptibility,
         transmisibility = infectivity,
         trans_ind = NA)
}

build_patients() 

build_patients() %>% filter(state=="I")

## Make Interactions -----------------------------------------------------------

# Write a function that makes the patients interact with one another

make_interactions <- function(){ 
  
  # Loop over agents
  
  # How to do this efficiently?
  
  # for each agent i
  
  #### for each agent j != i
  
  ####### draw contact with probability cm[i,j]
  
  ####### if this contact is drawn then update trans_indicator or trans_vector
  
  }

## Draw Transmission Events ----------------------------------------------------

# Write a function that determines which infections occur (when infected and 
# susceptible agents interact)

draw_transmissions <- function(){
  
  }

## Update States ---------------------------------------------------------------

# Write a function that updates the states of all the agents in the simulator
# when we reach the end of a timestep

update_states <- function(){
  
  }


############################################
#### Main Simulation Procedure Function ####
############################################

## Build Simulator -------------------------------------------------------------

# Combine each of the previous functions to run through a simulation

patients <- build_patients()

for (i in 1:n_days) {
  
  make_interactions()
  
  draw_transmissions()
  
  update_states()
  
  }

## Build Simulation Functions --------------------------------------------------




# Write a function that incorporates the above steps to run through a single 
# trial of the simulation.

# Consider an intermediate function that computes statistics of interest at each
# stage of the simulation, then aggregate this into an output object

run_single_sim <- function(){
  
  }


# Write final simulation function that allows for multiple trials (later you may
# want to rewrite this to run in parallel)

run_sim <- function(trials = 100){
  
  }