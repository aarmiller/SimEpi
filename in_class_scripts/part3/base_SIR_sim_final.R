
rm(list=ls()) 
library(tidyverse)

##########################
#### Helper Functions ####
##########################

## Flip a vector of weighted coins ---------------------------------------------

flip_coin <- function(probs){
  #as.logical(rbinom(length(probs),1,probs))
  runif(length(probs))<probs
}

# flip_coin(c(0.1,0.3,0.5,0.6,0.9)) # example


###############################
#### Simulation Parameters ####
###############################

## Specify a simulation control function for holding parameters ----------------


sim_ctrl <- function(n_agents=1000, n_days = 100, susceptibility = .1, infectivity = .65,
                     duration = 7, init_infect = 2, daily_contacts = 3, contact_prob = NULL){
  
  # contact prob if using # of daily contacts
  if (is.null(contact_prob)) {contact_prob <- daily_contacts/n_agents}
  
  # constuct contact matrix
  cm <- matrix(contact_prob,n_agents,n_agents)
  diag(cm) <- 0                              # make diagonals 0
  cm[lower.tri(cm)] <- t(cm)[lower.tri(cm)]  # make symetric
  
  # build output parameter list
  list(n_agents = n_agents,             # Number of agents (patients or HCWs) to simulate
       n_days = n_days,                 # Number of days to run simulation)
       susceptibility = susceptibility, # how susceptible agents are
       infectivity = infectivity,       # how infective agents are that are infected
       duration = duration,             # how many periods the infection lasts
       init_infect = init_infect,       # initial number of infections to seed
       cm = cm)                         # contact matrix
}

# sim_ctrl(daily_contacts = 5) # example

########################################
#### Simulation Procedure Functions ####
########################################

## Build Patients --------------------------------------------------------------

# Write a function that builds a set of agents for the simulator

build_patients <- function(sim_params = sim_ctrl()){
  
  infect_index <- sample(sim_params$n_agents, size = sim_params$init_infect)
  
  tibble(agent = 1:sim_params$n_agents,
         time = 1L,
         state = ifelse(agent %in% infect_index, "I", "S"),
         days_infected = ifelse(state == "I", 1L, 0L),
         #days_infected = ifelse(state == "I", sample(1:duration,init_infect), 0L),
         susceptibility = sim_params$susceptibility,
         transmisibility = sim_params$infectivity,
         trans_ind = NA)
}

# build_patients() 

# sim_ctrl(susceptibility = 0.2) %>% 
#   build_patients() 


## Make Interactions -----------------------------------------------------------

# Write a function that makes the patients interact with one another and 
# determines what transmission occurred
make_interactions <- function(data, sim_params = sim_ctrl()){ 
  
  # Loop over agents
  
  # find infectious agents
  infectious_index <- which(data$state == "I")
  
  # create transmission vector placeholder
  trans_vec <- rep(FALSE, nrow(data))
  
  # looping over just infectious agents
  for (i in infectious_index){
    
    #### for each agent j != i
    
    # susceptibility of j * infectivity of i * contact probability 
    trans_prob <- data$susceptibility * data$transmisibility[i] * sim_params$cm[i,]
    
    # flip coin to determine transmissions
    tmp_trans_vec <- flip_coin(trans_prob)
    
    # add to our overall transmission vector
    trans_vec <- (trans_vec + tmp_trans_vec)>0
  }
  
  # add transmission indicator into data
  data %>% 
    mutate(trans_ind = trans_vec)
  
}

# build_patients() %>% 
#   make_interactions() %>% 
#   filter(trans_ind==TRUE)




## Update States ---------------------------------------------------------------

# Write a function that updates the states of all the agents in the simulator
# when we reach the end of a timestep

update_states <- function(data, sim_params = sim_ctrl()){
  
  # Update the the time step
  # Update the state from I to R if they hit the duration threshold
  out <- data %>% 
    mutate(time = time + 1L) %>% 
    mutate(state = ifelse(state == "I" & days_infected > sim_params$duration, "R", state))
  
  # add in the new infections from the trans_ind
  out <- out  %>% 
    mutate(state = ifelse(trans_ind==TRUE & state == "S", "I", state))
  
  # update the number of days infected
  out <- out  %>% 
    mutate(days_infected = ifelse(state == "I", days_infected+1L, 0L))
  
  return(out)
}

# build_patients() %>% 
#   make_interactions() %>% 
#   update_states() 

############################################
#### Main Simulation Procedure Function ####
############################################

## Build Single Simulation Function --------------------------------------------

# Write a function that incorporates the above steps to run through a single 
# trial of the simulation.

# Consider an intermediate function that computes statistics of interest at each
# stage of the simulation, then aggregate this into an output object

run_single_sim <- function(sim_params = sim_ctrl(), output_final_state = FALSE){
  
  # initial patients
  patients <- build_patients(sim_params = sim_params)
  
  # keep track of agent state history
  agent_history <- patients %>% 
    count(state) %>% 
    mutate(time = 0L)
  
  for (i in 1:sim_params$n_days) {
    
    # update patient states
    patients <- patients %>% 
      make_interactions(sim_params = sim_params) %>% 
      update_states(sim_params = sim_params)
    
    # update patient history
    tmp_agent_history <- patients %>% 
      count(state) %>% 
      mutate(time = i)
    
    # append patient history
    agent_history <- rbind(agent_history,tmp_agent_history)
    
    # how many infectious
    n_infectious <- sum(patients$state=="I")
    
    # stop simulation if no more infections 
    if (n_infectious == 0) { break }
    
  }
  
  if (output_final_state){
    
    # return output with final state
    return(list(agent_history = agent_history,
                final_state = patients))
    
  } else {
    
    return(agent_history)
    
  }
  
}

# run_single_sim(output_final_state = TRUE)

## Build Multiple Trial Simulation Function ------------------------------------

# Write final simulation function that allows for multiple trials (later you may
# want to rewrite this to run in parallel)

run_sim <- function(trials = 10, sim_params = sim_ctrl()){
  
  tibble(trials = 1:trials) %>% 
    mutate(results = map(trials, ~run_single_sim(sim_params = sim_params))) %>% 
    unnest(cols = c(results))
  
}

res <- run_sim()

## Parallel Version of Run Sim -------------------------------------------------

library(parallel)
detectCores(logical = FALSE)


run_sim_mc <- function(trials = 10, sim_params = sim_ctrl(), cores = 4){
  
  tmp <- mclapply(1:trials,
                  function(x) run_single_sim(sim_params = sim_params), 
                  mc.cores = cores)
  
  res <- enframe(tmp,name = "trials") %>% 
    unnest(cols = c(value))
 
  return(res) 
}

# generate results for 100 trials using 5 cores
tmp <- run_sim_mc(trials = 100, cores = 5)


###########################
#### Visualize Results ####
###########################

## Visualize average trend across trials ---------------------------------------

tmp %>% 
  pivot_wider(names_from = state, 
              values_from = n,
              values_fill = 0) %>% 
  group_by(time) %>% 
  summarise_at(vars(I:R), list(mean)) %>% 
  pivot_longer(cols = I:R,
               names_to = "state",
               values_to = "n") %>% 
  ggplot(aes(x = time, y = n, color = state)) +
  geom_line() 


## Visualize curves across all simulations -------------------------------------

tmp %>% 
  ggplot(aes(time,n,order = as.factor(trials))) +
  geom_line(alpha = 0.25) +
  facet_wrap(~state, scale = "free_y")


# overlay mean

means_vals <- tmp %>% 
  pivot_wider(names_from = state, 
              values_from = n,
              values_fill = 0) %>% 
  group_by(time) %>% 
  summarise_at(vars(I:R), list(mean)) %>% 
  pivot_longer(cols = I:R,
               names_to = "state",
               values_to = "mean_n")

# Add mean to graph
tmp %>% 
  inner_join(means_vals) %>% 
  ggplot(aes(time,n,order = as.factor(trials))) +
  geom_line(alpha = 0.25) +
  geom_line(aes(time,mean_n, color = state), size = 1) +
  facet_wrap(~state, scale = "free_y") +
  theme_bw()

