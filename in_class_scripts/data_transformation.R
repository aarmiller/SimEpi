
# This script covers basi data transformation using dplyr

# Dplyr cheatsheet: https://github.com/rstudio/cheatsheets/blob/master/data-transformation.pdf

library(tidyverse)

################################################
#### Pipe Operator & Functional Programming ####
################################################

# Note: There is an official native pipe operator coming to R
#       This will look like |> but will have slightly different behavior

## What is the pipe operator? --------------------------------------------------

mean(mtcars$mpg)

mtcars$mpg %>% 
  mean()

# f(x) becomes x %>% f()

filter(mtcars,mpg>20)

mtcars %>% 
  filter(mpg>20)

# How functions should be written f(data,option1,option2,option3)

# regression model
lm(mpg ~ cyl + disp, data = mtcars)

# this does not work
mtcars %>% 
  lm(mpg ~ cyl + disp)

# here is how to correct
mtcars %>% 
  lm(mpg ~ cyl + disp, data = .)

# or we could fix this function
lm_functional <- function(data,...){
  lm(data = data, ...)
}

# now this works as expected
mtcars %>% 
  lm_functional(mpg ~ cyl + disp) 


## Why use the pipe ------------------------------------------------------------

mtcars %>% 
  filter(mpg > 16) %>%                # exclude very inefficient cars
  mutate(cyl = as.factor(cyl)) %>%    # treat cylinder as a factor
  select(mpg,cyl,disp) %>%            # select only the variable for regression
  lm_functional(mpg ~ .)              # run model



## Limitations of using tidyverse ----------------------------------------------


#####################
#### Dplyr Verbs ####
#####################

## Load Data -------------------------------------------------------------------
load("data/nhds/nhds_same_day.RData")

## Select ----------------------------------------------------------------------
select()

# renaming variables
rename()

# renaming during selection

## Filter ----------------------------------------------------------------------
filter()

# See R4DS Chapter 5.2.2 for more on logical operators

## Mutate ----------------------------------------------------------------------
mutate()

# transmute
transmute()

## Arrange ---------------------------------------------------------------------
arrange()

# arrange helper function
desc()

## Summarize -------------------------------------------------------------------
summarize()
summarise()

## Group By --------------------------------------------------------------------
group_by()

# shortcut for grouped counting
count()

## Others ----------------------------------------------------------------------
slice()

distinct()

sample_frac()

sample_n()

######################
#### Helper Verbs ####
######################

# selection helpers
contains()
starts_with()
ends_with()

# filter helpers
between()

# mutate or summarize helpers
n()
row_number()

#######################
#### Joins & Binds ####
#######################

# Joining

inner_join()

left_join()

right_join()

full_join()

anti_join()

# Binding/Stacking
bind_rows()

bind_cols()

######################
#### Scoped Verbs ####
######################

mutate_at()
mutate_all()


########################
#### Group Problems ####
########################

# Problem 1 --------------------------------------------------------------------

# Problem 1: Using 1 chain of commands find the primary diagnosis codes that 
# occured in at least 15 or more records, then reduce the dataset down to visits 
# for just those observations and add a column dx_counts with the frequency of 
# that dx

# Note: you can do this in 3 lines of code

# Your dataset will look something like this

# A tibble: 380 x 13
#   dx1   dx_count  ageu   age   sex  race month status region atype dx2   dx3     pr1
#   <chr>    <int> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <chr> <chr>   <chr> 
# 1 41401       57     1    71     1     1    10      1      3     3 4111  "5854"  "0066"
# 2 41401       57     1    78     2     1    12      1      2     2 486   "496"   ""    
# 3 41401       57     1    55     1     1     8      1      3     1 07054 "27801" "3722"




# Problem 2 --------------------------------------------------------------------

# Problem 2 - Using 1 chain of commands count the most common primary diagnosis 
# code by sex

# Your dataset should look something like this:

# A tibble: 2 x 3
#    sex   dx1       n
#   <dbl>  <chr>  <int>
# 1     2  4019     27
# 2     1  41401    38  



# Problem 3 --------------------------------------------------------------------

# Problem 3 - For each diagnosis code count the number of times it occered 
# overall (n), the number of times it occured in females (female_n), the number
# of times it occured in males (male_n), the overall rank of the code in terms 
# of counts (overall_rank), the rank for female (female_rank) and the rank for
# males (male_rank). Name he variable the values in parenthesize
#
# Hint: the dplyr helper function dense_rank(), is not required, but can help
?dense_rank

# Your result should look something like the following:

# A tibble: 779 x 7
#   dx1       n female_n male_n overall_rank female_rank male_rank
#   <chr> <int>    <int>  <int>        <int>       <int>     <int>
# 1 41401    57       19     38            1           5         1
# 2 4019     53       27     26            2           1         4
# 3 0389     50       21     29            3           4         2