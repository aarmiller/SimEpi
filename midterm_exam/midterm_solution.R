
############################################################
### Midterm - Simulation In Epidemiology Spring 2021
### Example Solution
############################################################

# Note: You answers may differ quite a bit...this is just one example of how
#       to approach the problem
rm(list=ls())
library(tidyverse)


#######################################
#### Build Datasets for Simulation ####
#######################################

load("data/ia_county_pop_2017.RData")

county_data <- ia_county_2017 %>% 
  filter(hispanic=="Total",
         race == "All races") %>% 
  filter(age_group %in% c("Total population","65 to 69 years of age",
                          "70 to 74 years of age","75 to 79 years of age",
                          "80 to 84 years of age","85 years of age and over")) %>% 
  mutate(age65=ifelse(age_group=="Total population","total_population","pop_over_65")) %>% 
  group_by(county,age65) %>% 
  summarise_at(vars(total:female), funs(sum)) %>% 
  select(county:total) %>% 
  pivot_wider(names_from = age65, values_from = total) %>% 
  ungroup()

county_covid <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")

county_cases_dec15 <- county_covid %>% 
  filter(state=="Iowa") %>% 
  filter(date=="2020-12-15") %>% 
  select(county,covid_cases=cases)


county_data <- county_data %>% 
  ungroup() %>% 
  inner_join(county_cases_dec15, by = "county")

county_data

# here the above steps have been saved
load("data/midterm_sim_data.RData")


# load the projection data
load("data/weekly_supply_projection.RData")

####################################
#### Write Simulation Functions ####
####################################


## Initialization Function -----------------------------------------------------

initialize_counties <- function(data){
  data %>% 
    mutate(pop_pct=total_population/sum(total_population),
           pop_65_pct=pop_over_65/sum(pop_over_65),
           under65_threshold = (total_population-pop_over_65)*0.70,
           over65_threshold = pop_over_65*0.90,
           under65_vac = 0,
           over65_vac = 0)
}

# test function
county_data %>% 
  initialize_counties()


## Allocation Function ---------------------------------------------------------

allocate_vaccine_pop <- function(data,n){
  
  # This is the main step
  out <- data %>% 
    mutate(allocation=round(n*pop_pct))
  
  # The following is used to correct for rounding errors
  total_allocated <- sum(out$allocation)
  
  pos_counties <- out %>% 
    filter(allocation>0) %>% 
    select(county)
  
  if (total_allocated>n){
    num_to_remove <- total_allocated-n
    counties_to_reduce <- sample(pos_counties$county,num_to_remove)
    out <- out %>% 
      filter(allocation>0) %>% 
      mutate(allocation=ifelse(county %in% counties_to_reduce,
                               allocation-1, allocation))
    
  } else if (total_allocated<n){
    num_to_add <- n - total_allocated
    counties_to_reduce <- sample(1:99,num_to_add)
    out <- out %>% 
      mutate(allocation=ifelse(row_number() %in% counties_to_reduce,
                               allocation+1, allocation))
  }
  
  return(out)
}


# test function
county_data %>% 
  initialize_counties() %>% 
  allocate_vaccine_pop(5000) %>% 
  glimpse()


## Distribution Function -------------------------------------------------------

distribute_vaccine <- function(data){
  data %>% 
    mutate(max_over65=ifelse(over65_vac>=over65_threshold,0,over65_threshold-over65_vac),
           max_under65=ifelse(under65_vac>=under65_threshold,0,under65_threshold-under65_vac)) %>% 
    mutate(to65=ifelse(max_over65<allocation,max_over65,allocation),
           to_under65=ifelse(max_under65<(allocation-to65),max_under65,(allocation-to65))) %>% 
    mutate(over65_vac=over65_vac+to65,
           under65_vac=under65_vac+to_under65) %>% 
    select(-max_over65,-max_under65,-to65,-to_under65)
}

# test function
county_data %>% 
  initialize_counties() %>% 
  allocate_vaccine_pop(50000) %>% 
  distribute_vaccine() %>% 
  summarise(tot_allocate = sum(allocation),
            tot_distribute = sum(under65_vac,over65_vac))


county_data %>% 
  initialize_counties() %>% 
  allocate_vaccine_pop(5000000) %>% 
  distribute_vaccine() %>% 
  summarise(tot_allocate = sum(allocation),
            tot_distribute = sum(under65_vac,over65_vac))



## Loop to run simulation Function ---------------------------------------------


run_sim <- function(county_level_data,weekly_supply_data){
  
  county_holder <- list()
  
  county_holder[[1]] <- initialize_counties(county_level_data) 
  
  for (i in 2:(nrow(weekly_supply_data)+1)){
    
    county_holder[[i]] <- county_holder[[i-1]] %>% 
      allocate_vaccine_pop(weekly_supply_data$new_supply[i-1]) %>% 
      distribute_vaccine() %>% 
      mutate(date=weekly_supply_data$week_date[i-1])
  }
  
  out <- bind_rows(county_holder)
  
  return(out)
  
}

# test function
run_sim(county_data,weekly_supply_data = weekly_supply)

run_sim(county_data,weekly_supply_data = weekly_supply) %>% 
  group_by(date) %>% 
  summarise(under65 = sum(under65_vac),
            over65 = sum(over65_vac)) %>% 
  pivot_longer(under65:over65,names_to = "Age Group", values_to = "value") %>% 
  ggplot(aes(date,value,color = `Age Group`)) +
  geom_line()


###################################
#### Add stochastic components ####
###################################


## Update Initialization Function ----------------------------------------------

## Example Function for drawing random threshold -------------------------------

# This uses a negative binomial distribution to draw thresholds with the same 
# mean but with a tail skewed to the left

draw_threshold <- function(mean_pct){
  # draw value
  x <- 1-rnbinom(99, 10, mu = (100-mean_pct))/100
  # make sure not to return negative values
  ifelse(x<0,0,x)
}

draw_threshold(90) %>% 
  hist()


## Updated initialization function -------------------------------------------------
initialize_counties <- function(data){
  data %>% 
    mutate(pop_pct=total_population/sum(total_population),
           pop_65_pct=pop_over_65/sum(pop_over_65),
           under65_threshold = (total_population-pop_over_65)*draw_threshold(70),
           over65_threshold = pop_over_65*draw_threshold(90),
           under65_vac = 0,
           over65_vac = 0)
}

# test random draws
county_data %>% 
  initialize_counties()

## Justification for stochastic component --------------------------------------

# provide a brief summary justifying your choice of distribution for example

# ANSWERS WILL VARY - But the above randomization generates random values with
# the correct mean but skewed with a long tail to the left. It also will not 
# generate values outside of (0,1)


######################################
#### Evaluate Different Scenarios ####
######################################


## Create alternative allocation functions -------------------------------------


## Vaccine allocation pop65 ----------------------------------------------------
allocate_vaccine_pop65 <- function(data,n){
  
  out <- data %>% 
    mutate(allocation=round(n*pop_65_pct))
  
  total_allocated <- sum(out$allocation)
  
  pos_counties <- out %>% 
    filter(allocation>0) %>% 
    select(county)
  
  if (total_allocated>n){
    num_to_remove <- total_allocated-n
    counties_to_reduce <- sample(pos_counties$county,num_to_remove)
    out <- out %>% 
      filter(allocation>0) %>% 
      mutate(allocation=ifelse(county %in% counties_to_reduce,
                               allocation-1, allocation))
    
  } else if (total_allocated<n){
    num_to_add <- n - total_allocated
    counties_to_reduce <- sample(1:99,num_to_add)
    out <- out %>% 
      mutate(allocation=ifelse(row_number() %in% counties_to_reduce,
                               allocation+1, allocation))
  }
  
  return(out)
}


## Vaccine allocation equal ----------------------------------------------------
allocate_vaccine_equal <- function(data,n){
  
  out <- data %>% 
    mutate(allocation=round(n/99))
  
  total_allocated <- sum(out$allocation)
  
  pos_counties <- out %>% 
    filter(allocation>0) %>% 
    select(county)
  
  if (total_allocated>n){
    num_to_remove <- total_allocated-n
    counties_to_reduce <- sample(pos_counties$county,num_to_remove)
    out <- out %>% 
      filter(allocation>0) %>% 
      mutate(allocation=ifelse(county %in% counties_to_reduce,
                               allocation-1, allocation))
    
  } else if (total_allocated<n){
    num_to_add <- n - total_allocated
    counties_to_reduce <- sample(1:99,num_to_add)
    out <- out %>% 
      mutate(allocation=ifelse(row_number() %in% counties_to_reduce,
                               allocation+1, allocation))
  }
  
  return(out)
}


## Vaccine allocation case history  ----------------------------------------------------
allocate_vaccine_case_history <- function(data,n,frac_identified = .25){
  
  out <- data %>% 
    mutate(covid_cases = covid_cases/frac_identified,
           pop_immune = total_population-covid_cases,
           immune_pct = pop_immune/sum(pop_immune)) %>% 
    mutate(allocation=round(n*immune_pct))
  
  total_allocated <- sum(out$allocation)
  
  pos_counties <- out %>% 
    filter(allocation>0) %>% 
    select(county)
  
  if (total_allocated>n){
    num_to_remove <- total_allocated-n
    counties_to_reduce <- sample(pos_counties$county,num_to_remove)
    out <- out %>% 
      filter(allocation>0) %>% 
      mutate(allocation=ifelse(county %in% counties_to_reduce,
                               allocation-1, allocation))
    
  } else if (total_allocated<n){
    num_to_add <- n - total_allocated
    counties_to_reduce <- sample(1:99,num_to_add)
    out <- out %>% 
      mutate(allocation=ifelse(row_number() %in% counties_to_reduce,
                               allocation+1, allocation))
  }
  
  return(out)
}




## Update run_sim() function to include allocation options ---------------------

run_sim <- function(county_level_data,weekly_supply_data,allocation_method = "pop"){
  
  county_holder <- list()
  
  county_holder[[1]] <- initialize_counties(county_level_data) 
  
  if (allocation_method == "pop"){
    allocate_vaccine <- allocate_vaccine_pop
  } else if (allocation_method == "pop65"){
    allocate_vaccine <- allocate_vaccine_pop65
  } else if (allocation_method == "equal") {
    allocate_vaccine <- allocate_vaccine_equal
  } else {
    allocate_vaccine <- allocate_vaccine_case_history
  }
  
  for (i in 2:(nrow(weekly_supply_data)+1)){
    
    county_holder[[i]] <- county_holder[[i-1]] %>% 
      allocate_vaccine(weekly_supply_data$new_supply[i-1]) %>% 
      distribute_vaccine() %>% 
      mutate(date=weekly_supply_data$week_date[i-1])
  }
  
  out <- bind_rows(county_holder)
  
  return(out)
  
}


# test out function
run_sim(county_data,weekly_supply_data = weekly_supply,allocation_method = "equal") %>% 
  group_by(date) %>% 
  summarise(under65 = sum(under65_vac),
            over65 = sum(over65_vac)) %>% 
  pivot_longer(under65:over65,names_to = "Age Group", values_to = "value") %>% 
  ggplot(aes(date,value,color = `Age Group`)) +
  geom_line()

# compare different methods
bind_rows(run_sim(county_data,weekly_supply_data = weekly_supply,allocation_method = "pop") %>% 
            mutate(method = "pop"),
          run_sim(county_data,weekly_supply_data = weekly_supply,allocation_method = "pop65") %>% 
            mutate(method = "pop65"),
          run_sim(county_data,weekly_supply_data = weekly_supply,allocation_method = "equal") %>% 
            mutate(method = "equal"),
          run_sim(county_data,weekly_supply_data = weekly_supply,allocation_method = "case_history") %>% 
            mutate(method = "case_history")) %>% 
  group_by(date,method) %>% 
  summarise(under65 = sum(under65_vac),
            over65 = sum(over65_vac)) %>% 
  pivot_longer(under65:over65,names_to = "Age Group", values_to = "value") %>% 
  ggplot(aes(date,value,color = `Age Group`)) +
  geom_line() +
  facet_wrap(~method)



## Evaluate different outcomes across multiple trials --------------------------

# it is probably easiest to write a new function around what you want to look at


# suppose we want to run a simulation then compute a number of metrics (here we
# compute the number of doses distributed in each group, as percentage of total, 
# the total amount of derived immunity and the amount wasted)

run_sim(county_data,weekly_supply_data = weekly_supply,allocation_method = "equal") %>% 
  group_by(date) %>% 
  summarise(under65_vac = sum(under65_vac),
            over65_vac = sum(over65_vac),
            tot_vac = sum(under65_vac,over65_vac), 
            under65_pct_vac = 100*under65_vac/sum(total_population-pop_over_65),
            over65_pct_vac = 100*over65_vac/sum(pop_over_65),
            tot_immunity = tot_vac + sum(covid_cases),
            allocation = sum(allocation)) %>% 
  mutate(vaccine_waste = cumsum(allocation)-tot_vac)

# now we can put this into a function
run_sim2 <- function(county_data,weekly_supply_data = weekly_supply,allocation_method = "equal"){
  run_sim(county_data,weekly_supply_data = weekly_supply,
          allocation_method = allocation_method) %>% 
    group_by(date) %>% 
    summarise(under65_vac = sum(under65_vac),
              over65_vac = sum(over65_vac),
              tot_vac = sum(under65_vac,over65_vac), 
              under65_pct_vac = 100*under65_vac/sum(total_population-pop_over_65),
              over65_pct_vac = 100*over65_vac/sum(pop_over_65),
              tot_immunity = tot_vac + sum(covid_cases),
              allocation = sum(allocation)) %>% 
    mutate(vaccine_waste = cumsum(allocation)-tot_vac)
}

run_sim2(county_data, weekly_supply,"equal")


run_trials <- function(county_data,weekly_supply_data = weekly_supply,
                       allocation_method = "equal", n_trials = 10){
  
  tibble(trial = 1:n_trials) %>% 
    mutate(data = map(trial, ~run_sim2(county_data = county_data, 
                                      weekly_supply_data = weekly_supply_data,
                                      allocation_method = allocation_method))) %>% 
    unnest(data)
}


# simulate results for population distribution
tmp_pop <- run_trials(county_data, weekly_supply,"pop")

# view metrics
tmp_pop %>% 
  select(trial,date,under65_pct_vac,over65_pct_vac,tot_immunity,vaccine_waste) %>% 
  pivot_longer(under65_pct_vac:vaccine_waste,names_to = "measure", values_to = "value") %>% 
  ggplot(aes(date,value, color = as.factor(trial))) +
  geom_line() +
  facet_wrap(~measure, scales = "free_y")


# simulate results for equal distribution
tmp_equal <- run_trials(county_data, weekly_supply,"equal")

# view metrics
tmp_equal %>% 
  select(trial,date,under65_pct_vac,over65_pct_vac,tot_immunity,vaccine_waste) %>% 
  pivot_longer(under65_pct_vac:vaccine_waste,names_to = "measure", values_to = "value") %>% 
  ggplot(aes(date,value, color = as.factor(trial))) +
  geom_line() +
  facet_wrap(~measure, scales = "free_y")
