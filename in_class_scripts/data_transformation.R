
# This script covers basi data transformation using dplyr


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
