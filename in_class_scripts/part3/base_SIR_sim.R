
rm(list=ls())
library(tidyverse)

###############################
#### Simulation Parameters ####
###############################

# Define parameter values for simulation

n_agents <- 1000           # Number of agents (patients) to simulate
n_days <- 100              # Number of days to run simulation



########################################
#### Simulation Procedure Functions ####
########################################

## Build Patients --------------------------------------------------------------

# Write a function that builds a set of agents for the simulator
build_patients <- function(){
  }

## Make Interactions -----------------------------------------------------------
make_interactions <- function(){ 
  }

## Update States ---------------------------------------------------------------
update_states <- function(){
}


############################################
#### Main Simulation Procedure Function ####
############################################



patients <- build_patients()

for (i in 1:100) {
  
  make_interactions()
  
  draw_transmissions()
  
  update_states()
  
}