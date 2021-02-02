
# This script provides a more in-depth exploration of data types and structures
# along with subsetting and creation

library(tidyverse)
library(lobstr)


####################
#### Data Types ####
####################

## Creating 4 Basic Types ------------------------------------------------------

# "scalars" are created as the following types....but these aren't really scalars...

# Logicals created with:
T
F
TRUE
FALSE
as.logical(0L)
as.logical(1L)
as.logical(3L)

# Doubles/floating-point number created with:
0.1332
1.23e5
0xcafe # This is a hexadecimal number
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

# These are the most basic types of data

# Notice we can work with logicals like integers
TRUE*5
TRUE+TRUE
TRUE/TRUE
TRUE/FALSE
as.integer(TRUE)
as.integer(FALSE)

# By default NA reverts to logical
class(NA)
typeof(NA)

## More on numeric class -------------------------------------------------------

# What does class() tell us about an object
class(1L)

# Double / Numeric
class(4) 

# Integer
class(4L) # integer

# Notice the difference here:
is.numeric(4L)  # This is checking class
is.integer(4L)  # This is checking type
is.double(4L)   # This is checking type

is.numeric(4)
is.integer(4)
is.double(4)


# type vs class
# type is typically what we want to know (integer, double, character, etc.)
typeof(4)
typeof(4L)

# class is information used within the object-oriented programming
# class is basically a piece of meta data - describing what the oject is or how 
# it should be used
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

# What the true numbers look like - note: behind the scenes the exact value is
# not being stored. This is because of floating point representation (more below)
print(.1, digits=20)
print(.2, digits=20)
print(.1+.2, digits=20)
print(.3, digits=20)

# Problem 1: Weird Behavior - this is the first probably we need to watch out for
sqrt(2) ^ 2 == 2

# we can use something like all.equal() to look for "near" equality
all.equal(sqrt(2) ^ 2,2)
all.equal(.1 + .2,.3)

## floating point arithmetic & data storage ------------------------------------

# how integers are stored on a computer - binary representation (bits)
# these are essentially boolean values that get multiplied by 2^i for different 
# values i

# This is the binary represent of the integer 4
as.numeric(intToBits(4L))

# Now lets encode/decode this:
a <- 4L  # number we want to encode
b <- as.numeric(intToBits(a)) # the binary representation (how stored in computer)
sum(b*2^(0:31)) # decode the original representation
# Note this is the math: 0*2^0 + 0*2^1 + 1*2^2 + 0*2^3 + ... + 0*2^31

## Problem 2: Integer overflow - another problem to watch out for
#a <- .Machine$integer.max #if you uncomment this line, this will give the largest integer the machine can store
a <- 2147483647L
typeof(a)
typeof(a+1) # adding double 1 converts a to double and everything works fine

b <- a+1L # adding integer 1 causes things to blow up (integer overflow)
b

# Note: base R is limited to 32-bit integers
# The bit64 package introduces 64-bit integers
library(bit64)
b <- as.integer64(a) + 1L
b   # now we can store an integer

# Now we can go all the way up to 9,223,372,036,854,775,295
as.integer64(9223372036854775295) # this is now our upper limit
as.integer64(9223372036854775296)  # but this blows up

# How real numbers are stored in a computer...
# What is a floating point number? 
# floating point representation - How to represent real numbers in computer
# a floating point number is broken into 3 components (each of which are easy to
# store as an integer/bits)

# Sign 
s = 0
# Exponent
e = -3
# significand
sig = 1+2^(-2)

# Combining these in the following form gives the floating-point representation
# (-1)*sign+significad*2^exponent
(-1)^s*sig*2^e

## Problem 3: arithmetic underflow/overflow
# If you multiply many small or large number you may loose precision

a <- rep(0.01,times=1000)
b <- rep(0.01,times=10000)

prod(a)==prod(b)

# a possible solution: apply log() -  think about why this works?
sum(log(a))==sum(log(b)) # this works as a comparison
# even though exp(sum(log(a)))==exp(sum(log(b))) are what we want

## Different Classes (not type) ------------------------------------------------
# the following do not introduce new data types but rather classes

## Factors are an integer
a <- as.factor("C")
class(a)
typeof(a)

## Dates & Times are a double
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
# This allows us to incorporate time (more on this later)
b <- as.POSIXct("2018-08-01 22:00", tz = "UTC")
b
typeof(b)
class(b)
attributes(b)


## Others ----------------------------------------------------------------------

# Null is it's own class/type
class(NULL) 
typeof(NULL)

# Note NA is not a class but assumes what object it is contained in
typeof(NA) # missing...logical?
typeof(as.integer(NA))
typeof(as.numeric(NA))

# These are special types of doubles
typeof(NaN)  # not a number
typeof(Inf)  # positive infinity
typeof(-Inf) # negative infinity

# Don't use == to check NA or NULL values....this causes probablems
NA == NA
NULL == NULL

# instead use is. functions to check special types
is.na(NA)
is.null(NULL)
is.infinite(Inf)
is.finite(Inf)

## Other special values

1e308 * 10
1e308 * -10
0/0
Inf - Inf

# efficiency of object sizes, we will come back to this...but notice integers use
# less space than doubles, which use less space than characters
a <- c(1L,2L,3L)
b <- c(1,2,3)
d <- c("1","2","3")
object.size(a)  # integers are smallest
object.size(b)  # doubles are next
object.size(d)  # characters are largest

# notice the impact as vectors grow
a <- seq(from=1, to=1000000)
b <- as.numeric(a)
c <- as.character(a)
object.size(a)
object.size(b)
object.size(c) # What? That's weird...why is c smaller than b (more below)

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

## Vectors have 2 main properties: type and length
letters
# type
typeof(letters)
# length
length(letters)

# type preference Logical -> Int -> Numeric -> Character
# R will force the most general type on objects when it encounters incompatible 
# types
a <- c(TRUE,FALSE)  # Least general type (logical)
b <- c(a,3L)
c <- c(b,5)
d <- c(c,"help")    # Most general type (character)

typeof(a)
typeof(b)
typeof(c)
typeof(d)

# testing and coercion - We can test the type of object or force it to be another 
x <- c(1,2,3,4)

# testing functions are denoted with is.*
is.numeric(x)
is.double(x)
is.character(x)

# coercion functions are denoted with as.*
as.character(x)
as.logical(x)
as.factor(x)


## Missing values in vectors ---------------------------------------------------
typeof(NA) # this starts as a logical....

# but..missing values adopt the type of vector the belong to
c(1,2,3,4,NA)
as.integer(c(1,2,3,4,NA))
as.character(c(1,2,3,4,NA))

# first notice how NA behaves with logical operations
NA > 5
10 * NA
!NA
NA ^ 0
NA | TRUE
NA & FALSE

# now notice how it behaves inside vectors
x1 <- c(1,5,8,10)
x2 <- c(NA, 5, NA, 10)

x1<7   # note this works as expected
x1 == NA # this does not
x2 == NA # neither does this
is.na(x1) # this is what we want
is.na(x2) # this is what we want

mean(x1)
mean(x2)  # note that many functions may not work properly with NA
mean(x2,na.rm = T) # but can be corrected with optional arguments

## Attributes of Vectors -------------------------------------------------------

# We can name the elements in a vetor in a number of ways

# One way with = 
x <- c(a = 1, b = 2, c = 3)

# Another way with names()
x <- 1:3
names(x) <- c("a", "b", "c")

# Still another way with setNames()
x <- setNames(1:3, c("a", "b", "c"))

# adding names basically adds a name attribute to the vector...if does not 
# change the data being stored in the vector
attributes(x)
attr(x,"names")
names(x)
x
class(x)
typeof(x)

## Notice that we can create other attributes...not just restricted to names
a <- c(a = 1L, b = 2L, c = 3L) # create vector with names
attr(a,"x") <- "abcdef" # add attribute x
attr(a, "y") <- 4:6     # add attribute y
attributes(a)           # view attributes
typeof(a)               # still an integer vector but with some attributes

## Character Vectors -----------------------------------------------------------

# R uses a global string pool
# each unique string is only stored once

a <- c("aaa","aab","aac")
obj_size(a)

b <- c("aac","aac","aac")
obj_size(b) # note this is smaller than a, because b contains 3 of the same string


x <- "This is a long series of characters"
obj_size(x)  # size of the string repeated 1 time
obj_size(x)*1000 # note what size 1,000 repititions should be

y <- rep(x,1000)
obj_size(y)  # however the actual size is much smaller

# the above is because of special memory assignment of character vectors
x <- c("a", "a", "abc", "d","abc")
# this shows us that the data in slots 2 and 5 are actually repetitions of the 
# same data stored in slots 1 and 3...the computer only needs to hold the data
# in slots 1, 3 and 4 - slots 2 and 5 are recycled
lobstr::ref(x, character = TRUE) 

## Factors ---------------------------------------------------------------------

# notice converting our string vector to a factor makes it even smaller
obj_size(y)
obj_size(as.factor(y))
# Factors are built on top of integers with two attributes class (factor)
# and levels
attributes(as.factor(y))

# Notice how the size of a factor is actually broken down
x <- rep(state.name,times=10000/50) # create a character vector
obj_size(x) # this is the size of the character vector

y <- as.factor(x)
obj_size(y) # this is the size of the same character vector expressed as a factor

# Now we can see where this comes from
z <- as.integer(y)
obj_size(z)  # size expressed as an integer

# now notice the factor is the same size as the integer sequence plus the characters
obj_size(state.name) + obj_size(z)
object.size(y) # note the above is basically equivalent to this

# notice how information on factors is being stored as an attribute attached to
# an integer vector
attributes(y)
typeof(y)

# Note that we can easily see that a factor is an integer by converting to integer
head(as.integer(y),100)

## Why is this important to keep in mind???????

# keep in mind what happens when we convert to factors
y[1:10]  # this works fine

# some functions will treat as integer
c(y[1:10]) # but if we try to combine subsets the integer will be used

# some functions will just break with factors
nchar(y[1]) # this breaks

nchar("Alabama") # this is what we wanted

nchar(as.character(y[1])) # we would first need to convert to a character to get this to work


## Ordered Factors - factor values can be assigned an ordering
# Note: we will come back to this more later
# Re-ordering factors
summary(y)

# If we wanted counts for Wyoming and NY to appear first we could re-order the factor
summary(fct_relevel(y,"Wyoming","New York"))

# Note....we will talk more about functions to
# This will be most useful for printing and tables

## Dates and times -------------------------------------------------------------
# these are built on top of Numeric vectors

# get the current date
Sys.Date()

a <- Sys.Date()
b <- a + 0:31   # add values 0 through 31 to expand to a longer vector
b
typeof(b)       # notice the type of vector is double
class(b)        # but the class is date
as.numeric(b)   # we can fource out the numeric representation
attributes(b)


## Other characteristics of vectors --------------------------------------------

# Vector recycling - not that when we combine vectors of different sizes they
# "recycle" values
1:10 + 1:2
1:10 + rep(1:2,times=5) # this is actually what recycling is doing

## vectorized operations ------------------------------------------------------

# Golden Rule of efficiency - "access the underlying C/Fortran routines as quickly as possible"
#    - Efficient R Programming 3.2.2

# whenever you can perform steps using vectorized operations it is likely the 
# most efficient way to do so

# draw 10 random uniform numbers
runif(10)
# add 1 to each random uniform number (this is a vectorized opperation)
runif(10) + 1

# Example: our first simulation - Law of Large Numbers (LLN)
# this example uses vectorized algebra to show that as the sample size n increases
# the mean of n randomly drawn numbers converges to the expected value
# Note: this is very fast because it is vectorized
a <- runif(1000)  # draw numbers
b <- 1:1000       # compute index (for denominator)
c <- cumsum(a) / b # compute the cumulative mean (for n random numbers)
plot(b,c)          # plot convergence of mean

# A simulation all in one line
plot(1:1000, cumsum(runif(1000)) / 1:1000)


#################################
#### Data Structures - Lists ####
#################################


## Lists ----------------------------------------------------------------------

# Like a vector but allow for heterogeneous types and lengths
x <- list(a=1:10,
          b=letters,
          c=c(3.3,4,4))

length(x) # vectors have a length
length(x$a) # but so do the objects inside them

# Lists adhere to copy on modify behavior we have described before
l1 <- list(1, 2, 3)  # create a list
lobstr::obj_addr(l1[[1]]) # view where 1st element stored
lobstr::obj_addr(l1[[2]]) # where 2nd is stored
lobstr::obj_addr(l1[[3]]) # where 3rd is stored

l2 <- l1 # create a new list
lobstr::obj_addr(l2[[1]])==lobstr::obj_addr(l1[[1]]) # note still stored in same spot

l2[[4]] <- 9 # now add an element to second list

# note all the other data is still stored in the same spots
lobstr::obj_addr(l2[[1]])==lobstr::obj_addr(l1[[1]])
lobstr::obj_addr(l2[[2]])==lobstr::obj_addr(l1[[2]])

l2[[2]] <- 4 # modify the second object in the second list

lobstr::obj_addr(l2[[2]])==lobstr::obj_addr(l1[[2]])  # Now the second object locations differ
lobstr::obj_addr(l2[[1]])==lobstr::obj_addr(l1[[1]])  # But the first elements remain the same


# Matrices and Arrays ----------------------------------------------------------

# A matrix is just a vector with a different shape
x <- matrix(1:6, nrow = 2, ncol = 3) # creating a matrix from a vector 1:6
x
as.vector(x)  # and back to a vector

# An array is similar but contains multiple matrices
y <- array(1:12, c(2, 3, 2)) # creating from a vector
y
as.vector(y) # and back to a vector

# To see this even more clearly...we can simply turn a vector into a matrix simply
# by modifying the dimensions (attributes) of the vector. So a matrix is similar 
# to a factor, insofar as it is a standard vector with attributes that change it's
# representation and functionality
z <- 1:6
attributes(z)
class(z)
# now convert to matrix by adding dimensions
dim(z) <- c(3, 2)
z
attributes(z)
class(z)
# and back to a vector by removing dimensions
dim(z) <- NULL
z



###################################################
#### Data Structures - data.frames and tibbles ####
###################################################

## data.frames -----------------------------------------------------------------

# like lists a data.frame is a combination of vectors of the same length but of 
# possibly different types

# here is an example data.frame
mtcars

# attributes
attributes(mtcars)

# these are the standard attributes of a data.frame
names(mtcars)
rownames(mtcars) # this is not always present
colnames(mtcars)

# data.frames can also be described by their size
length(mtcars) # number of columns
ncol(mtcars)   # also number of columns
nrow(mtcars)   # number of rows

# to see that a data.frame is essentially just a list
as.list(mtcars)

# or more to the point...notice where data is stored
a <- mtcars
b <- as.list(a)
# the vectors of the df and list are storred in the same place
lobstr::obj_addr(a$mpg)==lobstr::obj_addr(b$mpg)
lobstr::obj_addr(a$cyl)==lobstr::obj_addr(b$cyl)

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


## Tibbles ---------------------------------------------------------------------

# Tibbles are basically just data.frames but with some improved appearance properties

# Creating by converting a data.frame
as_tibble(mtcars)

# Or create by combining vectors
tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)

# another benefit of tibble are they allow for non-standard column names
tibble(
  `:)` = "smile", 
  ` ` = "space",
  `2000` = "number"
)

# can also create using tribble()
tribble(
  ~x, ~y, ~z,
  #--|--|----
  "a", 2, 3.6,
  "b", 1, 8.5
)



# One difference between data.frames and tibbles is partial matching

# to see this create a df and tibble
df <- data.frame(abc = c(1,2,3), xyz = c("a","b","c"))
df
# now convert to tibble
df2 <- as_tibble(df)

# the data.frame will return partial matches
df$a
df$x

# the tibble will not
df2$a
df2$x

# we need to specify the full column name with a tibble
df2$abc
df2$xyz


# Converting back and forth
mtcars
mtcars2 <- as_tibble(mtcars)
mtcars2
as.data.frame(mtcars2) # notice what we lost? the row names
rownames_to_column(mtcars) # to avoid we would first need to add the rownames to a column

####################
#### Subsetting ####
####################

# Base R Subsetting

## Subsetting Vectors ----------------------------------------------------------

# create a vector with names
x <- 3:7
names(x) <- c("a","b","c","d","e")
x

## subset by position
x[1]

# subset using a vector of positions or logical values
x[c(1,3,5)]
x[x>5]
x[c(T,T,F,F,F)]

# subset by name (only if the vector has names)
x["a"]
x[c("a","e")]


## Subsetting Lists ------------------------------------------------------------

# create a list
y <- list(a=1:10,
          b=letters,
          c=c(3.3,4,5.2))

# subsetting by position
y[1] # note that this still returns a list with 1 element

y[[1]] # to pull out the actual vector use [[ ]] (double brackets)

y[[1]][1] # subsetting the vector pulled out from the vector
y[[1]][2]

y[c(1,2)]   # pulling out multiple elements from list
y[c(1,2)][2]  # then pulling out a list with second element
y[c(1,2)][[2]]  # finally pulling out the vector contained in the second element

# subsetting by name (only if the list contains names)
y["a"]
y[c("a","c")]
y$a

# notice what is going on here
y$a == y["a"] # did not pull out the vector
y$a == y[["a"]] # did pull out the vector for comparison

## Subsetting data.frames ------------------------------------------------------

# create a data.frame
df <- data.frame(num=1:26,
                 lower_case=letters,
                 upper_case=LETTERS)

# subset by position
df[1,1] # specify row and column
df[1,]  # specify row
df[,1]  # specify column

df[c(1,2,3),] # a list of rows

df[rep(c(T,F),times=13),] # returning every other value using logical vector
rep(c(T,F),times=13) # see what this does in the above command

df[c(T,T,F),] #? Why did this happen (the logical values got recycled)

# returning columns by name
df$num
df$lower_case
df$upper_case

# sometimes we have rownames
mtcars
mtcars["Fiat 128",] # returning a row by row name

# subsetting by filtering
df$num>10 # a logical vector indicating rows where num > 10
df[df$num>10,] # subset rows wher num>10
df[df$num>10,]$upper_case # subset rows wher num>10 and selecting upper_case variable

df[df$lower_case %in% c("a","e","i","o","u"),] # another logical subset

## Subsetting a matrix ---------------------------------------------------------
x <- matrix(1:6, nrow = 2, ncol = 3)
x

# can subset by the original vector coordinates (remember a matrix is a vector 
# with dimensional attributes)
x[1]
x[3]

# or by matrix position [row,colum]
x[2,]
x[,1]
x[2,1]
x[2,3]
