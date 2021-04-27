
rm(list=ls())
library(tidyverse)

###############################
#### Simulation Parameters ####
###############################

# Define parameter values for simulation

n_agents <- 1000           # Number of agents (patients or HCWs) to simulate
n_days <- 100              # Number of days to run simulation



########################################
#### Simulation Procedure Functions ####
########################################

## Build Patients --------------------------------------------------------------

# Write a function that builds a set of agents for the simulator

build_patients <- function(){
  }

## Make Interactions -----------------------------------------------------------

# Write a function that makes the patients interact with one another

make_interactions <- function(){ 
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

for (i in 1:100) {
  
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