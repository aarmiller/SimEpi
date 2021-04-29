
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

# test that the matrix is symmetric
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

## Helper function -------------------------------------------------------------

# Write a function that flips a weighted coin for a vector of probability
# values where the probability values reflect the weight

# flip a weighted coin with 10% probability of true
runif(1) < 0.1

# we want to do the same thing with a vector of different probability values

c(0.1,0.3,0.5,0.6,0.9)

as.logical(rbinom(5,1,c(0.1,0.3,0.5,0.6,0.9)))

flip_coin <- function(probs){
  #as.logical(rbinom(length(probs),1,probs))
  runif(length(probs))<probs
}

flip_coin(c(0.1,0.3,0.5,0.6,0.9))


## Make Interactions -----------------------------------------------------------

# Write a function that makes the patients interact with one another and 
# determines what transmission occurred

# implementation from class
make_interactions <- function(data){ 
  
  # Loop over agents
  
  # How to do this efficiently?
  
  # for each agent i (who is infectious)
  
  # find infectious agents
  infectious <- data %>% 
    filter(state == "I")
  
  # create transmission vector placeholder
  trans_vec <- rep(FALSE, nrow(data))
  
  # looping over infectious agents
  for (i in 1:nrow(infectious)){
   
    #### for each agent j != i
    
    ####### draw contact with probability cm[i,j]
    
    ####### if this contact is drawn then determine if transmission occurs and 
    ####### update trans_ind to reflect transmission
    
    agent_index <- infectious$agent[i]
    
    # susceptibility of j * infectivity of i * contact probability 
    trans_prob <- data$susceptibility * infectious$transmisibility[i] * cm[agent_index,]
    
    # flip to determine transmissions
    tmp_trans_vec <- flip_coin(trans_prob)
    
    # add to our overall transmission vector
    trans_vec <- (trans_vec + tmp_trans_vec)>0
  }
  
  # add transmission indicator into data
  data %>% 
    mutate(trans_ind = trans_vec)
  
}


# a better implementation
make_interactions <- function(data){ 
  
  # Loop over agents
  
  # find infectious agents
  infectious_index <- which(data$state == "I")
  
  # create transmission vector placeholder
  trans_vec <- rep(FALSE, nrow(data))
  
  # looping over just infectious agents
  for (i in infectious_index){
    
    #### for each agent j != i
    
    # susceptibility of j * infectivity of i * contact probability 
    trans_prob <- data$susceptibility * data$transmisibility[i] * cm[i,]
    
    # flip coin to determine transmissions
    tmp_trans_vec <- flip_coin(trans_prob)
    
    # add to our overall transmission vector
    trans_vec <- (trans_vec + tmp_trans_vec)>0
  }
  
  # add transmission indicator into data
  data %>% 
    mutate(trans_ind = trans_vec)
  
}

build_patients() %>% 
  make_interactions() %>% 
  filter(trans_ind==TRUE)




## Update States ---------------------------------------------------------------

# Write a function that updates the states of all the agents in the simulator
# when we reach the end of a timestep

update_states <- function(data){
  
  # Update the the time step
  # Update the state from I to R if they hit the duration threshold
  out <- data %>% 
    mutate(time = time + 1L) %>% 
    mutate(state = ifelse(state == "I" & days_infected > duration, "R", state))
  
  # add in the new infections from the trans_ind
  out <- out  %>% 
    mutate(state = ifelse(trans_ind==TRUE & state == "S", "I", state))
  
  # update the number of days infected
  out <- out  %>% 
    mutate(days_infected = ifelse(state == "I", days_infected+1L, 0L))
  
  return(out)
}


build_patients() %>% 
  make_interactions() %>% 
  update_states() %>% 
  make_interactions() %>% 
  update_states() %>% 
  make_interactions() %>% 
  update_states() %>% 
  make_interactions() %>% 
  update_states() %>% 
  make_interactions() %>% 
  update_states() %>%
  make_interactions() %>% 
  update_states() %>% 
  make_interactions() %>% 
  update_states() %>% 
  make_interactions() %>% 
  update_states() %>% 
  make_interactions() %>% 
  update_states() %>% 
  count(state)


############################################
#### Main Simulation Procedure Function ####
############################################

## Build Simulator -------------------------------------------------------------

# Combine each of the previous functions to run through a simulation

patients <- build_patients()

for (i in 1:n_days) {
  
  make_interactions()
  
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