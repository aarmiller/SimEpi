library(tidyverse)

# This script provides an introduction to methods for generating random values

########################
#### Random Uniform ####
########################

# this is the canonical distribution for random number generation

n <- 1000 # number of draws
u <- runif(n) # generate random uniform

# view histogram of results
hist(u)

# we can change the default min and max values on the uniform distribution
runif(n,min = 1, max = 100)


##########################
#### Inversion Method ####
##########################

## Exponential Distribution ----------------------------------------------------

n <- 1000  # number of draws
u <- runif(n) # generate random uniform
lambda <- 1   # choose a lambda value for the exponential distribution

# function to compute the inverse of CDF distribution
inverse_exp <- function(x){-(1/lambda)*log(x)}

x <- inverse_exp(u)  # Use inversion method to get random exponential values

hist(x,breaks = 50)  # view results

# Now write a function to generate random exponential values so that we can look 
# at different sample sizes and values for lambda
rand_exp <- function(n,lambda=1){
  u <- runif(n,0,1)
  x <- -(1/lambda)*log(u)
  return(x)
}

# look at simulating different sample sizes
tibble(n=c(100,1000,10000,100000)) %>% 
  mutate(draw=map(n,rand_exp)) %>% 
  unnest(draw) %>% 
  ggplot(aes(draw)) +
  geom_histogram(bins=100) +
  facet_wrap(~n,scales = "free_y")

# or for different lambda values
tibble(lambda=c(0.1,0.5,1,2)) %>% 
  mutate(draw=map(lambda,~rand_exp(n=10000,lambda = .))) %>% 
  unnest(draw) %>% 
  ggplot(aes(draw)) +
  geom_histogram(bins = 50) +
  facet_wrap(~lambda,scales = "free")

## Normal Distribution ---------------------------------------------------------

n <- 1000  # number of draws
u <- runif(n) # generate random uniform

# pass uniform values to inverse of normal (using the qnorm function)
x <- qnorm(u)

# plot a histogram of our samples
hist(x, freq = FALSE)
# add a standard normal density curve
densitySamps <- seq(-4, 4, by = 0.01)
lines(densitySamps, dnorm(densitySamps), lwd = 2, col = "red")


## Example distribution --------------------------------------------------------

# This is a hypothetical distribution where the inverse function is x^(1/3)

n <- 1000  # number of draws
u <- runif(n) # generate random uniform
x <- u^(1/3) # use inversion method
hist(x, prob = TRUE) #density histogram of sample
y <- seq(0, 1, .01)
lines(y, 3*y^2)#density curve f(x)


## Bernoulli Distribution ------------------------------------------------------

n <- 1000  # number of draws
u <- runif(n) # generate random uniform

p <- 0.4 # Bernoulli(p = 4)

# F(0) = 1-p so inverse is F^-1(u) = 1 if u > 1-p = 0.6
# convert to results of bernouli trials
x <- as.integer(u > (1-p))

hist(x)


## Discrete Uniform ------------------------------------------------------------

n <- 1000  # number of draws
u <- runif(n) # generate random uniform
a <- 2  # min value
b <- 10  # max value
m <- length(a:b) # number of discrete values in domain

# compute inversion
x <- floor(m*u)+a

# view results
ggplot(data.frame(x),aes(x)) +
  geom_bar()


## Discrete non-uniform --------------------------------------------------------

n <- 1000  # number of draws
u <- runif(n) # generate random uniform
vals <- c("a","b","c","d") # values to draw from
probs <-  c(.4,.3,.2,.1)   # probability values to draw with

# cumulative sums for the lookup table 
cut_points <- c(0,cumsum(probs))

# now use cut function to split up u by the corresponding cut points and then 
# draw the associated vals for labels
x <- cut(x = u, breaks = cut_points,labels = vals)

# plot results
ggplot(data.frame(x),aes(x)) +
  geom_bar()


#########################################
#### Alias / Square Histogram Method ####
#########################################

# In R this can be done relatively easily with the sample function

x <- sample(c("a","b","c","d"), size = n, replace = TRUE, prob = c(.4,.3,.2,.1))

# see here
?sample




############################
#### Rejection Sampling ####
############################

## Simulate from beta(alpha = 2, beta = 2) distribution

# Note this Example - from statistical computing in R (Rizzo) - Example 3.7
# here we want to sample from a beta(2,2) distribution

n <- 1000 # number of values to generate
k <- 0 # counter for number of accepted values
j <- 0 # counter for current iterations
y <- numeric(n)

# Note the beta density, when alpha = 2 and beta = 2, is given by f(x) = 6x(1-x), 
# for this example we will use c = 6 and g(x) = 1 (i.e. the uniform density). 
# Note that the unif(0,1) density is given by g(x) = 1

c <- 6
f <- function(x) 6*x*(1-x)
g <- function(x) 1

# remember we are going to draw random value x from g(x) (i.e., from unif(0,1)),
# and if that value x is such that f(x) / (c*g(x)) > u then we accept the value
# we drew


while (k < n) {
  
  # while we have fewer than n random values accepted, do the following:
  
  j <- j + 1  # increase iteration tracker to see how many total runs
  
  u <- runif(1) # generate random uniform u for comparison
  
  x <- runif(1) #random variable from g that we will consider accepting or rejecting
  
  # accept reject condition to check
  if (f(x)/(c*g(x)) > u) {
    
    # we accept x and add it to the vector y
    y[k] <- x
    
    # increase count
    k <- k + 1
  }
}

# plot results
hist(y)

# count number of rejections: total iterations - total values generated
j-k

#####
## note if we use 3/2 instead of 6 would require fewer rejections
#####

n <- 1000 # number of values to generate
k <- 0 # counter for number of accepted values
j <- 0 # counter for current iterations
y <- numeric(n)

c <- 3/2
f <- function(x) 6*x*(1-x)
g <- function(x) 1

while (k < n) {
  j <- j + 1  # iteration tracker to see how many total runs
  
  u <- runif(1) # generate random uniform for comparison
  
  x <- runif(1) #random variable from g we will consider accepting or rejecting
  
  # accept reject condition to check
  if (f(x)/(c*g(x)) > u) {
    
    # we accept x and add it to the vector y
    y[k] <- x
    # increase count
    k <- k + 1
  }
}

# plot results
hist(y)

# count number of rejections: total iterations - total values generated
j-k

################################
#### Monte-Carlo Simulation ####
################################

## Simulate Pi -----------------------------------------------------------------

# Number of random points to drop
trials <- 1000

# Build a tibble with the randompoints
random_points <- tibble(x=runif(n = trials,-1,1),      # draw random x coordinate
                        y=runif(n = trials,-1,1)) %>%  # draw random y coordiante
  mutate(dist=x^2+y^2) %>%                      # comute the distence from center
  mutate(in_circle=dist<=1)                     # identify points that fall in circle

# note what the trials set contains
random_points

# view where the random points fall
random_points %>% 
  ggplot(aes(x,y,color=in_circle)) +
  geom_point()

# compute estimate for pi
pi_est <- random_points %>% 
  summarise(pct_in=sum(in_circle)/n(),
            pi=pct_in*4)

pi_est$pi

# Notice how accuracy changes for different number of trials

random_points_2 <-tibble(num_trials=c(100,1000,10000,30000)) %>% 
  mutate(points=map(num_trials,~tibble(x=runif(n = .,-1,1),      
                                       y=runif(n = .,-1,1)) %>% 
                      mutate(dist=x^2+y^2) %>%
                      mutate(in_circle=dist<=1)))

random_points_2 %>% 
  unnest() %>% 
  group_by(num_trials) %>% 
  summarise(pi=4*sum(in_circle)/n())

# plot for different number of trials
random_points_2 %>% 
  unnest() %>% 
  ggplot(aes(x,y,color=in_circle)) +
  geom_point() +
  facet_wrap(~num_trials)


## Monte-Carlo Integration -----------------------------------------------------

# Note: feel free to disregard this section if have not covered integration in 
#       a prior course

# suppose we want to integrate e^-x over the interval 0 to 1
# the integral of x can be easily computed as e^(-0) - e^(-1) = 1-e^(-1)

# the exact answer
1-exp(-1)

# the monte-carlo estimate
n <- 10000 # number of trials
x <- runif(n) # random uniform over (0,1)

# the monte-carlo estimate
mean(exp(-x))


# now suppose more generally we want to compute the integral over some interval
# a b, this requires a bit of math because the limits of integration differ. We 
# can do this by using a uniform(a,b) distribution and computing 
# (b-a)*mean(exp(x)) where x are the vector of generated values (Note this is a 
# transformation of the integral)

# the exact answer (as a function)
exact_integral <- function(a,b) exp(-a)-exp(-b)

exact_integral(0,1)
exact_integral(0,3)
exact_integral(0,10)

# a quick plot as a reminder what values we are integrating over
tibble(x=seq(0,10,.1)) %>% 
  mutate(y=exp(-x)) %>% 
  ggplot(aes(x,y)) +
  geom_line()

# now we can write a function that computes the monte-carlo estimate of this integral

monte_carlo_integral <- function(a,b,n){
  # generate random uniform values based on the domain we specify
  x <- runif(n, min = a, max = b)
  # return the monte carlo estimate
  mean(exp(-x)*(b-a))
}

# or without transforming the domain on the random draws
monte_carlo_integral2 <- function(a,b,n){
  # generate random uniform values based on the domain we specify
  x <- runif(n)
  # return the monte carlo estimate
  mean(exp(-(x*(b-a)+a))*(b-a))
}

exact_integral(1,3)
monte_carlo_integral(1,3,100000)
monte_carlo_integral2(1,3,100000)


exact_integral(1,2)
monte_carlo_integral(1,2,100000)
monte_carlo_integral2(1,2,100000)
