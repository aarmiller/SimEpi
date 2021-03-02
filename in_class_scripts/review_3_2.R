

library(tidyverse)
rm(list = ls())


#### Review Session ####

####################
#### Subsetting ####
####################

## Dplyr subsetting -------------------------------------------------------------

# Best when you are analyzing data or trying to create a subset of the entire 
# dataset

load("R/SimEpi/example_data/nhds_adult.RData")

nhds_adult %>% 
  select(age=age_years,sex)

nhds_adult %>% 
  select(age=age_years,sex) %>% 
  filter(age>=65)

## Base R subsetting -----------------------------------------------------------

# Best for writing functions or when the outcome you are trying to extract is 
# NOT a data.frame (e.g., single elements or vectors)

# The same subsetting opperations as above
tmp <- nhds_adult[c("age_years","sex")]

names(tmp) <- c("age","sex")

tmp[tmp$age>=65,]

# some other subsetting operations

# re-assign a single name
names(tmp)[1] <- "new_age"

# find name to subset
names(tmp)[which(names(tmp)=="new_age")] <- "age"


# subsetting based on index locations
tmp[c(1,3),c(1)]

tmp[c(1,3),1]

# subsetting based on logical vectors that indicate index locations (i.e., the
# index location where there is a TRUE value)
tmp[tmp$age >= 65, c(TRUE,FALSE)]


###################
#### Iteration ####
###################

#### EXAMPLE 1 - Simple iteration  ---------------------------------------------
# Suppose we want to simulate drawing random values from a normal distribution, 
# then compute the mean value across draws for samples of various sizes in order
# to see how close the mean from a particular sample of random values comes to 
# approximating the true mean - here we will sample from normal(0,1)

# Here is a vector of sample sizes we would like to draw values for
sample_sizes <- c(10,50,100,500)


# Let's start with what we want to do for sample size 10
drawn_sample <- rnorm(10, mean = 0, sd = 1)

mean(drawn_sample)

# we can turn this into a function of sample size n

draw_sample_mean <- function(n){
  drawn_sample <- rnorm(n, mean = 0, sd = 1)
  mean(drawn_sample)
}

# test that the function works
draw_sample_mean(10)

draw_sample_mean(100)


## Simulate with a for loop ----------------------------------------------------

# printing output
for (i in sample_sizes){
  print(draw_sample_mean(i))
}

# storing output in a vector
res <- vector()
for (i in 1:length(sample_sizes)){
  res[i] <- draw_sample_mean(sample_sizes[i])
}
res

## Simulate with apply function ------------------------------------------------

lapply(sample_sizes, draw_sample_mean)

sapply(sample_sizes, draw_sample_mean)

# without the function from aboe
sapply()


## Simulate with the map function ----------------------------------------------

map(sample_sizes, draw_sample_mean)

map_dbl(sample_sizes, draw_sample_mean)

# without the function from above
map()


# using map with a tibble to store values
tibble(n=sample_sizes) %>% 
  mutate() %>% 
  unnest()

# without haveing to unnest
tibble(n=sample_sizes) %>% 
  mutate(map_dbl())



#### A SECOND EXAMPLE ----------------------------------------------------------

# Now let's do something a bit more complex. For each of the sample sizes, we 
# would actually like to perform the experiment a given number of times (say 
# m = 1000 times). In other words for sample size n=10, we would like to generate
# a random sample of size 10, 1000 different times then look at the mean value 
#  for the 10 different random values across the 1000 different experiments

# number of times we would like to replicate the experiment
m <- 1000

# This involves 2 loops or two functions. First we need to draw the sample and 
# compute the mean for a given sample size (we wrote this function above). Then
# we need to repeat this a given number of times.

# Let's write the function to do the experiment using one of the approaches. But 
# note that we are applying the same sample size multiple times
run_expirement <- function(sample_size,m){
  
  
}

run_expirement(10,100)


# Now we can perform the simulation across sample sizes

# using a for loop -------------------------------------------------------------

res <- list()

for (i in 1:length(sample_sizes)){
  
}

res

# using apply function ---------------------------------------------------------

lapply()

# using map function -----------------------------------------------------------

map() 



## Visualize results ----------------------------------------------------------- 
# Now let's take a quick peak at the results

results_list <- map() 

results_list %>% 
  enframe() %>% 
  mutate(sample_size=sample_sizes) %>% 
  unnest(value)  %>% 
  ggplot(aes(value)) +
  geom_histogram() +
  facet_wrap(~sample_size)



#### Example 3 - Now try for another distribution ------------------------------

# Repeat the above steps but instead sample from a random uniform distribution


