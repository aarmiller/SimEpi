
# This script covers basi data transformation using dplyr

# Dplyr cheatsheet: https://github.com/rstudio/cheatsheets/blob/master/data-transformation.pdf

# uncomment and run this if you would like to install all the packages we need:
# source("R/SimEpi/admin/install_packages.R")

library(tidyverse)
library(icd)

################################################
#### Pipe Operator & Functional Programming ####
################################################

# Note: There is an official native pipe operator coming to R
#       This will look like |> but will have slightly different behavior

## What is the pipe operator? --------------------------------------------------

# The following are equivalent:
mean(mtcars$mpg)

mtcars$mpg %>% 
  mean()

# f(x) becomes x %>% f()

# another example of equivalent commands (we discuss filter below)
filter(mtcars,mpg>20)

mtcars %>% 
  filter(mpg>20)

# How functions should be written to be pipeable: f(data,option1,option2,option3)

# regression model is not a pipeable function (notice where data is)
lm(mpg ~ cyl + disp, data = mtcars)

# this does not work
mtcars %>% 
  lm(mpg ~ cyl + disp)

# here is how to correct using . to direct the input
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
  lm_functional(mpg ~ .)               # run model

# Notice the advantages:

# can quickly chain together multiple steps without creating intermetiate objects

# can run selections or chunks of code

# easy to comment, interpret and debug

# can comment out individual steps

## Limitations of using tidyverse ----------------------------------------------

# It's not the most stable package - things change a lot

# Uses non-standard evaluation

# Can be problematic to write packages with


#####################
#### Dplyr Verbs ####
#####################

# The grammar of data analysis/transformation

## Load Data -------------------------------------------------------------------

# example data to work with
load("R/SimEpi/example_data/nhds_same_day.RData")

## Select ----------------------------------------------------------------------

# basic select:
select(nhds, age, sex)

# or using pip:
nhds %>% 
  select(age,sex)

# can use ":" to specify all variables between two
select(nhds,age:status,dx1:dx3)

# use "-" to remove variables
select(nhds,-ageu,-age)

# you can also rename and re-arrange with select
select(nhds,age,sex,principal_dx=dx1)

nhds %>% 
  select(age,sex,race,atype)

# renaming variables with rename() - this renames variables without selecting
# or removing any variables
nhds %>% 
  rename(principal_dx=dx1)


## Filter ----------------------------------------------------------------------

# Filter males (sex==1)
nhds %>% 
  filter(sex==1)

# Filter to regions 3 or 4 using |
nhds %>% 
  filter(region ==3 | region == 4)

# same filter using %in%
nhds %>% 
  filter(!(region %in% c(3,4)))

# negating a conditional: not 3 and not 4
nhds %>% 
  filter(!(region %in% c(3,4)))

# See R4DS Chapter 5.2.2 for more on logical operators

## Mutate ----------------------------------------------------------------------

# mutate modifies, transformes and creates new variables

# change sex from integer to character representation
nhds %>% 
  mutate(sex = ifelse(sex == 1, "Male","Female"))

# combining mutates
nhds %>% 
  mutate(pr1 = ifelse(pr1=="",NA,pr1)) %>% 
  mutate(tmp_indicator=ifelse(pr1=="3834",1,0))

# multiple mutations inside a single mutate will work in order. 
# notice how these differ based on order
nhds %>% 
  mutate(pr1 = ifelse(pr1=="",NA,pr1),
         tmp_indicator=ifelse(pr1=="3834",1,0)) 

nhds %>% 
  mutate(tmp_indicator=ifelse(pr1=="3834",1,0),
         pr1 = ifelse(pr1=="",NA,pr1))

# transmute -  transmute()
# this is the same as mutate except only the mutated variables are kept, the 
# rest are dropped
nhds %>% 
  transmute(tmp_indicator=ifelse(pr1=="3834",1,0),
            pr1 = ifelse(pr1=="",NA,pr1))


## Arrange ---------------------------------------------------------------------
# Arrange is used to sort/arrange data

# arrange based on age
nhds %>% 
  arrange(age)

# arrange based on age then sex
nhds %>% 
  arrange(age,sex)

# arrange age in descending using -
nhds %>% 
  arrange(-age)

# arrange by age ascending then sex descending
nhds %>% 
  arrange(age,-sex)

# same arrange using helper function desc()
nhds %>% 
  arrange(age,desc(sex))


## Summarize -------------------------------------------------------------------

# Summarize computes summary metrics across rows
summarize()
summarise()

# compute mean and median age and correlation between age and sex
nhds %>% 
  summarise(mean_age=mean(age),
            median_age=median(age),
            cor_age_sex=cor(age,sex))

## Group By --------------------------------------------------------------------

# Group by can be added before other verbs to perform grouped operations
group_by()

# mean and median age by sex and race
nhds %>% 
  group_by(sex,race) %>% 
  summarise(mean_age=mean(age),
            median_age=median(age))

# mean and median age and number of individuals by sex
nhds %>% 
  group_by(sex) %>% 
  summarise(mean_age=mean(age),
            median_age=median(age),
            n=n())

# we can also add a grouped operation by group
# add a variable that computes the mean age of all people that had the same atype 
nhds %>% 
  group_by(atype) %>% 
  mutate(mean_atype_age=mean(age))


# shortcut for grouped counting using the count() function
nhds %>%
  count(sex,race)

# we can change the name of the count variable that gets created
nhds %>%
  count(sex,race, name = "visit_count")

# note the count function is just a summarize statement with group_by
nhds %>%
  group_by(sex,race) %>% 
  summarise(n=n())


## Others ----------------------------------------------------------------------
# Slice selects particular rows of the data
slice()

# return the first 15 rows
nhds %>% 
  slice(1:15)

# first and last observations
nhds %>% 
  slice(1,n())

# return just the distinct icd9 codes in dx1
nhds %>% 
  distinct(dx1)

# return all the distinct age and sex combinations 
nhds %>% 
  distinct(age,sex)

# take a random 20% sample of the data set
nhds %>% 
  sample_frac(.2)

# randomly sample n=10 observations
nhds %>% 
  sample_n(10)

######################
#### Helper Verbs ####
######################

# selection helpers -  these work with select functions ------------------------
# select rows that contain "dx
nhds %>% 
  select(contains("dx"))

# select rows that start with pr
nhds %>% 
  select(starts_with("pr"))

# rows that end with 1
nhds %>% 
  select(ends_with("1"))

# select sex first then everything else
nhds %>% 
  select(sex, everything())

# filter helpers ---------------------------------------------------------------

# filter age between 12 and 45
nhds %>% 
  filter(between(age,12,45))


# mutate or summarize helpers --------------------------------------------------

# count number with n()
# count number of individuals of each age
nhds %>% 
  group_by(age) %>% 
  summarise(n=n())

# add row number with row_number
# count number of ages then rank
nhds %>% 
  count(age) %>% 
  arrange(desc(n)) %>%
  mutate(rank=row_number())

#######################
#### Joins & Binds ####
#######################

# Joining ----------------------------------------------------------------------

### inner_join() 

# notice var_labls contains the labels for the variables
var_labels

# inner_join to add atype variable
inner_join(nhds,var_labels$atype, by = c("atype"="val")) %>% 
  mutate(atype=label) %>% 
  select(-label)

# or laid out differently
nhds %>% 
  inner_join(var_labels$atype, by = c("atype"="val")) %>% 
  mutate(atype=label) %>% 
  select(-label)

### left_join()
# keep only the visits for the primary dx code  c("41401","4111","42830")
# note...normally we would just use filter
tibble(dx1 = c("41401","4111","42830")) %>% 
 left_join(nhds)

# the above guessed the by variable but normally you should specify 
tibble(dx1 = c("41401","4111","42830")) %>% 
  left_join(nhds, by="dx1")


### right_join()
# this is the exact same filter step but now using right join
nhds %>% 
  right_join(tibble(dx1 = c("41401","4111","42830")), by="dx1")


### full_join()
# a contrived example for demonstation

df1 <- tibble(letters=c("a","b"),
              numbers=c(1,3))

df2 <- tibble(letters=c("a","c"),
              onomatopoeia=c("Pow","Boom"))

full_join(df1,df2)

### anti_join()
# keep all the observations with icd9 codes not in c("41401","4111","42830")
nhds %>% 
  anti_join(tibble(dx1 = c("41401","4111","42830")),
            by = "dx1")


# Binding/Stacking -------------------------------------------------------------

# bind_rows() - Bind rows together

# build table with counts of race and then counts of sex below

race_count <- nhds %>% 
  count(race) %>% 
  inner_join(var_labels$race, by = c("race"="val")) %>% 
  select(label,n)

sex_count <- nhds %>% 
  count(sex) %>% 
  inner_join(var_labels$sex, by = c("sex"="val")) %>% 
  select(label,n)

# count table we want
bind_rows(race_count,sex_count)

# or all in one chain
bind_rows(nhds %>% 
            count(race) %>% 
            inner_join(var_labels$race, by = c("race"="val")) %>% 
            select(label,n),
          nhds %>% 
            count(sex) %>% 
            inner_join(var_labels$sex, by = c("sex"="val")) %>% 
            select(label,n))

# bind columns together using bind_cols()

# count admission types for each sex, with males in left column and female right

# first create male counts
males_count <- nhds %>% 
  filter(sex==1) %>% 
  count(atype, name = "male count")

# next create female counts
females_count <- nhds %>% 
  filter(sex==2) %>% 
  count(atype, name = "female count")

# finally bind together
bind_cols(males_count,
          select(females_count,`female count`))

######################
#### Scoped Verbs ####
######################

# add missing for all dx and pr codes
nhds %>% 
  mutate_at(vars(dx1:pr1),~ifelse(.=="",NA,.))

# same using na_if() function
nhds %>% 
  mutate_at(vars(dx1:pr1),~na_if(.,""))


# or we could apply the same thing to all variables using mutate_all()
nhds %>% 
  mutate_all(~ifelse(.=="",NA,.))


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