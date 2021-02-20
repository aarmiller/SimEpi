
rm(list=ls())
# This function covers an introduction to iteration in R


########################
#### Random Numbers ####
########################

# random uniform
runif(10)

# random normal
rnorm(10)

# modifying parameters
runif(10, min = 2, max = 5)
rnorm(10, mean = 10, sd = 3)

# sample from a vector 
sample(x = c("Heads","Tails"), size = 1)
sample(x = c("Heads","Tails"), size = 3, replace = TRUE)


# function for examples
flip_coin <- function(n=1){
  sample(x = c("Heads","Tails"), size = n, replace = TRUE)
}

flip_coin()


###################
#### For Loops ####
###################

for (i in 1:10){
  flip_coin()
}

# to see output printed you have to explicitly print
for (i in 1:10){
  print(flip_coin())
}

# using the index
for (i in 1:10){
  print(flip_coin(i))
}

# using the index to create output vector
out_vec <- vector(mode = "character", length = 10)
for (i in 1:10){
  out_vec[i] <- flip_coin()
}
out_vec

# using the index to create output list
out_list <- list()
for (i in 1:10){
  out_list[[i]] <- flip_coin(i)
}
out_list

## looping over other vectors --------------------------------------------------

# custom vectors
for (i in c(10,20,50)){
  print(i)
}

# character vectors
for (i in state.abb){
  print(i)
}

# across column names in data.frame
for (i in seq_along(mtcars)){
  print(i)
  print(names(mtcars[i]))
}


#####################
#### While Loops ####
#####################

# using stopping criteria
out_vec <- vector()
while (length(out_vec)<10){
  out_vec <- c(out_vec,flip_coin())
}
out_vec

# using iteration
out_vec <- vector()
iter <- 1
while (iter<=10){
  out_vec <- c(out_vec,flip_coin())
  iter <- iter + 1
}
out_vec

# flip coin until 5 heads come up
out_vec <- vector() 
num_heads <- 0     # place holder for count of heads
while (num_heads<5){
  out_vec <- c(out_vec,flip_coin())  
  num_heads <- sum(out_vec=="Heads")   # count number of heads
}
out_vec

#########################
#### Apply Functions ####
#########################

## lapply ---------------------------------------------------------------------- 
# apply function over lists
lapply(1:10, flip_coin)

lapply(1:10, flip_coin(n = 1))

lapply(1:10,function(x) flip_coin(n = 1))


## sapply ----------------------------------------------------------------------
# simplify apply results
sapply(1:10, flip_coin)

sapply(1:10,function(x) flip_coin(n = 1))


## mapply ----------------------------------------------------------------------
# if we have multiple arguments
mapply(flip_coin, 1:10)
mapply(function(x) flip_coin(n = 1),1:10)

# add together 2 values
add_nums <- function(x,y) x+y

mapply(add_nums, 1:3, 4:6)


# add together 2 values then divide by the third
mapply(function(x,y,z) (x+y)/z, 1:3, 4:6, 7:9)

## Vectorizing a function ------------------------------------------------------

# create a function to compute factorials
factorial(5)

prod(1:5)

new_factorial <- function(x){
  prod(1:x)
}

new_factorial(5)

# notice this is not vectorized
new_factorial(c(3,5))

vec_factorial <- Vectorize(new_factorial)

vec_factorial(c(3,5))

# Note: Vectorize is simply a wrapper function around mapply
?Vectorize

mapply(new_factorial,c(3,5))



#############################
#### purrr map functions ####
#############################

library(tidyverse)

## map -------------------------------------------------------------------------
# map over a single vector/list

map(1:10,flip_coin)

# create function using ~ and .
map(1:10, ~flip_coin(1))

map(1:10, ~flip_coin(.))

# convert output to vector
map_chr(1:10, ~flip_coin(1))

map_lgl(1:10, ~flip_coin(1))
map_int(1:10, ~flip_coin(1))

map_lgl(1:10, ~flip_coin(1)=="Heads")
map_int(1:10, ~flip_coin(1)=="Heads")


## map2 ------------------------------------------------------------------------
# map over two vectors/lists
add_nums <- function(x,y) x+y

map2_dbl(1:10, 11:20, add_nums)


# creating function using ~ .x and .y
map2(1:10, 11:20, ~ .x + .y)


# convert output to vector
map2_int(1:10, 11:20, add_nums)
map2_chr(1:10, 11:20, add_nums)


## pmap ------------------------------------------------------------------------
# map over multiple lists/vectors
add_divide_nums <- function(x,y,z) (x+y)/z

pmap(list(1:3,4:6,7:9),add_divide_nums)


# create function
pmap_dbl(list(c=1:3,a=4:6,b=7:9),function(a,b,c) (a+b)/c)


# convert to vector
pmap_dbl(list(1:3,4:6,7:9),add_divide_nums)


## using map inside tidyverse --------------------------------------------------

load("data/nhds/nhds_adult.RData")

tmp_data <- nhds_adult %>% 
  select(age_years) %>% 
  slice(1:100)

# note this is not the efficient way to do this
tmp_data %>% # make smaller so this performs quicker
  mutate(age_days=map(age_years, ~.*365L)) 

tmp_data %>% # make smaller so this performs quicker
  mutate(age_days=map_int(age_years, ~.*365L))

# using unnest to pull out age
tmp_data %>% # make smaller so this performs quicker
  mutate(age_days=map(age_years, ~.*365L)) %>% 
  unnest(age_days)


# where this really comes in handy
# let's say we want to run a regression model for each region where we predict
# los as a function of sex, age, and admission type
library(broom)

tmp_data <- nhds_adult %>% 
  select(region,care_days,age_years,sex,adm_type) %>% 
  group_by(region) %>% 
  nest()

tmp_data
tmp_data$data[[1]]

mod_res <- tmp_data %>% 
  mutate(model = map(data,
                     ~lm(care_days ~ age_years + sex + adm_type, data=.))) %>%
  mutate(estimates = map(model,tidy),
         performance = map(model,glance))
  
mod_res %>% 
  select(region,estimates) %>% 
  unnest(estimates)

mod_res %>% 
  select(region,performance) %>% 
  unnest(performance)


# find DRG's with more than 100 observations
nhds_adult %>% 
  count(DRG) %>% 
  filter(n>100) %>% 
  inner_join(nhds_adult) %>% 
  select(DRG,care_days,age_years,adm_type) %>% 
  group_by(DRG) %>% 
  nest() %>% 
  mutate(model = map(data,
                     ~lm(care_days ~ age_years + adm_type, data=.))) %>%
  mutate(estimates = map(model,tidy),
         performance = map(model,glance))
  

###########################
#### Practice Problems ####
###########################

# 1) Write a function that contains an internal loop that computes and prints 
#    the mean for each column in a data.frame where the given column is a 
#    numeric (double or integer) vector. This question is an extension of 
#    question 3 in R4DS 21.3.5. (See assignment for example of output).


#### Note: for the following problems see the week4 assignment for more details:

# 2) This problem is intended to demonstrate how a study sample size relates to
#    the law of large numbers. Using the three approaches outlined above (i.e., 
#    loop, apply function, and map function) perform the following: For each of 
#    the sample sizes in the vector below draw a random sample of that number
#    of that many observations from 

sample_sizes <- c(10,20,50,100,200)



# 3) Now pick one of you iteration approaches from (2) and turn it into a function 
#    so that when you supply a vector of sample sizes you get back a sample mean
#    corresponding to a random sample of that size. Call this function 
#    run_single_trial()


# 4) Now write another loop, or iteration, to run multiple simulation trials 
#    (e.g.,1000 trials) of your above function from (3). Then turn this into 
#    a new function that takes as inputs (1) a vector of sample sizes and (2) 
#    the number of trials to run, and then returns as an output the results 
#    (i.e. sample means) for the corresponding sample sizes across each of the 
#    trials. Call this function run_trials()



# 5) Now using the run_trials() function you just created run 1000 trials and
#    compute how frequently a given trial returns an extreme value defined as 
#    the sample mean exceeding a distance of 0.3 units from the true value. 
#    In other words if you were to draw a sample of 10, 20, 50, etc. random 
#    normal values, what would be the probability of having a sample mean that 
#    either exceeds 0.3 or is less than -0.3.


# Test









