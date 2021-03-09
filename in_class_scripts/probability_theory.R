
library(tidyverse)
#####
## This script provides some examples for understanding probability theory
## using simulation models


##############################
#### Law of Large Numbers ####
##############################

# Flip a coin and count how often heads comes up

# A couple of options for flipping a coin 10 times
sample(c("Heads","Tails"),size = 10, replace = TRUE)
rbinom(n=10,size = 1, prob = 0.5) # Here we could set heads = 1


# single trial - return results as a tibble
single_trial <- function(n, p = 0.5){
  
  # draw the random values
  res <- rbinom(n=n,size = 1, prob = p)
  
  # create a tibble of outputs
  tibble(toss=1:n) %>% 
    mutate(res=res,
           total_heads=cumsum(res),
           prob_est=total_heads/toss)
}

single_trial(10)

# plot results of single trial
single_trial(1000) %>% 
  ggplot(aes(toss,prob_est)) +
  geom_line() +
  geom_hline(aes(yintercept = 0.5),color="red")

# replicate results
sim_coin <- function(n, p = 0.5, replicates = 1){
  
  tibble(repl=as.factor(1:replicates)) %>% 
    mutate(sim_res=map(repl,~single_trial(n=n,0.5))) %>% 
    unnest(sim_res)
  
}


sim_coin(10000,replicates = 100) %>% 
  ggplot(aes(toss,prob_est,order = repl)) +
  geom_line() +
  geom_hline(aes(yintercept = 0.5),color="red")


## Replicate Simulations -------------------------------------------------------
sim_coin <- function(n, p = 0.5, replicates = 1){
  
  tibble(repl=as.factor(1:replicates)) %>% 
    mutate(sim_res=map(repl,~single_trial(n=n,0.5))) %>% 
    unnest(sim_res)
  
}


sim_coin(10000,replicates = 100) %>% 
  group_by(toss) %>% 
  mutate(upr = quantile(prob_est,probs=0.975),
            lwr = quantile(prob_est,probs=0.025)) %>% 
  ggplot(aes(toss,prob_est,order = repl)) +
  geom_line() +
  geom_hline(aes(yintercept = 0.5),color="red") +
  geom_line(aes(y=upr),color = "orange") +
  geom_line(aes(y=lwr), color = "orange")


## Plotting the distribution for different sample sizes ------------------------

rbinom(n=10,size = 100, prob = 0.5)

rbinom(n=10,size = 100, prob = 0.5)/100

flip_many <- function(flips,repl = 100){
  rbinom(n=repl,size = flips, prob = 0.5)/flips
}


sample_sizes <- c(10,20,40,80,500,1000,5000,10000)

#pdf(file = "figs/prob_theory/LLN_fig.pdf",width = 10,height = 5)
tibble(sample_size = sample_sizes) %>% 
  mutate(sim_res = map(sample_size,~flip_many(flips = ., repl = 10000))) %>% 
  unnest(sim_res) %>% 
  ggplot(aes(sim_res)) +
  geom_histogram(bins = 100) +
  facet_wrap(~sample_size, scales = "free_y", ncol = 4)
#dev.off()

tibble(sample_size = sample_sizes) %>% 
  mutate(sim_res = map(sample_size,~flip_many(flips = ., repl = 10000))) %>% 
  unnest(sim_res) %>% 
  ggplot(aes(sim_res)) +
  geom_density() +
  facet_wrap(~sample_size, scales = "free_y", ncol = 2)


###############################
#### Central Limit Theorem ####
###############################

# Draw random values from different distributions ------------------------------

n <- 10

rnorm(n)
runif(n)
rexp(n)
rbeta(n, 0.35, 0.25)

tibble(normal=rnorm(n),
       uniform=runif(n),
       exponential=rexp(n),
       beta=rbeta(n, 0.35, 0.25))

draw_rand_vals <- function(n){
  tibble(normal=rnorm(n),
         uniform=runif(n),
         exponential=rexp(n),
         beta=rbeta(n, 0.35, 0.25))
}

draw_rand_vals(100)

## plot distribution of random variables ---------------------------------------

#pdf(file = "figs/prob_theory/clt_dist.pdf",width = 10,height = 6)
draw_rand_vals(1000) %>% 
  pivot_longer(cols = normal:beta,names_to = "distribution") %>% 
  ggplot(aes(value)) +
  geom_histogram() +
  facet_wrap(~distribution, scales = "free")
#dev.off()

## draw random values and compute means ----------------------------------------

draw_rand_vals(1000) %>% 
  summarise_all(mean)

# turn this into a function for use later
draw_rand_means <- function(n){
  draw_rand_vals(n) %>% 
    summarise_all(mean)
}
draw_rand_means(100)
draw_rand_means(1000)

## replicate drawing random values and computing means

# suppose we wanted to draw 100 random values for each distribution, compute the 
# mean and then replicate this 10 different times:
tibble(trial = 1:10) %>% 
  mutate(res = map(trial, ~draw_rand_means(n = 100))) %>% 
  unnest(res)

# lets turn this into a function
clt_sim <- function(n = 10, trials = 2){
  
  tibble(trial = 1:trials) %>% 
    mutate(res = map(trial,~draw_rand_means(n=n))) %>% 
    unnest(res)
}

## plot results demonstrating the central limit theorem ------------------------

# Draw sample size = 2 random values, compute the mean, and repeat this 
# experiment 1000 times
pdf(file = "figs/prob_theory/clt_n2.pdf",width = 10,height = 6)
clt_sim(n=2,trials=1000) %>% 
  pivot_longer(cols = normal:beta,names_to = "distribution") %>% 
  ggplot(aes(x=value)) +
  geom_histogram(bins = 20) +
  facet_wrap(~distribution,scales = "free") +
  ggtitle("Sample Size 2")
dev.off()

# Draw sample size = 10 random values, compute the mean, and repeat this 
# experiment 1000 times
#pdf(file = "figs/prob_theory/clt_n10.pdf",width = 10,height = 6)
clt_sim(n=10,trials=1000) %>% 
  pivot_longer(cols = normal:beta,names_to = "distribution") %>% 
  ggplot(aes(x=value)) +
  geom_histogram(bins = 30) +
  facet_wrap(~distribution,scales = "free") +
  ggtitle("Sample Size 10")
#dev.off()

# Draw sample size = 100 random values, compute the mean, and repeat this 
# experiment 1000 times
#pdf(file = "figs/prob_theory/clt_n100.pdf",width = 10,height = 6)
clt_sim(n=100,trials=1000) %>% 
  pivot_longer(cols = normal:beta,names_to = "distribution") %>% 
  ggplot(aes(x=value)) +
  geom_histogram(bins = 30) +
  facet_wrap(~distribution,scales = "free") +
  ggtitle("Sample Size 100")
#dev.off()


# try out the same thing for the median
draw_rand_medians <- function(n){
  tibble(normal=rnorm(n),
         uniform=runif(n),
         exponential=rexp(n),
         beta=rbeta(n, 0.35, 0.25)) %>% 
    summarise_all(median)
}

# update the clt_sim function to allow for median
clt_sim <- function(n = 10, trials = 2, estimator = "mean"){
  
  if (estimator == "mean"){
    tibble(trial = 1:trials) %>% 
      mutate(res = map(trial,~draw_rand_means(n=n))) %>% 
      unnest(res)
  } else if (estimator == "median"){
    tibble(trial = 1:trials) %>% 
      mutate(res = map(trial,~draw_rand_medians(n=n))) %>% 
      unnest(res)
  }
}

# plot results
clt_sim(n=100,trials=1000,estimator = "median") %>% 
  pivot_longer(cols = normal:beta,names_to = "distribution") %>% 
  ggplot(aes(x=value)) +
  geom_histogram(bins = 20) +
  facet_wrap(~distribution,scales = "free") 

##############################
#### Confidence Intervals ####
##############################

# Here we demonstrate the connection between sample size and confidence 
# intervals. We start by using simulation to demonstrate the correct 
# interpretation of a confidence interval. We next repeat an experiment where 
# we draw random values from a known distribution for a given sample size, then
# we construct the quantiles around the mean values we obtain for the various 
# experiments


## Experiment 1 - Confirm Interpretation of CI ---------------------------------
alpha <- .05   # level of signifigance 
zval <- qnorm(1-alpha/2)  # z-value to be used for computing the CI

# function to draw a random sample and compute sample CI
sample_norm <- function(n){
  draw_vals <- rnorm(n) # draw random normal values 
  mean_draw <- mean(draw_vals) # compute the mean of the sample
  sample_bound <- zval*sqrt(var(draw_vals) / n) # construct the bounds for the CI
  
  # return the CI as a tibble
  tibble(low = mean_draw - sample_bound, 
         high = mean_draw + sample_bound)
}

# Count the number of times the simulated confidence interval contained the 
# true value

# generate results
sim_results <- tibble(trial=1:10000) %>% 
  mutate(res=map(trial,~sample_norm(100))) %>% 
  unnest() 
# calculate number of times contained
sim_results %>%   
  mutate(contains_true=(low<0 & high>0)) %>%  # 0 is the true mean value
  summarise(sum(contains_true)/n())

## A second set of experiments, deriving the confidence values -----------------

# A function to randomly compute the mean value of set of random values from the
# normal distribution with sample_size=10, then repeat times=100 different times
sim_norm <- function(sample_size=10,times=100){
  sapply(1:times,function(x) mean(rnorm(n=sample_size)))
}

sim_norm(10,10)
sim_norm(sample_size=100,times=10)

## Experiment 2 - sample of size 10 --------------------------------------------

# set the parameters for the known sampling distribution
mean <- 0
sd <- 1
n <- 10
alpha <- 0.05

# z statistic
qnorm(1-alpha/2)

# If we were constructing a CI it would be formed by adding and subtracting the 
# following margin of error with the mean
qnorm(1-alpha/2)*sqrt(sd^2/n)

# generate using simulation
sim_results <- sim_norm(sample_size = n, times = 100000)

# calculate quantiles across mean values
quantile(sim_results,probs = c(0.025,0.975))

# a simulated mean and CI (a type of bootstrapped based CI)
mean(sim_results)
quantile(sim_results,probs = c(0.025,0.975))

# Experiment 3 - sample of size 100 --------------------------------------------
mean <- 0
sd <- 1
n <- 100
alpha <- 0.05

# CI - mean +/- the following
qnorm(1-alpha/2)*sqrt(sd^2/n)

sim_results <- sim_norm(sample_size = 100, times = 100000)

# a simulated mean and CI 
mean(sim_results)
quantile(sim_results,probs = c(0.025,0.975))



