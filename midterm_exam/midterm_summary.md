Mid-Term Take Home Exam
================
Aaron Miller
3/10/2021

``` r
library(tidyverse)
library(lubridate)
```

# Simulate Vaccine Distribution in Iowa

### Due Date: Monday 3/22/2021 by midnight

For your midterm project you will be developing a simulation model to
explore different vaccine distribution strategies in the state of Iowa.
Specifically, this project asks you to develop a simulation of vaccine
distribution across each of Iowa’s 99 counties, then analyze how
different strategies might alter the total number of people vaccinated
across time. This is a type of allocation problem: Given an available
supply of vaccines each week, you need to decide how best to distribute
the supply across all of Iowa’s 99 counties based on the different
population characteristics of those counties.

Imagine you are sitting at the point in time when vaccine allocation has
just begun (around December 15th). Your goals are to reach as much as
the population as quick as possible, but you also want to target
individuals who might be at greatest risk (e.g., individuals &gt; 65
years of age). You also want to evaluate the total amount of immunity
(either naturally acquired or via vaccination) in hopes of achieving
some sort of “herd immunity” threshold as quick as possible.

### Some oversimplifying assumptions

To make this problem a bit more tractable in the time allocated we will
make a few simplifying assumptions

-   We will assume that vaccines are only a single dose (the 2 dose
    distribution problem is a bit more complex) and we will compute
    total immunity assuming individuals are immune once they receive a
    vaccination

-   We will focus only on two sub-populations: (1) High-risk individuals
    above age 65 and (2) low-risk individuals below age 65.

-   Vaccines are distributed to counties in weekly batches.

-   Vaccines that are allocated to a county, but not distributed (e.g.,
    because we reach the population vaccination threshold in a given
    county) are wasted and not returned to the overall state.

### Some Distribution Assumptions

Once a county receives it’s allocation of vaccines, they should be
distributed in the following manner:

1.  A county can only distribute doses to 10% of it’s population in a
    given week.

2.  On average, 90% of individuals age 65+ will voluntarily take the
    vaccine - in the static case treat this as a fixed value but in the
    stochastic case this can vary across counties by trial

3.  On average, 70% of individuals age &lt;65 will voluntarily take the
    vaccine - in the static case treat this as a fixed value but in the
    stochastic case this can vary across counties by trial

### Distribution strategies

We will be evaluating 4 different vaccination strategies in this
project, regarding how vaccines will be partitioned across the 99
counties.

1.  Proportional to county population percentage

2.  Proportional to county 65 and older population percentage

3.  Equal across all counties

4.  Inversely proportionally to the percentage of the population with
    natural immunity (i.e., who had prior infection)

## Part 1: Build the required datasets (20 pts)

Start by loading in the data necessary for this simulation and
constructing the data that will be used across the trials. The following
data will be required for this simulation:

-   County population (total)

-   County population over age 65

-   County population with prior infection

-   Estimated total vaccine supply each week over the simulation period

Iowa county-level population data can be found on the course GitHub site
and is saved as `ia_county_pop_2017.RData.`

The county level COVID-19 data can be found here:
<https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv>

Weekly projections of the number of vaccines available in the state of
Iowa can be found on the course GitHub site as
`weekly_supply_projection.RData`. Note: these data differ slightly but
are extrapolated from the actual vaccine distribution data so far in the
state of Iowa.

Finally, after loading each of the datasets create one county-level
dataset for the simulation model that contains the variables for county,
population over age 65, total population and total number of COVID-19
cases in the county to date: call these variables
`county, pop_over_65, total_population, covid_cases`, respectively.
Since you will be modeling each county as if you are are at the starting
point of vaccine distribution in the state (i.e., December 15th), you
should use the total COVID-19 case count in each county from December
15th. Your dataset should then look like the following:

``` r
county_data
```

    ## # A tibble: 99 x 4
    ##    county     pop_over_65 total_population covid_cases
    ##    <chr>            <dbl>            <dbl>       <dbl>
    ##  1 Adair             1573             7054         513
    ##  2 Adams              842             3686         212
    ##  3 Allamakee         3100            13884        1027
    ##  4 Appanoose         2777            12352         880
    ##  5 Audubon           1361             5578         334
    ##  6 Benton            4643            25642        1873
    ##  7 Black Hawk       21181           132648       11882
    ##  8 Boone             4716            26484        1655
    ##  9 Bremer            4813            24911        2140
    ## 10 Buchanan          3725            21202        1333
    ## # … with 89 more rows

The vaccine supply data contains a projection from the current trends in
vaccine distribution in the state of Iowa. This contains both the
cumulative total supply (the variable `total_supply`) and the new supply
of vaccines each week (the variable `new_supply`). For your simulation
you will be using the `new_supply` projections. Even though we have
started actual distribution, you will be using the trajectory to
simulate distribution trajectories as if we were sitting in early
December 2020.

The projections in the `weekly_supply` dataset are based on the total
vaccinations initiated (i.e., the initial dose) each week so far and is
then extrapolated forward into the future (note: some of the historical
data differs slightly from actual trends reported on the IDPH website).
Here is a plot of the total supply projections, where the green dots
denote weeks that have already occurred and the red dots are future
projections. Based on these projections, if trends continue we should
reach supply sufficient to reach the entire population by early July.

![](midterm_summary_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

## Part 2 - Create functions for the simulation (50 pts)

Next you will create the functions necessary for the simulation. Before
doing so let’s run through each of the steps the simulation needs to
perform:

1.  Initialize a county-level dataset containing information at time 0,
    this will be used in the simulation to track allocations across
    counties, assign distribution to different population subgroups
    (i.e., older or younger than 65) in each county, and keep track of
    the total vaccines previously allocated. This dataset will be
    updated across time to track distribution across the simulation. I
    will refer to this as the “county-level dataset” and versions of
    this dataset will need to be created and stored for each time
    period.

2.  Determine weekly allocation across counties, add this allocation
    information to the county-level data created in step 1.

3.  Determine the distribution of vaccines to the different population
    groups using the distribution assumptions outlined above (i.e.,
    based on the weekly thresholds by county and the thresholds for the
    total percent of each age group willing to vaccinate voluntarily).
    Update the counts for the total number of people vaccinated in each
    group in the county-level dataset. In other words, given a
    county-level allocation, determine how much is actually used and how
    many individuals in each age group will get vaccinated.

4.  Repeat each step (creating an updated county-level dataset), based
    on the new vaccine supply in each period.

### Initialization Function

Write a function to initializes the county-level dataset that will start
the simulation at time zero. This function should take as an argument
the `county_data` dataset you created above and add to it the
information required for the simulation; call this function
`initialize_counties()`. For now this should be initialized by adding
the following values to the `county_data` you created above: the total
percent of the overall state population, percent of the states
population above 65, the threshold of total vaccines voluntarily taken
by people under age 65 (e.g., 70% of the individuals under 65), the
threshold of voluntary vaccination for individuals above 65, the number
currently vaccinated less than 65 and the number currently vaccinated
above 65 (these last two variables will be updated each stage of the
simulation. Call these variables
`pop_pct, pop_65_pct, under65_threshold, over65_threshold, under65_vac, over65_vac`.
Later we will update this function to add stochastic thresholds by age
group.

When you run your function you should get results that look like the
following:

``` r
initialize_counties(county_data) %>% glimpse()
```

    ## Rows: 99
    ## Columns: 10
    ## $ county            <chr> "Adair", "Adams", "Allamakee", "Appanoose", "Audubo…
    ## $ pop_over_65       <dbl> 1573, 842, 3100, 2777, 1361, 4643, 21181, 4716, 481…
    ## $ total_population  <dbl> 7054, 3686, 13884, 12352, 5578, 25642, 132648, 2648…
    ## $ covid_cases       <dbl> 513, 212, 1027, 880, 334, 1873, 11882, 1655, 2140, …
    ## $ pop_pct           <dbl> 0.002242418, 0.001171754, 0.004413629, 0.003926616,…
    ## $ pop_65_pct        <dbl> 0.002990170, 0.001600587, 0.005892898, 0.005278896,…
    ## $ under65_threshold <dbl> 3836.7, 1990.8, 7548.8, 6702.5, 2951.9, 14699.3, 78…
    ## $ over65_threshold  <dbl> 1415.7, 757.8, 2790.0, 2499.3, 1224.9, 4178.7, 1906…
    ## $ under65_vac       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
    ## $ over65_vac        <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …

### Allocation Function

Next, write an allocation function for the first strategy (described
above) to distribute vaccines based on population percentage. This
function should take as an argument the total number of vaccine doses
available at a given time and then return how many of those doses should
be allocated to each county. Call this function `allocate_vaccine_pop()`
where `_pop` denotes that you are basing allocation on the total
population in each county (later you will create
`allocate_vaccine_pop65()`, `allocate_vaccine_equal()`, and
`allocate_vaccine_case_history()).` Start by merging in the number of
doses available at a given time into the county-level dataset, so that
the dataset contains a column for the total number of doses. It is
relatively easy to solve this problem by multiplying the population
percentage by the total doses available…but keep in mind you can only
distribute whole doses of the vaccine (so consider using something like
the `round()` function to round values to the nearest integer). Note:
for this problem you should also check that you are distributing all
doses and not under distributing any doses (when you multiply the number
of doses by the fraction and then round, your total doses may not be
exact). If you have any extra doses be sure to randomly partition them
across counties or if you allocate too many remember to remove them at
random. (You will receive partial credit as long as you can complete
this first part)

Your function should return a result that looks like the following:

``` r
initialize_counties(county_data) %>% 
  allocate_vaccine_pop(5000)
```

    ## # A tibble: 99 x 11
    ##    county pop_over_65 total_population covid_cases pop_pct pop_65_pct
    ##    <chr>        <dbl>            <dbl>       <dbl>   <dbl>      <dbl>
    ##  1 Adair         1573             7054         513 0.00224    0.00299
    ##  2 Adams          842             3686         212 0.00117    0.00160
    ##  3 Allam…        3100            13884        1027 0.00441    0.00589
    ##  4 Appan…        2777            12352         880 0.00393    0.00528
    ##  5 Audub…        1361             5578         334 0.00177    0.00259
    ##  6 Benton        4643            25642        1873 0.00815    0.00883
    ##  7 Black…       21181           132648       11882 0.0422     0.0403 
    ##  8 Boone         4716            26484        1655 0.00842    0.00896
    ##  9 Bremer        4813            24911        2140 0.00792    0.00915
    ## 10 Bucha…        3725            21202        1333 0.00674    0.00708
    ## # … with 89 more rows, and 5 more variables: under65_threshold <dbl>,
    ## #   over65_threshold <dbl>, under65_vac <dbl>, over65_vac <dbl>,
    ## #   allocation <dbl>

### Distribution

Next, write a function that takes an allocation for a given county and
then calculates how to distribute that amount between individuals over
65 years of age and those under 65 years of age. Call this function
`distribute_vaccine()`. This function should take as an argument the
county dataset containing the county-level allocation at a given time
point and then return the same dataset with the variables for
`under65_vac` and `over65_vac` updated after vaccines have been
allocated to these age groups.

Hint: This function can be written entirely with dplyr commands (e.g.,
`mutate()`, `select()`, etc.). By modifying the columns. You will likely
have to create intermediate columns of data that compute the maximum
number of doses that can be allocated to an age group at a particular
timestep given the number who have been previously vaccinated. I
recommend you do something like the following to confirm that the
function works before proceeding. Basically create the dataset you need
to manipulate and then figure our the column operations you need to
perform

``` r
initialize_counties(county_data) %>% 
  allocate_vaccine_pop(5000) %>% 
  distribute_vaccine() %>% 
  glimpse()
```

    ## Rows: 99
    ## Columns: 11
    ## $ county            <chr> "Adair", "Adams", "Allamakee", "Appanoose", "Audubo…
    ## $ pop_over_65       <dbl> 1573, 842, 3100, 2777, 1361, 4643, 21181, 4716, 481…
    ## $ total_population  <dbl> 7054, 3686, 13884, 12352, 5578, 25642, 132648, 2648…
    ## $ covid_cases       <dbl> 513, 212, 1027, 880, 334, 1873, 11882, 1655, 2140, …
    ## $ pop_pct           <dbl> 0.002242418, 0.001171754, 0.004413629, 0.003926616,…
    ## $ pop_65_pct        <dbl> 0.002990170, 0.001600587, 0.005892898, 0.005278896,…
    ## $ under65_threshold <dbl> 3836.7, 1990.8, 7548.8, 6702.5, 2951.9, 14699.3, 78…
    ## $ over65_threshold  <dbl> 1415.7, 757.8, 2790.0, 2499.3, 1224.9, 4178.7, 1906…
    ## $ under65_vac       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
    ## $ over65_vac        <dbl> 11, 6, 22, 20, 9, 41, 211, 42, 40, 34, 32, 23, 15, …
    ## $ allocation        <dbl> 11, 6, 22, 20, 9, 41, 211, 42, 40, 34, 32, 23, 15, …

### Write a loop to run a single trial of the simulation

You now have the functions necessary to run the simulation. Write a
function called `run_sim()` that runs a simulation of vaccine allocation
across each of the periods in the `weekly_supply` dataset. This function
should take as arguments the `county_data` and `weekly_supply` datasets
(later you will add an option that defines which county-level allocation
strategy you want to simulate.) The function should then return a
county-level dataset across time, with the vaccine allocation and
distribution across time.

This function should start by creating the initial county level data
using the `initialize_counties()` function, then loop over the weekly
allocation projections in the `weekly_supply` dataset and for each week
determine the allocation to each county (using `allocate_vaccine_pop()`)
and determine the distribution to each age group (using
`distribute_vaccine()`). Note: I recommend storing each period’s county
level dataset inside a list with a separate element in the list for each
period, and then combining the tibbles in the list using `bind_rows()`
(if `x` is a list of tibbles, then `bind_rows(x)` will stack all the
tibbles on top of one another).

Here is an example of what the `run_sim()` function should produce.
Note: in the initial period seen here the allocation and date are set to
NA. However, for later iterations of the simulation these are replaced
by the week date and corresponding allocation; this can be seen in the
second example

``` r
run_sim(county_data,weekly_supply)
```

    ## # A tibble: 3,168 x 12
    ##    county pop_over_65 total_population covid_cases pop_pct pop_65_pct
    ##    <chr>        <dbl>            <dbl>       <dbl>   <dbl>      <dbl>
    ##  1 Adair         1573             7054         513 0.00224    0.00299
    ##  2 Adams          842             3686         212 0.00117    0.00160
    ##  3 Allam…        3100            13884        1027 0.00441    0.00589
    ##  4 Appan…        2777            12352         880 0.00393    0.00528
    ##  5 Audub…        1361             5578         334 0.00177    0.00259
    ##  6 Benton        4643            25642        1873 0.00815    0.00883
    ##  7 Black…       21181           132648       11882 0.0422     0.0403 
    ##  8 Boone         4716            26484        1655 0.00842    0.00896
    ##  9 Bremer        4813            24911        2140 0.00792    0.00915
    ## 10 Bucha…        3725            21202        1333 0.00674    0.00708
    ## # … with 3,158 more rows, and 6 more variables: under65_threshold <dbl>,
    ## #   over65_threshold <dbl>, under65_vac <dbl>, over65_vac <dbl>,
    ## #   allocation <dbl>, date <date>

``` r
run_sim(county_data,weekly_supply) %>% 
  filter(!is.na(date))
```

    ## # A tibble: 3,069 x 12
    ##    county pop_over_65 total_population covid_cases pop_pct pop_65_pct
    ##    <chr>        <dbl>            <dbl>       <dbl>   <dbl>      <dbl>
    ##  1 Adair         1573             7054         513 0.00224    0.00299
    ##  2 Adams          842             3686         212 0.00117    0.00160
    ##  3 Allam…        3100            13884        1027 0.00441    0.00589
    ##  4 Appan…        2777            12352         880 0.00393    0.00528
    ##  5 Audub…        1361             5578         334 0.00177    0.00259
    ##  6 Benton        4643            25642        1873 0.00815    0.00883
    ##  7 Black…       21181           132648       11882 0.0422     0.0403 
    ##  8 Boone         4716            26484        1655 0.00842    0.00896
    ##  9 Bremer        4813            24911        2140 0.00792    0.00915
    ## 10 Bucha…        3725            21202        1333 0.00674    0.00708
    ## # … with 3,059 more rows, and 6 more variables: under65_threshold <dbl>,
    ## #   over65_threshold <dbl>, under65_vac <dbl>, over65_vac <dbl>,
    ## #   allocation <dbl>, date <date>

## Part 3 - Add stochastic components (20 pts)

Once your static simulation is working, you should add stochastic
components to make the simulation more realistic. Specifically, the
threshold in terms of the number of individuals who are willing to get
vaccinated in a given county should be treated as a random variable
(e.g., in some counties we may be able to vaccinate &gt;90% of the
population over age 65 while in others you may only be able to vaccinate
&lt;90% of individuals over age 65).

To implement this stochastic component, at the start of the simulation
draw the two thresholds for the number of individuals in the two age
groups that are able to be vaccinated. This threshold should be drawn as
a random variable that differs between counties, and the thresholds
should be re-drawn each time the simulation is run. Choose a
distribution to draw from that seems reasonable…but make the mean for
the two age groups the same as described above (i.e., 70% and 90%). **In
your code you should add a brief comment defending the type of
distribution you chose.** Implement this random assignment by modifying
the `initialize_counties()` function.

## Part 4 - Evaluate different scenarios (40 pts)

For the final part of the midterm, you will use the simulation to
evaluate the impact of different distribution scenarios. For each of the
strategies and outcomes below, you should evaluate your results across
multiple trails.

### Setup alternative distribution strategies

At the beginning of this document, 4 different distribution plans were
described. You already implemented the first one of these strategies
with the function `allocate_vaccine_pop()`. Now implement the following
strategies by creating 3 new distribution functions. <u>Note: each of
these only requires modifying a line or two in the
function`allocage_vaccine_pop()`, so you should start by copying this
function and then modifying as required.</u>

-   `allocate_vaccine_pop65()` - This function should allocate vaccines
    based on the proportion of all individuals age 65 or older that
    reside in a particular county

-   `allocate_vaccine_equal()` - This function should allocate all
    vaccines equally across all counties (i.e. the same number to each
    county)

-   `allocate_vaccine_case_history()` - This function should allocate
    all vaccines inversely proportional to the number of prior COVID
    cases in a particular county. The goal here is to maximize total
    immunity (natural and vaccine produced). Specifically, allocate
    cases based on the portion of the state population without natural
    immunity. In other words, you should compute the number of cases
    from the population in each county, and then re-compute the
    proportion of the state population without immunity that resides in
    each county.

After each of these functions has been created, update the `run_sim()`
function to include an argument specifying which allocation strategy to
use. One way this can be done is using `if` and `else` statements like
the following:

``` r
run_sim_new <- function(county_level_data,weekly_supply_data,strategy="pop"){
  
  if (strategy == "pop"){
    
    # code for population-based strategy
    
  } else if (strategy == "pop65") {
    
    # code for population over 65 strategy
    
  } else if (strategy == "equal") {
    
    # code for equal distribution strategy
    
  } else {
    
    # code for COVID case history strategy
    
  }
  
}
```

### Evaluate different outcomes

Once you have the simulation working for each of the distribution
strategies you should compare how the different strategies compare
across time in terms of the following outcomes. For each of these
outcomes, aggregate the values across all counties at a state level:

-   % of total population vaccinated - each week plot what percent of
    the population is vaccinated

    -   plot for % of all individuals, % of individuals &gt;65 and % of
        individuals &lt;65 that are vaccinated

-   Wasted doses - if you wrote your simulation correctly…there should
    be un-allocated doses over time. In reality we would try to
    reallocate these in some manner, but there might be costs involved.
    Plot the number of unused doses that are allocated but not
    distributed across time.

-   Total amount of natural immunity - how many people might we expect
    to be immune (through natural infection or vaccination in each
    county). Keep in mind, people with prior infections are getting
    vaccinated as well. This is a bit tricky and will require you to
    make some judgments. If you want, you can also make this stochastic.

    -   At each time period for a given county you have data on the
        number currently vaccinated and the number of COVID cases (prior
        to December 15th). So assuming there was no correlation between
        likelihood of getting vaccinated and having previously had an
        infection how might we compute the number of people with some
        degree of immunity? If a county had 100 people and 20 had a
        previous infection, and then we vaccinated 50 people at
        random…how many people would we expect to have immunity through
        either vaccination or infection. (If this is not clear write a
        quick simulation!!!)

    -   As a second twist you should add undetected cases…we know the
        number of detected cases in a given county is only a fraction of
        the true number of cases. For examples, some studies suggest the
        true number may be 2-10 times as many as the detected number
        (depending on location and time). Consider adding a single
        scaling parameter that multiplies the number of detected cases
        to determine the likely number of true cases.

### Summarize Results

For each of the strategies and outcomes described above, provide
visualizations that demonstrate outcomes across time for the different
strategies. Run your simulation across a number of different trials to
show how results vary as you draw different random variables for the
allocation thresholds. Consider running 100 or more simulations for each
of the strategies and then summarizing across trials.
