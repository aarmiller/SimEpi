
# This script contains examples for a basic review of R

# See Chapters 1,2,4,6 of R4DS for additional details

##################################
#### R scripts and commenting ####
##################################

# Use '#' to comment code

# It is VERY IMPORTANT to leave yourself notes in comments
# This makes your code more readable to others and also reminds you what 
# you were doing

# You should also use commenting to organize and separate code in meaningful 
# sections or compartments.

# You can create collapsible code using multiple #

# Load Data ######################

# Plot Data ######################

# Load data ----------------------

# Plot data ----------------------


#################################
#### Using R as a calculator ####
#################################

# Note: You can used ctrl + enter (Windows) or cmd + enter (Mac) to send code 
#       to the console

# You can use R for basic mathematical operations

1+4

40*50

sqrt(2)

abs(4.56)

(4+5)/10

4+5/10

# Mathematical operators
# +
# -
# *
# /
# ^ or **
#  %% - modulus - example: 5 %% 2
#  %/% - integer division - 5 %/% 2

# What is going on here?
(5 %/% 2)*2+ (5 %% 2)
(50 %/% 12)*12+ (50 %% 12)

###########################
#### Object assignment ####
###########################

## Basic object assignment -----------------------------------------------------
# Note: The keyboard shortcut for the assignment operator is alt + "-" or option + "-"
x <- 2

# Why <- is preferred over = ?

# This is good practice:
x <- 1

# this works but is considered bad practice. Why?
x=10

# How does '=' differ in functions? 
# (Note: runif() generates random uniform numbers)
runif(n = 5)

# notice what happens here...
runif(min <- 5)
runif(min = 5)

# Side note: There are other assignment operators/functions. We will revisit 
# these later. But here is a quick divergence:

## Scoping/global assignment operator - "<<-" 
# Example of <<- (Note this is often not a great idea)
a<<-1

# note how regular assignment works
test_func <- function(x){
  z <- x
}
test_func(5)

# versus global assignment
test_func <- function(x){
  z <<- x
}
test_func(5)

## The assign() function also assigns values
assign("z",15)

# assignment can also be done backwards (although this is not standard)
13 -> x

## Naming conventions --------------------------------------------------------
# Consistency is important for efficient programming
# (See Advanced R 1st ED - Style guide - http://adv-r.had.co.nz/Style.html)

### Object Names - should be meaningful and consistent ------------------------

#### First, select a style and try to stay consistent

# snake_case (recomended)
my_vector <- c(1,2,3,4)

# camelCase
myVector <- c(1,2,3,4)
MyVector <- c(1,2,3,4)

# with periods
my.vector <- c(1,2,3,4)

#### Second, choose object names that are easy to understand but not too complex

# Good
start_year <- 2005
init_yr <- 2005

# Bad
first_year_of_the_simulation <- 2005
fyots <- 2005
simyr1 <- 2005
nelyx589 <- 2005

# Illegal Names - some names are not allowed
_abc <- 2
if <- 2
1abc <- 2

# but these can be forced with `` (however, try to avoid this)
`1abc` <- 2

### File Names - should also be meaningful --------------------------

# Good names
# regression-models.R
# utility-functions.R
# regression-models-01252021.R  # Note: date stamp added

# Bad names
foo.r
stuff.r

# for files that need to be run sequentially
# 0-download.R
# 1-clean_data.R
# 2-build_models.R

## Copy on modify -----------------------------------------------

# R is lazy (this is a good thing) when it comes to object assignment
# When is value of b assigned a new location?
a <- c(1, 5, 3, 2)
b <- a
b[[1]] <- 10

# the function lobstr::obj_addr() tells us the address (memory location) of an object
a <- c(1, 5, 3, 2)
b <- a
lobstr::obj_addr(a)
lobstr::obj_addr(b)
b[[1]] <- 10
lobstr::obj_addr(b)

# R creates copies lazily (from help file)
x <- 1:10
y <- x
lobstr::obj_addr(x)
lobstr::obj_addr(y)

# The address of an object is different every time you create it:
obj_addr(1:10)
obj_addr(1:10)

#########################################
#### Workspace and working directory ####
#########################################

# summarizing workspace
ls()

# clearing objects
rm(a)

# clearing all objects
rm(list=ls())

# locating or setting the working directory
getwd()
setwd()

############################################
#### Very Basic Data Types & Structures ####
############################################

## Basic data types -----------------------------------------------------------

# checking object type/class
class(1)

# numeric or double
class(1)
# integer
class(1L)
# character
class("1")
# factor
class(as.factor("1"))

## Vectors --------------------------------------------------------------------

# created with c() function
vec1 <- c(1,2,3,4)

# or with : colon/sequence operator
vec2 <- 10:30

# or other functions
seq(from = 100, to = 1000, by = 30)

### vectorized operations
vec1^2
sqrt(vec1)

## list -----------------------------------------------------------------------
list(1,2,3,4)
list(vec1,vec2)

# lists can contain different data types
list(vec1,vec2,c("A","B","C","D"))

# values can also be named
list(a=1,
     b="happy",
     c=c(24L,30L),
     d=1:30,
     e=letters)

## data.frame -----------------------------------------------------------------
tmp_df <- data.frame(a = c(1,2,3),
                     b = c("happy","sad","mad"))

# Note: a data.frame is a special type of list
b <- as.list(tmp_df)

lobstr::obj_addr(tmp_df$a) == lobstr::obj_addr(b$a)

## missing values -------------------------------------------------------------
vec3 <- c(1,2,3,4,NA,6,7)

###################
#### Functions ####
###################

# R is a functional programing language...we have already seen a number of functions

mean(vec1)
median(vec2)

# Most functions allow or require multiple argument
# Notice required, optional and default argument
mean(vec3)
mean(vec3, na.rm = TRUE)

# default values
rnorm(10)
rnorm(10,mean = 10,sd = 3)

# writing a basic function
add_vals <- function(a,b){
  a+b
}

add_vals(1,2)
add_vals(c(1,2,3),c(4,5,6))

################
#### Base R ####
################

# Functions and operators loaded as part of the default R install package, 
# available without having to load packages

# view examples here: https://rstudio.com/wp-content/uploads/2016/10/r-cheat-sheet-3.pdf

#############################
#### installing packages ####
#############################

# installing packages
install.packages("dplyr")

# updating packages
update.packages()

# loading packages
library(dplyr)

# calling functions from within packages
# Note: function names often overlap
stats::filter()
dplyr::filter()

# installing packages from github
# UNCOMENT ONLY TO INSTALL THE DEVELOPMENT VERSION
# install.packages("devtools")
# devtools::install_github("hadley/dplyr")


############################
#### Logical Operations ####
############################

# basic
1<3
2<=2
5==4
5!=4

# and/or

TRUE & TRUE

TRUE & FALSE

TRUE | FALSE

# in
1 %in% c(1,2,3,4)

# is. functions
is.integer(1L)
is.integer(1)

is.character("happy")

is.na(NA)

NA == NA

is.numeric(1L)

is.double(1L)

# vectorized logic
vec1 <- 1:10
vec1

vec1 < 5

x <- c(TRUE,TRUE,FALSE)
!x

# Basic conditional statements
a <- 3
b <- 2

if (a>b) {"A"} else {"B"}

a <- 1
b <- 2

if (a==b) {
  print("Equals")
  } else {
    print("Not Equal")
    }

###########################
#### Internal datasets ####
###########################

# R comes with a number of preloaded datasets
mtcars

# use data() to see available datasets
data()

# or data sets contained in other packages
data(package = .packages(all.available = TRUE))


####################
#### Help Files ####
####################


# use ? or help() to get help files for function
?mean

help(mean)


# Example in help files
x <- c(0:10, 50)
xm <- mean(x)
c(xm, mean(x, trim = 0.1))


###########################
#### Sourceing Scripts ####
###########################

source("R/SimEpi/admin/install_packages.R")

