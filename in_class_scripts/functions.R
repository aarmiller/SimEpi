
# This function covers an introduction to writing functions in R

#########################
#### Function Basics ####
#########################

## Function Arguments ----------------------------------------------------------

# writing a basic function add_two

add_two <- function(x){
  x + 2
}

add_two(10)
add_two(1:10)

# multiple arguments
exponentiate <- function(x,exponent){
  x^exponent
}

exponentiate(2,2)
exponentiate(c(1:10),2)
exponentiate(c(1:10),3)

## Default Arguments -----------------------------------------------------------

# default to squared
exponentiate <- function(x,exponent=2){
  x^exponent
}

exponentiate(2)
exponentiate(c(1:10))
exponentiate(c(1:10),3)


## Default Arguments and argument order ----------------------------------------

# Data arguments should come first and generally don't have default values

# Optional arguments should come second and should have a default if common 
# values exist

# Argument order should generally reflect the necessity/frequency of use

# Example from R4DS (Chapter 19): Compute confidence interval around mean using 
# normal approximation
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

x <- runif(100)
mean_ci(x)
mean_ci(x, conf = 0.99)

## Conditional execution -------------------------------------------------------

# often a function will do different things depending on what arguments are 
# specified. 

# The mean function is one example:
mean(c(1,2,3,4,NA))
mean(c(1,2,3,4,NA), na.rm = TRUE)

# rewrite a new mean function that behaves similarly
mean_new <- function(x){
  if (anyNA(x)) {
    NA
  } else {
    sum(x)/length(x)
  }
}

mean_new(c(1,2,3,4))
mean_new(c(1,2,3,4,NA))

# How to rewrite mean_new function with na.rm argument?
# Hint: consider using na.omit()
# Answer: See bottom of script


# Another example - add a 3rd (less useful option) to the mean_ci function to
# return the output as a data.frame

mean_ci <- function(x, conf = 0.95, return_df = FALSE) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  ci_data <- mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
  
  if (return_df){
    data.frame(low = ci_data[1],
               high = ci_data[2])
  } else {
    ci_data
  }
}

x <- runif(100)
mean_ci(x)
mean_ci(x,return_df = TRUE)


# Important Note: a conditional statement must evaluate to a single TRUE or 
# FALSE value and not NA
if (c(TRUE, FALSE)) {}

if (NA) {}

# Use conditional statements that to evaluate to a single value
# &&
# ||
c(T,T,T) || c(F,F,F)
c(T,T,T) && c(F,F,F)
c(T,T,T) && c(T,T,T)
any()
anyNA()
all()
identical(3,3)
identical(c(3,3),c(3,3))
# does not coerce types:
identical(c(2L,2L), c(2,2))
dplyr::near(c(2L,2L), c(2,2))


## Multiple Conditions ---------------------------------------------------------

# when evaluating multiple conditions consider using switch() to make things
# simpler and easier to read

# Here is a function that performs a defined opperation (e.g., plus, minus, etc)
# on two vectors that are provided

# one way to write using if else statements
test_func <- function(x, y, op){
  if (op=="plus") {
    x + y
  } else if (op == "minus") {
    x - y
  } else if (op == "times") {
    x * y
  } else if (op == "divide") {
    x / y
  } else {
    stop("Unkown op!")
  }
}

# see how function works
test_func(1,2,"plus")
test_func(1,2,"divide")

# another way to write using switch
test_func <- function(x, y, op) {
  switch(op,
         plus = x + y,
         minus = x - y,
         times = x * y,
         divide = x / y,
         stop("Unknown op!")
  )
}
test_func(1,2,"plus")
test_func(1,2,"divide")


## Checking argument values ----------------------------------------------------

# Often we need to check that our arguments satisfy certain conditions before 
# running the function and if these conditions are not satisfied the function
# should not run but should instead return an error.

# Example from R4DS (Chapter 19): Checking conditions 
# This function computes a weighted mean
wt_mean <- function(x, w) {
  sum(x * w) / sum(w)
}

# What is wrong with this and why does this still work?
# These vectors are not the same size, so the second gets recycled
wt_mean(1:6, 1:3)

# An update to check that they are the same length before proceeding
wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  sum(w * x) / sum(w)
}

wt_mean(1:6, 1:3)
wt_mean(1:6, 1:6)

# Be careful not to take this too far - the following checks other conditions
# that should be satisfied, but this could also slow down the function 
# performance if multiple checks need to be performed
wt_mean <- function(x, w, na.rm = FALSE) {
  if (!is.logical(na.rm)) {
    stop("`na.rm` must be logical")
  }
  if (length(na.rm) != 1) {
    stop("`na.rm` must be length 1")
  }
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}

wt_mean(1:6, 1:3)
wt_mean(1:6, c(1:3,NA,NA,NA),na.rm = TRUE)
wt_mean(1:6, c(1:3,NA,NA,NA),na.rm = c(TRUE,TRUE))

# Another option for checking conditions is using stopifnot()
# stopifnot() allows us to check multiple conditions at once, and rather than
# specifying an error message stopifnot() will return which condition is not
# satisfied if an error occurs
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}

wt_mean(1:6, 6:1, na.rm = "foo")
wt_mean(1:6, 6:1, na.rm = TRUE)


##########################
#### Function Returns ####
##########################


## Explicit vs Implicit Return -------------------------------------------------

# in this function the last argument passed is returned by default....this is an
# implicit return
add_two <- function(x){
  x+2
}

# here the output being returned is being explicitly declared
add_two <- function(x){
  out <- x+2
  return(out)
}

add_two(10)

# note: if your output has been assigned to an object, you have to either call
# the object in your last step or you have to explicitly return the object like 
# above. For example, this will not work:
add_two <- function(x){
  out <- x+2
}

add_two(10)

# but this will work:
add_two <- function(x){
  out <- x+2
  out
}

add_two(10)


## Ordering explicit returns ---------------------------------------------------

# Explicit returns (i.e., using the return() function) work best when they are
# used to terminate a function early. So if we have a simple output that should
# be returned we might want to place that evaluation first and return the output 
# if a condition is not met.

# Consider these two functions:
f <- function() {
  if (x) {
    # Do 
    # something
    # that
    # takes
    # many
    # lines
    # to
    # express
  } else {
    # return something short
  }
}

f <- function() {
  if (!x) {
    return(something_short)
  }
  
  # Do 
  # something
  # that
  # takes
  # many
  # lines
  # to
  # express
}

# here is a more concrete example - consider a re-write of the new_mean example
# from above

# here was the old function
mean_new <- function(x){
  if (anyNA(x)) {
    NA
  } else {
    sum(x)/length(x)
  }
}

# here is a rewrite
mean_new <- function(x){
  if (anyNA(x)) {
    return(NA)
  } 
  sum(x)/length(x)
}
mean_new(c(1,2,3,4))
mean_new(c(1,2,3,4,NA))

## Return and print ------------------------------------------------------------

# Often we might call a function and would like it too return certain data but
# also print something different. Notice that something like this happens when 
# we use the lm() function to run a regression
fit <- lm(mpg~cyl+hp,data=mtcars)
fit  # the output that gets printed
unclass(fit) # the data that gets returned is actually giant list

# we can pull out specific data from the fit object
fit$coefficients  
fit$residuals
# Note: the above is actually done with an S3 class but the print/output has the
#       same principles


# The invisible function can be used to do something similar, the data is still
# returned by the function put the print output of the data is suppressed

# Example R4DS - 19.6.2
# here we write a function that prints the number of missing values using the
# cat() function. But the output return is actually still the dataset
show_missings <- function(df) {
  n <- sum(is.na(df))
  cat("Missing values: ", n, "\n", sep = "")
  
  invisible(df)
}
# notice what gets printed
show_missings(mtcars)

# notice what gets outputted/stored
x <- show_missings(mtcars) 
x
class(x)
dim(x)

# notice that this is a pipeable function because the data is still passed
mtcars %>% 
  show_missings() %>% 
  mutate(mpg = ifelse(mpg < 20, NA, mpg)) %>% 
  show_missings() 

# a slightly different version using an explicit print. Here the number of 
# missing values is still printed but the data is also printed
show_missings2 <- function(df) {
  n <- sum(is.na(df))
  print(paste0("Missing values: ", n, sep = ""))
  
  df
}

show_missings2(mtcars)
show_missings(mtcars)
# notice the print statement still prints on assignment
x <- show_missings2(mtcars)
x

##############################
#### Function Environment ####
##############################

## Local vs Global environments ------------------------------------------------

# these variables are stored globally
a <- 10
b <- 3
c <- 5

# the values a,b,c are only locally available inside this function
f <- function(a,b){
  c <- a + b
  return(c)
}

# these are equivalent 
f(a,b)
f(a=a,b=b)

# here we specify different values for a and b, these are local assignments 
# inside the function
f(a=9,b=10)

# note we cannot call without a or b
f()



## Lexical Scoping -------------------------------------------------------------

# A function first looks for a named object assigned inside the function

# y is looked up outside the function
f <- function(x) {
  x + y
} 

y <- 100
f(10)

y <- 1000
f(10)

# we could also specify y inside the function and then the global y will be 
# ignored

f <- function(x) {
  y <- 8
  x + y
}

# notice that now the global y is ignored
y <- 1000
f(10)

# if a variable is not specified in the function or in the global environment 
# the function will then look at the environment inside packages
dplyr::storms # dataset contained in the dplyr package
library(dplyr)

# R will look inside loaded packages if storms is not found in global environment
f <- function(){
  count(storms,year)
}
f()

# now add a modified object storms to the global environment
storms <- storms %>% slice(1:1000)
# this changes the function output
f()

# if we remove storms from the global environment it will resume looking in 
# loaded packages
rm(storms)
f()

## functions vs variables ------------------------------------------------------
# when function and variable share same name R will look for the value first 
# before looking for the function
g09 <- function(x) x + 100

g10 <- function() {
  g09 <- 10 # inside the local environment of the function
  g09(g09)
}
g09

# note that the function uses the value 10 assigned to g09 inside the function
g10()


## Assignment ------------------------------------------------------------------

# clear space to make if easier to view what is happening
rm(list=ls())

# let's assign x a value of 10
x <- 10

# then try to change x using a function
change_x <- function(val){
  x <- val
}

change_x(19)
x
# notice x does not change, this is because the value x assigned inside the 
# function is local to the function

# Now to change the global x value we can use the global assignment (or scoping)
# opperator <<-
change_x <- function(val){
  x <<- val
}
change_x(19)
x
# now the value of x is changed

# Another option is to use the assign() function and specify the environment
# to assign the variable to
change_x <- function(val){
  assign("x",val,envir = .GlobalEnv)
}

change_x(30)
x



######################################
#### Advanced Aspects of Function ####
######################################

## passing through arguments with ... ------------------------------------------

# often we want to pass multiple arguments through a function that are not
# explicitly specified when the function is created

# For example, many R functions often allow multiple arguments that are not 
# explicitly specified
sum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
stringr::str_c("a", "b", "c", "d", "e", "f")

# As another example suppose we want to create a function to center and scale
# our data
center_scale <- function(x){
  (x-mean(x))/sd(x)
}

a <- c(3,4,3,5,6,8,2,6,4)
b <- c(3,4,3,5,6,8,2,6,4,NA) # a dataset with missing values

center_scale(a)
# when we pass a vector with missing values both the mean() and
# sd() functions break down
center_scale(b) 

# both the mean and sd functions had the option na.rm, we can use ... to pass 
# additional arguments through our function to the other functions called inside
center_scale <- function(x,...){
  (x-mean(x,...))/sd(x,...)
}

# This then allows us to pass the argument na.rm = TRUE through to the internal
# functions without having to explicitly state what the na.rm return behavior 
# should be.
center_scale(b,na.rm = TRUE)

# This example also appeared in prior notes....when we talked about how to make 
# the lm() function pipeable...recall data is not the first argument in lm()

# this does not work because the first argument is not the dataset
mtcars %>% 
  lm(mpg ~ wt + hp)

# here we explicitly pass data to the data argument in the lm function, but then
# all remaing arguments are passed as well
lm_new <- function(data,...){
  lm(...,data = data)
}

# now we can pipw with the lm_new() function
mtcars %>% 
  lm_new(mpg ~ wt + hp)


## Function Lists --------------------------------------------------------------

# functions are like any other object in R...they can be stored inside lists for
# example. This is useful if we want to apply multiple functions at once

# we can create a list of functions that compute summary statistics
funs <- list(
  sum = sum,
  mean = mean,
  median = median
)

funs
# some value to apply the functions to
x <- 1:10

# now we can apply these functions to the vector of values in x (more details
# on the lapply function will come later)
lapply(funs, function(f) f(x))


## Closures --------------------------------------------------------------------

# R also allows us to build function factories...these are called closures and 
# are functions that build functions. 

# here we create a power function that allows us to create other functions where
# the exponent is set
power <- function(exponent) {
  function(x) {
    x ^ exponent
  }
}

# note that the output of this function is a function
power(2)
power(2)(4)

# we can then use this to create explicit functions based on a given exponent
square <- power(2)
cube <- power(3)

square(2)
square(4)
cube(2)
cube(4)

# to see the enclosing environment and the internal exponent value that is used
# in the environment us environment() and as.list()
as.list(environment(square))
as.list(environment(cube))

## copy on modify --------------------------------------------------------------

# The same copy on modify behavior applies to functions as discussed before
f <- function(a) {
  a
}

x <- c(1, 2, 3)
lobstr::obj_addr(x)
y <- f(x)
# when y is assigned by the function, the same location is preserved if no 
# modification is made
lobstr::obj_addr(y)

# the above point will be useful when we pass lists (or data.frames) to a 
# function but only certain variables are modified. This should allow you to 
# understand the following

tmp_data <- mtcars

lobstr::obj_addr(tmp_data$mpg)
lobstr::obj_addr(tmp_data$wt)

tmp_data2 <- tmp_data %>% 
  mutate(wt=wt+10)

lobstr::obj_addr(tmp_data$mpg) == lobstr::obj_addr(tmp_data2$mpg)
lobstr::obj_addr(tmp_data$wt) == lobstr::obj_addr(tmp_data2$wt)


###########################
#### Practice Problems ####
###########################

# 1) Write a function is.odd(x) that checks if a value x is even or odd, and 
#    then returns TRUE if the number is odd and FALSE if the number is even.


# 2) Using the function you just wrote, create another function called 
#    separate_odd_even(x) that takes a vector of values x and separates them 
#    into a list containing two vectors one containing the odd values and one
#    containing the even values.


# 3) Complete question 4 from Exercises 19.2.1 (in R4DS) to first create a 
#    function to compute variance, and one function to compute skewness. See
#    here for the formulas: https://r4ds.had.co.nz/functions.html#exercises-50

# create variance()


# create skewness()


###########################
#### Answer to Example ####
###########################

# here is how we could create a new mean function with similar behavior 
mean_new <- function(x, na.rm = FALSE){
  
  # remove missing if na.rm==TRUE
  if (na.rm==TRUE){
    x <- na.omit(x)
  }
  # then proceed as before
  if (anyNA(x)) {
    NA
  } else {
    sum(x)/length(x)
  }
}

mean_new(c(1,2,3,4,NA))
mean_new(c(1,2,3,4,NA), na.rm = TRUE)

mean(c(1,2,3,4,NA))
mean(c(1,2,3,4,NA), na.rm = TRUE)


