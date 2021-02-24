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

## Simulate from beta distribution

# Example - from statistical computing in R 

n <- 1000
k <- 0 #counter for accepted
j <- 0 #iterations
y <- numeric(n)

while (k < n) {
  u <- runif(1)
  j <- j + 1
  x <- runif(1) #random variate from g
  if (x * (1-x) > u) {
    #we accept x
    k <- k + 1
    y[k] <- x
  }
}

# plot results
hist(y)


n <- 1000
k <- 0 #counter for accepted
k2 <- 0 #counter for 
j <- 0 #iterations
y <- numeric(n)
y_rej <- numeric(6000)
while (k < n) {
  u <- runif(1)
  j <- j + 1
  x <- runif(1) #random variate from g
  if (x * (1-x) > u) {
    #we accept x
    k <- k + 1
    y[k] <- x
  } else {
    k2 <- k2 + 1
    y_rej[k2] <- x
  }
}

# plot results
hist(y)

hist(y_rej[y_rej>0])

# note if we use 3/2 instead of 6 would require fewer rejections





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


