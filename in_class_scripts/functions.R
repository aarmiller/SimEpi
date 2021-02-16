


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

# rewrite a new mean function
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
c(T,T,T) && c(F,F,T)
any()
anyNA()
all()
identical(3,3)
identical(c(3,3),c(3,3))
# does not coerce types:
identical(c(2L,2L), c(2,2))
dplyr::near(c(2L,2L), c(2,2))


## Multiple Conditions ---------------------------------------------------------

# when evaluating multiple conditions consider using switch()

# one way
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

test_func(1,2,"plus")
test_func(1,2,"divide")

# another way
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

# Often we need to check that our arguments satisfy certain conditions

# Example from R4DS (Chapter 19): Checking conditions 
wt_mean <- function(x, w) {
  sum(x * w) / sum(w)
}

# What is wrong with this and why does this still work?
wt_mean(1:6, 1:3)

# An update to make check that they are the same length
wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  sum(w * x) / sum(w)
}

wt_mean(1:6, 1:3)

# Be careful not to take this too far
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

# Another option is using stopifnot()
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


add_two <- function(x){
  x+2
}

add_two <- function(x){
  out <- x+2
  return(out)
}

add_two(10)


## Ordering explicit returns ---------------------------------------------------

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

## Return and print ------------------------------------------------------------

# Often we might call a function and would like it too return certain data but
# also print something different. 
fit <- lm(mpg~cyl+hp,data=mtcars)
fit
fit$coefficients
fit$residuals

# Note: the above is actually done with S3 class but the print/output has the
#       same principles



# Example R4DS - 19.6.2
show_missings <- function(df) {
  n <- sum(is.na(df))
  cat("Missing values: ", n, "\n", sep = "")
  
  invisible(df)
}

show_missings(mtcars)

x <- show_missings(mtcars) 
class(x)
dim(x)
x

mtcars %>% 
  show_missings() %>% 
  mutate(mpg = ifelse(mpg < 20, NA, mpg)) %>% 
  show_missings() 


show_missings2 <- function(df) {
  n <- sum(is.na(df))
  print(paste0("Missing values: ", n, sep = ""))
  
  df
}

show_missings2(mtcars)
show_missings(mtcars)
x <- show_missings2(mtcars)
x

##############################
#### Function Environment ####
##############################

## Local vs Global environments ------------------------------------------------

a <- 10
b <- 3
c <- 5

f <- function(a,b){
  c <- a + b
  return(c)
}

# these are equivalent 
f(a,b)
f(a=a,b=b)

f(a=9,b=10)

# note we cannot call without a or b
f()



## Lexical Scoping -------------------------------------------------------------

f <- function(x) {
  x + y
} 

y <- 100
f(10)

y <- 1000
f(10)

dplyr::storms
library(dplyr)

# finally R will look inside loaded packages
f <- function(){
  count(storms,year)
}
f()

storms <- storms %>% slice(1:1000)
f()

rm(storms)
f()

## functions vs variables ------------------------------------------------------
# when function and variable share same name R will look for the value
g09 <- function(x) x + 100
g10 <- function() {
  g09 <- 10
  g09(g09)
}
g09
g10()


## Assignment ------------------------------------------------------------------

rm(list=ls())

x <- 10

change_x <- function(val){
  x <- val
}

change_x(19)
x

# Now to change the global x value
change_x <- function(val){
  x <<- val
}

change_x(19)
x

# Another option using assign()
change_x <- function(val){
  assign("x",val,envir = .GlobalEnv)
}

change_x(30)
x



###########################
#### Advanced Function ####
###########################

## passing through arguments with ... ------------------------------------------

# R functions often allow multiple arguments that are not explicitly specified
sum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
stringr::str_c("a", "b", "c", "d", "e", "f")


center_scale <- function(x){
  (x-mean(x))/sd(x)
}

a <- c(3,4,3,5,6,8,2,6,4)
b <- c(3,4,3,5,6,8,2,6,4,NA)

center_scale(a)
center_scale(b)

# we can use ... to pass arguments through
center_scale <- function(x,...){
  (x-mean(x,...))/sd(x,...)
}

center_scale(b,na.rm = TRUE)

# example from prior notes....make lm pipeable
lm_new <- function(data,...){
  lm(...,data = data)
}

mtcars %>% 
  lm_new(mpg ~ wt + hp)


## Function Lists --------------------------------------------------------------
x <- 1:10

# we can create lists of functions
funs <- list(
  sum = sum,
  mean = mean,
  median = median
)

funs

lapply(funs, function(f) f(x))


## Closures --------------------------------------------------------------------

power <- function(exponent) {
  function(x) {
    x ^ exponent
  }
}
power(2)

square <- power(2)
square(2)
square(4)

cube <- power(3)
cube(2)
cube(4)

# to see the enclosing environment
as.list(environment(square))
as.list(environment(cube))

## copy on modify --------------------------------------------------------------

# same behavior applies to functions as discussed before
f <- function(a) {
  a
}

x <- c(1, 2, 3)
lobstr::obj_addr(x)
y <- f(x)
lobstr::obj_addr(y)


###########################
#### Practice Problems ####
###########################

# 1) Write a function is.odd(x) that checks if a value x is even or odd, and 
#    then returns TRUE if the number is odd and FALSE if the number is even.


# 2) Using the function you just wrote, create another function called 
#    separate_odd_even(x) that takes a vector of values x and separates them 
#    into a list containing two vectors one containing the odd values and one
#    containing the even values.


