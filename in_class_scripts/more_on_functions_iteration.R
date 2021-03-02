
library(tidyverse)
rm(list=ls())
### Additional Practice with Functions and Iteration ###


############################################
#### Write a function to categorize age ####
############################################

# For this problem we want to write a function that categorizes age into bins, 
# based as pre-specified bins. The function should be pipeable and should take
# two arguments the data set and the category breaks to use to define bins:
# add_age_cats(data, age_breaks)

# Load in the NHDS adult dataset
load("data/nhds/nhds_adult.RData")

# subset the dataset to a few variables we are interested in and rename 
# age_years to just age
# Note: this is a temporary step for demonstration purposes so we can see what 
# is being manipulated and make age easier to work with
nhds_new <- nhds_adult %>% 
  select(age=age_years,sex, race, care_days)

## Function Guts ---------------------------------------------------------------

# Let's start by doing this steps outside of a function

# start by creating age bins
age_bins <- c(18,31,45,65,120)

# create some example ages to start working with
test_ages <- 18:100

# use the cut function to segment into age bins
cut(x = test_ages, breaks = age_bins, right = FALSE)

# add the age categories to the dataset
nhds_new %>% 
  mutate(age_cats = cut(x = age, breaks = age_bins, right = FALSE))



## Create the function ---------------------------------------------------------

add_age_cats <- function(data, cat_breaks){
  
  data %>% 
    mutate(age_cats = cut(x = age, breaks = cat_breaks, right = FALSE))
  
}

## check that the function works -----------------------------------------------
nhds_new %>% 
  add_age_cats(age_bins)

nhds_new %>% 
  add_age_cats(c(0,30,60,200))

nhds_new %>% 
  slice(5:500) %>% 
  add_age_cats(c(0,30,60,200))

###########################################################
#### Write a function to categorize a generic variable ####
###########################################################

# notice that the previous function is of limited use
nhds_adult %>% 
  rename(age=age_years) %>% 
  add_age_cats(age_bins)

# Now let's make a more generic version of the function so we can apply it to
# other numeric variables and create bins. For this we would like to have 3 
# arguments: the dataset we want to apply it to, the name of the variable we 
# would like to categorize and the break points we would like to use to define
# categories. Write the function so it looks like this:
# categorize_var(data, var, breaks)


## Function guts ---------------------------------------------------------------

# To do this we should step back from tidyverse a bit and return to base R. If 
# you try to work with variable names using dplyr function you will quickly 
# encounter lots of additional complexity. 

# start by assigning the variable name we would like to extract
var_name <- "age"

# now subset that dataset to the variable of interest using base R
var_to_cut <- nhds_new[[var_name]]

# Now create the categories
new_categories <- cut(x = var_to_cut, breaks = age_bins, right = FALSE)

# now mutate the variable in the dataset 
# note create a temporary dataset so you don't overwrite the data we want to 
# work with
tmp_new_data <- nhds_new

tmp_new_data[[var_name]] <- new_categories

  
## Create the function ---------------------------------------------------------
categorize_var <- function(data,var,breaks){
  
  var_to_cut <- data[[var]]
  
  new_categories <- cut(x = var_to_cut, breaks = breaks, right = FALSE)
  
  data[[var]] <- new_categories
  
  data

}

## Test the function -----------------------------------------------------------

nhds_new %>% 
  categorize_var(var = "age", breaks = age_bins)

nhds_adult %>% 
  categorize_var(var = "age_years", breaks = age_bins)

nhds_new %>% 
  categorize_var(var = "age", breaks = c(18,65,120))

nhds_new %>% 
  categorize_var(var = "care_days", breaks = c(0,4,10,20,1000))

nhds_new %>% 
  categorize_var(var = "age", breaks = c(18,65,120)) %>% 
  categorize_var(var = "care_days", breaks = c(0,4,10,20,1000))



##################################################################
#### Write a function to find values that are perfect squares ####
##################################################################

# For this problem we are going to write a series of functions that return all
# of the integer values up to some input value that are perfect squares.
# For example find_perfect_squares(20) should return the following output:
# [1]    1    4    9   16


# start by writing a function that checks if a value is a perfect square

# try out these values to see how to do this
sqrt(5)
sqrt(4)
sqrt(16)

# write the guts
sqrt(5) %% 1

# write the function
perfect_square <- function(x){
  (sqrt(x) %% 1) == 0
}

# check the function
perfect_square(4)
perfect_square(2)
perfect_square(c(1,2,3,4,5))



## Algorithm 1: Write function with for loop -----------------------------------

# For this algorithm we will use a for loop to check all values up to n

## Create the guts (i.e., the loop)

# the loop
n <- 100
for (i in 1:n){
  if (perfect_square(i)){
    print(i)
  }
}

# create vector from loop...this does not quite work...
res <- vector()
for (i in 1:n){
  if (perfect_square(i)){
    res[i] <- i
  }
}
res

# another approach that works
res <- vector(mode = "integer")
for (i in 1:n){
  if (perfect_square(i)){
    res <- c(res,i)
  }
}

# another approach using two index trackers
res <- vector(mode = "integer")
j <- 1
for (i in 1:n){
  if (perfect_square(i)){
    res[j] <- i
    j <- j + 1
  }
}
res

# still another approach, using which after the loop
res <- vector()
j <- 1
for (i in 1:n){
  res[i] <- perfect_square(i)
}
which(res)

  
## Now create the function

find_perfect_squares1 <- function(x){
  
  res <- vector(mode = "integer")
  
  for (i in 1:x){
    if (perfect_square(i)){
      res <- c(res,i)
    }
  }
  res
}

## test the function
find_perfect_squares1(5000)


## Algorithm 2: Without a loop using vectorized operations ---------------------

# notice that perfect_square() is already vectorized
perfect_square(1:20)
perfect_square(1:n)

## create the guts
which(perfect_square(1:n))
(1:n)[perfect_square(1:n)]

## create the function

find_perfect_squares2 <- function(x){
  which(perfect_square(1:x))
}

## test the function
find_perfect_squares2(5000)


## Algorithm 3: Using a while loop ---------------------------------------------

# the more efficient algorithm will use a while loop.
# Notice that all the perfects squares are the square value of sequential 
# integers 1^2 = 1, 2^2 = 4, 3^2 = 9, ....

# So what is the more efficient algorithm...and why?

## Write the guts of the function

stop_val <- 100
current_val <- 1
res <- vector()
while (current_val^2 <= stop_val){
  res <- c(res,current_val^2)
  current_val <- current_val + 1
}
res


## Write the function
find_perfect_squares3 <- function(x){
  current_val <- 1
  res <- vector()
  while (current_val^2 <= x){
    res <- c(res,current_val^2)
    current_val <- current_val + 1
  }
  res
}

## Test the function
find_perfect_squares3(5000)

##########################################################
#### Check which function/algorithm is most efficient ####
##########################################################


find_perfect_squares1(50000)
find_perfect_squares2(50000)
find_perfect_squares3(50000)

# note it is challenging to see which function is most efficient by running them,
# even if we have a lot of values.

# you could uses system.time()...but this is only one trial and could be 
# dependent on other processes
system.time(find_perfect_squares1(50000))
system.time(find_perfect_squares2(50000))
system.time(find_perfect_squares3(50000))

# a better option is the microbenchmark package
library(microbenchmark)

microbenchmark(find_perfect_squares1(50000),
               find_perfect_squares2(50000),
               find_perfect_squares3(50000))
