
# This script provides a more in-depth exploration of data types and structures
# along with subsetting and creation

library(tidyverse)
library(lobstr)


####################
#### Data Types ####
####################

## Creating 4 Basic Types ------------------------------------------------------

# "scalars" are created as....but these aren't really scalars...
T
F
TRUE
FALSE
as.logical(0L)
as.logical(1L)

# Doubles created with
0.1332
1.23e5
0xcafe
NaN
Inf
-Inf

# Integers
1313L
22e4L
0xcafeL

# strings
"help"
"NEVER"

## Logical ----------------------------------------------------------------------

# The most basic data type
TRUE*5
TRUE+TRUE
TRUE/TRUE
TRUE/FALSE

as.integer(TRUE)
as.integer(FALSE)

# By default NA revert to logical
class(NA)
typeof(NA)

## More on numeric class -------------------------------------------------------

# What does class() tell us about an object
class(1L)

# Double / Numeric

class(4) 

# Integer

class(4L) # integer

is.numeric(4L)
is.integer(4L)

is.integer(4L)
is.double(4)

# type vs class

typeof(4)
typeof(4L)

?class()
?typeof()

## What is going on here in the following chunks of code? (Something does not add
## up correctly?)
1 + 2 == 3
(1 + 2)/10 == .3
.1 + .2 == .3

seq(0, 1, by=.1)
seq(0, 1, by=.1) == .3

x <- sqrt(2) ^ 2
x
x == 2

# What the true numbers look like
print(.1, digits=20)
print(.2, digits=20)
print(.1+.2, digits=20)
print(.3, digits=20)

# Problem 1: Weird Behavior
sqrt(2) ^ 2 == 2

## floating point arithmetic & data storage ------------------------------------

# how integers are stored on a computer (bits)

as.numeric(intToBits(4L))

a <- 4L

b <- as.numeric(intToBits(a))

sum(b*2^(0:31))
# 0*2^0 + 0*2^1 + 1*2^2 + 0*2^3 + ... + 0*2^31

## Problem 2: Integer overflow
#a <- .Machine$integer.max
a <- 2147483647L
typeof(a)
typeof(a+1)

b <- a+1L
b

library(bit64)
b <- as.integer64(a) + 1L
b

# Now we can go all the way up to 9,223,372,036,854,775,295
as.integer64(9223372036854775295)
as.integer64(9223372036854775296)

# How real numbers are stored in a computer...
# What is a floating point number? 
# floating point representation - How to represent real numbers in computer

# Sign 
s = 0
# Exponent
e = -3
# significand
sig = 1+2^(-2)

# (-1)*sign+significad*2^exponent
(-1)^s*sig*2^e

## Problem 3: arithmetic underflow

a <- rep(0.01,times=1000)
b <- rep(0.01,times=10000)

prod(a)==prod(b)

## Different Classes (not type) ------------------------------------------------

## Factors
a <- as.factor("C")
class(a)
typeof(a)

## Dates & Times 
a <- as.Date("1/16/19",format="%m/%d/%y")
class(a)
typeof(a)
attributes(a)

as.numeric(as.Date("1/16/19",format="%m/%d/%y"))
as.integer(as.Date("1/16/19",format="%m/%d/%y"))

class(as.Date("1/16/19",format="%m/%d/%y")) 

# whats the origin
today_ref <- as.integer(Sys.Date())
Sys.Date()-today_ref

# POSIX times - Portable Operating System Interface

b <- as.POSIXct("2018-08-01 22:00", tz = "UTC")
b
typeof(b)
class(b)
attributes(b)


## Others ----------------------------------------------------------------------

# Null
class(NULL) 
typeof(NULL)

# Note NA is not a class but assumes what object it is contained in

typeof(NA) # missing...logical?
typeof(as.integer(NA))
typeof(as.numeric(NA))

# special doubles
typeof(NaN)
typeof(NA)
typeof(Inf)

# Don't use == to check
NA == NA
NULL == NULL

is.na(NA)
is.null(NULL)
is.infinite(Inf)
is.finite(Inf)

## Other special values

1e308 * 10
1e308 * -10
0/0
Inf - Inf

# efficiency of object sizes, 
a <- c(1,2,3)
b <- c(1L,2L,3L)
d <- c("1","2","3")
object.size(a)
object.size(b)
object.size(d)

b <- seq(from=1, to=1000000)
a <- as.numeric(b)
object.size(a)
object.size(b)

###################################
#### Data Structures - Vectors ####
###################################

## Vector Types and Construction  ----------------------------------------------

### There are no scalars in R
1 # this is a vector of size 1

# vectors are atomic...they can only be of a homogeneous type

### Four basic types of atomic vectors: logical, integer, double, and character
### Note: numeric vectors include both integer and double

# creating and combining
c(1,2)
rep(c("a","b"), times = 3)
rep(c("a","b"), each = 3)

c(c(1,2),c(3,4))

## Vectors have 2 main properties
letters
# type
typeof(letters)
# length
length(letters)

# type preference Logical -> Int -> Numeric -> Character
a <- c(TRUE,FALSE)
b <- c(a,3L)
c <- c(b,5)
d <- c(c,"help")

typeof(a)
typeof(b)
typeof(c)
typeof(d)

# testing and coercion

x <- c(1,2,3,4)

# testing functions is.*
is.numeric(x)
is.double(x)
is.character(x)

# coercien functions as.*
as.character(x)
as.logical(x)

## Missing values in vectors ---------------------------------------------------
typeof(NA)

# Missing values adopt the type of vector
c(1,2,3,4,NA)
as.integer(c(1,2,3,4,NA))
as.character(c(1,2,3,4,NA))

# first notice how NA behaves
NA > 5
10 * NA
!NA
NA ^ 0
NA | TRUE
NA & FALSE

x1 <- c(1,5,8,10)
x2 <- c(NA, 5, NA, 10)
x1 == NA
x2 == NA
is.na(x1)
is.na(x2)

mean(x1)
mean(x2)
mean(x2,na.rm = T)

## Attributes of Vectors -------------------------------------------------------

# Naming
x <- c(a = 1, b = 2, c = 3)

x <- 1:3
names(x) <- c("a", "b", "c")

x <- setNames(1:3, c("a", "b", "c"))

attributes(x)
attr(x,"names")
names(x)
x
class(x)

## We can create other attributes
a <- c(a = 1, b = 2, c = 3)
attr(a,"x") <- "abcdef"
attr(a, "y") <- 4:6
attributes(a)


## Character Vectors -----------------------------------------------------------

# R uses a global string pool
# each unique string is only stored once

a <- c("aaa","aab","aac")
obj_size(a)

b <- c("aac","aac","aac")
obj_size(b)


x <- "This is a long series of characters"
obj_size(x)
# not what 1,000 times the size would be
obj_size(x)*1000

y <- rep(x,1000)
obj_size(y)

# special memory assignment of character vector
x <- c("a", "a", "abc", "d","abc")
lobstr::ref(x, character = TRUE)

## Factors ---------------------------------------------------------------------
obj_size(as.factor(y))
# Factors are built on top of integers with two attributes class - "factor"
# and levels

x <- rep(state.name,times=10000/50)
obj_size(x)

y <- as.factor(rep(state.name,times=10000/50))
obj_size(y)

z <- as.integer(seq(from=1, to=10000, by=1))
obj_size(z)
# quick digression (why did I have to use seq and not 1:10000)
obj_size(1:10)
obj_size(1:10000)

# now notice the factor is the same size as the integer sequence plus the characters
obj_size(state.name) + obj_size(z)

# notice how information on factors is being stored as an attribute attached to
# an integer vector
attributes(y)
typeof(y)

# Note that we can easily see by converting to integer
head(as.integer(y),100)

## Why is this important to keep in mind???????

# keep in mind what happens when we convert to factors
y[1:10]

# some functions will treat as integer
c(y[1:10])

# some will break
nchar(y[1])


## Ordered Factors - factor values can be assigned an ordering
# Re-ordering factors
summary(y)

summary(fct_relevel(y,"Wyoming","New York"))
# Note....we will talk more about functions to
# This will be most useful for printing and tables

## Dates and times -------------------------------------------------------------
# these are built on top of Numeric vectors

Sys.Date()

a <- Sys.Date()
b <- a + 0:31
b
typeof(b)
as.numeric(b)
attributes(b)


## Other characteristics of vectors --------------------------------------------

# Vector recycling
1:10 + 1:2

## vectorized operations ------------------------------------------------------

# Golden Rule of efficiency - "access the underlying C/Fortran routines as quickly as possible"
#    - Efficient R Programming 3.2.2

runif(10)
runif(10) + 1

# our first simulation - Law of Large Numbers (LLN)
a <- runif(1000)
b <- 1:1000
c <- cumsum(a) / b 
plot(b,c)

# in one line
plot(1:1000, cumsum(runif(1000)) / 1:1000)


#################################
#### Data Structures - Lists ####
#################################


## Lists ----------------------------------------------------------------------

# Like a vector but allow for heterogeneous types and lengths

x <- list(a=1:10,
          b=letters,
          c=c(3.3,4,4))

length(x)
length(x$a)

# Lists copy on modify behavior

l1 <- list(1, 2, 3)
lobstr::obj_addr(l1[[1]])
lobstr::obj_addr(l1[[2]])
lobstr::obj_addr(l1[[3]])

l2 <- l1
lobstr::obj_addr(l2[[1]])==lobstr::obj_addr(l1[[1]])
l2[[4]] <- 9

lobstr::obj_addr(l2[[1]])==lobstr::obj_addr(l1[[1]])
lobstr::obj_addr(l2[[1]])==lobstr::obj_addr(l1[[]])

# Matrices and Arrays ----------------------------------------------------------
x <- matrix(1:6, nrow = 2, ncol = 3)
x

y <- array(1:12, c(2, 3, 2))
y

z <- 1:6
attributes(z)
class(z)

dim(z) <- c(3, 2)
attributes(z)
class(z)


# Discuss more later 


###################################################
#### Data Structures - data.frames and tibbles ####
###################################################

## data.frames -----------------------------------------------------------------

# attributes

attributes(mtcars)

names(mtcars)
rownames(mtcars)
colnames(mtcars)

length(mtcars)
nrow(mtcars)

as.list(mtcars)

# Copy-on-modify behavior (Note a certain type of list)
d1 <- data.frame(x = c(1, 5, 6), y = c(2, 4, 3))

lobstr::obj_addr(d1$x)
lobstr::obj_addr(d1$y)

# modify a column
d2 <- d1
d2[, 2] <- d2[, 2] * 2

lobstr::obj_addr(d2$x)==lobstr::obj_addr(d1$x)
lobstr::obj_addr(d2$y)==lobstr::obj_addr(d1$y)

# modify a row
d3 <- d1
d3[1, ] <- d3[1, ] * 3

lobstr::obj_addr(d3$x)==lobstr::obj_addr(d1$x)
lobstr::obj_addr(d3$y)==lobstr::obj_addr(d1$y)


# note what happens with list
l1 <- as.list(d1)

obj_addr(d1$x)==obj_addr(l1$x)

## Tibbles ---------------------------------------------------------------------

# Creating
as_tibble(mtcars)

tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)

tibble(
  `:)` = "smile", 
  ` ` = "space",
  `2000` = "number"
)

tribble(
  ~x, ~y, ~z,
  #--|--|----
  "a", 2, 3.6,
  "b", 1, 8.5
)


# Advantages of Tibbles

# Differences

# Viewing

# a different with tibbles - partial matching

as.data.frame(mtcars)[["mp"]]

df <- data.frame(abc = c(1,2,3), xyz = c("a","b","c"))
df

df2 <- as_tibble(df)

df$a
df$x
df2$x


# Converting back and forth
mtcars
mtcars2 <- as_tibble(mtcars)
mtcars2
as.data.frame(mtcars2)
# notice what we lost?
rownames_to_column(mtcars)
?rownames

####################
#### Subsetting ####
####################

# Base R Subsetting

## Subsetting Vectors ----------------------------------------------------------

x <- 3:7
names(x) <- c("a","b","c","d","e")
x

## by position
x[1]

# using a vector
x[c(1,3,5)]
x[x>5]
x[c(T,T,F,F,F)]

# by name
x["a"]
x[c("a","e")]


## Subsetting Lists ------------------------------------------------------------

y <- list(a=1:10,
          b=letters,
          c=c(3.3,4,5.2))

# by position
y[1]
y[[1]] # to pull out the actuall vector
y[[1]][1]
y[[1]][2]

y[c(1,2)]
y[c(1,2)][2]
y[c(1,2)][[2]]

# by name
y["a"]
y[c("a","c")]
y$a

#notice
y$a == y["a"]
y$a == y[["a"]]

## Subsetting data.frames ------------------------------------------------------

df <- data.frame(num=1:26,
                 lower_case=letters,
                 upper_case=LETTERS)

# by position
df[1,1]
df[1,]
df[,1]

df[c(1,2,3),]
df[c(T,T,F),] #? Why did this happen

# by name
df$num
df$lower_case
df$upper_case

# sometimes we have rownames
mtcars
mtcars["Fiat 128",]

# filtering
df$num>10
df[df$num>10,]
df[df$num>10,]$upper_case

df[df$lower_case %in% c("a","e","i","o","u"),]

## Subsetting a matrix ---------------------------------------------------------
x <- matrix(1:6, nrow = 2, ncol = 3)
x

# can subset the original vector
x[1]
x[3]

# or by matrix position
x[2,]
x[,1]
x[2,1]
x[2,3]
