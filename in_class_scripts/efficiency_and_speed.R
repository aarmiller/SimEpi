
##############################################################################
### This script goes through some examples of making code more efficient #####
##############################################################################

# In general options to make our code more efficient include:

# 1) Using more efficient base-R functions and vectorization when possible

# 2) Write more efficient algorithms that require fewer computational steps

# 3) Write slower procedures in a lower level programming langurage (e.g., using 
#    C++ with Rcpp)

# 4) Run operations in parallel


###################################
#### Example 1: Weighted Means ####
###################################

# A common procedure that can have varying levels of efficiency is computing a 
# weighted mean

## Built-in R function weighted.mean() -----------------------------------------

# R has a built in weighted mean function 

x <- rnorm(100000)   # A random vector of values to compute a mean for
w <- rnorm(100000)   # A random vector of weights

weighted.mean(x,w) # compute the weighted mean using the built-in function

## Using a for loop ------------------------------------------------------------

# using a loop will probably be slow...but this is how the wighted mean function 
# explicitly looks

wmean_loop <- function(x,w) {
  num <- 0
  denom <- 0
  for (i in seq_along(x)) {
    num <- num + x[i]*w[i]
    denom <- denom + w[i]
  }
  num / denom
}

wmean_loop(x,w)

## Vectorized operations -------------------------------------------------------

# Another approach is to use vectorized operations

wmean_vec <- function(x,w) {
  sum(x*w) / sum(w)
}

wmean_vec(x,w)

## Weighted mean using C++ for loop --------------------------------------------

# We can take the exact same loop we wrote above and rewrite it in C++
Rcpp::cppFunction('
  double wmean_cpp(NumericVector x, NumericVector w) {
  int n = x.size();
  double num = 0, denom = 0;
  for(int i =0; i < n; ++i) {
    num += x[i] * w[i];
    denom += w[i];
    }
    return num / denom;
    }
  ')


microbenchmark(weighted.mean(x,w),  # Built-in R function
               wmean_loop(x,w),     # Our explicit for loop
               wmean_vec(x,w),      # Using vectorized operations
               wmean_cpp(x,w))      # The for-loop written in C++


########################################
#### Example 2: Fibonacci Numbers  #####
########################################

# Here we would like to write a function to return the nth positive Fibonacci
# number. Here is the beginning of the Fibonacci sequence:
# 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ...

# So the 1st positive Fibonacci number is 1, the fifth is 5, the 10th is 55, etc.


## Recursive Function in R -----------------------------------------------------

# The most straight forward approach is to create the explicit recursive 
# function in R
fib_R <- function(n) {
  if (n < 2) return(n)    # for 0 and 1 we return the given values 
  return(fib_R(n-1) + fib_R(n-2))   # otherwise we sum the prior two values
}

# check the function
fib_R(5)
fib_R(10)

# or we could recreate the sequence with sapply()
sapply(0:10,fib_R)

# Note: this recursive function will end up being very slow for large number...
#       notice how long this takes for 35
fib_R(35)

# check how many times this function gets called

fib_R_track <- function(n) {
  iter <- 0 # a counter to see how many times the fib_R() function gets called
  fib_R <- function(n) {
    iter <<- iter + 1   # add a value each time this function is called
    if (n < 2) return(n) 
    return(fib_R(n-1) + fib_R(n-2))
  }
  return(list(out_val = fib_R(n),
              iter = iter))
}

# now see how many times the function is called
fib_R_track(35)

## Using a loop ----------------------------------------------------------------

# Normally, using for loops in R can be quite slow, however, the recursive function
# is essentially performing a loop in a relatively inefficient manner.

# We can write a new function that is more efficient by creating each value in 
# the sequence up to the value we want to return, and then returning the last 
# output

n <- 10 # the n'th positive value we want to return

# a placeholder to store the vector, this need to be n+1 since the first number 
# in the sequence is 0
out_vec <- vector(length = n+1) 

for (i in 0:n){
  # note: to deal with the 0 index we need to increment i+1 (i.e., out_vec[0] does 
  #       not exist) so j will be the position index
  j <- i+1
  if (i < 2){
    out_vec[j] <- i
  } else {
    out_vec[j] <- out_vec[j-1] + out_vec[j-2]
  }
  
}
out_vec[n+1]

# now take the above code and put it into a function:
fib_R_fast <- function(n){
  out_vec <- vector(length = n+1)
  for (i in 0:n){
    # note: to deal with the 0 index we need to increment i+1 (i.e., out_vec[0] does 
    #       not exist) so j will be the position index
    j <- i+1
    if (i < 2){
      out_vec[j] <- i
    } else {
      out_vec[j] <- out_vec[j-1] + out_vec[j-2]
    }
  }
  return(out_vec[n+1])
}

# already you can see the speed improvement
fib_R(30)
fib_R_fast(30)

microbenchmark(fib_R(20),
               fib_R_fast(20))

## Recursive C++ function ------------------------------------------------------

# We can use Rcpp to rewrite the original recursive function

## The C++ version looks like this:
# int fib_cpp(int n) {
#     if (n < 2) return(n); 
#     return(fib_cpp(n-1) + fib_cpp(n-2));
# }

# Creating using Rcpp
Rcpp::cppFunction('int fib_cpp(int n) { 
  if (n < 2) return(n); 
  return(fib_cpp(n-1) + fib_cpp(n-2)); }')


# compare performance
microbenchmark(fib_R(20),
               fib_R_fast(20),
               fib_cpp(20))

# Notice the recursive cpp function sped up the process but is still a bit slower
# than the fast R version.

## Efficient C++ loop ----------------------------------------------------------

# Finally we can rewrite the exact same loop in our fib_R_fast function in C++
# to speed up the process even further

Rcpp::cppFunction('int fib_cpp_fast(int n) {
  IntegerVector y(n+1);
  int out = 0;
  for (int i = 0; i <= n; i++){
    if (i<2) {
      y[i] = i;
    } else {
      y[i] = y[i-1] + y[i-2];
    }
  }
  out = y[n];
  return out;
  }
  ')

fib_cpp_fast(30)

microbenchmark(fib_R(20),        # The R recursive function
               fib_cpp(20),      # The cpp recursive function
               fib_R_fast(20),   # The R efficient loop
               fib_cpp_fast(20)) # The cpp efficient loop



#################################################
#### Example 3 - Dynamic Conditionals/Values ####
#################################################

# Suppose you have a longitudinal dataset and for each visit you would like to 
# compute the number of visits a patient had in the prior 30 days. This will 
# typically require some sort of loop across all of the visits.

library(lubridate)
load("R/SimEpi/example_data/longitudinal_example_data.RData")

# function to compute the number of visits in the "days_since" previous days
count_prior_visits <- function(x,days_since){
  n = length(x)  # number of visits to loop over
  
  n_visits <- vector("integer",n)
  for (i in 1:n){
    n_visits[i] <- 0
    for (j in 1:n){
      if (((x[i]-days_since) < x[j]) & x[j] <x[i]) {
        n_visits[i] <- n_visits[i] + 1
      }
    }
  }
  return(n_visits)
}

# count number of visits in the prior 60 days
long_test %>% 
  arrange(date) %>% 
  mutate(n_prior=count_prior_visits(date,60))

longitudinal %>%
  slice(1:10000) %>%  # slice so this does not take forever to run
  group_by(id) %>% 
  mutate(n_prior=count_prior_visits(admdate,60))

# we can really speed this up using a function written in C++
Rcpp::cppFunction('NumericVector prev_visits(NumericVector x, int y) {
            int n = x.size();
            NumericVector n_visits(n);
            for (int i = 0; i < n; ++i) {
            n_visits[i] = 0;
            for (int j = 0; j < n; ++j) {
            if (j != i) {
            if (((x[i] - y) < x[j]) and x[j] < x[i]) {
            n_visits[i] = n_visits[i] + 1;
            }
            }
            }
            }
            return n_visits;
            }')


longitudinal %>%
  group_by(id) %>% 
  mutate(n_prior=prev_visits(admdate,60))

##############################
#### Run code in parallel ####
##############################

## Simple correlation example --------------------------------------------------

# suppose we want to see how often two randomly generated sets of values may 
# appear to be correlated

# generate two random samples
x <- rnorm(50)
y <- rnorm(50)

# compute correlation
cor(x,y)

# now write a function that generate two sets of random values of a given size
# and returns their correlation
rand_correlation <- function(size){
  x <- rnorm(size)
  y <- rnorm(size)
  cor(x,y)
}

# test the function
rand_correlation(50)

# now suppose we want to run this 20,000 time (i.e., number of expirements) and 
# each time we want to check the correlation for 5,000 random values
system.time(lapply(1:20000,function(x) rand_correlation(5000)))

# This will take a bit of time to run

# We can speed up the process by running this in parallel
# load the parallel package for running in parallel
library(parallel)

# detect the number of cores available (note: logical = FALSE will detect actual
# number of physical CPU cores and not hyper-threading)
num_cores <- detectCores(logical = FALSE)

# now compare a profile of the performance
microbenchmark(lapply(1:20000,function(x) rand_correlation(5000)),
               mclapply(1:20000,function(x) rand_correlation(5000), mc.cores = num_cores),
               times = 5)


## A quick preview of bootstrapping --------------------------------------------

# suppose we want to use bootstrapping to evaluate the coefficients for a 
# a regression model

# start by creating a subset of the nhds_adult dataset
small_data <- nhds_adult %>% select(age=age_years,sex,care_days)

# fit the model on the whole dataset
fit <- lm(care_days~age+sex,data=small_data)

# extract coefficients
fit$coefficients

# now draw a bootstrapped sample
boot_sample <- sample_frac(small_data,replace = TRUE)

# fit model on bootstrapped sample
fit_boot <- lm(care_days~age+sex,data=boot_sample)

# look at the coefficients
fit_boot$coefficients

# Turn these steps into a function
bootstrap_coef <- function(){
  boot_sample <- sample_frac(small_data,replace = TRUE)
  fit_boot <- lm(care_days~age+sex,data=boot_sample)
  fit_boot$coefficients
}

# test the function
bootstrap_coef()

# use lapply to run 500 different models
lapply(1:500,function(x) bootstrap_coef())
# use mclapply to do the same thing in parallel
mclapply(1:500,function(x) bootstrap_coef(), mc.cores = num_cores)

# compare a profile of the difference in speed
microbenchmark(lapply(1:200,function(x) bootstrap_coef()),
               mclapply(1:200,function(x) bootstrap_coef(), mc.cores = num_cores),
               times = 5)


