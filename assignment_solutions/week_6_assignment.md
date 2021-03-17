Week6
================
Aaron Miller
3/8/2021

## Due Date: Tuesday 3/16/2021 by 5pm

# Simulate admissions and discharges to a hospital setting

For this assignment you will be building a simulation of admissions and
discharges to a hospital setting. This simulation will randomly draw
patients from the NHDS dataset representing new admissions to a hospital
setting. This type of simulation could be used as part of a larger
simulation model designed to simulate activities within a hospital
setting. For example, this could be used inside an infectious disease
model to simulate transmission of HAIs within a healthcare facility, or
inside a model of healthcare interactions and resource utilization.

### Load in the NHDS dataset and subset the data

Start by loading the NHDS adult dataset that we have been working with
in prior assignments:

``` r
load("R/SimEpi/example_data/nhds_adult.RData")
```

Now create a subset called nhds\_reduced that contains the following
variables
`age, sex, race, care_days, dx_adm, dx01, dx02, dx03, DRG, payor_primary, DRG, adm_type, adm_origin, dc_month, region, n_beds, hospital_ownership.`
Rename `age_years` to `age`. This should look like the following:

``` r
nhds_reduced <- nhds_adult %>% 
  select(age=age_years,sex,race,care_days,dx_adm,dx01,dx02,dx03,DRG,payor_primary,
         DRG,adm_type,adm_origin,dc_month,region,n_beds,hospital_ownership)
```

``` r
nhds_reduced
```

    ## # A tibble: 129,242 x 16
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    19 fema… white         7 <NA>   64403 64663 64723 778   other govern…
    ##  2    20 fema… black         1 29623  29623 <NA>  <NA>  885   Medicaid     
    ##  3    44 fema… black         1 24200  24200 4019  4280  627   other privat…
    ##  4    80 fema… not_…         3 7804   25060 78609 7804  074   Medicare     
    ##  5    66 male  white         1 78605  99739 4239  5119  206   Medicare     
    ##  6    52 fema… white         8 2989   96509 34839 1985  917   Medicaid     
    ##  7    76 fema… white        19 78079  1539  5070  25000 329   Medicare     
    ##  8    58 fema… white         7 0389   49322 <NA>  <NA>  192   Medicare     
    ##  9    78 fema… asian        15 311-   29633 59651 78830 885   Medicare     
    ## 10    33 fema… white         1 27801  27801 V854  30000 621   HMO or PPO   
    ## # … with 129,232 more rows, and 6 more variables: adm_type <fct>,
    ## #   adm_origin <fct>, dc_month <int>, region <fct>, n_beds <ord>,
    ## #   hospital_ownership <fct>

### Set initial parameter values

We want our simulation model to take a set of initial parameters that
govern how the simulation operates. Specifically, we need to specify the
range of dates for the simulation to run for (defined by the parameters
`start_date` and `end_date`) and the size of the hospital in terms of
the number of patient beds. Later we will consider extensions to these
sets of parameters to make the simulation a bit more realistic. Here are
the parameters (note there is nothing to do with this step, later we
will pass these to our simulation function):

``` r
start_date <- ymd("2019-01-01") # date for the start of the simulation
end_date <- ymd("2019-12-31") # date for the end of the simulation
hospital_size <- 300 # number of beds
```

### Draw an initial set of patients

Write a function that takes an argument `n` that specifies the number of
patients to draw and then returns a random sample of `n` total patients
from the `nhds_reduced` dataset. Draw your sample with replacement. Call
this function `draw_patients()`. Note: the function `sample_n()` from
the dplyr package can be used to randomly draw a sample of size n from a
given dataset.

``` r
draw_patients <- function(n){
  sample_n(nhds_reduced,size = n,replace = TRUE)
}
```

Confirm that your function is work and returns a random draw of the
correct size each time.

``` r
draw_patients(500)
```

    ## # A tibble: 500 x 16
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    65 male  white        12 78097  2920  8602  80709 894   Medicare     
    ##  2    38 fema… not_…         3 <NA>   0479  <NA>  <NA>  076   HMO or PPO   
    ##  3    46 fema… white         1 <NA>   41071 5856  4280  280   Medicare     
    ##  4    82 fema… white        11 <NA>   0389  486-  51881 871   Medicare     
    ##  5    66 fema… white         5 5789   53551 2851  28989 378   Medicare     
    ##  6    40 fema… white         7 5789   41071 5770  5849  280   Medicaid     
    ##  7    81 male  white         3 5990   5989  5990  2875  697   HMO or PPO   
    ##  8    54 male  white         3 71536  71536 2720  4019  470   HMO or PPO   
    ##  9    73 fema… other         1 53550  53550 28860 4019  392   Medicare     
    ## 10    19 male  white         1 311-   29570 V6284 311-  885   blue cross b…
    ## # … with 490 more rows, and 6 more variables: adm_type <fct>, adm_origin <fct>,
    ## #   dc_month <int>, region <fct>, n_beds <ord>, hospital_ownership <fct>

Below you will use this function to draw the initial set of patients in
the hospital and to draw new patients each time other patients are
discharged and new patients are admitted. For example, if we wanted to
create the initial set of patients in the hospital we could just draw
all the patients we need based on the hospital size, defined above.
Note: we will recycle this step inside the hospital simulation function
below.

``` r
init_hospital <- draw_patients(hospital_size)

# view output
init_hospital
```

    ## # A tibble: 300 x 16
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    82 fema… white         1 <NA>   2761  7802  5990  641   Medicare     
    ##  2    63 male  white         1 78909  5609  4019  2270  390   blue cross b…
    ##  3    90 fema… white         3 <NA>   82009 2851  E8889 481   Medicare     
    ##  4    37 fema… black         2 25013  25013 V5867 2809  639   self pay     
    ##  5    79 fema… white        19 78900  56081 42843 5185  329   Medicare     
    ##  6    44 fema… white         2 78650  496-  78650 4019  192   HMO or PPO   
    ##  7    52 fema… black         4 <NA>   25092 2761  V0481 638   Medicaid     
    ##  8    21 fema… white         2 65971  V270  66411 65971 775   Medicaid     
    ##  9    47 male  not_…         9 7295   92710 95891 25002 908   worker compe…
    ## 10    57 fema… white         2 29690  29690 2720  3019  885   other privat…
    ## # … with 290 more rows, and 6 more variables: adm_type <fct>, adm_origin <fct>,
    ## #   dc_month <int>, region <fct>, n_beds <ord>, hospital_ownership <fct>

Now try adding admission and discharge dates to the initial hospital you
drew, call these variable `admdate` and `disdate`. Start by using the
start date of the simulation as the initial admission date (later you
will correct this since this will initially populate a hospital with
patients all having the same admission date). How will you determine the
discharge date (Hint: the information needed is in the dataset). Note:
you will recycle this step later in the hospital simulation, you will
also need to add admission and discharge dates each time you draw new
patients.

Your updated dataset should then look like the following:

``` r
init_hospital <- draw_patients(hospital_size) %>% 
  mutate(admdate=start_date,
         disdate=admdate+care_days)
```

``` r
init_hospital
```

    ## # A tibble: 300 x 18
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    79 fema… white         5 82021  82021 73313 2851  481   Medicare     
    ##  2    59 male  asian         1 41401  41401 4111  2724  249   blue cross b…
    ##  3    62 fema… white         4 78039  07054 78039 4019  443   blue cross b…
    ##  4    60 male  black         3 78900  5601  5990  5589  389   other privat…
    ##  5    62 male  white         2 78079  03849 78552 5849  853   Medicare     
    ##  6    77 fema… white         3 7802   29590 7804  7802  885   Medicare     
    ##  7    78 fema… black         2 <NA>   3383  179-  1991  948   Medicare     
    ##  8    73 fema… not_…         2 6826   6826  5849  27650 602   Medicare     
    ##  9    35 fema… white         3 311-   29632 V6284 25000 885   Medicaid     
    ## 10    23 fema… white         1 650-   V270  650-  <NA>  775   Medicaid     
    ## # … with 290 more rows, and 8 more variables: adm_type <fct>, adm_origin <fct>,
    ## #   dc_month <int>, region <fct>, n_beds <ord>, hospital_ownership <fct>,
    ## #   admdate <date>, disdate <date>

### Discharge and Admit Patients

Write a function called `discharge_admit_patients()` that takes two
arguments: a hospital population of currently admitted patients (i.e., a
subset extracted from the `nhds_reduced` dataset), and the current date.
The function should then perform a number of tasks: (1) find patients
who need to be discharged, based on the current date and the `disdate`
defined for patients in the dataset, (2) draw a new set of patients to
replace these discharges, (3) add `admdate` and `disdate` to the newly
admitted patients, and (4) combine the existing patients who were not
discharged along with the newly admitted patients to provide the update
hospital setting.

This function should return a list containing two elements: (1) the
patients who were discharged from the hospital and (2) the updated
hospital containing the newly admitted patients along with those who
were not discharged. Here is a sketch of the function.

``` r
discharge_admit_patients <- function(hospital,date){
  
  # patients_who are discharged
  discharges <- hospital %>% 
    filter(disdate<=date)
  
  # remove patients whose stay has ended 
  new_hospital <- hospital %>% 
    filter(disdate>date)
  
  # compute the number discharged
  num_discharged <- nrow(hospital)-nrow(new_hospital)
  
  # draw new admissions and add admission & discharge date
  new_patients <- draw_patients(num_discharged) %>% 
    mutate(admdate=date,
           disdate=date+care_days)
  
  # rebuild hospital
  new_hospital <- bind_rows(new_hospital,new_patients)
  
  return(list(hospital=new_hospital,
              discharges=discharges))
  
}
```

Test that your function works by running it on the initial hospital you
built above and then advancing the start date by 1.

``` r
discharge_admit_patients(init_hospital,start_date+1) 
```

    ## $hospital
    ## # A tibble: 300 x 18
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    79 fema… white         5 82021  82021 73313 2851  481   Medicare     
    ##  2    62 fema… white         4 78039  07054 78039 4019  443   blue cross b…
    ##  3    60 male  black         3 78900  5601  5990  5589  389   other privat…
    ##  4    62 male  white         2 78079  03849 78552 5849  853   Medicare     
    ##  5    77 fema… white         3 7802   29590 7804  7802  885   Medicare     
    ##  6    78 fema… black         2 <NA>   3383  179-  1991  948   Medicare     
    ##  7    73 fema… not_…         2 6826   6826  5849  27650 602   Medicare     
    ##  8    35 fema… white         3 311-   29632 V6284 25000 885   Medicaid     
    ##  9    63 fema… white         3 78701  1629  1983  1987  181   other privat…
    ## 10    23 fema… not_…         4 V222   V270  66481 65841 775   Medicaid     
    ## # … with 290 more rows, and 8 more variables: adm_type <fct>, adm_origin <fct>,
    ## #   dc_month <int>, region <fct>, n_beds <ord>, hospital_ownership <fct>,
    ## #   admdate <date>, disdate <date>
    ## 
    ## $discharges
    ## # A tibble: 50 x 18
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    59 male  asian         1 41401  41401 4111  2724  249   blue cross b…
    ##  2    23 fema… white         1 650-   V270  650-  <NA>  775   Medicaid     
    ##  3    59 male  white         1 7210   7210  V641  42731 552   HMO or PPO   
    ##  4    74 fema… white         1 78650  2724  78650 2443  642   Medicare     
    ##  5    74 male  white         1 7802   42731 7802  V5861 310   Medicare     
    ##  6    47 male  not_…         1 7231   7224  7220  V1582 473   other govern…
    ##  7    56 fema… white         1 27801  27801 V854  4019  621   HMO or PPO   
    ##  8    46 male  black         1 4019   5589  4019  3051  392   Medicare     
    ##  9    70 male  white         1 185-   185-  4019  2724  708   Medicare     
    ## 10    41 fema… other         1 <NA>   3090  V6284 4019  881   other govern…
    ## # … with 40 more rows, and 8 more variables: adm_type <fct>, adm_origin <fct>,
    ## #   dc_month <int>, region <fct>, n_beds <ord>, hospital_ownership <fct>,
    ## #   admdate <date>, disdate <date>

## Run Simulation

Write a function called `sim_hospital()` that simulates a hospital
environment across time using the steps and the functions we just wrote.
This function should perform the following operations:

-   Load an initial set of patients using the `draw_patients()` function
    and create their `admdate` and `disdate`

-   Create place holders to store the patient data for all patients who
    are discharged - note this will allow you to track all patients who
    passed through the simulator

-   Create place holders to store any other metrics you would like to
    collect on the state of the simulation across the different date.
    For now we will compute the **mean age** and **mean LOS** of
    patients on a given date.

-   Perform a loop across all remaining days in the simulation (i.e.,
    `start_date+1` through `end_date`) that does each of the following

    -   Update the state of the hospital by discharging and admitting
        patients on that particular date

    -   Add discharged patients into the placeholder containing all
        prior discharges

    -   Compute mean age and mean LOS of the currently admitted patients
        on a particular day, add this information to the corresponding
        placeholder

Your simulation should then return a list containing three elements: (1)
all discharges that occurred in the simulation, (2) the current state of
the hospital (i.e. patients that are admitted on the final day), and (3)
the computed statistics across each day in the simulation. Here is a
sketch of how this function might look:

``` r
sim_hospital <- function(start_date,end_date,hospital_size){
  
  # Build the inital hospital, including the initial 
  current_hospital <- draw_patients(hospital_size) %>% 
    mutate(admdate=start_date,
           disdate=admdate+care_days)
  
  # create any placeholders needed for the loop
  all_discharges <- list()
  daily_stats <- tibble()
  
  # Loop over - to run this you will need to determine and create a variable total_days
  # to tally how many days to simulate over
  total_days <- as.integer(end_date-start_date)
  
  for (i in 1:total_days){
    
    # admit and discharge patients
    update_res <- discharge_admit_patients(hospital = current_hospital,
                                           date = start_date+i) 
    
    # update hospital
    current_hospital <- update_res$hospital
    
    # store the discharges
    all_discharges[[i]] <- update_res$discharges
    
    # compute statistics for the current state of the hospital
    add_stats <- current_hospital %>% 
      summarise(mean_age=mean(age,na.rm=TRUE),
                mean_los=mean(care_days,na.rm=TRUE)) %>% 
      mutate(date=start_date+i)
    
    daily_stats <- bind_rows(daily_stats,add_stats)
    
  }
  
  # return the following
  # The dataset of all patients that passed through the simulation
  # Statistics across days in the simulation for the state of the hospital
  list(discharges=all_discharges,
       final_hospital=current_hospital,
       daily_stats=daily_stats)
  
}
```

Test your function by running it over the parameters you specified above

``` r
sim_res <- sim_hospital(start_date = start_date,
                        end_date = end_date,
                        hospital_size = hospital_size)
```

## Compute some statistics

Now try running you simulation and visualizing some of the output. For
example you could visualize the average age of all patients that were in
the hospital on a particular day:

![](week_6_assignment_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

Or you could visualize the average los for the patients that were in the
hospital on a given day. Note: your graph will look different than mine
(because this is stochastic), but think about why we are getting this
major shift upward:

![](week_6_assignment_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

## Extra Considerations - Try these if you have time

The following are extensions to this basic simulation. If you have time,
I would recommend giving these a try. Each of these will allow us to
make the simulation a bit more realistic.

### Specify the type of hospital setting

There are different types of hospitals represented in the dataset (e.g.,
hospital region, number of beds and ownership). You may want to add
parameters to draw patients only from those hospitals that are similar
to the type of hospital you are trying to simulate. For example, maybe
you want to draw admissions from the same type of region, or from
hospitals with the same type of ownership.

``` r
nhds_adult %>% count(region,n_beds,hospital_ownership)
```

    ## # A tibble: 39 x 4
    ##    region    n_beds  hospital_ownership     n
    ##    <fct>     <ord>   <fct>              <int>
    ##  1 northeast 6-99    proprietary          264
    ##  2 northeast 6-99    government           111
    ##  3 northeast 6-99    non_profit          4411
    ##  4 northeast 100-199 non_profit          2825
    ##  5 northeast 200-299 government          2266
    ##  6 northeast 200-299 non_profit          3854
    ##  7 northeast 300-499 government           929
    ##  8 northeast 300-499 non_profit          2185
    ##  9 northeast 500+    non_profit          8077
    ## 10 midwest   6-99    government           145
    ## # … with 29 more rows

**POSSIBLE SOLUTION**

The `draw_patients()` function is the function that is used to interact
with and draw patients from the `nhds_reduced` dataset. The easiest way
to specify the type of hospital setting to draw patients from is to
update the `draw_patients()` function to incorporate a data argument
that specifies which patients (e.g., regions, hospitals, etc.) to draw
from in the original dataset. You can then filter the dataset before
calling the functions and pass the filtered dataset to the sim
functions. Of course, once you update `draw_patients()` you also have to
update the corresponding functions that also rely on `draw_patients()`
to pass a filtered dataset.

Here I have updated each of the corresponding functions and have also
specified `nhds_reduced` as the default dataset. Thus, if I do not
specify how to filter the datasets, this function will work as before.

``` r
draw_patients <- function(n,patient_population = nhds_reduced){
  sample_n(patient_population,size = n,replace = TRUE)
}

discharge_admit_patients <- function(hospital,date, patient_population = nhds_reduced){
  
  # patients_who are discharged
  discharges <- hospital %>% 
    filter(disdate<=date)
  
  # remove patients whose stay has ended 
  new_hospital <- hospital %>% 
    filter(disdate>date)
  
  # compute the number discharged
  num_discharged <- nrow(hospital)-nrow(new_hospital)
  
  # draw new admissions and add admission & discharge date
  new_patients <- draw_patients(num_discharged, 
                                patient_population = patient_population) %>% 
    mutate(admdate=date,
           disdate=date+care_days)
  
  # rebuild hospital
  new_hospital <- bind_rows(new_hospital,new_patients)
  
  return(list(hospital=new_hospital,
              discharges=discharges))
  
}


sim_hospital <- function(start_date,end_date,hospital_size,
                         patient_population = nhds_reduced){
  
  # Build the inital hospital, including the initial 
  current_hospital <- draw_patients(hospital_size,
                                    patient_population = patient_population) %>% 
    mutate(admdate=start_date,
           disdate=admdate+care_days)
  
  # create any placeholders needed for the loop
  all_discharges <- list()
  daily_stats <- tibble()
  
  # Loop over - to run this you will need to determine and create a variable total_days
  # to tally how many days to simulate over
  total_days <- as.integer(end_date-start_date)
  
  for (i in 1:total_days){
    
    # admit and discharge patients
    update_res <- discharge_admit_patients(hospital = current_hospital,
                                           date = start_date+i,
                                           patient_population = patient_population) 
    
    # update hospital
    current_hospital <- update_res$hospital
    
    # store the discharges
    all_discharges[[i]] <- update_res$discharges
    
    # compute statistics for the current state of the hospital
    add_stats <- current_hospital %>% 
      summarise(mean_age=mean(age,na.rm=TRUE),
                mean_los=mean(care_days,na.rm=TRUE)) %>% 
      mutate(date=start_date+i)
    
    daily_stats <- bind_rows(daily_stats,add_stats)
    
  }
  
  # return the following
  # The dataset of all patients that passed through the simulation
  # Statistics across days in the simulation for the state of the hospital
  list(discharges=all_discharges,
       final_hospital=current_hospital,
       daily_stats=daily_stats)
  
}
```

### Draw patients according to the admission/discharge month

Some types of diseases and admissions are more seasonal than others
(e.g., more/less likely to occur in winter compared to summer). The NHDS
dataset contains a variable for the discharge month. Try drawing
patients for a corresponding admission date based on this information.

POSSIBLE SOLUTION

Again we can update the `draw_patients()` function to incorporate an
argument for the admission month (here `adm_month`). Then before drawing
patients we would filter the dataset to `dc_month == adm_month`. (Note:
the admission and discharge months may differ slightly but I am ignoring
that complexity here). Also, again you will have to update the functions
that rely on `draw_patients()`.

``` r
draw_patients <- function(n,patient_population = nhds_reduced, adm_month = NULL){
  if (is.null(adm_month)){
    sample_n(patient_population,size = n,replace = TRUE)
  } else {
    patient_population %>% 
      filter(dc_month==adm_month) %>% 
      sample_n(size = n, replace = TRUE)
  }
  
}

discharge_admit_patients <- function(hospital,date, patient_population = nhds_reduced){
  
  # patients_who are discharged
  discharges <- hospital %>% 
    filter(disdate<=date)
  
  # remove patients whose stay has ended 
  new_hospital <- hospital %>% 
    filter(disdate>date)
  
  # compute the number discharged
  num_discharged <- nrow(hospital)-nrow(new_hospital)
  
  # draw new admissions and add admission & discharge date
  new_patients <- draw_patients(num_discharged, 
                                patient_population = patient_population,
                                adm_month = lubridate::month(date)) %>% 
    mutate(admdate=date,
           disdate=date+care_days)
  
  # rebuild hospital
  new_hospital <- bind_rows(new_hospital,new_patients)
  
  return(list(hospital=new_hospital,
              discharges=discharges))
  
}


sim_hospital <- function(start_date,end_date,hospital_size,
                         patient_population = nhds_reduced){
  
  # Build the inital hospital, including the initial 
  current_hospital <- draw_patients(hospital_size,
                                    patient_population = patient_population,
                                    adm_month = lubridate::month(start_date)) %>% 
    mutate(admdate=start_date,
           disdate=admdate+care_days)
  
  # create any placeholders needed for the loop
  all_discharges <- list()
  daily_stats <- tibble()
  
  # Loop over - to run this you will need to determine and create a variable total_days
  # to tally how many days to simulate over
  total_days <- as.integer(end_date-start_date)
  
  for (i in 1:total_days){
    
    # admit and discharge patients
    update_res <- discharge_admit_patients(hospital = current_hospital,
                                           date = start_date+i,
                                           patient_population = patient_population) 
    
    # update hospital
    current_hospital <- update_res$hospital
    
    # store the discharges
    all_discharges[[i]] <- update_res$discharges
    
    # compute statistics for the current state of the hospital
    add_stats <- current_hospital %>% 
      summarise(mean_age=mean(age,na.rm=TRUE),
                mean_los=mean(care_days,na.rm=TRUE)) %>% 
      mutate(date=start_date+i)
    
    daily_stats <- bind_rows(daily_stats,add_stats)
    
  }
  
  # return the following
  # The dataset of all patients that passed through the simulation
  # Statistics across days in the simulation for the state of the hospital
  list(discharges=all_discharges,
       final_hospital=current_hospital,
       daily_stats=daily_stats)
  
}
```

### Pick a non-uniform start date

Currently the stimulation populates the hospital with a set of patients
all having the same admission date. Try updating this so that the
admission date is within some small range of the initial start date of
the simulation. For example maybe each patient admitted, their admission
date is randomly drawn between 1 and x, where x is their LOS or
care\_days.

POSSIBLE SOLUTION

Before when we drew the initial set of patients we set the admission
date to be the start date of the simulation. Now we need to pick a day
at or prior to the current date. To do so, we can sample from the range
of possible that a patient may have been admitted. We know each
patient’s total care days. So if we sample from the values 1:care\_days
we can draw an index to subtract from the current date. The easiest way
to do this is to draw uniformly from the values over the interval
`[1, care_days]`, then subtract 1 (so we get starts on the current
date), and then subtract this value from the current date.

Here is a quick example to demonstrate how this should work. Recall from
the lecture notes that if you take the ceiling of a uniform random
number multiplied by some value `b` then you will have uniform discrete
values over the interval \[1,b\].

``` r
start_date <- ymd("2019-01-01")
  
# get a batch of 10 patients
tmp <- draw_patients(10)

# draw from a random uniform over [1, care_days] then subtract 1 so that we get some startes
# on the same date
start_index <- ceiling(tmp$care_days*runif(10)) - 1

# update the index date
tmp %>% 
  mutate(admdate = start_date-start_index)
```

    ## # A tibble: 10 x 17
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    74 fema… white         2 78459  43491 42832 7843  065   Medicare     
    ##  2    87 fema… white         6 6826   8921  6826  4019  902   Medicare     
    ##  3    57 male  white         4 2354   2118  4592  <NA>  357   HMO or PPO   
    ##  4    62 fema… white        21 1744   V580  1744  <NA>  849   other privat…
    ##  5    32 fema… not_…         2 V221   V270  64881 66401 775   HMO or PPO   
    ##  6    72 fema… white         1 <NA>   38600 25000 34690 134   Medicare     
    ##  7    71 fema… white         7 514-   42831 51881 486-  291   Medicare     
    ##  8    49 male  white         1 27401  27401 4019  27800 554   not stated   
    ##  9    66 fema… white         9 V5789  V5789 2851  72402 945   other privat…
    ## 10    71 male  not_…         4 42731  42731 5849  42732 308   Medicare     
    ## # … with 7 more variables: adm_type <fct>, adm_origin <fct>, dc_month <int>,
    ## #   region <fct>, n_beds <ord>, hospital_ownership <fct>, admdate <date>

And here is how you update the simulation to get this to work:

``` r
sim_hospital <- function(start_date,end_date,hospital_size,
                         patient_population = nhds_reduced){
  
  # Build the inital hospital, including the initial 
  current_hospital <- draw_patients(hospital_size,
                                    patient_population = patient_population,
                                    adm_month = lubridate::month(start_date)) %>% 
    mutate(admdate= start_date - (ceiling(tmp$care_days*runif(hospital_size)) - 1),
           disdate=admdate+care_days)
  
  # create any placeholders needed for the loop
  all_discharges <- list()
  daily_stats <- tibble()
  
  # Loop over - to run this you will need to determine and create a variable total_days
  # to tally how many days to simulate over
  total_days <- as.integer(end_date-start_date)
  
  for (i in 1:total_days){
    
    # admit and discharge patients
    update_res <- discharge_admit_patients(hospital = current_hospital,
                                           date = start_date+i,
                                           patient_population = patient_population) 
    
    # update hospital
    current_hospital <- update_res$hospital
    
    # store the discharges
    all_discharges[[i]] <- update_res$discharges
    
    # compute statistics for the current state of the hospital
    add_stats <- current_hospital %>% 
      summarise(mean_age=mean(age,na.rm=TRUE),
                mean_los=mean(care_days,na.rm=TRUE)) %>% 
      mutate(date=start_date+i)
    
    daily_stats <- bind_rows(daily_stats,add_stats)
    
  }
  
  # return the following
  # The dataset of all patients that passed through the simulation
  # Statistics across days in the simulation for the state of the hospital
  list(discharges=all_discharges,
       final_hospital=current_hospital,
       daily_stats=daily_stats)
  
}
```

### Hospital over/under capacity

The way we have setup the simulator, the hospital is always at full
capacity and we immediately draw a new patient for each patient that is
discharged. Consider making number number of new arrivals stochastic in
some way. For example, you might draw new patients using a poisson
distribution where the mean is set to the number of patients discharged.

POSSIBLE SOLUTION

To do this, when we compute the number of patients discharged in the
`discharge_admit_patients()` function we should draw the number of new
patients from some random value that is around this value. One option is
to add or subtract a random value from the number discharged. Another
approach would be to draw from something like a Poisson distribution
with the mean set to the number of discharges. This would have the
effect, on average, of drawing the same number of admissions as the
number discharged. However, sometimes slightly fewer would be admitted,
sometimes slightly more, and occasionally quite a few more would be
admitted (e.g., surge in patient demand).

Here is how to draw 1 random value from the poisson distribution with
mean 10.

``` r
rpois(1,10)
```

    ## [1] 8

And here we incorporate the poisson process into the
`discharge_admit_patient()` function:

``` r
discharge_admit_patients <- function(hospital,date, patient_population = nhds_reduced){
  
  # patients_who are discharged
  discharges <- hospital %>% 
    filter(disdate<=date)
  
  # remove patients whose stay has ended 
  new_hospital <- hospital %>% 
    filter(disdate>date)
  
  # compute the number discharged
  num_discharged <- nrow(hospital)-nrow(new_hospital)
  # update for random draw
  num_to_admit <- rpois(1,num_discharged)
  
  # draw new admissions and add admission & discharge date
  new_patients <- draw_patients(num_to_admit, 
                                patient_population = patient_population,
                                adm_month = lubridate::month(date)) %>% 
    mutate(admdate=date,
           disdate=date+care_days)
  
  # rebuild hospital
  new_hospital <- bind_rows(new_hospital,new_patients)
  
  return(list(hospital=new_hospital,
              discharges=discharges))
  
}
```
