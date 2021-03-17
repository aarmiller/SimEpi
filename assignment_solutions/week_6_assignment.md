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
    ##  1    44 fema… white         4 78609  5569  311-  V5869 387   HMO or PPO   
    ##  2    35 male  not_…         5 30390  30390 29189 <NA>  897   self pay     
    ##  3    52 male  white         1 7842   99565 25000 496-  916   self pay     
    ##  4    45 fema… white         3 1749   1744  1963  6988  580   blue cross b…
    ##  5    75 fema… black        16 V5789  V5789 43820 5856  945   Medicare     
    ##  6    25 fema… not_…         3 <NA>   V270  64822 2859  775   Medicaid     
    ##  7    87 fema… other         4 81200  81203 486-  5119  562   Medicare     
    ##  8    20 fema… white         2 V220   V270  64811 2449  775   HMO or PPO   
    ##  9    62 fema… black         5 49121  49121 4010  4659  191   blue cross b…
    ## 10    76 fema… white         8 8052   5180  V0382 41401 168   Medicare     
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
    ##  1    31 fema… not_…         3 V222   V270  65421 <NA>  766   Medicaid     
    ##  2    46 male  white         2 <NA>   72252 7213  <NA>  460   other govern…
    ##  3    79 male  white        15 41401  41401 5601  6826  234   Medicare     
    ##  4    69 male  not_…         3 5849   5849  5770  5601  682   Medicare     
    ##  5    77 fema… white         1 78609  9221  E8859 78609 605   HMO or PPO   
    ##  6    73 male  not_…        16 2111   41511 5185  2766  981   Medicare     
    ##  7    81 fema… not_…         4 71536  71536 4019  2724  470   Medicare     
    ##  8    26 fema… white         2 V221   V270  66401 66481 775   blue cross b…
    ##  9    76 male  white         9 <NA>   53783 42832 4352  378   Medicare     
    ## 10    82 fema… white         2 <NA>   53011 V146  4019  392   Medicare     
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
    ##  1    71 male  white         2 79439  42731 5853  40390 287   blue cross b…
    ##  2    65 male  white         2 78659  42731 25092 V433  310   Medicare     
    ##  3    27 fema… white         2 65641  V271  65641 64891 775   HMO or PPO   
    ##  4    40 fema… white         2 29570  29570 30183 34590 885   Medicare     
    ##  5    68 fema… white         1 4111   41401 78659 42769 287   Medicare     
    ##  6    89 male  white         5 78605  486-  5849  49121 193   other govern…
    ##  7    37 fema… black         2 2189   2180  2181  2182  743   other privat…
    ##  8    53 male  white         3 71536  71536 412-  4280  470   Medicaid     
    ##  9    33 male  white         1 27800  27801 6826  V854  620   HMO or PPO   
    ## 10    40 male  white         2 4599   44422 25002 4439  238   self pay     
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
    ##  1    71 male  white         2 79439  42731 5853  40390 287   blue cross b…
    ##  2    65 male  white         2 78659  42731 25092 V433  310   Medicare     
    ##  3    27 fema… white         2 65641  V271  65641 64891 775   HMO or PPO   
    ##  4    40 fema… white         2 29570  29570 30183 34590 885   Medicare     
    ##  5    89 male  white         5 78605  486-  5849  49121 193   other govern…
    ##  6    37 fema… black         2 2189   2180  2181  2182  743   other privat…
    ##  7    53 male  white         3 71536  71536 412-  4280  470   Medicaid     
    ##  8    40 male  white         2 4599   44422 25002 4439  238   self pay     
    ##  9    71 male  white         2 71536  71536 2851  2720  470   Medicare     
    ## 10    47 male  black         3 <NA>   042-  6826  1761  977   HMO or PPO   
    ## # … with 290 more rows, and 8 more variables: adm_type <fct>, adm_origin <fct>,
    ## #   dc_month <int>, region <fct>, n_beds <ord>, hospital_ownership <fct>,
    ## #   admdate <date>, disdate <date>
    ## 
    ## $discharges
    ## # A tibble: 67 x 18
    ##      age sex   race  care_days dx_adm dx01  dx02  dx03  DRG   payor_primary
    ##    <int> <fct> <fct>     <int> <icd9> <icd> <icd> <icd> <chr> <fct>        
    ##  1    68 fema… white         1 4111   41401 78659 42769 287   Medicare     
    ##  2    33 male  white         1 27800  27801 6826  V854  620   HMO or PPO   
    ##  3    88 fema… white         1 9729   9729  9720  96569 918   Medicare     
    ##  4    54 fema… not_…         1 49122  49122 4254  2761  191   other privat…
    ##  5    62 fema… black         1 <NA>   25002 78659 2767  639   blue cross b…
    ##  6    52 fema… white         1 <NA>   62133 71536 <NA>  743   other privat…
    ##  7    20 fema… white         1 7840   34692 6253  78340 103   Medicaid     
    ##  8    66 fema… white         1 49120  32723 7873  4928  156   Medicare     
    ##  9    42 male  white         1 <NA>   6826  2869  8911  603   other govern…
    ## 10    27 fema… white         1 29620  29623 V6284 34590 885   blue cross b…
    ## # … with 57 more rows, and 8 more variables: adm_type <fct>, adm_origin <fct>,
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

### Draw patients according to the admission/discharge month

Some types of diseases and admissions are more seasonal than others
(e.g., more/less likely to occur in winter compared to summer). The NHDS
dataset contains a variable for the discharge month. Try drawing
patients for a corresponding admission date based on this information.

### Pick a non-uniform start date

Currently the stimulation populates the hospital with a set of patients
all having the same admission date. Try updating this so that the
admission date is within some small range of the initial start date of
the simulation. For example maybe each patient admitted, their admission
date is randomly drawn between 1 and x, where x is their LOS or
care\_days.

### Hospital over/under capacity

The way we have setup the simulator, the hospital is always at full
capacity and we immediately draw a new patient for each patient that is
discharged. Consider making number number of new arrivals stochastic in
some way. For example, you might draw new patients using a poisson
distribution where the mean is set to the number of patients discharged.
