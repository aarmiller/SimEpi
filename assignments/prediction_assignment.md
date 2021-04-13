Predictive Modelling Assignment
================
Aaron Miller
4/13/2021

## Build two types of predictive Models

For this assignment you will build two types of predictive models based
on the applications we discussed in class. Specifically, you will build
predictive models for a regression problem (numerical outcome) and a
binary classification problem. These specific applications are described
below. The objective of this assignment is to provide you some exposure
to the types of tools available for performance evaluation when building
predictive models. You should utilize the `caret` package to train/tune
these models (although you should be comfortable doing this manually
using the resampling/randomization functions we have also discussed.)

For each problem, you should build models using the following methods
that we will discuss in class:

-   Linear or Logistic Regression

-   K-Nearest Neighbors (KNN)

-   Classification and Regression Trees (CART)

-   Random Forests

We will begin by developing some basic models in class for both of these
problems. Your specific objective with this assignment is to do the
following:

1.  Expand upon the feature set from what was used in class. For the
    in-class demonstration, we used a very limited feature set (age,
    sex, race, admission type). You should incorporate other features
    that make sense from the point of prediction. Start by adding
    information from the admitting diagnosis (note: diagnosis codes that
    occur after admission may be tricky to predict with).

2.  Explore other model building approaches either in terms of
    performance evaluation / cross-validation or model tuning. For
    example, you could look at repeated cross validation using different
    numbers of k-folds or using bootstrapping. Alternatively, you could
    consider different tuning grids or range of tuning parameters (for
    applicable methods).

Note: Some of the prediction algorithms will take a lot of time to run
(e.g., KNN with 120K+ observations). Thus, you may want to subset the
data you work with. For example, in the classification problem you could
keep all of the cases where a patient died and randomly select a
corresponding number of patients who survived so you were only working
with a few thousand cases and a balanced dataset.

## Regression Problem: Predicting LOS

For the regression problem, you will be predicting inpatient length of
stay. This is a common measure used to evaluate healthcare outcomes or
costs, and is often the target of predictive modeling problems.

Below is the basic code we used in class to build a dataset for this
regression problem. You should expand upon this initial feature set.

``` r
load("R/SimEpi/example_data/nhds_adult.RData")

nhds_adult <- nhds_adult %>% 
  mutate(id = row_number()) %>% 
  select(id,everything()) %>% 
  rename(los = care_days, age=age_years)

reg_data <- nhds_adult %>% 
  select(los, age, sex, race, region)

reg_data
```

    ## # A tibble: 129,242 x 5
    ##      los   age sex    race       region   
    ##    <int> <int> <fct>  <fct>      <fct>    
    ##  1     7    19 female white      west     
    ##  2     1    20 female black      midwest  
    ##  3     1    44 female black      northeast
    ##  4     3    80 female not_stated northeast
    ##  5     1    66 male   white      northeast
    ##  6     8    52 female white      south    
    ##  7    19    76 female white      south    
    ##  8     7    58 female white      northeast
    ##  9    15    78 female asian      south    
    ## 10     1    33 female white      northeast
    ## # … with 129,232 more rows

## Classification Problem: Predicting In-Hospital Mortality

For the classification problem, you will be predicting in-hospital
mortality. This is also another common outcome measure and a frequent
target of predictive modeling application. Mortality can be identified
with the discharge status variable `dc_status`. The following code was
used to create the example dataset used in class. Like above, you should
expand upon this feature set for your analysis.

``` r
class_data <- nhds_adult %>% 
  mutate(died = dc_status=="dead") %>% 
  select(died, age, sex, race, region,adm_type)

class_data
```

    ## # A tibble: 129,242 x 6
    ##    died    age sex    race       region    adm_type 
    ##    <lgl> <int> <fct>  <fct>      <fct>     <fct>    
    ##  1 FALSE    19 female white      west      urgent   
    ##  2 FALSE    20 female black      midwest   urgent   
    ##  3 FALSE    44 female black      northeast elective 
    ##  4 FALSE    80 female not_stated northeast emergency
    ##  5 FALSE    66 male   white      northeast emergency
    ##  6 FALSE    52 female white      south     emergency
    ##  7 FALSE    76 female white      south     elective 
    ##  8 FALSE    58 female white      northeast elective 
    ##  9 FALSE    78 female asian      south     emergency
    ## 10 FALSE    33 female white      northeast elective 
    ## # … with 129,232 more rows
